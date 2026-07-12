# :godmode: k8s.leonid.sh :godmode:

Personal Kubernetes environment for `leonid.sh`.

Prerequisites: authenticated `yc`, configured Terraform backend credentials, `terraform`, `ansible-playbook`, `helm`, `kubectl`, and `argocd`.

## Provision cloud resources

```sh
cd cloud_resources/yc
terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"
terraform apply
```

Before the first `terraform init`, configure remote state storage by following the [Yandex Cloud Terraform state storage guide](https://yandex.cloud/en/docs/tutorials/infrastructure-management/terraform-state-storage).

Fetch kubeconfig for the provisioned cluster with `yc`:

```sh
yc managed-kubernetes cluster get-credentials \
  --id "$(terraform output -raw cluster_id)" \
  --external \
  --force
```

## Commit generated values

Read the values created by Terraform:

```sh
terraform output -raw ingress_nginx_public_ip
terraform output -raw cert_manager_lockbox_secret_id
terraform output -raw external_dns_lockbox_secret_id
```

Copy them into:

- `controller.service.loadBalancerIP` in `argocd/platform/ingress-nginx/values.yaml`
- `externalSecret.lockboxSecretId` in `argocd/platform/cert-manager/values.yaml`
- `externalSecret.lockboxSecretId` in `argocd/platform/external-dns/values.yaml`

Commit and push these values before bootstrap because Argo CD reads its applications from `master` on GitHub:

```sh
cd ../..
git add argocd/platform/ingress-nginx/values.yaml \
  argocd/platform/cert-manager/values.yaml \
  argocd/platform/external-dns/values.yaml
git commit -m "Configure platform cloud values"
git push origin master
```

## Bootstrap the cluster

```sh
cd ansible
python3 -m pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/bootstrap.yml
```

Ansible runs `terraform output -json` in `cloud_resources/yc` and reads the required values from the configured remote Terraform state. It uses them to fetch kubeconfig, seed the External Secrets and Git bootstrap credentials, install Argo CD, and sync the platform applications.
