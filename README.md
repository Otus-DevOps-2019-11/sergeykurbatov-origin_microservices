# sergeykurbatov-origin_microservices
sergeykurbatov-origin microservices repository

### Homework 12
Создан `Dockerfile` с настройками запуска контейнера с установленным и запущенным приложением web сервиса.
Контейнер импортирован в Docker hub.
Создана инфраструктура с динамическим окружение для запуска контейнерезированного приложения web сервиса в GCP.
Для запуска контейнера выполните - `docker run --name reddit -d -p 9292:9292 <your-login>/otus-reddit:1.0`
Для создание образа packer с установленным docker выполните - `cd docker-monolith/infra && packer -var-file=packer/variables.json.example reddit_docker.json`
Для запуска инфраструктуры с помощью Terraform в GCP выполните - `cd docker-monolith/infra/terraform && terraform init -var-file=terraform.tfvars.example`
`terraform apply -var-file=terraform.tfvars.example`
`cd stage/ && terraform init -var-file=terraform.tfvars.example`
`terraform apply -var-file=terraform.tfvars.example`
Для запуска ansible установки и запуска контейнера выполните - `cd docker-monolith/infra/ansible && ansible-playbook playbooks/site.yml`

### Homework 13
Созданы 3 `Dockerfile` для разных приложений (Post, Comment, UI)
Собраны 3 образа для разных приложений (Post, Comment, UI)
Создана единая сеть для работы приложений на контейнерах `reddit`
Обновлены `Dockerfile` для 3х разных приложений (Post, Comment, UI) для уменьшения веса с использование Alpine Linux
Подключен раздел для сохранения конфигураций базы данных, дабы не пропали данные из приложений.
Для создания образов воспользуйтесь -
```
docker build -t sfrost1988/post:1.0 ./post-py
docker build -t sforst1988/comment:1.0 ./comment
docker build -t sfrost1988/ui:1.0 ./ui
```
Для запуска легковесных контейнеров в папке src/comment и src/ui переименуйте файлы `Dockerfile.1` в `Dockerfile` и выполните создание образов - 
```
docker build -t sforst1988/comment:3.0 ./comment
docker build -t sfrost1988/ui:3.0 ./ui
```
Для создания единой сети выполните - `docker network create reddit`
Для окончательного запуска приложения выполните - 
```
docker pull mongo:latest
sudo docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post sfrost1988/post:1.0
docker run -d --network=reddit --network-alias=comment sfrost1988/comment:3.0
docker run -d --network=reddit -p 9292:9292 sfrost1988/ui:3.0
```

### Homework 14

Базовое имя проекта берется из имени папки в которой расположен проект. Его можно переопределить ключем `--project-name <name>`
Проведена работа с сетями контейнеров, разбиение контейнеров по разным сетям и подключение контейнеров к существующим сетям.
Создан `src/docker-compose.yml` для описания запуска всех контейнеров и их зависимостей.
Параметризованы многие из значений в `src/docker-compose.yml` и вынесены, как пример, в отдельный файл `src/.env.example`
Контейнеры распределены и подключены к разным сетям, это описано в `src/docker-compose.yml`
Описан запуск контейнеров без сборки образов, подключение к различным сетям, параметризацией данных и подключения `volumes` для сохранения изменений при выключении, перезапуске и переноса контейнеров.

Для запуска контейнеров в ручном режиме по разным сетям выполните - 
```
cd src/
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=back_net --network=front_net --network-alias=post --name post sfrost1988/post:1.0 
docker run -d --network=back_net --network=front_net --network-alias=comment --name comment sfrost1988/comment:3.0
docker run -d --network=front_net -p 9292:9292 --name ui sfrost1988/ui:3.0
```
Для запуска через docker-compose выполните - `cd src/ && docker-compose up -d`. Незабудьте использовать `.env` файл, его пример приведен в `src/.env.example`
Для запуска через docker-compose без выполнения сборки образов + подключение `volumes` выполните - `cd src/ && docker-compose -f docker-compose.override.yml --project-name sfrost up -d`
Для выключения выполните команду - `cd src/ && docker-compose -f docker-compose.override.yml --project-name sfrost down`

### Homework 15

Slack channel для проверки оповещений - https://app.slack.com/client/T6HR0TUP3/CRVKNU9DL
Установлен Gitlab сервер в контейнере.
Настроен проект и отключена автоматическая регистрация пользователей.
Создан файл `.gitlab-ci.yml` с различными тестами и автоматическими созданиями environments.
Настроена интеграция с Slack через web hook, канал - https://app.slack.com/client/T6HR0TUP3/CRVKNU9DL
Описан building контейнера приложения и заливка его в dockerhub + автотест с развертыванием контейнера.
Столкнулся с проблемой при билде `ERROR: error during connect: Get http://docker:2375/v1.40/info: dial tcp: lookup docker on 169.254.169.254:53: no such host`, при использовании разных dind версий ситуация не меняется, но при локальном развертывании все работает.
Для запуска gitlab в контейнере в дерриктории `gitlab-ci` создан файл `docker-compose.yml`

Для запуска gitlab выполните `cd gitlab-ci && docker-compose up -d`

### Homework 16

Dockerhub repository with PUMA UI - https://hub.docker.com/repository/docker/sfrost1988/ui
Dockerhub repository with PUMA POST - https://hub.docker.com/repository/docker/sfrost1988/post
Dockerhub repository with PUMA COMMENT - https://hub.docker.com/repository/docker/sfrost1988/comment
Dockerhub repository with prometheus service for monitoring microservices - https://hub.docker.com/repository/docker/sfrost1988/prometheus
Dockerhub repository with google cloudprober service for blackbox monitoring - https://hub.docker.com/repository/docker/sfrost1988/cloudprober

Создан `Dockerfile` в дерриктории `monitoring\prometheus` для создания докер образа сервиса мониторинга Prometheus.
Создан `prometheus.yml` конфигурационный файл для настройки службы мониторинга. В нем описаны параметры мониторинга сервисов.
Описан запуск всех сервисов в контейнерах с помощью файла `docker-compose.yml` в дерриктории `docker`
Описан запуск сервиса `node-exporter` для мониторинга состояния `docker-host`
Описан запуск сервиса `bitnami/mongodb-exporter` для мониторинга состояния `mongodb`
Описано создание и запуск контейнера с сервисом `cloudprober` для мониторинга сервисов с помощью blackbox. Состояние сервисов можно отследить с помощью графика и лога `total` в prometheus
Создан Makefile для автоматического создания контейнеров и заливки их на dockerhub.

Для запуска сборки контейнеров выполните: `make build-all`
Для заливки контейнеров в dockerhub выполните: `make push-all`
Для выполнения операций выше выполните: `make docker-all`
Для запуска инфраструктуры на контейнерах, при условии подключенного docker-host, выполните: `make run-infra`
Для отключения инфраструктуры на контейнерах, при условии подключенного docker-host, выполните: `make down-infra`
Для вывода ip-адреса docker-host, выполните: `make docker-ip`
Для вывода справки по командам, выполните: `make` или `make help`

### Homework 17

Dockerhub repository with PUMA UI - https://hub.docker.com/repository/docker/sfrost1988/ui
Dockerhub repository with PUMA POST - https://hub.docker.com/repository/docker/sfrost1988/post
Dockerhub repository with PUMA COMMENT - https://hub.docker.com/repository/docker/sfrost1988/comment
Dockerhub repository with prometheus service for monitoring microservices - https://hub.docker.com/repository/docker/sfrost1988/prometheus
Dockerhub repository with google cloudprober service for blackbox monitoring - https://hub.docker.com/repository/docker/sfrost1988/cloudprober
Dockerhub repository with alertmanager service for alerting about incendent with infra - https://hub.docker.com/repository/docker/sfrost1988/alertmanager

Разделены инфрастурктурный docker-compose файл (`docker/docker-compose.yml`) и для мониторинга (`docker/docker-compose-monitoring.yml`).
Добавлен сервис мониторинга контейнеров cAdvisor.
Добавлен сервис мониторинга контейнеров и построения графиков Grafana.
В Grafana установлен dashboarb для мониторинга docker контейнеров `monitoring\grafana\dashboards\DockerMonitoring.json`.
В Prometheus добавлен мониторинг сервиса `post`.
В Grafana создан dashboard для мониторинга UI сервиса и запросов к нему `monitoring\grafana\dashboards\UI_Service_Monitoring.json`.
В Grafana создан dashboard для мониторинга бизнес метрик `monitoring\grafana\dashboards\Business_Logic_Monitoring.json`.
Добавлен сервис оповещения об инцендентах с инфраструктурой Alermanager.
В docker-host включен эсперементальный режим общения docker контейнеров и сервиса мониторинга Prometheus в `/etc/docker/daemon.json`
```
{
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
```
Для работы с метриками docker в експерементальном режиме в Grafana добавлен dashboard `monitoring\grafana\dashboards\docker-engine-metrics_rev3.json`. Количество метрик значительно ниже, чем при использовании cAdvisor и они в большей степени направлены на мониторинг docker-host и его параметров с небольшой статистикой по docker контейнерам.
Добавлен сервис мониторинга и хранения данных о состоянии контейнеров influxDB и telegraf.
Для работы с метриками docker с использованием influxdb и telegraf в Grafana добавлен dashboard `monitoring\grafana\dashboards\telegraf-system-dashboard_rev4.json`. Количество метрик сопоставимо с метриками cAdvisor но дополнительно ставится база данных, что усложняет конфигурирование.
Добавлен alert в prometheues, что если в случае большого времени отклика одного из сервисов, будет отправлено оповещение в slack и на почту (преведены фейковые данные).
Добавлен собственный контейнер с Grafana и автоматическим добавлением данных о дашбордах и сервисов данных.
Добавлен сервис сбора метрик stackdriver. Но метрики приложения и бизнеса придумать не удалось.
Добавлен сервис Autoheal для перезагрузки и исправления ситуации с контейнерами, но пока не могу представить проблем, которые бы не решались healthcheack'ами без доп контейнера или опцией авторестартом контейнеров.


Подключиться к инфраструктуре можно следующим образом:
- Web интерфейс приложения - http://<docke-host_ip>:9292
- Web интерфейс Prometheus - http://<docke-host_ip>:9090
- Web интерфейс cAdvisor - http://<docke-host_ip>:8080
- Web интерфейс Grafana - http://<docke-host_ip>:3000
- Web интерфейс Alermanager - http://<docke-host_ip>:9093

### Homework 18

Установлен код измененного приложения.
Создан и настроен контейнер fluentd для сбора лог сообщений и пересылки их в контейнер с Elasticsearch.
Настроено развертывания контейнера Elasticsearch и Kibana для сбора логов и отображения в графическом виде.
Настроен сбор лог сообщений с сервисов post и ui с использованием fluentd.
Рассмотрено отображение лог сообщений в elasticsearch и kibana.
Настроен парсинг лог сообщений с использованием конфигурации fluentd при помощи json формата отображения логов, grok патернов и регулярных выражений.
Рассмотрен вариант отслеживания проблем и задержек в web приложении с использование zipkin.
В задании со * была анализирована причина некоректного работа микросервиса post. С применением инструмента Zipkin и git diff была найдена ошибка (по моему мнению) в коде создающая проблему в задержки открытия поста на портале. При запросе записи в БД процесс засыпал на 3 секунды. Найденная фукнция `time.sleep(3)` в коде:
```
...
        stop_time = time.time()  # + 0.3
        resp_time = stop_time - start_time
        app.post_read_db_seconds.observe(resp_time)
        time.sleep(3)
        log_event('info', 'post_find',
                  'Successfully found the post information',
                  {'post_id': id})
        return dumps(post)
...
```

Подключиться к инфраструктуре можно следующим образом:
- Web интерфейс приложения - http://<docke-host_ip>:9292
- Web интерфейс kibana - http://<docke-host_ip>:5601
- Web интерфейс zipkin - http://<docke-host_ip>:9411
- Web интерфейс elasticsearch - http://<docke-host_ip>:9200

### Homework 19

Создана и настроена инфраструктура согласно Kubernetes The Hard Way.
Создан Makefile для быстрого развертывания или удаления Kubernetes The Hard Way.
Сделаны smoketest'ы.
Удалена инфраструктура.

Для запуска инфраструктуры без применения настроек, выполните `cd kubernetes/the_hard_way/ && make run_kub`
Для удаления инфрастуктуры, выполните `cd kubernetes/the_hard_way/ && make delete_kub`

Для проверки работоспособности, выполните `cd kubernetes/the_hard_way/ && make phase13`

### Homework 20

Установлен Minikube с использованием Virtualbox.
Созданы манифесты по запуску приложения в Minikube с использованием контейниризации.
Созданы сервис манифесты для создания взаимодействия между контейнерами в среде Kubernetes.
Развернут Kubernetes Dashboard и произведено ознакомление с его возможностями.
Развернут Kubernetes в среде Google cloud.
Развернуто приложение с использованием средств GKE.
Создано инфрструктура создания кластера Kubernetes в GKE с использованием Terraform.

Для запуска kubernetes кластера в GKE, выполните 
```
cd ./kubernetes/terraform/ && terraform init
terraform apply
kubectl apply -f ../reddit/dev-namespace.yml
kubectl apply -f ../reddit/ -n dev
```

Для проверки работоспособности, выполните `kubectl get nodes -o wide` и `kubectl describe service ui  -n dev  | grep NodePort`. Выполните подключение к одному из внешних IP кластера Kubernetes с использование NodePort из выдачии последней команды.

### Homework 21

Создан LoadBalancer в GCE для балансирования и проксирования трафика.
Создан Ingress для UI приложения и настроено взаимодействие по tcp/80.
Выпущены сертификаты и установлены для Ingress дабы обеспечить взаимодействие по зашифрованному соединению.
Создана конфигурация Ingress для автоматического включения HTTPS - файл `kubernetes/reddit/ui-secret.yml`
Настроено сетевое взаимодействие между Mongo и сервисами post и comment.
Настроены различные взаимодействия с хранилищами, включая выделение отдельного диска.

Для запуска kubernetes кластера в GKE, выполните 
```
cd ./kubernetes/terraform/ && terraform init
terraform apply
kubectl apply -f ../reddit/
kubectl apply -f ../reddit/ -n dev
```

Для проверки работоспособности, выполните `kubectl get ingress`. Выполните подключение к внешнему IP Ingress контроллера с использование https.

# Homework 22

Установлен helm версии 3, так как это актуальная версия на данный момент.
Создан манифест Tiller и применен к инфраструктуре kubernetes (хотя для helm 3 он не нужен).
Попытка инициализации тиллера (безуспешно, потому как он не актуален).
Созданы Chart'ы для компонентов приложения.
Проинсталлировано приложение и все его компоненты с использованием helm.
Настроено взаимодействие между компонентами через общий Chart.
Установлен gitlab с omnibus с помощью Helm. (нужно не забывать ставить галочку про устаревшие права в GCE).
Созданы проекты `UI`, `Comment` и `Post` для создания через pipeline gitlab контейнеров этих приложний и заливка их в dockerhub.
Создан центральный проект `reddit-deploy` для автоматического развертывания инфраструктуры в разных environment'ах. 
Для каждого приложения создан свой `.gitlab-ci.yml` конфиг для разных pipeline.
Модернизированы `.gitlab-ci.yml` конфиги всех приложений для развертывания с разных версий helm.

Для запуска приложения выполните ```helm install gitlab kubernetes/Charts/gitlab-omnibus/ -f kubernetes/Charts/gitlab-omnibus/values.yaml``` и заливайте и играйтесь с разными приложениями, их pipeline и тд.

Для проверки работоспособности, выполните `kubectl get ingress`. Выполните подключение к внешнему IP Ingress контроллера с использование https.
