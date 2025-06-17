{{/*
Expand the name of the chart.
*/}}
{{- define "php-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "php-stack.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "php-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "php-stack.labels" -}}
helm.sh/chart: {{ include "php-stack.chart" . }}
{{ include "php-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "php-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "php-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "php-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "php-stack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PHP labels
*/}}
{{- define "php-stack.php.labels" -}}
{{ include "php-stack.labels" . }}
app.kubernetes.io/component: php
{{- end }}

{{/*
PHP selector labels
*/}}
{{- define "php-stack.php.selectorLabels" -}}
{{ include "php-stack.selectorLabels" . }}
app.kubernetes.io/component: php
{{- end }}

{{/*
Varnish labels
*/}}
{{- define "php-stack.varnish.labels" -}}
{{ include "php-stack.labels" . }}
app.kubernetes.io/component: varnish
{{- end }}

{{/*
Varnish selector labels
*/}}
{{- define "php-stack.varnish.selectorLabels" -}}
{{ include "php-stack.selectorLabels" . }}
app.kubernetes.io/component: varnish
{{- end }}
