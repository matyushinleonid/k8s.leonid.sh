{{- define "proxy.labels" -}}
app.kubernetes.io/name: proxy
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: proxy
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "proxy.selectorLabels" -}}
app.kubernetes.io/name: proxy
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
