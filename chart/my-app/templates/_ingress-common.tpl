{{/*
This file defines a reusable template for rendering a Kubernetes Ingress resource
for a given component, if ingress is enabled and the component is not disabled.

Template function:
- my-app.component.ingress: Generates an Ingress with support for custom annotations, labels,
  ingress class, multiple hosts, paths, and TLS configuration.

Supports:
- Multiple host/path definitions
- Dynamic backend name/port resolution using tplvalue
- Optional TLS settings
*/}}

{{- define "my-app.component.ingress" }}
{{- $ := index . 0 }}
{{- with index . 1 }}
{{- if not .disabled }}
{{- if .ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "my-app.component.fullname" (dict "context" $ "name" .name) }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
    {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 4 }}
    {{- with .ingress.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- if .ingress.annotations }}
  annotations:
    {{- range $key, $value := .ingress.annotations }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
  {{- end }}
spec:
  {{- if .ingress.ingressClassName }}
  ingressClassName: {{ .ingress.ingressClassName }}
  {{- end }}
  rules:
  {{- range $host := .ingress.hosts }}
  - host: {{ include "tplvalue" (list $ . $host.host) }}
    http:
      paths:
      {{- range $path := $host.paths }}
      - path: {{ $path.path }}
        pathType: {{ $path.pathType }}
        backend:
          service:
            name: {{ include "tplvalue" (list $ . $path.backendName) }}
            port:
              number: {{ include "tplvalue" (list $ . $path.backendPort) }}
      {{- end }}
  {{- end }}
  {{- if and .ingress.tls .ingress.https }}
  tls:
  {{- range .ingress.tls }}
  - hosts:
    {{- range .hosts }}
    - {{ include "tplvalue" (list $ . .) }}
    {{- end }}
    secretName: {{ include "tplvalue" (list $ . .secretName) }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
