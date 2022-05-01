# Deploy Bites app procedures

```bash
ansible-galaxy install -r requirements.yml

ansible-playbook build-deploy-fruit-instances.yml -i inventory -e @vault.yml --ask-vault-pass

ansible-playbook install-nginx-proxy.yml -i inventory

ansible-playbook install-new-relic-infra.yml -i inventory -e @vault.yml --ask-vault-pass
```
