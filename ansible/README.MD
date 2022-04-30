# Deploy Bites app procedures

```bash
ansible-galaxy install -r requirements.yml

ansible-playbook build-deploy-fruit-instances.yml -i inventory -e @vault.yml --ask-vault-pass
```
