{{/*
This file contains reusable template functions (helpers) for the Helm chart.
These helpers are used across multiple templates to reduce duplication and
improve readability.

Functions included:
- tplvalue: Safely render string or YAML values that contain Go templates.
- getValueFromKey: Retrieve deeply nested values from `.Values` using a dot-separated key.
- my-app.component.podsecuritycontext: Generates the pod-level securityContext block.
- my-app.component.securitycontext: Generates the container-level securityContext block.
- my-app.component.resources: Renders CPU/memory resource requests and limits.

These helpers promote DRY (Don't Repeat Yourself) principles and allow flexible configuration per component.
*/}}
{{- define "tplvalue" }}
  {{- $ := index . 0 }}
  {{- $val := index . 2 }}
  {{- with index . 1 }}
    {{- if typeIs "string" $val }}
      {{- tpl $val $ }}
    {{- else }}
      {{- tpl ($val | toYaml) $ }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
getValueFromKey — retrieves a value from .Values using a dotted key path
Usage:
{{ include "getValueFromKey" (dict "key" "path.to.key" "context" $) }}
*/}}
{{- define "getValueFromKey" }}
  {{- $splitKey := splitList "." .key }}
  {{- $value := "" }}
  {{- $latestObj := $.context.Values }}
  {{- range $splitKey }}
    {{- if not $latestObj }}
      {{- printf "please ensure the path '%s' exists in values.yaml" $.key | fail }}
    {{- end }}
    {{- $value = ( index $latestObj . ) }}
    {{- $latestObj = $value }}
  {{- end }}
  {{- printf "%v" (default "" $value) }}
{{- end }}

{{/*
my-app.component.podsecuritycontext — defines pod-level security context
*/}}
{{- define "my-app.component.podsecuritycontext" }}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.podSecurityContext | default $.Values.default.podSecurityContext) }}
securityContext:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
my-app.component.securitycontext — defines container-level security context
*/}}
{{- define "my-app.component.securitycontext" }}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.securityContext | default $.Values.default.securityContext) }}
securityContext:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
my-app.component.resources — defines container resources (CPU/memory requests/limits)
*/}}
{{- define "my-app.component.resources" }}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.resources | default $.Values.default.resources) }}
resources:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
