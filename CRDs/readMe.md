# Custom Operator with Operator SDK: Step-by-Step with Go

This guide documents how to build a Custom operator from scratch using the Operator SDK in Go. It includes command explanations, folder structure, example content, and expected outputs.
## 🧰 Prerequisites

Ensure the following tools are installed:

| Tool          | Check Command                  |
|---------------|---------------------------------|
| Go (1.19+)    | `go version`                   |
| Operator SDK  | `operator-sdk version`         |
| Docker        | `docker version`               |
| kubectl       | `kubectl version --client`     |
| Kind/Minikube | for local Kubernetes testing   |

Install Operator SDK:
```bash
brew install operator-sdk  # Mac
# or Linux
curl -LO https://github.com/operator-framework/operator-sdk/releases/download/v1.33.0/operator-sdk_linux_amd64
chmod +x operator-sdk_linux_amd64
sudo mv operator-sdk_linux_amd64 /usr/local/bin/operator-sdk
```
---
## ✅ Step 1: Initialize the Operator Project

```bash
go mod init github.com/binamra-thapa/custom-operator
operator-sdk init --domain=yourorg.io --repo=github.com/yourorg/Custom-operator
```

### 📂 Project Structure Created:
```
Custom-operator/
├── api/                    # API types go here
├── cmd/                    # Command-line entry point
├── config/                 # Kubernetes manifests (RBAC, CRD, samples)
├── controllers/            # Reconcile logic
├── Dockerfile              # Docker image definition
├── Makefile                # Make commands
├── go.mod / go.sum         # Dependencies
├── main.go                 # Entrypoint
```
---
## ✅ Step 2: Create an API and Controller

```bash
operator-sdk create api --group=pmx --version=v1alpha1 --kind=customcluster
```

### 📂 New Files Created:
```
api/v1alpha1/customcluster_types.go        # CRD Spec + Status definitions
internal/controllers/customcluster_controller.go    # Controller logic
config/crd/bases/                         # CRD YAML output
config/samples/                           # Sample customcluster YAML
```

---

## ✅ Step 3: Define customcluster Spec

Edit `api/v1alpha1/customcluster_types.go`:

```go
package v1alpha1

import (
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// customclusterSpec defines the desired state of customcluster
type customclusterSpec struct {
    Replicas int32 `json:"replicas"`
    Sentinel SentinelSpec `json:"sentinel"`
    Storage  StorageSpec  `json:"storage"`
}

type SentinelSpec struct {
    Enabled  bool  `json:"enabled"`
    Replicas int32 `json:"replicas"`
}

type StorageSpec struct {
    Size      string `json:"size"`
    ClassName string `json:"className"`
}

// customclusterStatus defines the observed state of customcluster
type customclusterStatus struct {
    ReadyReplicas int32 `json:"readyReplicas"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

type customcluster struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   customclusterSpec   `json:"spec,omitempty"`
    Status customclusterStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

type customclusterList struct {
    metav1.TypeMeta `json:",inline"`
    metav1.ListMeta `json:"metadata,omitempty"`
    Items           []customcluster `json:"items"`
}

func init() {
    SchemeBuilder.Register(&customcluster{}, &customclusterList{})
}
```

---

## ✅ Step 4: Run `make generate`

### 🔍 Purpose:
Generates Go code (like deepcopy functions) required by Kubernetes.

```bash
make generate
```

### 📂 Output:
Creates:
```
api/v1alpha1/zz_generated.deepcopy.go
```
Which contains:
```go
func (in *customcluster) DeepCopyObject() runtime.Object
```

---

## ✅ Step 5: Run `make manifests`

### 🔍 Purpose:
Generates Kubernetes CRD YAML and RBAC role YAML from your Go types.

```bash
make manifests
```

### 📂 Output:
Creates:
```
config/crd/bases/Custom.yourorg.io_customclusters.yaml
config/rbac/role.yaml
```

This CRD file defines your custom resource in YAML.

---
## Only Required to run it locally, else convert into a docker file and deploy it
## ✅ Step 6: Install CRD into Cluster

```bash
make install
```
This runs:
```bash
kubectl apply -f config/crd/bases/
```
Registers the CRD with Kubernetes so it knows about `customcluster` kind.

---

## ✅ Step 7: Run the Operator Locally

```bash
make run
```
This starts the controller locally (talking to your cluster via kubeconfig).

---

## ✅ Step 8: Apply a Sample Custom Resource

```yaml
# config/samples/Custom_v1alpha1_customcluster.yaml
apiVersion: Custom.yourorg.io/v1alpha1
kind: customcluster
metadata:
  name: Custom-example
spec:
  replicas: 3
  sentinel:
    enabled: true
    replicas: 3
  storage:
    size: 2Gi
    className: standard
```

```bash
kubectl apply -f config/samples/Custom_v1alpha1_customcluster.yaml
```

Now your operator will react and (eventually) create Custom resources in `Reconcile()`.

---

## ✅ Summary of Commands

| Command | Description |
|---------|-------------|
| `operator-sdk init` | Initialize the Go operator project |
| `operator-sdk create api` | Scaffold the CRD and controller |
| `make generate` | Generate Go deep copy interfaces |
| `make manifests` | Generate CRD + RBAC YAML files |
| `make install` | Apply CRD to the cluster |
| `make run` | Run controller locally to observe/test |

---
# Full Project Folder Structure (after init, create api, make generate, and make manifests)
```
Custom-operator/
├── api/
│   └── v1alpha1/
│       ├── groupversion_info.go            # API metadata
│       ├── customcluster_types.go           # Your CRD Spec and Status (written by you)
│       └── zz_generated.deepcopy.go        # Auto-generated DeepCopy code
│
├── bin/                                    # Contains controller-gen binary (after first run)
│
├── config/
│   ├── crd/
│   │   ├── bases/
│   │   │   └── Custom.yourorg.io_customclusters.yaml  # ← Your CRD YAML (generated by make manifests)
│   │   └── kustomization.yaml
│   │
│   ├── default/
│   │   └── kustomization.yaml
│   │
│   ├── manager/
│   │   ├── manager.yaml                    # Deployment for your operator
│   │   └── kustomization.yaml
│   │
│   ├── rbac/
│   │   ├── role.yaml                       # RBAC rules (generated by make manifests)
│   │   ├── role_binding.yaml
│   │   └── kustomization.yaml
│   │
│   ├── samples/
│   │   ├── Custom_v1alpha1_customcluster.yaml  # Example custom resource
│   │   └── kustomization.yaml
│   │
│   └── scorecard/
│       └── patches/
│           └── basic.config.yaml
│
├── controllers/
│   ├── customcluster_controller.go          # The Reconcile logic (generated stub)
│   └── suite_test.go                       # Test setup
│
├── Dockerfile                              # Image for your operator
├── Makefile                                # All your make commands
├── PROJECT                                 # Project metadata
├── go.mod / go.sum                         # Go modules
├── main.go                                 # Entrypoint to run the operator
```
---

Link: https://chatgpt.com/share/68721c81-6b78-800b-96cd-42988ea0c5c3