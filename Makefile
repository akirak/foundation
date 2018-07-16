.PRUNE: update

update:
	cd ansible && \
	ansible-playbook -c local -i localhost, install-as-user.yml
