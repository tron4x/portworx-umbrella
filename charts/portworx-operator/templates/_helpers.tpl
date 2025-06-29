{{/*
Expand the name of the chart.
*/}}
{{- define "portworx-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "portworx-operator.fullname" -}}
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
{{- define "portworx-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "portworx-operator.labels" -}}
helm.sh/chart: {{ include "portworx-operator.chart" . }}
{{ include "portworx-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "portworx-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "portworx-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "portworx-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "portworx-operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the correct API Version based on the version of the cluster
*/}}
{{- define "rbac.apiVersion" -}}
{{$version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+" | trimPrefix "v"}}
{{- if semverCompare ">= 1.8" $version -}}
"rbac.authorization.k8s.io/v1"
{{- else -}}
"rbac.authorization.k8s.io/v1beta1"
{{- end -}}
{{- end -}}

{{/*
Get the deployment namespace
*/}}
{{- define "portworx-operator.namespace" -}}
{{- if .Values.global.namespace }}
{{- .Values.global.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Get the correct image registry
*/}}
{{- define "portworx-operator.imageRegistry" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/portworx/px-operator" .Values.global.imageRegistry }}
{{- else }}
{{- "portworx/px-operator" }}
{{- end }}
{{- end }}
