# CI/CD for Kubernetes with GitHub Actions

This repository contains reusable and secure GitHub Actions workflows to automate the CI/CD process for Kubernetes applications running on AWS EKS. The workflows are integrated with ArgoCD, Amazon ECR, and follow best practices including OIDC-based IAM authentication and image signing.

---

## 📁 Repository Structure

<pre>
.
├── .github/
│   └── workflows/            # GitHub Actions workflows
│       ├── build.yml         # Build and push Docker image to Amazon ECR
│       ├── deploy.yml        # Update Helm chart and sync ArgoCD app
│       ├── test.yml          # Run tests (e.g. pytest)
│       └── sign.yml          # Cosign image signing
├── charts/                   # Helm charts
├── src/                      # Source code of the application (e.g. Python app)
└── Dockerfile                # Docker image definition

</pre>

---

## ⚙️ Features

- ✅ **Automated Testing** – Unit/integration tests triggered on PR
- 🐳 **Docker Image Build** – Build & push to Amazon ECR
- 🚀 **Helm-based Deployment** – Helm chart version bump & ArgoCD sync
- 🔐 **Secure IAM via OIDC** – No hardcoded AWS secrets, uses GitHub OIDC provider
- 🔏 **Image Signing with Cosign** – Images are signed and verified with [Sigstore](https://www.sigstore.dev/)
- 🔍 **Policy Enforcement** – Image signatures verified via Kyverno before deployment

---

## 🔄 Workflows Overview

### ✅ Test Workflow (`test.yml`)

Runs automated tests, e.g. `pytest`, on every pull request.

### 🐳 Build & Push Workflow (`build.yml`)

- Builds Docker image  
- Authenticates to ECR using OIDC  
- Pushes the image with `git SHA` or semantic version tag

### 🚀 Deploy Workflow (`deploy.yml`)

- Updates the Helm chart version and image tag  
- Commits the chart change to the Git repo used by ArgoCD  
- Optionally triggers ArgoCD sync via webhook or auto-sync

### 🔏 Sign Workflow (`sign.yml`)

- Uses Cosign to sign the Docker image  
- Publishes signature to the OCI registry alongside the image

## 📌 TODO

- [ ] 
- [ ] 
- [ ] 
- [ ] 
