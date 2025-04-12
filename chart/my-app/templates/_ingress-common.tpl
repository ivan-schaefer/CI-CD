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

{{- $ing := .ingress | default $.Values.default.ingress }}
{{- if $ing.enabled }}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "my-app.component.fullname" (dict "context" $ "name" .name) }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
    {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 4 }}
    {{- with $ing.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $ing.annotations }}
  annotations:
    {{- range $key, $value := . }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
  {{- end }}
spec:
  {{- if $ing.ingressClassName }}
  ingressClassName: {{ $ing.ingressClassName }}
  {{- end }}
  rules:
    {{- range $host := $ing.hosts }}
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
  {{- if and $ing.tls $ing.https }}
  tls:
    {{- range $ing.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ include "tplvalue" (list $ . .) }}
        {{- end }}
      secretName: {{ include "tplvalue" (list $ . .secretName) }}
    {{- end }}
  {{- end }}

{{- end }} {{/* if $ing.enabled */}}
{{- end }} {{/* if not .disabled */}}
{{- end }} {{/* with index . 1 */}}
{{- end }} {{/* define */}}
