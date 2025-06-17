# php-stack

A Helm chart to deploy a scalable PHP 8.4 stack with:
- Bitnami PHP-FPM (with optional PHP extensions)
- MySQL on Longhorn
- Redis
- Varnish frontend
- NFS-backed uploads

---
## Prerequisites
- Kubernetes cluster with Longhorn CSI installed
- NFS storage class (`nfs-client`) for user uploads
- Helm v3.8+

---
## File Structure
```
php-stack/
├── Chart.yaml           # Chart metadata and dependencies
├── values.yaml          # Default configuration values
├── templates/           # Kubernetes manifest templates
│   ├── php-deployment.yaml
│   ├── pvc-uploads.yaml
│   ├── php-service.yaml
│   ├── varnish-deployment.yaml
│   ├── varnish-service.yaml
│   ├── ingress.yaml
│   └── php-init-and-config.yaml
├── NOTES.txt            # Helm install/upgrade notes
└── README.md            # This file
```

---
## Installation

1. **Fetch dependencies**

   ```bash
   cd php-stack
   helm dependency update
   ```

2. **Install into a custom namespace**

   You can target any namespace by passing `--namespace` (and `--create-namespace` if it doesn’t exist):

   ```bash
   helm install mysite ./php-stack \
     --namespace your-namespace \
     --create-namespace \
     --set php.gitRepoUrl=https://github.com/you/site.git \
     --set php.gitRepoTag=v1.0.0 \
     --set php.extraModules={xml,zip} \
     --set mysql.auth.username=$MYSQL_USER \
     --set mysql.auth.password=$MYSQL_PASSWORD \
     --set mysql.auth.rootPassword=$MYSQL_ROOT_PASSWORD \
     --set ingress.enabled=true \
     --set ingress.hosts[0].host=example.com \
     --set ingress.hosts[0].paths[0].path=/ \
     --set ingress.hosts[0].paths[0].pathType=Prefix
   ```

   All resources (PVCs, Deployments, Services, Ingress) will live under `your-namespace`.

---
## Upgrading

```bash
helm upgrade mysite ./php-stack \
  --namespace your-namespace \
  [same `--set` flags as install]
```

---
## Uninstalling

```bash
helm uninstall mysite --namespace your-namespace
```

---
## Chart Configuration
You can modify the following in `values.yaml`:

- **php**: image, git repo URL/tag, extraModules, resources, uploads PVC
- **mysql**: auth credentials, persistence.storageClass (e.g. `longhorn`), resources
- **redis**: password, resources
- **varnish**: image, ports, resources
- **ingress**: enable, hosts, annotations

---
*(Detailed comments are in `values.yaml` and individual templates.)*
