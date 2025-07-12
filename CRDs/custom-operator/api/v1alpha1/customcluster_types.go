package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// customclusterSpec defines the desired state of customcluster
type customclusterSpec struct {
	Replicas int32        `json:"replicas"`
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
