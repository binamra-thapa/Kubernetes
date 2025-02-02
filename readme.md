# CreateHelmChart
```
helm create `<release-name>` ; ## Example: helm create kubeclt
helm template `<release-name>` `<chart-path>`
helm install `<release-name>` `<chart-path>`
```
# CreateCertificateFile and sign it
### Details in RBAC-notes.txt
./generate-certificate.sh `<username>`; 



# CreatingHelmReleaseforRoleBinding
### This can also be done using ./role-binding.sh <username>
helm install rolebindings rolebindings/ -set namespace="${ns}",username="${username}"
