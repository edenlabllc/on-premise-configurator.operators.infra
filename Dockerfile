FROM quay.io/operator-framework/ansible-operator:v1.38.1

USER root
RUN dnf install -y openssh-clients && dnf clean all

USER ${USER_UID}
COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
