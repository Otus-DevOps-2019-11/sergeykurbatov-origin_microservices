.DEFAULT_GOAL := help

DOCKERHUB = sfrost1988

help:
#	$(info Building docker images and pushing them to dockerhub. Example: make 'docker-all')
#	$(info For running only one of command you cat type: make 'ui' && make 'ui-push')
	$(info Available command for make: )
	$(info - create_kub-net)
	$(info - create_kub-firewall-rule)
	$(info - create_kub-ip)
	$(info - create_kub-controllers)
	$(info - create_kub-workers)
	$(info - generate_kub-ca-certs)
	$(info - generate_kub-admin-certs)
	$(info - generate_kub-client-certs)
	$(info - delete_kub-controllers)
	$(info - delete_kub-workers)
	$(info - show_kub-ip)
	$(info - show_kub-instances)
	$(info - connect_kub-cont0)
	$(info - connect_kub-cont1)
	$(info - connect_kub-cont2)
	$(info - connect_kub-work0)
	$(info - connect_kub-work1)
	$(info - connect_kub-work2)

phase03: create_kub-net create_kub-firewall-rule create_kub-ip create_kub-controllers create_kub-workers
phase04: generate_kub-certs copy_kub-all-certs
phase05: env_kub-ip generate_kub-all-configs copy_kub-all-configs
phase06: generate_kub-enc-key create_kub-enc-configs copy_kub-enc-configs
#phase07: env_kub-int-gcp-ip env_kub-hostname
phase08: create_kub-loadbalancer verification_kub-loadbalancer verification_kub-loadbalancer2

create_kub-net:
	gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom && \
	gcloud compute networks subnets create kubernetes \
  		--network kubernetes-the-hard-way \
  		--range 10.240.0.0/24

create_kub-firewall-rule:
	gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
  		--allow tcp,udp,icmp \
  		--network kubernetes-the-hard-way \
  		--source-ranges 10.240.0.0/24,10.200.0.0/16 && \
	gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
  		--allow tcp:22,tcp:6443,icmp \
  		--network kubernetes-the-hard-way \
  		--source-ranges 0.0.0.0/0

create_kub-ip:
	gcloud compute addresses create kubernetes-the-hard-way \
  		--region europe-west1

create_kub-controllers:
	for inst in 0 1 2; do \
		gcloud compute instances create controller-$${inst} \
			--async \
			--boot-disk-size 200GB \
			--can-ip-forward \
			--image-family ubuntu-1804-lts \
			--image-project ubuntu-os-cloud \
			--machine-type n1-standard-1 \
			--private-network-ip 10.240.0.1$${inst} \
			--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
			--subnet kubernetes \
			--tags kubernetes-the-hard-way,controller ; \
	done

create_kub-workers:
	for inst in 0 1 2; do \
		gcloud compute instances create worker-$${inst} \
			--async \
			--boot-disk-size 200GB \
			--can-ip-forward \
			--image-family ubuntu-1804-lts \
			--image-project ubuntu-os-cloud \
			--machine-type n1-standard-1 \
			--metadata pod-cidr=10.200.$${inst}.0/24 \
			--private-network-ip 10.240.0.2$${inst} \
			--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
			--subnet kubernetes \
			--tags kubernetes-the-hard-way,worker ; \
	done

create_kub-loadbalancer:
	KUBERNETES_PUBLIC_ADDRESS=$$(gcloud compute addresses describe kubernetes-the-hard-way \
		--region $$(gcloud config get-value compute/region) \
		--format 'value(address)') ; \
	gcloud compute http-health-checks create kubernetes \
		--description "Kubernetes Health Check" \
		--host "kubernetes.default.svc.cluster.local" \
		--request-path "/healthz" ; \
	gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
		--network kubernetes-the-hard-way \
		--source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
		--allow tcp ; \
	gcloud compute target-pools create kubernetes-target-pool \
		--http-health-check kubernetes ; \
	gcloud compute target-pools add-instances kubernetes-target-pool \
		--instances controller-0,controller-1,controller-2 ; \
	gcloud compute forwarding-rules create kubernetes-forwarding-rule \
		--address $${KUBERNETES_PUBLIC_ADDRESS} \
		--ports 6443 \
		--region $$(gcloud config get-value compute/region) \
		--target-pool kubernetes-target-pool

verification_kub-loadbalancer:
	KUBERNETES_PUBLIC_ADDRESS=$$(gcloud compute addresses describe kubernetes-the-hard-way \
		--region $$(gcloud config get-value compute/region) \
		--format 'value(address)')

verification_kub-loadbalancer2:
	curl --cacert certs/ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version

generate_kub-certs: generate_kub-ca-certs generate_kub-admin-certs generate_kub-client-certs generate_kub-controllers-certs generate_kub-proxy-certs generate_kub-sched-certs generate_kub-api-certs generate_kub-service-acc-certs

generate_kub-ca-certs:
	sh generate-CA-certs.sh

generate_kub-admin-certs:
	sh generate-admin-certs.sh

generate_kub-client-certs:
	sh generate-client-certs.sh

generate_kub-controllers-certs:
	sh generate-controller-certs.sh

generate_kub-proxy-certs:
	sh generate-proxy-certs.sh

generate_kub-sched-certs:
	sh generate-scheduler-certs.sh

generate_kub-api-certs:
	sh generate-api-certs.sh

generate_kub-service-acc-certs:
	sh generate-service-acc-certs.sh

generate_kub-all-configs: generate_kub-configs generate_kub-proxy-configs generate_kub-controllers-configs generate_kub-sched-configs generate_kub-admin-configs

generate_kub-configs:
	for instance in worker-0 worker-1 worker-2; do \
		kubectl config set-cluster kubernetes-the-hard-way \
			--certificate-authority=certs/ca.pem \
			--embed-certs=true \
			--server=https://$${KUBERNETES_PUBLIC_ADDRESS}:6443 \
			--kubeconfig=configs/kub/$${instance}.kubeconfig ; \
		kubectl config set-credentials system:node:$${instance} \
			--client-certificate=certs/$${instance}.pem \
			--client-key=certs/$${instance}-key.pem \
			--embed-certs=true \
			--kubeconfig=configs/kub/$${instance}.kubeconfig ; \
		kubectl config set-context default \
			--cluster=kubernetes-the-hard-way \
			--user=system:node:$${instance} \
			--kubeconfig=configs/kub/$${instance}.kubeconfig ; \
  		kubectl config use-context default --kubeconfig=configs/kub/$${instance}.kubeconfig ; \
	done

generate_kub-proxy-configs:
	kubectl config set-cluster kubernetes-the-hard-way \
		--certificate-authority=certs/ca.pem \
		--embed-certs=true \
		--server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
		--kubeconfig=configs/kub/kube-proxy.kubeconfig ; \
	kubectl config set-credentials system:kube-proxy \
		--client-certificate=certs/kube-proxy.pem \
		--client-key=certs/kube-proxy-key.pem \
		--embed-certs=true \
		--kubeconfig=configs/kub/kube-proxy.kubeconfig ; \
	kubectl config set-context default \
		--cluster=kubernetes-the-hard-way \
		--user=system:kube-proxy \
		--kubeconfig=configs/kub/kube-proxy.kubeconfig ; \
  	kubectl config use-context default --kubeconfig=configs/kub/kube-proxy.kubeconfig

generate_kub-controllers-configs:
	kubectl config set-cluster kubernetes-the-hard-way \
		--certificate-authority=certs/ca.pem \
		--embed-certs=true \
		--server=https://127.0.0.1:6443 \
		--kubeconfig=configs/kub/kube-controller-manager.kubeconfig ; \
	kubectl config set-credentials system:kube-controller-manager \
		--client-certificate=certs/kube-controller-manager.pem \
		--client-key=certs/kube-controller-manager-key.pem \
		--embed-certs=true \
		--kubeconfig=configs/kub/kube-controller-manager.kubeconfig ; \
	kubectl config set-context default \
		--cluster=kubernetes-the-hard-way \
		--user=system:kube-controller-manager \
		--kubeconfig=configs/kub/kube-controller-manager.kubeconfig ; \
	kubectl config use-context default --kubeconfig=configs/kub/kube-controller-manager.kubeconfig

generate_kub-sched-configs:
	kubectl config set-cluster kubernetes-the-hard-way \
		--certificate-authority=certs/ca.pem \
		--embed-certs=true \
		--server=https://127.0.0.1:6443 \
		--kubeconfig=configs/kub/kube-scheduler.kubeconfig ; \
	kubectl config set-credentials system:kube-scheduler \
		--client-certificate=certs/kube-scheduler.pem \
		--client-key=certs/kube-scheduler-key.pem \
		--embed-certs=true \
		--kubeconfig=configs/kub/kube-scheduler.kubeconfig ; \
	kubectl config set-context default \
		--cluster=kubernetes-the-hard-way \
		--user=system:kube-scheduler \
		--kubeconfig=configs/kub/kube-scheduler.kubeconfig ; \
	kubectl config use-context default --kubeconfig=configs/kub/kube-scheduler.kubeconfig

generate_kub-admin-configs:
	kubectl config set-cluster kubernetes-the-hard-way \
		--certificate-authority=certs/ca.pem \
		--embed-certs=true \
		--server=https://127.0.0.1:6443 \
		--kubeconfig=configs/kub/admin.kubeconfig ; \
	kubectl config set-credentials admin \
		--client-certificate=certs/admin.pem \
		--client-key=certs/admin-key.pem \
		--embed-certs=true \
		--kubeconfig=configs/kub/admin.kubeconfig ; \
	kubectl config set-context default \
		--cluster=kubernetes-the-hard-way \
		--user=admin \
		--kubeconfig=configs/kub/admin.kubeconfig ; \
	kubectl config use-context default --kubeconfig=configs/kub/admin.kubeconfig

generate_kub-enc-key:
	ENCRYPTION_KEY=$$(head -c 32 /dev/urandom | base64)

copy_kub-all-configs: copy_kub-workers-configs copy_kub-controllers-configs

copy_kub-workers-configs:
	for instance in worker-0 worker-1 worker-2; do \
		gcloud compute scp configs/kub/$${instance}.kubeconfig configs/kub/kube-proxy.kubeconfig $${instance}:~/ ; \
	done

copy_kub-controllers-configs:
	for instance in controller-0 controller-1 controller-2; do \
		gcloud compute scp configs/kub/admin.kubeconfig configs/kub/kube-controller-manager.kubeconfig configs/kub/kube-scheduler.kubeconfig $${instance}:~/ ; \
	done

copy_kub-all-certs: copy_kub-workers-certs copy_kub-controllers-certs

copy_kub-workers-certs:
	for instance in worker-0 worker-1 worker-2; do \
  		gcloud compute scp certs/ca.pem certs/$${instance}-key.pem certs/$${instance}.pem $${instance}:~/ ; \
	done

copy_kub-controllers-certs:
	for instance in controller-0 controller-1 controller-2; do \
  		gcloud compute scp certs/ca.pem certs/ca-key.pem certs/kubernetes-key.pem certs/kubernetes.pem \
    		certs/service-account-key.pem certs/service-account.pem $${instance}:~/ ; \
	done

copy_kub-enc-configs:
	for instance in controller-0 controller-1 controller-2; do \
		gcloud compute scp configs/encryption-config.yaml $${instance}:~/ ; \
	done

delete_kub-controllers:
	for inst in 0 1 2; do \
		gcloud compute instances delete controller-$${inst} ; \
	done

delete_kub-workers:
	for inst in 0 1 2; do \
		gcloud compute instances delete worker-$${inst} ; \
	done

show_kub-ip:
	gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"

env_kub-ip:
	KUBERNETES_PUBLIC_ADDRESS=$$(gcloud compute addresses describe kubernetes-the-hard-way \
  		--region $$(gcloud config get-value compute/region) \
  		--format 'value(address)')

env_kub-int-gcp-ip:
	INTERNAL_IP=$$(curl -s -H "Metadata-Flavor: Google" \
		http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

env_kub-hostname:
	ETCD_NAME=$$(hostname -s)

show_kub-instances:
	gcloud compute instances list

connect_kub-cont0:
	gcloud compute ssh controller-0

connect_kub-cont1:
	gcloud compute ssh controller-1

connect_kub-cont2:
	gcloud compute ssh controller-2

connect_kub-work0:
	gcloud compute ssh worker-0

connect_kub-work1:
	gcloud compute ssh worker-1

connect_kub-work2:
	gcloud compute ssh worker-2

create_kub-enc-configs:
	sh create-kub-enc-configs.sh
