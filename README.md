# 📚 Spring Boot BookApp Monitoring System using Kubernetes, Prometheus & Grafana

![GitHub Repo Banner](https://img.shields.io/badge/Project-DevOps%20Monitoring-blue) ![Spring Boot](https://img.shields.io/badge/SpringBoot-3.x-brightgreen) ![Kubernetes](https://img.shields.io/badge/Kubernetes-Deployed-blueviolet) ![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-orange) ![Grafana](https://img.shields.io/badge/Grafana-Dashboard-yellow)

A production-style **end-to-end DevOps project** that demonstrates how to build, containerize, deploy, and monitor a Spring Boot CRUD application in a Kubernetes cluster.

This project covers:

* 🚀 Application deployment using Kubernetes
* 🐳 Docker image build and push
* 🗄️ MySQL StatefulSet deployment
* 📈 Monitoring with Prometheus
* 📊 Dashboard visualization with Grafana
* 🛠️ Real-world troubleshooting and issue resolution

---

## 📸 Project Screenshots

Add the following screenshots in your GitHub repo inside a `screenshots/` folder and reference them here:

### 📊 Grafana Dashboard


<img width="1523" height="868" alt="Screenshot 2026-04-03 121757" src="https://github.com/user-attachments/assets/ebbbd92b-16f7-4d1b-bb81-c06c5400d247" />


### 📈 Prometheus Targets / Metrics


<img width="1919" height="871" alt="Screenshot 2026-04-03 121812" src="https://github.com/user-attachments/assets/5ce4e79b-37ff-42d3-a5f0-5a01bc61b4cb" />


### 📚 BookApp Application UI / API Output


<img width="1919" height="942" alt="Screenshot 2026-04-03 121834" src="https://github.com/user-attachments/assets/085c7ac7-f51d-449f-ba59-496382599f74" />


---

# Spring Boot BookApp Monitoring System using Kubernetes, Prometheus & Grafana

## Project Overview

This project demonstrates an end-to-end **Spring Boot application deployment and monitoring setup** using:

* **Spring Boot (BookApp CRUD API)**
* **Docker**
* **Kubernetes (kubeadm cluster)**
* **MySQL StatefulSet**
* **Prometheus**
* **Grafana**
* **Node Exporter**

The application is deployed inside a Kubernetes cluster and monitored at:

* **Server level** → CPU, memory, disk, network
* **Pod / container level** → pod health, restarts, availability
* **Application level** → Spring Boot actuator metrics

---

# Architecture

```text
User Request
   ↓
EC2 Public IP : NodePort
   ↓
Kubernetes Service
   ↓
Spring Boot Pods
   ↓
MySQL StatefulSet

Prometheus ← Node Exporter + Spring Boot Actuator
      ↓
   Grafana Dashboards
```

---

# Tech Stack

* Java 17
* Spring Boot
* Spring Data JPA
* MySQL
* Docker
* Kubernetes
* Prometheus
* Grafana
* Linux / EC2

---

# Step 1: Build Spring Boot Application

## Dependencies

* spring-boot-starter-web
* spring-boot-starter-data-jpa
* mysql-connector-j
* spring-boot-starter-actuator
* micrometer-registry-prometheus

## Important configuration

`src/main/resources/application.properties`

```properties
server.port=8085
spring.datasource.url=jdbc:mysql://mysql-service:3306/myapplication?createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=root
spring.jpa.hibernate.ddl-auto=update
management.endpoints.web.exposure.include=*
management.endpoint.prometheus.access=unrestricted
management.prometheus.metrics.export.enabled=true
```

---

# Step 2: Build Docker Image

```bash
mvn clean package

docker build -t zaidmohammad038/springboot-bookapp-monitoring-using-prometheus-grafana:latest .

docker push zaidmohammad038/springboot-bookapp-monitoring-using-prometheus-grafana:latest
```

> Important: Docker image name must be fully lowercase.

---

# Step 3: Deploy MySQL in Kubernetes

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
```

Deploy:

```bash
kubectl apply -f mysql-statefulset.yml
```

Verify:

```bash
kubectl get pods
kubectl get svc
```

---

# Step 4: Deploy Spring Boot Application

## Deployment + NodePort Service

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-bookapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: spring-bookapp
  template:
    metadata:
      labels:
        app: spring-bookapp
    spec:
      containers:
        - name: spring-bookapp
          image: zaidmohammad038/springboot-bookapp-monitoring-using-prometheus-grafana:latest
          ports:
            - containerPort: 8085
---
apiVersion: v1
kind: Service
metadata:
  name: spring-bookapp-service
spec:
  type: NodePort
  selector:
    app: spring-bookapp
  ports:
    - port: 8085
      targetPort: 8085
      nodePort: 30088
```

Deploy:

```bash
kubectl apply -f app-deploy-svc.yml
```

Access:

```text
http://<EC2_PUBLIC_IP>:30088
```

---

# Step 5: Install Node Exporter

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz

tar -xvf node_exporter-1.8.1.linux-amd64.tar.gz

sudo cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
```

Run service on:

```text
9100
```

---

# Step 6: Install Prometheus

```bash
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
```

## prometheus.yml

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['13.235.17.136:9100']

  - job_name: 'springboot-app'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['13.235.17.136:30088']
```

Restart:

```bash
sudo systemctl restart prometheus
sudo systemctl status prometheus
```

Access:

```text
http://<EC2_PUBLIC_IP>:9090
```

---

# Step 7: Install Grafana

```bash
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

Access:

```text
http://<EC2_PUBLIC_IP>:3000
```

Default login:

```text
admin / admin
```

```
sum(rate(http_server_requests_seconds_count{job="spring-boot-app", uri!="/actuator/prometheus"}[1m]))
```

---

# Issues Faced and Resolutions

## 1) Kubernetes resource name invalid

### Error

```text
Invalid value: "spring-bookApp"
```

### Cause

Uppercase letters in deployment/service name.

### Fix

Changed:

```text
spring-bookApp
```

To:

```text
spring-bookapp
```

---

## 2) Invalid Docker image name

### Error

```text
InvalidImageName
repository name must be lowercase
```

### Cause

Image name contained uppercase letters and underscore.

### Wrong

```text
zaidmohammad038/Springboot-bookApp-monitoring-using_prometheus-grafana
```

### Fixed

```text
zaidmohammad038/springboot-bookapp-monitoring-using-prometheus-grafana
```

---

## 3) Application not accessible via NodePort

### Cause

Port mismatch.

Spring Boot was starting on `8080` while service exposed `8085`.

### Resolution

Rebuilt the JAR after updating properties:

```bash
mvn clean package
```

Then rebuilt Docker image and redeployed.

---

## 4) Prometheus service failed

### Error

```text
status=2
Error loading config
```

### Cause

Invalid YAML target format.

### Wrong

```yaml
targets: ['http://13.235.17.136:9100/']
```

### Correct

```yaml
targets: ['13.235.17.136:9100']
```

Prometheus requires `host:port` only.

---

## 5) Spring Boot config not picked up

### Issue

`server.port=8085` was set but logs showed `8080`.

### Cause

Old JAR image was still running.

### Fix

```bash
mvn clean package
docker build ...
docker push ...
kubectl rollout restart deployment spring-bookapp
```

---

# Monitoring Covered

## Server Monitoring

* CPU usage
* RAM usage
* Disk usage
* Network traffic

## Kubernetes Monitoring

* Pod status
* Restarts
* Replica count
* Service availability

## Application Monitoring

* JVM memory
* HTTP requests
* request latency
* actuator metrics

---

# Resume Project Title

**Spring Boot BookApp Deployment and Monitoring using Kubernetes, Prometheus and Grafana**

---

# Learning Outcomes

* Docker image build and push
* Kubernetes deployment troubleshooting
* NodePort networking
* Spring Boot actuator metrics
* Prometheus target configuration
* Grafana dashboards
* Real-world DevOps debugging
