#! /bin/bash 


CA_CRT="~/.minikube/ca.crt"
CA_KEY="~/.minikube/ca.key"
username=$1
user_crt_files="/Users/binamra.thapa/Desktop/Desktop-Bottomline/My/Devops/K8s/kubernetes-rbac-helm/user-certificates"
userkey="${user_crt_files}/key/${username}.key"
usercsr="${user_crt_files}/csr/${username}.csr"
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


#generatePrivatekey 
echo "Creating user.key"
openssl genrsa -out ${userkey} 2048

echo "Creating user.csr"
#generateCSR -> CertificatesigningRequest
openssl req -new -key ${userkey} -out ${usercsr} -subj "/CN=${username}" 

echo "Creating user.crt"
#Getthe certificate signed 
openssl x509 -req -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -in ${usercsr} -out ${usercrt}

echo "Setting certificate and key for user ${username}"
kubectl config set-credentials "${username}" --client-certificate "${usercrt}" --client-key "${userkey}"