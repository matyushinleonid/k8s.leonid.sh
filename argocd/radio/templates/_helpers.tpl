{{- define "radio.labels" -}}
app.kubernetes.io/part-of: radio
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "radio.rcloneEnvironment" -}}
- name: RCLONE_CONFIG_RADIO_TYPE
  value: s3
- name: RCLONE_CONFIG_RADIO_PROVIDER
  value: AWS
- name: RCLONE_CONFIG_RADIO_REGION
  value: {{ .Values.objectStorage.region | quote }}
- name: RCLONE_CONFIG_RADIO_ENDPOINT
  value: {{ .Values.objectStorage.endpoint | quote }}
{{- end }}
