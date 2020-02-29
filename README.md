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
