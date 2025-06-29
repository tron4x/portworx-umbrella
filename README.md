# Portworx Umbrella Chart

[![CI/CD Pipeline](https://github.com/tron4x/portworx-umbrella/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/tron4x/portworx-umbrella/actions/workflows/ci-cd.yml)
[![Chart Testing](https://github.com/tron4x/portworx-umbrella/actions/workflows/test.yml/badge.svg)](https://github.com/tron4x/portworx-umbrella/actions/workflows/test.yml)
[![Helm](https://img.shields.io/badge/Helm-3.14+-blue?logo=helm)](https://helm.sh/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.29+-blue?logo=kubernetes)](https://kubernetes.io/)

A modular Helm chart for deploying Portworx in Kubernetes environments with air-gap support.

---

## Overview

This umbrella chart divides the Portworx installation into four separate modules:

* **portworx-operator**: The Portworx Operator
* **portworx-software**: The Portworx Storage Cluster Software  
* **portworx-storageclasses**: Standard StorageClasses
* **portworx-monitoring**: Monitoring Components

### Benefits of the Umbrella Approach

> **Modular Architecture**: Components can be activated individually  
> **Air-Gap Optimized**: Centralized registry configuration  
> **Easy Maintenance**: Separate sub-charts  
> **Flexible Deployments**: Mix & match possible  
> **Production Ready**: Based on official Portworx charts

## Prerequisites

* Kubernetes 1.26+
* Helm 3.x
* Air-gap environment with private registry (Artifactory)

---

## Installation

### 1. Download dependencies

```bash
helm dependency update
```

### 2. Install chart

> **Info**: CRDs are automatically installed from the `/crds` directory.

```bash
helm install portworx . \
  --namespace portworx \
  --create-namespace \
  --set global.imageRegistry="your-artifactory.com/portworx" \
  --set global.clusterName="my-cluster"
```

### 3. With registry secret

```bash
helm install portworx . \
  --namespace portworx \
  --create-namespace \
  --set global.imageRegistry="your-artifactory.com/portworx" \
  --set global.registrySecret="my-registry-secret" \
  --set global.clusterName="my-cluster"
```

---

## Configuration

### Global values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Private registry URL | `""` |
| `global.clusterName` | Portworx cluster name | `""` |
| `global.namespace` | Namespace for Portworx | `""` |
| `global.registrySecret` | Registry secret name | `""` |

### Enable/disable modules

| Parameter | Description | Default |
|-----------|-------------|---------|
| `operator.enabled` | Enable Portworx Operator | `true` |
| `software.enabled` | Enable Portworx Software | `true` |
| `storageclasses.enabled` | Enable StorageClasses | `true` |
| `monitoring.enabled` | Enable Monitoring | `false` |

---

## Air-Gap Deployment

For air-gap environments:

1. Load all required images into your private registry
2. Configure `global.imageRegistry`
3. Ensure registry secrets are available

---

## Examples

### Minimal installation (operator and software only)

```bash
helm install portworx . \
  --set operator.enabled=true \
  --set software.enabled=true \
  --set storageclasses.enabled=false \
  --set monitoring.enabled=false
```

### Complete installation with monitoring

```bash
helm install portworx . \
  --set global.imageRegistry="your-artifactory.com/portworx" \
  --set monitoring.enabled=true
```

### Production configuration

```bash
helm install portworx . \
  --namespace portworx \
  --create-namespace \
  --set global.imageRegistry="your-artifactory.com/portworx" \
  --set global.registrySecret="portworx-registry-secret" \
  --set global.clusterName="prod-cluster" \
  --set software.drives="/dev/nvme1n1;/dev/nvme2n1" \
  --set software.provider="aws" \
  --set monitoring.enabled=true
```

---

## Module Details

### Portworx Operator

Deploys the Portworx Operator that manages StorageCluster CRDs.

### Portworx Software

Creates the StorageCluster Custom Resource with all storage configurations.

### StorageClasses

Creates standard StorageClasses for various use cases:

* `portworx-sc`: General StorageClass with 3 replicas
* `portworx-shared-sc`: Shared volume StorageClass
* `portworx-db-sc`: Database optimized StorageClass
* `portworx-db2-sc`: DB2 optimized StorageClass
* `portworx-null-sc`: Single replica StorageClass

### Monitoring

Creates Grafana dashboards and Prometheus ServiceMonitor for existing monitoring setup.

---

## Upgrade

```bash
helm upgrade portworx . \
  --reuse-values \
  --set global.imageRegistry="your-artifactory.com/portworx"
```

> **Important Note**: For major chart versions, CRDs should be manually updated beforehand:

```bash
kubectl apply -f ./crds/
helm upgrade portworx .
```

---

## Uninstallation

```bash
helm uninstall portworx --namespace portworx
```

---

## Troubleshooting

### Image Pull Errors

Ensure that:
1. `global.imageRegistry` is correctly set (without trailing slash)
2. Registry secret exists: `kubectl get secret my-registry-secret`
3. All images are available in the private registry

### StorageCluster Not Created

Check:
1. If the operator is running: `kubectl get pods -n portworx`
2. Operator logs: `kubectl logs -n portworx deployment/portworx-operator`
3. CRD installation: `kubectl get crd storageclusters.core.libopenstorage.org`
4. StorageCluster status: `kubectl describe storagecluster -n portworx`

### Modules Not Installing

Check:
1. Module activation in values: `helm get values portworx`
2. Dependencies: `helm dependency list`
3. Chart status: `helm status portworx`

### Common Issues

**Problem**: Chart installation fails

```bash
# Solution: Update dependencies
helm dependency update
helm install portworx .
```

**Problem**: Pods remain in ImagePullBackOff

```bash
# Solution: Check registry configuration
kubectl describe pod -n portworx
kubectl get secret -n portworx
```

**Problem**: StorageCluster does not become Ready

```bash
# Solution: Check node status and drives
kubectl get storagecluster -n portworx
kubectl describe storagenodes -n portworx
```

---

## CRD Management

### Automatic CRD Installation

> **Helm automatically installs CRDs** from the `/crds` directory during first installation.

### Important Notes on CRDs

1. **First Installation**: CRDs are installed automatically
2. **Upgrades**: For major version jumps, CRDs should be manually updated
3. **Deletion**: CRDs are **NOT** deleted during `helm uninstall` (Kubernetes standard)

### Manually Update CRDs (if needed)

Only required for major chart updates:

```bash
# Before Helm upgrade (optional)
kubectl apply -f ./crds/

# Then Helm upgrade
helm upgrade portworx .
```

### Completely Remove CRDs (only for complete uninstallation)

```bash
# ⚠️ WARNING: Deletes ALL Portworx StorageClusters and data!
kubectl delete crd storageclusters.core.libopenstorage.org
kubectl delete crd storagenodes.core.libopenstorage.org
```

---

## Developer

**Author**: tron4x  
**Project**: Portworx Umbrella Chart for Air-Gapped Environments  
**Version**: 1.1  

---

## Additional Information

* [Portworx Documentation](https://docs.portworx.com/)
* [Kubernetes Storage Concepts](https://kubernetes.io/docs/concepts/storage/)
* [Original Portworx Helm Chart](https://github.com/portworx/helm/tree/master/charts/portworx)
