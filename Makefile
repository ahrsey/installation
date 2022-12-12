check:
	shellcheck *.sh

install: install.sh
	bash install.sh

update: update.sh
	bash update.sh

uninstall: uninstall.sh
	bash uninstall.sh

setup:
	docker build --progress=plain --no-cache -t installtest .
	docker run -d -p 2022:22 installtest 
	docker ps -a

# TODO
# This doesn't work atm, not sure how to do this
CONTAINER_ID = $(docker ps -a | grep installtest | awk '{print $1}')
connect: 
	docker exec -it $(CONTAINER_ID) /bin/bash

remove: dockerfile
	echo 'Not working from within Makefile currently, but if you run this command
	itll work.'
	docker rm -f $(docker ps -a | grep installtest | awk "{print $1}")

readme_update:
	echo '\n# List of TODOS \n --- \n' >> README.md
	grep --no-filename -A 3 TODO *.sh >> README.md
