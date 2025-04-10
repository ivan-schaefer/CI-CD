# CI/CD for Kubernetes with GitHub Actions, GitLab Ci/CD and Jenkins
[![My Skills](https://skillicons.dev/icons?i=kubernetes,githubactions,jenkins,gitlab &perline=5)](https://skillicons.dev) ![Helm Logo](https://github.com/cncf/artwork/blob/main/projects/helm/icon/color/helm-icon-color.png?raw=true)

This repository contains reusable and secure GitHub Actions workflows to automate the CI/CD process for Kubernetes applications running on AWS EKS. The workflows are integrated with ArgoCD, Amazon ECR, and follow best practices including OIDC-based IAM authentication and image signing.


---

## 📁 Repository Structure

<pre>
.
├── .github/
│   └── workflows/                   # GitHub Actions workflows
│       ├── build.yml                # Build and push Docker image to Amazon ECR
│       ├── deploy.yml               # Update Helm chart and sync ArgoCD app
│       ├── test.yml                 # Run tests (e.g. pytest)
│       └── sign.yml                 # Cosign image signing
│
├── app/                             # Source code of the application (e.g. Python app)
│   └── main.py
│
├── argocd/                          # ArgoCD configurations (optional, if populated later)
│
├── chart/
│   └── my-app/                      # Helm chart
│       ├── Chart.yaml
│       ├── values.yaml              # main values file
│       ├── templates/
│       ├── .helmignore              # Ignore patterns for Helm
│       │   ├── mainapp/             # Main deployment templates
│       │   │   ├── deployment-mainapp.yaml
│       │   │   ├── hpa-mainapp.yaml
│       │   │   ├── ingress-mainapp.yaml
│       │   │   └── service-mainapp.yaml
│       │   ├── _configmap-common.tpl
│       │   ├── _deployment-common.tpl
│       │   ├── _helpers.tpl
│       │   ├── _hpa-common.tpl
│       │   ├── _ingress-common.tpl
│       │   └── _service-common.tpl
│
├── Dockerfile                       # Docker image definition
├── requirements.txt                 # Dependencies for app (Python)
├── README.md


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

## 📌 TODO: CI/CD

- [ ] Define proper resource **limits and requests** for all workloads
- [ ] Add:
  - [ ] Licenses check
  - [ ] Liveness, Readiness, Startup Probes
  - [ ] `lifecycle` hooks (`preStop`, etc.)
- [ ] Use **AWS Secrets Manager** or other secret stores for env injection
- [ ] Implement **Pod Security Standards** (restricted, baseline)
- [ ] Add support for:
  - [ ] GitLab CI/CD pipelines
  - [ ] Jenkins pipelines
- [ ] Improve testing:
  - [ ] Add Linter (e.g. yamllint, hadolint, helm lint)
  - [ ] Add **SonarQube** for code quality
  - [ ] Add **Trivy** for vulnerability scanning
  - [ ] Add **Cosign** image signing
- [ ] Implement CI best practices:
  - [ ] Docker layer caching
  - [ ] BuildKit / Buildx usage
- [ ] Add support for:
  - [ ] ArgoCD Rollouts with **Canary** strategy
  - [ ] Helm Rollouts with **Canary**/**Blue-Green** deployment
  - [ ] Rollbacks from GitHub Actions, GitLab CI, and Jenkins
- [ ] Integrate **HPA** (HorizontalPodAutoscaler) 
- [ ] Enforce image tag management and **ConfigMap** tracking/versioning
- [ ] Set **terminationGracePeriodSeconds** properly for all Pods
- [ ] Add **PodDisruptionBudget** for high availability
