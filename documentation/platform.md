# Bootstrapping Kubernetes
## platform
```sh
kubectl create namespace certs
kubectl apply -f /mnt/devvol/persistent/certs/cloudflare-api-token.yaml

helm upgrade cert-manager \
    oci://quay.io/jetstack/charts/cert-manager \
    --install \
    --version v1.19.1 \
    --values /workspaces/thoughtlyify.io/platform/certs/cert-manager-1.19.1.yaml

kubectl apply -f /workspaces/thoughtlyify.io/platform/certs/clusterissuer-letsencrypt-staging.yaml

# install trust-manager if using let's encrypt staging
helm upgrade trust-manager \
    oci://quay.io/jetstack/charts/trust-manager \
    --install \
    --version v0.20.2 \
    --values /workspaces/thoughtlyify.io/platform/certs/trust-manager-0.20.2.yaml \
    --wait
```