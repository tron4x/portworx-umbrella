{{/*
Expand the name of the chart.
*/}}
{{- define "portworx-software.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "portworx-software.fullname" -}}
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
{{- define "portworx-software.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "portworx-software.labels" -}}
helm.sh/chart: {{ include "portworx-software.chart" . }}
{{ include "portworx-software.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "portworx-software.selectorLabels" -}}
app.kubernetes.io/name: {{ include "portworx-software.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get the deployment namespace
*/}}
{{- define "portworx-software.namespace" -}}
{{- if .Values.global.namespace }}
{{- .Values.global.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Get the correct image registry
*/}}
{{- define "portworx-software.imageRegistry" -}}
{{- if .Values.global.imageRegistry }}
{{- .Values.global.imageRegistry }}
{{- end }}
{{- end }}

{{/*
Get the cluster name
*/}}
{{- define "portworx-software.clusterName" -}}
{{- if .Values.global.clusterName }}
{{- .Values.global.clusterName }}
{{- else }}
{{- .Values.clusterName }}
{{- end }}
{{- end }}

{{/*
Check if volumes are present
*/}}
{{- define "portworx-software.volumesPresent" }}
{{- $result := false }}
{{- if (default false .Values.isTargetOSCoreOS) }}
    {{- $result = true }}
{{- end }}
{{- if ne (default "none" .Values.etcd.certPath) "none" }}
    {{- $result = true }}
{{- end }}
{{- if .Values.volumes }}
    {{- $result = true }}
{{- end }}
{{- $result }}
{{- end }}

{{/*
Build miscArgs from deprecated kvdb args and miscArgs
*/}}
{{- define "portworx-software.miscArgs" }}
{{- $result := "" }}
{{- if ne .Values.miscArgs "none" }}
    {{- $result = printf "%s %s" $result .Values.miscArgs }}
{{- end }}
{{- trim $result }}
{{- end }}
