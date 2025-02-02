#! /bin/bash

ns="test-minikube"
user_crt_files="/Users/binamra.thapa/Desktop/Desktop-Bottomline/My/Devops/K8s/user-certificates"
username=$1
userkey="${user_crt_files}/key/${username}.key"
usercrt="${user_crt_files}/crt/${username}.crt"

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Usage: ./generate-certificate.sh <username>"
  echo ""
  echo "This script generates a private key, CSR, and signed certificate for the given user."
  echo ""
  echo "Arguments:"
  echo "  <username>   The username for which the certificate is generated."
  echo ""
  echo "The script will generate the following files in the user-certificates directory:"
  echo "  - user.key   (Private Key)"
  echo "  - user.csr   (Certificate Signing Request)"
  echo "  - user.crt   (Certificate)"
  echo ""
  exit 0
fi

if [ -z "$1" ]; then
  echo "Error: No username provided."
  echo "Use '--help' or '-h' for usage instructions."
  exit 1
fi

kubectl config use-context minikube
helm upgrade rolebindings rolebindings/ --set namespace="${ns}",username="${username}"

echo "Setting certificate and key for user ${username}"
kubectl config set-credentials "${username}" --client-certificate "${usercrt}" --client-key "${userkey}"

echo "Setting context namespace for user ${username}"
kubectl config set-context "${username}-context" --user=${username} --cluster=minikube
kubectl config use-context "${username}-context"

kubectl config get-contexts

echo "Setting the namespace as ${ns}"
kubectl config set-context --current --namespace "${ns}"

