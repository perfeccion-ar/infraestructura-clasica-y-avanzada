#/bin/bash

NAMESPACE="test-environment"

mkdir $NAMESPACE
OUTPUT_FILE="$NAMESPACE/${NAMESPACE}_all_manifests.yaml"

echo
echo "DUMPING $NAMESPACE"
echo
echo "# pods" > "$OUTPUT_FILE"
kubectl get pods -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# deployments" >> "$OUTPUT_FILE"
kubectl get deployments -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# services" >> "$OUTPUT_FILE"
kubectl get services -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# ingress" >> "$OUTPUT_FILE"
kubectl get ingress -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# replicaset" >> "$OUTPUT_FILE"
kubectl get replicaset -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# secrets" >> "$OUTPUT_FILE"
kubectl get secrets -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# configmaps" >> "$OUTPUT_FILE"
kubectl get configmaps -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# daemonsets" >> "$OUTPUT_FILE"
kubectl get daemonsets -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# cronjobs" >> "$OUTPUT_FILE"
kubectl get cronjobs -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"

echo "# jobs" >> "$OUTPUT_FILE"
kubectl get jobs -n "$NAMESPACE" -o yaml >> "$OUTPUT_FILE"
echo --- >> "$OUTPUT_FILE"
