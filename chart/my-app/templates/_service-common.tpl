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

{{- $svc := .service | default $.Values.default.service }}

apiVersion: v1
kind: Service
metadata:
  name: {{ include "my-app.component.fullname" (dict "context" $ "name" .name) }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
    {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 4 }}
    {{- with $svc.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $svc.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ $svc.type }}
  {{- $context := . }}
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
