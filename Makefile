# Minikube 
.PHONY: minikube-start
minikube-start:
	@echo "Minikube - Starting ..."
	@minikube start
	@minikube addons enable ingress
	@minikube addons enable metrics-server

.PHONY: minikube-stop
minikube-stop:
	@echo "Minikube - Stopping ..."
	@minikube stop

.PHONY: minikube-delete
minikube-delete:
	@echo " Minikube - Deleting ..."
	@minikube delete

.PHONY: minikube-check
minikube-check: minikube-start
	@echo "Minikube - Checking if is ready..."
	@minikube status | grep -q "host: Running" && minikube status | grep -q "kubelet: Running" && minikube status | grep -q "apiserver: Running" || { \
		echo "Minikube is not ready. Please ensure Minikube is running before executing this task."; \
		exit 1; \
	}

.PHONY: run
run: minikube-check
	@kubectl wait --namespace ingress-nginx \
	  --for=condition=ready pod \
	  --selector=app.kubernetes.io/component=controller \
	  --timeout=90s
	@kubectl apply -f ingress-manifest.yaml

