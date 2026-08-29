{{- define "opencanary.labels" -}}
app.kubernetes.io/name: opencanary
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: opencanary
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "opencanary.selectorLabels" -}}
app.kubernetes.io/name: opencanary
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
