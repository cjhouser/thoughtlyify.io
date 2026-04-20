## Connect to a private AKS cluster through bastion host
```sh
az aks get-credentials --name platform-a --overwrite-existing

# Set these from terraform outputs
API_SERVER_HOSTNAME=
API_SERVER_IP=
BASTION_IP=

# Resolve the API server address to localhost where the tunnel port is bound so kubectl
echo "127.0.0.1 ${API_SERVER_HOSTNAME}" >> /etc/hosts

# Tell kubectl to reach out to the cluster on the SSH tunnel port
# Careful with this. It will update all clusters in your config that are using privatelink.
sed -i '/privatelink/s/:443/:6443/g' ~/.kube/config

# Create the SSH tunnel
ssh -f -N -o ServerAliveInterval=180 -L 6443:${API_SERVER_IP}:443 ${BASTION_IP}
```
