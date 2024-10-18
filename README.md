
# Running NGINX Ingress on Minikube

This guide walks through the steps required to set up an NGINX Ingress controller on Minikube, deploy an application, and expose it via the Ingress using an IP address.

## Prerequisites

- **Minikube** installed ([Installation Guide](https://minikube.sigs.k8s.io/docs/start/)).
- **kubectl** installed ([Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)).

## Steps

### 1. Start Minikube

Start Minikube and specify the driver you want to use (default is typically `docker`).

```bash
minikube start
```

### 2. Enable the Ingress Addon

Enable the NGINX Ingress controller using the built-in addon.

```bash
minikube addons enable ingress
```

### 3. Verify Ingress is Running

Ensure that the Ingress controller pods are running:

```bash
kubectl get pods -n ingress-nginx
```

You should see something like:

```
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-xxxxxxxxxx-yyyyy   1/1     Running   0          1m
```

### 4. Create a Namespace

Create a new namespace for the application:

```bash
kubectl create namespace hello-world
```

### 5. Deploy an Application

Create a simple `Deployment` and `Service` for the application:

```yaml
# hello-world.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello-world
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: hello-world
  name: hello-world
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello World"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world
  namespace: hello-world
spec:
  selector:
    app: hello-world
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5678
```

Apply the `hello-world.yaml` file:

```bash
kubectl apply -f hello-world.yaml
```

### 6. Create an Ingress Resource

Create an Ingress resource to expose the application via Minikube’s IP:

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
  namespace: hello-world
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-world
            port:
              number: 80
```

Apply the `ingress.yaml` file:

```bash
kubectl apply -f ingress.yaml
```

### 7. Access the Application

1. Get the Minikube IP address:

   ```bash
   minikube ip
   ```

   Example output:

   ```
   192.168.49.2
   ```

2. Access the application using `curl`:

   ```bash
   curl http://<minikube-ip>
   ```

   Example:

   ```bash
   curl http://192.168.49.2
   ```

   Expected output:

   ```
   Hello World
   ```

## Cleanup

To remove all the resources created in this guide:

```bash
kubectl delete -f ingress.yaml
kubectl delete -f hello-world.yaml
minikube stop
minikube delete
```
