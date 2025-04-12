{{/*
This file defines a reusable template for rendering a HorizontalPodAutoscaler (HPA)
resource for a given component.

Template function:
- my-app.component.hpa: Generates an HPA if autoscaling is enabled and the component is not disabled.

Supports:
- minReplicas and maxReplicas
- Target CPU and memory utilization
- Optional HPA behavior configuration
*/}}

{{- define "my-app.component.hpa" }}
{{- $ := index . 0 }}
{{- with index . 1 }}
{{- if and (not .disabled) (and .autoscaling .autoscaling.enabled) }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  labels:
    {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 4 }}
  name: {{ include "my-app.component.fullname" (dict "context" $ "name" .name) }}
  namespace: {{ $.Release.Namespace | quote }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "my-app.component.fullname" (dict "context" $ "name" .name) }}
  minReplicas: {{ .autoscaling.minReplicas }}
  maxReplicas: {{ .autoscaling.maxReplicas }}
  metrics:
  {{- with .autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          averageUtilization: {{ . }}
          type: Utilization
  {{- end }}
  {{- with .autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          averageUtilization: {{ . }}
          type: Utilization
  {{- end }}
  {{- with .autoscaling.behavior }}
  behavior:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
