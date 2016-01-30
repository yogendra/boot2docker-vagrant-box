BOX_NAME := yogendra/boot2docker-vmware
ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v1.9.1/boot2docker.iso
ISO_SHA256SUM := d1ac84f01f9e3bc9eaf68a38afdbe2accd11b1d6c678d107018b545552cba199
PACKER_BUILD := packer build --var 'sha256sum=${ISO_SHA256SUM}'

all: vmware

vmware: boot2docker-vmware.box
	vagrant box add -f --name ${BOX_NAME} boot2docker-vmware.box


boot2docker-vmware.box: boot2docker.iso template.json vagrantfile.tpl \
	files/bootlocal.sh files/bootsync.sh files/docker-enter files/oem-release
	${PACKER_BUILD} -only vmware template.json

boot2docker.iso: get_iso check_iso

get_iso:
	@if [ ! -e boot2docker.iso ] ; then curl -LO ${ISO_URL} ; fi

check_iso:
	@if [ "${ISO_SHA256SUM}" != "$(shasum -a256 boot2docker.iso | awk '{print $1}')" ]; then echo "Checksum mismatch for iso. Try running again after removing boot2docker.iso."; exit ; fi

files/docker-enter:
	curl -L https://raw.githubusercontent.com/YungSang/docker-attach/master/docker-nsenter -o files/docker-enter

test: test/Vagrantfile boot2docker-vmware.box
	@cd test; \
	vagrant destroy -f; \
	vagrant up vmware-test --provider vmware_fusion; \
	echo "-----> /etc/os-release"; \
	vagrant ssh -c "cat /etc/os-release"; \
	echo "-----> /etc/oem-release"; \
	vagrant ssh -c "cat /etc/oem-release"; \
	echo "-----> docker version"; \
	DOCKER_HOST="tcp://localhost:2375"; \
	docker version; \
	echo "-----> docker images -t"; \
	docker images -t; \
	echo "-----> docker ps -a"; \
	docker ps -a; \
	echo '-----> docker-enter `docker ps -l -q` ls -l'; \
	vagrant ssh -c 'docker-enter `docker ps -l -q` ls -l'; \
	echo "-----> NFS Test"; \
	vagrant ssh -c 'cat /vagrant/Makefile'; \
	echo "-----> Docker user persistent home dir"; \
	vagrant ssh -c 'cat /home/docker/.ssh/authorized_keys'; \
	vagrant halt; \
	vagrant up vmware-test --provider vmware_fusion; \
	vagrant ssh -c 'cat /home/docker/.ssh/authorized_keys'; \
	vagrant halt

clean:
	cd test; vagrant destroy -f
	rm -f boot2docker.iso
	rm -f files/docker-enter
	rm -f boot2docker-virtualbox.box
	rm -f boot2docker-parallels.box
	rm -rf output-*/

.PHONY: test clean get_iso check_iso
