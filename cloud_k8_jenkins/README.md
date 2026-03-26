# Cloud & Kubernetes Deployment — Trading App

## Overview
Containerized and deployed a Spring Boot trading application with a PostgreSQL database using Kubernetes—first locally with Minikube and then on AWS EKS. Deployment was automated using Jenkins.

## What Was Done

### Local Deployment (Minikube)
- Wrote Kubernetes manifests for the trading app and PostgreSQL using Kustomize:
  - `kustomization.yaml`
  - `psql-deployment.yaml`
  - `trading-deployment.yaml`
- Configured secrets via Kustomize `secretGenerator` for database credentials and API tokens
- Set resource `requests` and `limits` on all containers to prevent noisy neighbor issues
- Added a `PersistentVolumeClaim` for PostgreSQL so data survives pod restarts
- Configured the trading app `Service` as a `LoadBalancer` with 2 replicas, using Kubernetes DNS for inter-pod communication (`trading-psql-dev:5432`)

### AWS EKS Deployment
- Provisioned an EKS cluster using `eksctl` with a `t3.small` managed node group
- Pushed Docker images to AWS ECR and updated deployment manifests to use ECR image URLs
- Automated build and deployment pipeline using Jenkins

## Stack
- **App**: Spring Boot (Java), PostgreSQL  
- **Containers**: Docker (DockerHub + AWS ECR)  
- **Orchestration**: Kubernetes (Minikube, AWS EKS)  
- **CI/CD**: Jenkins  
- **Infrastructure as Code**: Kustomize, eksctl  
- **Storage**: AWS EBS via EBS CSI driver (`ebs-sc` StorageClass)  
- **Networking**: Kubernetes `LoadBalancer` Service → AWS ELB  
