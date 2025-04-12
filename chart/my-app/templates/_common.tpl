{{/*
This file contains reusable component-level blocks for Helm templates.

These helpers are designed to be included in workload templates (e.g., Deployment, StatefulSet)
to apply consistent configuration such as security contexts, resource limits, init containers

Included template functions:
- my-app.component.podsecuritycontext: Pod-level securityContext
- my-app.component.securitycontext: Container-level securityContext
- my-app.component.resources: Resource requests and limits for the container
- my-app.component.initcontainers: Optional initContainers block per component
- my-app.component.dependence: Optional dependency wait logic for other components

These helpers simplify complex configuration and promote DRY (Don't Repeat Yourself) practices.
*/}}

{{/*
Reusable block: pod-level securityContext
*/}}
{{- define "my-app.component.podsecuritycontext" -}}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.podSecurityContext | default $.Values.default.podSecurityContext) }}
securityContext:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Reusable block: container-level securityContext
*/}}
{{- define "my-app.component.securitycontext" -}}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.securityContext | default $.Values.default.securityContext) }}
securityContext:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Reusable block: container resource requests and limits
*/}}
{{- define "my-app.component.resources" -}}
  {{- $ := index . 0 }}
  {{- $component := index . 1 }}
  {{- with ($component.resources | default $.Values.default.resources) }}
resources:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Reusable block: initContainers
*/}}
{{- define "my-app.component.initcontainers" -}}
  {{- $ := index . 0 }}
  {{- $context := index . 1 }}
  {{- with index . 2 }}
initContainers:
  {{- range $init := . }}
  - name: {{ $init.name }}
    image: {{ $init.image }}
    {{- with $init.command }}
    command: {{ include "tplvalue" (list $ $context .) }}
    {{- end }}
  {{- end }}
  {{- end }}
{{- end }}