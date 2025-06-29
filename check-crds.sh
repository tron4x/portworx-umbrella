#!/bin/bash

# CRD Status Check Script für Portworx
# Prüft ob alle erforderlichen CRDs installiert und verfügbar sind

echo "============================================"
echo "Portworx CRD Status Check"
echo "============================================"

# Erforderliche CRDs
REQUIRED_CRDS=(
    "storageclusters.core.libopenstorage.org"
    "storagenodes.core.libopenstorage.org"
)

# Prüfe ob kubectl verfügbar ist
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl ist nicht installiert"
    exit 1
fi

echo "📋 Überprüfe erforderliche CRDs..."
echo ""

ALL_OK=true

for crd in "${REQUIRED_CRDS[@]}"; do
    echo -n "  $crd: "
    
    if kubectl get crd $crd >/dev/null 2>&1; then
        # CRD existiert, prüfe Status
        STATUS=$(kubectl get crd $crd -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null)
        
        if [ "$STATUS" = "True" ]; then
            echo "✅ OK"
        else
            echo "⚠️  Installiert aber nicht bereit"
            ALL_OK=false
        fi
    else
        echo "❌ Nicht gefunden"
        ALL_OK=false
    fi
done

echo ""

if [ "$ALL_OK" = true ]; then
    echo "✅ Alle CRDs sind verfügbar und bereit"
    echo ""
    echo "CRD Details:"
    for crd in "${REQUIRED_CRDS[@]}"; do
        echo "----------------------------------------"
        echo "CRD: $crd"
        kubectl get crd $crd -o custom-columns="NAME:.metadata.name,CREATED:.metadata.creationTimestamp,VERSION:.spec.versions[*].name" --no-headers
    done
    exit 0
else
    echo "❌ Einige CRDs fehlen oder sind nicht bereit"
    echo ""
    echo "CRDs installieren:"
    echo "  kubectl apply -f ./crds/"
    echo ""
    echo "CRD Status warten:"
    echo "  kubectl wait --for condition=established --timeout=60s crd/storageclusters.core.libopenstorage.org"
    echo "  kubectl wait --for condition=established --timeout=60s crd/storagenodes.core.libopenstorage.org"
    exit 1
fi
