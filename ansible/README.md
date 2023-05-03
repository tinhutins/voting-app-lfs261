this https://github.com/kodekloudhub/example-voting-app automated with ansible roles and terraform

first update inventory.yml with your nodes, create vault as needed for some tasks

install requirements :
  - pip3 install -r requirements.txt 
  - ansible-galaxy collection install -r requirements-galaxy.yml

run playbook for installing jenkins on node and all required software for it to work with argo: 
  - ansible-playbook -i inventory.yml playbook.yml --tags add_jenkins --ask-vault-pass -kK

run playbook for installing ArgoCD in kubernetes cluster and all required software for it, this is ran after terraform provision GKE cluster:
  -  ansible-playbook -i inventory.gcp.yml playbook.yml --tags add_argo --ask-vault-pass

for argo playbook to work we need to have kubeconfig and credentials.json defines in ansible/roles/gcp_argo/files/