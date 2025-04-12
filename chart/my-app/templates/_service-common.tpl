{{/*
This file defines a reusable template for rendering a Kubernetes Service
resource for a given component, if it's not disabled.

Template function:
- my-app.component.service: Generates a Service with annotations, labels, type, and ports.

Supports:
- Multiple named ports
- Custom service type (ClusterIP, NodePort, LoadBalancer)
- Optional service annotations and labels
*/}}

{{- define "my-app.component.service" }}
{{- $ := index . 0 }}
{{- with index . 1 }}
{{- if not .disabled }}
apiVersion: v1
kind: Service
metadata:
  {{- with .service }}
    {{- with .annotations }}
  annotations:
      {{- range $key, $value := . }}
    {{ $key }}: {{ $value | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
  name: {{ include "my-app.component.fullname" (dict "context" $ "name" .name) }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
    {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 4 }}
    {{- with .service.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- $context := . }}
  type: {{ (.service | default $.Values.default.service).type }}
  {{- with .containerPorts | default $.Values.default.containerPorts }}
  ports:
    {{- range $key, $value := . }}
    - name: {{ lower $key }}
      port: {{ include "tplvalue" (list $ $context $value ) }}
      targetPort: {{ include "tplvalue" (list $ $context $value ) }}
      protocol: TCP
    {{- end }}
  {{- end }}
  selector:
    {{- include "my-app.selectorLabels" (dict "context" $ "name" .name) | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
