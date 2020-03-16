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

docker-all: ui comment post prometheus cloudprober alertmanager telegraf grafana stackdriver trickster autoheal all-push

build-all: ui comment post prometheus cloudprober alertmanager telegraf grafana stackdriver trickster autoheal

push-all: ui-push comment-push post-push prometheus-push cloudprober-push alertmanager-push grafana-push stackdriver-push trickster-push autoheal-push

docker-machine: create_docker-machine docker-env docker-eval

docker-project:
	export GOOGLE_PROJECT=docker-268618

create_docker-machine:
	docker-machine create --driver google --google-project=docker-268618 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west1-b docker-host

delete_docker-machine:
	docker-machine rm docker-host

docker-env:
	docker-machine env docker-host

docker-eval:
	eval '$(docker-machine env docker-host)'

run-app:
	cd docker && docker-compose up -d

down-app:
	cd docker && docker-compose down

run-mon:
	cd docker && docker-compose -f docker-compose-monitoring.yml up -d

down-mon:
	cd docker && docker-compose -f docker-compose-monitoring.yml down

run-infra: run-app run-mon

down-infra:
	cd docker && docker-compose down && docker-compose -f docker-compose-monitoring.yml down

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

alertmanager:
	cd monitoring/alertmanager && docker build -t ${DOCKERHUB}/alertmanager .

telegraf:
	cd monitoring/telegraf && docker build -t ${DOCKERHUB}/telegraf .

grafana:
	cd monitoring/grafana && docker build -t ${DOCKERHUB}/grafana .

stackdriver:
	cd monitoring/stackdriver && docker build -t ${DOCKERHUB}/stackdriver .

trickster:
	cd monitoring/trickster && docker build -t ${DOCKERHUB}/trickster .

autoheal:
	cd monitoring/autoheal && docker build -t ${DOCKERHUB}/autoheal .

ui-push:
	docker push ${DOCKERHUB}/ui:latest

comment-push:
	docker push ${DOCKERHUB}/comment:latest

post-push:
	docker push ${DOCKERHUB}/post:latest

prometheus-push:
	docker push ${DOCKERHUB}/prometheus:latest

cloudprober-push:
	docker push ${DOCKERHUB}/cloudprober:latest

alertmanager-push:
	docker push ${DOCKERHUB}/alertmanager:latest

grafana-push:
	docker push ${DOCKERHUB}/grafana:latest

stackdriver-push:
	docker push ${DOCKERHUB}/stackdriver:latest

trickster-push:
	docker push ${DOCKERHUB}/trickster:latest

autoheal-push:
	docker push ${DOCKERHUB}/autoheal:latest
