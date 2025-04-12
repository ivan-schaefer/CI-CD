{{/*
This file contains reusable template functions (helpers) for the Helm chart.
These helpers are used across multiple templates to reduce duplication and
improve readability.

Functions included:
- tplvalue: Safely render string or YAML values that contain Go templates.
- getValueFromKey: Retrieve deeply nested values from `.Values` using a dot-separated key.
- my-app.name: Base name of the release
- my-app.fullname: Fully qualified name of the release
- my-app.component.fullname: Unique name per component
- my-app.chart: Chart name and version
- my-app.labels: Standard Kubernetes labels for resources
- my-app.selectorLabels: Labels used in selectors
- my-app.component.podsecuritycontext: Pod-level security context
- my-app.component.securitycontext: Container-level security context
- my-app.component.resources: CPU/memory resource configuration

These helpers promote DRY (Don't Repeat Yourself) principles and allow flexible configuration per component.
*/}}

{{/* tplvalue — safely renders templated strings or YAML objects */}}
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

{{/* getValueFromKey — retrieves a value from .Values using a dotted key path */}}
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

{{/* my-app.name — returns the base chart name */}}
{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* my-app.fullname — returns the release's full name */}}
{{- define "my-app.fullname" -}}
{{- if .Values.fullnameOverride }}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- $name := default .Chart.Name .Values.nameOverride }}
  {{- if contains $name .Release.Name }}
    {{- .Release.Name | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}
{{- end }}

{{/* my-app.component.fullname — returns a unique name for the given component */}}
{{- define "my-app.component.fullname" -}}
{{- if .name -}}
{{- printf "%s-%s" (include "my-app.fullname" .context) .name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* my-app.chart — returns chart name and version */}}
{{- define "my-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* my-app.labels — standard labels for resources */}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ include "my-app.chart" .context }}
{{ include "my-app.selectorLabels" (dict "context" .context "component" .component "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: {{ .context.Values.projectName | default "my-app" }}
{{- with (dig "default" "additionalLabels" nil (.context.Values | merge (dict))) }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/* my-app.selectorLabels — labels used in selectors */}}
{{- define "my-app.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ include "my-app.name" .context }}-{{ .name }}
{{- end }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/* my-app.component.podsecuritycontext — pod-level security context */}}
{{- define "my-app.component.podsecuritycontext" }}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.podSecurityContext | default $.Values.default.podSecurityContext) }}
securityContext:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/* my-app.component.securitycontext — container-level security context */}}
{{- define "my-app.component.securitycontext" }}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.securityContext | default $.Values.default.securityContext) }}
securityContext:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/* my-app.component.resources — resource limits and requests */}}
{{- define "my-app.component.resources" }}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.resources | default $.Values.default.resources) }}
resources:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}