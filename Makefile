DISTRIB_NAME=ubuntu
DISTRIB_VARIANT=server
ifndef DISTRIB_VERSION
    DISTRIB_VERSION=17.10
endif
PACKER_TEMPLATE=${DISTRIB_NAME}-${DISTRIB_VARIANT}.json

VAGRANT_PROVIDER=libvirt
VAGRANT_BOX_VARIANT=salt-lts
VAGRANT_BOX_NAME=${USER}/${VAGRANT_BOX_VARIANT}
#VAGRANT_LOG=debug
VAGRANT_BOX=output/${DISTRIB_NAME}-${DISTRIB_VARIANT}-${DISTRIB_VERSION}-amd64-${VAGRANT_PROVIDER}.box

DIST_DIR=dist
SALT_VERSION=2017.7.2

LIBVIRT_VOL=`virsh vol-list default | grep ${USER}-VAGRANTSLASH-${VAGRANT_BOX_VARIANT} | awk '{print $$1}')`

default: build

build: ${VAGRANT_BOX}

${VAGRANT_BOX}: ${PACKER_TEMPLATE}
	packer build -var 'salt_version=${SALT_VERSION}' -var-file='settings-${DISTRIB_NAME}-${DISTRIB_VARIANT}-${DISTRIB_VERSION}.json' ${PACKER_TEMPLATE}

install: build
	vagrant box add ${VAGRANT_BOX} --name ${VAGRANT_BOX_NAME} --force

uninstall: testclean
	# Remove vagrant box
	if [ `vagrant box list | grep ${VAGRANT_BOX_NAME} | wc -l` -ne 0 ]; then \
	    vagrant box remove ${VAGRANT_BOX_NAME}; \
	fi
	# Remove libvirt volume from storage pool
	if [ "${LIBVIRT_VOL}" != "" ]; then \
	    virsh vol-delete --pool default ${LIBVIRT_VOL}; \
	fi

clean:
	if [ -e "${VAGRANT_BOX}" ]; then \
	    rm -f ${VAGRANT_BOX}; \
	fi

test: testclean install
	if [ ! -e "Vagrantfile" ]; then \
	    vagrant init ${VAGRANT_BOX_NAME}; \
	fi
	vagrant up --provider=${VAGRANT_PROVIDER}

testclean:
	if [ -e "Vagrantfile" ]; then \
	    if [ `vagrant status | grep running | wc -l` -ne 0 ]; then \
	        vagrant destroy; \
	    fi; \
	    rm -f Vagrantfile; \
	fi

distclean: clean testclean
	if [ -e "packer_cache" ]; then \
	    rm -rf packer_cache; \
	fi

fullclean: distclean uninstall

.PHONY: build install uninstall clean test testclean fullclean distclean
