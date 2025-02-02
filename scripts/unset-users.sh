#! /bin/bash 

username=$1

## Incase new context were created
# kubectl config use-context minikube
# kubectl config delete-context ${username}-context

kubectl config unset users.${username}

kubectl config set-context --current --user minikube