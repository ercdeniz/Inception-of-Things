up:
	vagrant up --no-parallel

down:
	vagrant halt --no-parallel

pri:
	vagrant privates --no-parallel

stop:
	vagrant halt --no-parallel

clean:
	vagrant destroy --force --no-parallel
	rm -rf .vagrant
	rm -rf shared

vm-clean:
	rm -rf ${HOME}/VirtualBox\ VMs/*

status:
	vagrant global-status
