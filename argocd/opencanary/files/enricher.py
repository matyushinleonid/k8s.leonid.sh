#!/usr/bin/env python3

import hashlib
import json
import logging
import os
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import defaultdict
from datetime import datetime, timezone


LOKI_URL = os.environ.get("LOKI_URL", "http://loki-stack.monitoring.svc:3100").rstrip("/")
POLL_INTERVAL_SECONDS = float(os.environ.get("POLL_INTERVAL_SECONDS", "5"))
LOOKBACK_SECONDS = int(os.environ.get("LOOKBACK_SECONDS", "900"))
OVERLAP_SECONDS = int(os.environ.get("OVERLAP_SECONDS", "10"))
STATE_TTL_SECONDS = int(os.environ.get("STATE_TTL_SECONDS", "3600"))
QUERY_LIMIT = int(os.environ.get("QUERY_LIMIT", "5000"))
MODE = os.environ.get("MODE", "realtime")
BACKFILL_END_DELAY_SECONDS = int(os.environ.get("BACKFILL_END_DELAY_SECONDS", "3600"))
BACKFILL_CHUNK_SECONDS = int(os.environ.get("BACKFILL_CHUNK_SECONDS", "21600"))

ENVOY_QUERY = (
    '{namespace="envoy-gateway-system", container="envoy"} '
    '| json | upstream_cluster=~"tcproute/opencanary/opencanary-.+/rule/-1"'
)
OPENCANARY_QUERY = (
    '{namespace="opencanary", container="opencanary"} '
    '| json | logtype=~"3000|3003|4002|6001|17001"'
)
ENRICHED_QUERY = '{job="opencanary-enriched"}'
ROUTE_RE = re.compile(r"^tcproute/opencanary/opencanary-([^/]+)/rule/-1$")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
LOGGER = logging.getLogger("opencanary-enricher")


def http_json(url, *, payload=None):
    body = None
    headers = {"Accept": "application/json"}
    if payload is not None:
        body = json.dumps(payload, separators=(",", ":")).encode()
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url, data=body, headers=headers)
    with urllib.request.urlopen(request, timeout=30) as response:
        response_body = response.read()
        return json.loads(response_body) if response_body else {}


def query_range(query, start_ns, end_ns):
    entries = []
    cursor_ns = start_ns
    while cursor_ns <= end_ns:
        params = urllib.parse.urlencode(
            {
                "query": query,
                "start": str(cursor_ns),
                "end": str(end_ns),
                "direction": "forward",
                "limit": str(QUERY_LIMIT),
            }
        )
        response = http_json(f"{LOKI_URL}/loki/api/v1/query_range?{params}")
        if response.get("status") != "success":
            raise RuntimeError(f"Loki query failed: {response}")

        batch = []
        for stream in response.get("data", {}).get("result", []):
            for timestamp, line in stream.get("values", []):
                batch.append((int(timestamp), line))
        batch.sort(key=lambda entry: entry[0])
        entries.extend(batch)

        if len(batch) < QUERY_LIMIT:
            break
        next_cursor_ns = batch[-1][0] + 1
        if next_cursor_ns <= cursor_ns:
            raise RuntimeError("Loki query pagination did not advance")
        cursor_ns = next_cursor_ns

    entries.sort(key=lambda entry: entry[0])
    return entries


def event_id(source, timestamp_ns, line):
    value = f"{source}\0{timestamp_ns}\0{line}".encode()
    return hashlib.sha256(value).hexdigest()


def split_address(address):
    if not address:
        return None, None
    if address.startswith("[") and "]:" in address:
        host, port = address[1:].rsplit("]:", 1)
        return host, int(port)
    host, separator, port = address.rpartition(":")
    if not separator:
        return address, None
    try:
        return host, int(port)
    except ValueError:
        return address, None


def connection_id(host, port):
    if host is None or port is None:
        return None
    if ":" in host and not host.startswith("["):
        return f"[{host}]:{port}"
    return f"{host}:{port}"


def parse_envoy(timestamp_ns, line):
    try:
        record = json.loads(line)
    except json.JSONDecodeError:
        return None

    route = ROUTE_RE.match(str(record.get("upstream_cluster", "")))
    connection = record.get("upstream_local_address")
    if route is None or not connection:
        return None

    source_ip, source_port = split_address(record.get("downstream_remote_address"))
    if source_ip is None:
        return None

    service = route.group(1)
    public_ports = {"ssh": 22, "telnet": 23, "http": 8080, "redis": 6379}
    return connection, {
        "service": service,
        "public_port": public_ports.get(service),
        "source_ip": source_ip,
        "source_port": source_port,
        "bytes_received": record.get("bytes_received"),
        "bytes_sent": record.get("bytes_sent"),
        "duration_ms": record.get("duration"),
        "connection_closed_timestamp_ns": timestamp_ns,
    }


def parse_opencanary(timestamp_ns, line):
    try:
        record = json.loads(line)
    except json.JSONDecodeError:
        return None

    try:
        logtype = int(record.get("logtype"))
    except (TypeError, ValueError):
        return None

    event_types = {
        3000: ("http", "HTTP GET request"),
        3003: ("http", "HTTP request"),
        4002: ("ssh", "SSH login attempt"),
        6001: ("telnet", "Telnet login attempt"),
        17001: ("redis", "Redis command"),
    }
    if logtype not in event_types:
        return None

    source_host = record.get("src_host")
    source_port = record.get("src_port")
    connection = connection_id(source_host, source_port)
    if connection is None:
        return None

    service, event_type = event_types[logtype]
    logdata = record.get("logdata") or {}
    event = {
        "event_id": event_id("opencanary", timestamp_ns, line),
        "event_time": datetime.fromtimestamp(
            timestamp_ns / 1_000_000_000, tz=timezone.utc
        ).isoformat(),
        "event_timestamp_ns": timestamp_ns,
        "event_type": event_type,
        "service": service,
        "connection_id": connection,
        "logtype": logtype,
    }

    field_map = {
        "USERNAME": "username",
        "PASSWORD": "password",
        "REMOTEVERSION": "client_version",
        "PATH": "path",
        "USERAGENT": "user_agent",
        "CMD": "command",
        "ARGS": "arguments",
    }
    for source, destination in field_map.items():
        value = logdata.get(source)
        if value not in (None, ""):
            event[destination] = value
    return connection, event


def enriched_event(protocol_event, network_event):
    result = dict(protocol_event)
    result.update(network_event)
    result["correlation_delay_ms"] = max(
        0,
        (network_event["connection_closed_timestamp_ns"] - protocol_event["event_timestamp_ns"])
        // 1_000_000,
    )
    return result


def existing_event_ids(start_ns, end_ns):
    identifiers = {}
    for timestamp_ns, line in query_range(ENRICHED_QUERY, start_ns, end_ns):
        try:
            identifier = json.loads(line).get("event_id")
        except json.JSONDecodeError:
            continue
        if identifier:
            identifiers[identifier] = timestamp_ns
    return identifiers


def push_events(events, pipeline="realtime"):
    if not events:
        return

    streams = defaultdict(list)
    for event in events:
        timestamp_ns = str(event["event_timestamp_ns"])
        line = json.dumps(event, separators=(",", ":"), sort_keys=True)
        streams[event["service"]].append([timestamp_ns, line])

    payload = {
        "streams": [
            {
                "stream": {
                    "app": "opencanary-enricher",
                    "job": "opencanary-enriched",
                    "namespace": "opencanary",
                    "pipeline": pipeline,
                    "service": service,
                },
                "values": values,
            }
            for service, values in streams.items()
        ]
    }
    http_json(f"{LOKI_URL}/loki/api/v1/push", payload=payload)


def run_backfill():
    end_ns = time.time_ns() - BACKFILL_END_DELAY_SECONDS * 1_000_000_000
    start_ns = max(0, end_ns - LOOKBACK_SECONDS * 1_000_000_000)
    chunk_ns = BACKFILL_CHUNK_SECONDS * 1_000_000_000
    state_ttl_ns = STATE_TTL_SECONDS * 1_000_000_000
    network_events = {}
    pending_events = defaultdict(list)
    known_event_ids = set()
    published_count = 0

    LOGGER.info(
        "starting idempotent backfill: lookback=%ds end-delay=%ds chunk=%ds",
        LOOKBACK_SECONDS,
        BACKFILL_END_DELAY_SECONDS,
        BACKFILL_CHUNK_SECONDS,
    )
    chunk_start_ns = start_ns
    while chunk_start_ns < end_ns:
        chunk_end_ns = min(end_ns, chunk_start_ns + chunk_ns)
        known_event_ids.update(existing_event_ids(chunk_start_ns, chunk_end_ns))

        records = [
            (timestamp, "envoy", line)
            for timestamp, line in query_range(ENVOY_QUERY, chunk_start_ns, chunk_end_ns)
        ]
        records.extend(
            (timestamp, "opencanary", line)
            for timestamp, line in query_range(
                OPENCANARY_QUERY, chunk_start_ns, chunk_end_ns
            )
        )
        records.sort(key=lambda record: record[0])
        enriched = []

        for timestamp_ns, source, line in records:
            if source == "envoy":
                parsed = parse_envoy(timestamp_ns, line)
                if parsed is None:
                    continue
                connection, network_event = parsed
                network_events[connection] = network_event
                for protocol_event, _ in pending_events.pop(connection, []):
                    if protocol_event["event_id"] not in known_event_ids:
                        enriched.append(enriched_event(protocol_event, network_event))
                        known_event_ids.add(protocol_event["event_id"])
            else:
                parsed = parse_opencanary(timestamp_ns, line)
                if parsed is None:
                    continue
                connection, protocol_event = parsed
                network_event = network_events.get(connection)
                if (
                    network_event is not None
                    and network_event["connection_closed_timestamp_ns"]
                    >= protocol_event["event_timestamp_ns"]
                ):
                    if protocol_event["event_id"] not in known_event_ids:
                        enriched.append(enriched_event(protocol_event, network_event))
                        known_event_ids.add(protocol_event["event_id"])
                else:
                    pending_events[connection].append((protocol_event, timestamp_ns))

        push_events(enriched, pipeline="backfill")
        published_count += len(enriched)

        cutoff_ns = chunk_end_ns - state_ttl_ns
        for connection, network_event in list(network_events.items()):
            if network_event["connection_closed_timestamp_ns"] < cutoff_ns:
                del network_events[connection]
        for connection, events in list(pending_events.items()):
            retained = [entry for entry in events if entry[1] >= cutoff_ns]
            if retained:
                pending_events[connection] = retained
            else:
                del pending_events[connection]

        LOGGER.info(
            "backfill progress: %.1f%%, published=%d, pending=%d",
            100 * (chunk_end_ns - start_ns) / (end_ns - start_ns),
            published_count,
            sum(len(events) for events in pending_events.values()),
        )
        chunk_start_ns = chunk_end_ns + 1

    LOGGER.info(
        "backfill complete: published=%d, unmatched=%d",
        published_count,
        sum(len(events) for events in pending_events.values()),
    )


def prune_state(network_events, pending_events, seen_events, now_monotonic):
    cutoff = now_monotonic - STATE_TTL_SECONDS
    for connection, (_, observed_at) in list(network_events.items()):
        if observed_at < cutoff:
            del network_events[connection]

    dropped = 0
    for connection, events in list(pending_events.items()):
        retained = [(event, observed_at) for event, observed_at in events if observed_at >= cutoff]
        dropped += len(events) - len(retained)
        if retained:
            pending_events[connection] = retained
        else:
            del pending_events[connection]
    if dropped:
        LOGGER.warning("dropped %d protocol events without an Envoy match", dropped)

    seen_cutoff = now_monotonic - max(STATE_TTL_SECONDS, LOOKBACK_SECONDS * 2)
    for identifier, observed_at in list(seen_events.items()):
        if observed_at < seen_cutoff:
            del seen_events[identifier]


def run():
    network_events = {}
    pending_events = defaultdict(list)
    seen_events = {}
    cursor_ns = time.time_ns() - LOOKBACK_SECONDS * 1_000_000_000
    overlap_ns = OVERLAP_SECONDS * 1_000_000_000
    try:
        published_event_ids = existing_event_ids(cursor_ns, time.time_ns())
    except (OSError, RuntimeError, urllib.error.HTTPError) as error:
        LOGGER.warning("could not preload enriched event IDs: %s", error)
        published_event_ids = {}

    LOGGER.info("starting correlation from a %ds lookback", LOOKBACK_SECONDS)
    while True:
        cycle_started = time.monotonic()
        end_ns = time.time_ns()
        start_ns = max(0, cursor_ns - overlap_ns)
        enriched = []
        scheduled_event_ids = {}

        try:
            records = [
                (timestamp, "envoy", line)
                for timestamp, line in query_range(ENVOY_QUERY, start_ns, end_ns)
            ]
            records.extend(
                (timestamp, "opencanary", line)
                for timestamp, line in query_range(OPENCANARY_QUERY, start_ns, end_ns)
            )
            records.sort(key=lambda record: record[0])

            now_monotonic = time.monotonic()
            for timestamp_ns, source, line in records:
                identifier = event_id(source, timestamp_ns, line)
                if identifier in seen_events:
                    continue
                seen_events[identifier] = now_monotonic

                if source == "envoy":
                    parsed = parse_envoy(timestamp_ns, line)
                    if parsed is None:
                        continue
                    connection, network_event = parsed
                    network_events[connection] = (network_event, now_monotonic)
                    for protocol_event, _ in pending_events.pop(connection, []):
                        identifier = protocol_event["event_id"]
                        if (
                            identifier not in published_event_ids
                            and identifier not in scheduled_event_ids
                        ):
                            enriched.append(enriched_event(protocol_event, network_event))
                            scheduled_event_ids[identifier] = protocol_event[
                                "event_timestamp_ns"
                            ]
                else:
                    parsed = parse_opencanary(timestamp_ns, line)
                    if parsed is None:
                        continue
                    connection, protocol_event = parsed
                    network_entry = network_events.get(connection)
                    if (
                        network_entry is not None
                        and network_entry[0]["connection_closed_timestamp_ns"]
                        >= protocol_event["event_timestamp_ns"]
                    ):
                        identifier = protocol_event["event_id"]
                        if (
                            identifier not in published_event_ids
                            and identifier not in scheduled_event_ids
                        ):
                            enriched.append(
                                enriched_event(protocol_event, network_entry[0])
                            )
                            scheduled_event_ids[identifier] = protocol_event[
                                "event_timestamp_ns"
                            ]
                    else:
                        pending_events[connection].append((protocol_event, now_monotonic))

            push_events(enriched)
            published_event_ids.update(scheduled_event_ids)
            cursor_ns = end_ns
            prune_state(network_events, pending_events, seen_events, now_monotonic)
            published_cutoff_ns = cursor_ns - STATE_TTL_SECONDS * 1_000_000_000
            for identifier, timestamp_ns in list(published_event_ids.items()):
                if timestamp_ns < published_cutoff_ns:
                    del published_event_ids[identifier]
            if enriched:
                LOGGER.info("published %d enriched events", len(enriched))
        except (OSError, RuntimeError, urllib.error.HTTPError) as error:
            LOGGER.error("enrichment cycle failed: %s", error)
            network_events.clear()
            pending_events.clear()
            seen_events.clear()
            cursor_ns = time.time_ns() - LOOKBACK_SECONDS * 1_000_000_000

        elapsed = time.monotonic() - cycle_started
        time.sleep(max(0.1, POLL_INTERVAL_SECONDS - elapsed))


if __name__ == "__main__":
    if MODE == "backfill":
        run_backfill()
    else:
        run()
