# PHP Stack Helm Charts

This repository contains Helm charts for deploying scalable PHP applications on Kubernetes.

## Charts

### [php-stack](./helm/full-php-stack/)

A complete PHP 8.4 stack with:
- **PHP-FPM** with configurable extensions and git repository deployment
- **MySQL** database with Longhorn persistent storage
- **Redis** cache
- **Varnish** frontend cache with custom VCL configuration
- **NFS-backed storage** for file uploads
- **Ingress** support for external access

## Quick Start

1. **Clone this repository**
   ```bash
   git clone <repository-url>
   cd rancher
   ```

2. **Install the PHP stack**
   ```bash
   cd helm/full-php-stack
   helm dependency update
   helm install mysite . \
     --namespace myapp \
     --create-namespace \
     --set php.gitRepoUrl=https://github.com/your-org/your-app.git \
     --set php.gitRepoTag=main \
     --set mysql.auth.rootPassword=your-secure-password \
     --set mysql.auth.password=your-app-password
   ```

3. **Access your application**
   ```bash
   kubectl port-forward -n myapp svc/mysite-varnish 8080:80
   ```
   Then visit http://localhost:8080

## Prerequisites

- Kubernetes cluster
- Helm 3.8+
- Longhorn CSI driver (for MySQL storage)
- NFS storage class (for file uploads)

## Documentation

See the individual chart README files for detailed configuration options and deployment instructions.

## Contributing

1. Make your changes
2. Test the charts in a development environment
3. Update documentation as needed
4. Submit a pull request
