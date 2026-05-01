# Bootstrapping Kubernetes
## podman kind config yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: platform
runtimeConfig:
  "api/alpha": "false"
  "apps/v1beta2": "false"
networking:
  podSubnet: "172.16.0.0/18"
  serviceSubnet: "172.24.0.0/18"
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 80
  - containerPort: 30443
    hostPort: 443
```

## platform
```sh
# create cert management
kubectl create namespace certs
kubectl apply -f /mnt/devvol/persistent/certs/cloudflare-api-token.yaml

helm upgrade cert-manager \
    oci://quay.io/jetstack/charts/cert-manager \
    --install \
    --version v1.19.1 \
    --values /workspaces/thoughtlyify.io/platform/certs/cert-manager-1.19.1.yaml \
    --namespace certs

kubectl apply -f /workspaces/thoughtlyify.io/platform/certs/clusterissuer-letsencrypt-staging.yaml

# install trust-manager if using let's encrypt staging
helm upgrade trust-manager \
    oci://quay.io/jetstack/charts/trust-manager \
    --install \
    --version v0.20.2 \
    --values /workspaces/thoughtlyify.io/platform/certs/trust-manager-0.20.2.yaml \
    --wait \
    --namespace certs

# create gateway
kubectl create namespace gateway
kubectl apply -f /workspaces/thoughtlyify.io/platform/gateway/service.yaml
helm upgrade gateway \
    oci://docker.io/envoyproxy/gateway-helm \
    --install \
    --version 1.7.2 \
    --namespace gateway \
    --values /workspaces/thoughtlyify.io/platform/gateway/gateway-1.7.2.yaml
```
