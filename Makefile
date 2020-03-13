.DEFAULT_GOAL := help

DOCKERHUB = sfrost1988

help:
	$(info Building docker images and pushing them to dockerhub. Example: make 'docker-all')
	$(info For running only one of command you cat type: make 'ui' && make 'ui-push')
	$(info Available command for make: )
	$(info - docker-all)
	$(info - build-all)
	$(info - push-all)
	$(info - run-infra)
	$(info - down-infra)
	$(info - docker-ip)
	$(info - docker-machine)
	$(info - ui)
	$(info - comment)
	$(info - post)
	$(info - prometheus)
	$(info - cloudprober)
	$(info - ui-push)
	$(info - comment-push)
	$(info - post-push)
	$(info - prometheus-push)
	$(info - cloudprober-push)

docker-all: ui comment post prometheus cloudprober all-push

build-all: ui comment post prometheus cloudprober

push-all: ui-push comment-push post-push prometheus-push cloudprober-push

docker-machine: docker-project create_docker-machine docker-env docker-eval

docker-project:
	export GOOGLE_PROJECT=docker-268618

create_docker-machine:
	docker-machine create --driver google --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west1-b docker-host

docker-env:
	docker-machine env docker-host

docker-eval:
	eval $(docker-machine env docker-host)

run-infra:
	cd docker && docker-compose up -d

down-infra:
	cd docker && docker-compose down

docker-ip:
	docker-machine ip docker-host

ui:
	cd src/ui && docker build -t ${DOCKERHUB}/ui .

comment:
	cd src/comment && docker build -t ${DOCKERHUB}/comment .

post:
	cd src/post-py && docker build -t ${DOCKERHUB}/post .

prometheus:
	cd monitoring/prometheus && docker build -t ${DOCKERHUB}/prometheus .

cloudprober:
	cd monitoring/cloudprober && docker build -t ${DOCKERHUB}/cloudprober .

ui-push:
	docker push ${DOCKERHUB}/ui:latest

comment-push:
	docker push ${DOCKERHUB}/comment:latest

post-push:
	docker push ${DOCKERHUB}/post:latest

prometheus-push:
	docker push ${DOCKERHUB}/ui:latest

cloudprober-push:
	docker push ${DOCKERHUB}/cloudprober:latest
