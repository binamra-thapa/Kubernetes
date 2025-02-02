#! /bin/bash 

username=$1

kubectl config use-context minikube
kubectl config delete-context ${username}-context
kubectl config unset users.${username}