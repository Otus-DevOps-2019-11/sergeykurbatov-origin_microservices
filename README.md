# sergeykurbatov-origin_microservices
sergeykurbatov-origin microservices repository

# Homework 12
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

# Homework 13
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

# Homework 14

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
