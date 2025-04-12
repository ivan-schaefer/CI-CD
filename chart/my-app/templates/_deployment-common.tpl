{{/*
This file defines a reusable template for rendering Kubernetes Deployment resources
based on component configuration.

Template function:
- my-app.component.deployment: Generates a Deployment for a component if it's not disabled.

It supports:
- Conditional replicas (manual or via HPA)
- Pod and container annotations/labels
- Image config, commands, arguments, env vars
- Probes, resources, lifecycle hooks
- Volumes: emptyDir, configMap, secret
- Optional initContainers and inter-component readiness dependencies
*/}}

{{- define "my-app.component.deployment" }}
{{- $ := index . 0 }}
{{- with index . 1 }}
{{- if not .disabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  {{- with .deploymentAnnotations | default $.Values.default.deploymentAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  name: {{ include "my-app.component.fullname" (dict "context" $ "name" .name) }}
  namespace: {{ $.Release.Namespace | quote }}
  labels:
    {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 4 }}
spec:
  {{- $context := . -}}
  {{- $containerPorts := (.containerPorts | default $.Values.default.containerPorts) }}
  {{- if not ( .autoscaling | default $.Values.default.autoscaling ).enabled }}
  replicas: {{ .replicaCount | default $.Values.default.replicaCount }}
  revisionHistoryLimit: {{ .rsHistoryLimit | default $.Values.default.rsHistoryLimit }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" (dict "context" $ "name" .name) | nindent 6 }}
  {{- with .strategy | default $.Values.default.strategy }}
  strategy:
    {{- include "tplvalue" (list $ $context . ) | nindent 4 }}
  {{- end }}
  template:
    metadata:
      labels:
        {{- include "my-app.labels" (dict "context" $ "component" .name "name" .name) | nindent 8 }}
        {{- with .podLabels | default $.Values.default.podLabels }}
          {{- include "tplvalue" (list $ $context . ) | nindent 8 }}
        {{- end }}
      annotations:
        {{- with .podAnnotations | default $.Values.default.podAnnotations }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with $.Values.saName }}
      serviceAccountName: {{ . }}
      {{- end }}
      {{- with .imagePullSecrets | default $.Values.default.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- include "my-app.component.podsecuritycontext" (list $ .) | nindent 6 }}

      {{- if or .initContainers .dependsOn }}
      initContainers:
        {{- with .initContainers }}
          {{- include "tplvalue" (list $ $context .) | nindent 6 }}
        {{- end }}
        {{- with .dependsOn }}
          {{- include "my-app.component.dependence" (list $ .) | nindent 6 }}
        {{- end }}
      {{- end }}

      containers:
        - name: {{ .name }}
          image: "{{ .image.repository }}:{{ .image.tag | default $.Chart.AppVersion }}"
          imagePullPolicy: {{ .image.pullPolicy | default $.Values.default.imagePullPolicy }}
          {{- with .command | default $.Values.default.command }}
          command: {{ include "tplvalue" (list $ $context . ) | nindent 10 }}
          {{- end }}
          {{- with .args | default $.Values.default.args }}
          args: {{ include "tplvalue" (list $ $context . ) | nindent 10 }}
          {{- end }}

          env:
            {{- if .envvars }}
            {{- range $key, $value := .envvars }}
            - name: {{ $key }}
              value: {{ include "tplvalue" (list $ . $value ) | squote }}
            {{- end }}
            {{- end }}
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

          {{- with .containerPorts | default $.Values.default.containerPorts }}
          ports:
            {{- range $key, $value := . }}
            - containerPort: {{ include "tplvalue" (list $ $context $value ) }}
              name: {{ lower $key }}
            {{- end }}
          {{- end }}

          {{- include "my-app.component.securitycontext" (list $ . ) | nindent 8 }}
          {{- include "my-app.component.resources" (list $ . ) | nindent 8 }}

          {{- with .livenessProbe | default $.Values.default.livenessProbe }}
          livenessProbe: {{ include "tplvalue" (list $ $context . ) | nindent 10 }}
          {{- end }}
          {{- with .readinessProbe | default $.Values.default.readinessProbe }}
          readinessProbe: {{ include "tplvalue" (list $ $context . ) | nindent 10 }}
          {{- end }}
          {{- with .startupProbe | default $.Values.default.startupProbe }}
          startupProbe: {{ include "tplvalue" (list $ $context . ) | nindent 10 }}
          {{- end }}
          {{- with .lifecycle | default $.Values.default.lifecycle }}
          lifecycle: {{ include "tplvalue" (list $ $context . ) | nindent 10 }}
          {{- end }}

          {{- if .volumeMounts }}
          volumeMounts:
            {{- range $key, $value := .volumeMounts }}
            - name: {{ lower $key }}
              {{- with $value.mountPath }}mountPath: {{ . }}{{- end }}
              {{- with $value.subPath }}subPath: {{ . }}{{- end }}
              {{- with $value.readOnly }}readOnly: {{ . }}{{- end }}
            {{- end }}
          {{- end }}

      {{- if .volumeMounts }}
      volumes:
        {{- $fullname := include "my-app.component.fullname" (dict "context" $ "name" .name) }}
        {{- range $key, $value := .volumeMounts }}
        {{- if eq $value.type "emptyDir" }}
        - name: {{ lower $key }}
          emptyDir: {}
        {{- else if eq $value.type "configMap" }}
        - name: {{ $key }}
          configMap:
            name: {{ $fullname }}
            {{- with $value.defaultMode }}defaultMode: {{ . }}{{- end }}
            {{- with $value.optional }}optional: {{ . }}{{- end }}
        {{- else if eq $value.type "secret" }}
        - name: {{ $key }}
          secret:
            {{- with $value.defaultMode }}defaultMode: {{ . }}{{- end }}
            {{- with $value.secretName }}secretName: {{ . }}{{- end }}
        {{- end }}
        {{- end }}
      {{- end }}

      {{- with .terminationGracePeriodSeconds | default $.Values.default.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ . }}
      {{- end }}

      {{- with .nodeSelector | default $.Values.default.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}

      {{- with .affinity | default $.Values.default.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}

      {{- with .tolerations | default $.Values.default.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
{{- end }}
{{- end }}
