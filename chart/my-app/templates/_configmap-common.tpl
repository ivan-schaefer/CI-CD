{{/*
This file defines a reusable template for creating ConfigMaps
based on the component definition and its volumeMounts.

Template function:
- my-app.component.configmap: Generates a ConfigMap only if the component
  defines volumeMounts of type "configMap".

This allows dynamic and reusable generation of ConfigMaps
based on volume mount configuration.
*/}}

{{- define "my-app.component.configmap" }}
{{- $ := index . 0 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  {{- if .volumeMounts }}
    {{- $fullname := include "my-app.component.fullname" (dict "context" $ "name" .name) }}
    {{- range $key, $value := .volumeMounts }}
    {{- if eq $value.type "configMap" }}
  name: {{ $fullname }}
    {{- end }}
    {{- end }}
  {{- end }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
    {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 4 }}
  {{- with (.configAnnotations | default dict) }}
  annotations:
    {{- range $key, $value := . }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
  {{- end }}
data:
{{- end }}
{{- end }}
