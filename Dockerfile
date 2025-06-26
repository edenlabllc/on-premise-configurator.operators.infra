FROM quay.io/operator-framework/ansible-operator:v1.38.1

USER root
RUN dnf install -y openssh-clients && dnf clean all \
 && mkdir -p /opt/airgap-k3s \
 && chown -R ${USER_UID} /opt/airgap-k3s \
 && rm -f /usr/bin/python3 \
 && ln -s /usr/bin/python3.12 /usr/bin/python3

USER ${USER_UID}
COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible /opt/airgap-k3s

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
