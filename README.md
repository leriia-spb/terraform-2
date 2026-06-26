# HW9: Terraform Infrastructure

Инфраструктура в VK Cloud на базе Terraform с балансировкой нагрузки, DNS и двумя окружениями (prod/dev).

## Архитектура

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                         VK Cloud                            │
                                    │                                                             │
┌─────────┐                         │   ┌─────────────┐                                           │
│  Users  │ ──────┬─────────────────┼──►│  Shared LB  │ (Floating IP)                            │
└─────────┘       │                 │   │  (vip_port) │                                           │
                  │                 │   └──────┬──────┘                                           │
                  │ DNS             │          │                                                  │
    ┌─────────────▼──────────┐      │   ┌──────┴─────────────────────────────────────────────┐    │
    │  hw9-aleshina.ru       │      │   │                                                    │    │
    │  ├─ prod → FIP         │      │   │  ┌─────────────────┐  ┌─────────────────┐         │    │
    │  ├─ www.prod → prod    │      │   │  │  prod-listener  │  │  dev-listener   │         │    │
    │  ├─ dev → FIP          │      │   │  │  (port 80)      │  │  (port 8080)    │         │    │
    │  └─ www.dev → dev      │      │   │  └────────┬────────┘  └────────┬────────┘         │    │
    └────────────────────────┘      │   │           │                     │                   │    │
                                    │   │    ┌──────▼──────┐       ┌──────▼──────┐           │    │
                                    │   │    │ prod-fe ×2  │       │ dev-node ×2 │           │    │
                                    │   │    │ (HAProxy)   │       │ (HAProxy+NG)│           │    │
                                    │   │    └──────┬──────┘       └──────┬──────┘           │    │
                                    │   │           │                     │                   │    │
                                    │   │    ┌──────▼──────┐       ┌──────▼──────┐           │    │
                                    │   │    │ prod-be ×2  │       │ (сами себе) │           │    │
                                    │   │    │ (NGINX)     │       │             │           │    │
                                    │   │    └─────────────┘       └─────────────┘           │    │
                                    │   │                                                    │    │
                                    │   └────────────────────────────────────────────────────┘    │
                                    │                                                             │
                                    └─────────────────────────────────────────────────────────────┘
```

### Компоненты

| Модуль | Описание |
|--------|----------|
| `router` | Маршрутизатор с внешним шлюзом |
| `network` | Сети и подсети для окружений |
| `security_group` | Группы безопасности с правилами ingress |
| `loadbalancer` | Балансировщик с Floating IP |
| `listener` | Слушатели для prod (80) и dev (8080) |
| `compute` | Виртуальные машины (frontend/backend) |
| `dns` | DNS-зона и записи через vkcs-провайдер |

### Окружения

| Окружение | Подсеть | Listener | Backend |
|-----------|---------|----------|---------|
| **shared** | lb-net: `10.17.0.0/24` | — | — |
| **prod** | prod-net: `10.2.0.0/24` | порт 80 | 2 × nginx (port 8080) |
| **dev** | dev-net: `10.25.0.0/24` | порт 8080 | 2 × (nginx+haproxy) |

## Требования

- **Terraform** >= 1.6
- **OpenStack CLI** (опционально, для проверки каталога и ключей)
- **dig** (для проверки DNS)
- **graphviz** (для генерации графа зависимостей)
- S3-бакет в VK Cloud с версионированием

## Переменные окружения

```bash
# OpenStack (для terraform openstack/vkcs провайдеров)
source ~/path/to/openrc.sh

# S3 (для terraform backend)
export AWS_ACCESS_KEY_ID="<s3 access key>"
export AWS_SECRET_ACCESS_KEY="<s3 secret key>"
```

## Быстрый старт

### 1. Подготовка

```bash
# Склонировать репозиторий
git clone <repo-url>
cd hw9

# Создать terraform.tfvars из примеров
cp envs/shared/terraform.tfvars.example envs/shared/terraform.tfvars
cp envs/prod/terraform.tfvars.example envs/prod/terraform.tfvars
cp envs/dev/terraform.tfvars.example envs/dev/terraform.tfvars

# Отредактировать значения в terraform.tfvars
# Узнать имя SSH-ключа: openstack keypair list
```

### 2. Развёртывание

```bash
# 1. shared (базовая инфраструктура: router, LB, DNS)
cd envs/shared
terraform init
terraform apply

# 2. prod (окружение prod)
cd ../prod
terraform init
terraform apply

# 3. dev (окружение dev)
cd ../dev
terraform init
terraform apply
```

### 3. Проверка балансировки

```bash
# Получить Floating IP и зону из shared
FIP=$(terraform -chdir=envs/shared output -raw fip_address)
ZONE=$(terraform -chdir=envs/shared output -raw dns_zone_name)

# Через IP (должны чередоваться разные backend-узлы)
for i in {1..10}; do curl -s http://$FIP:80/; done    # prod
for i in {1..10}; do curl -s http://$FIP:8080/; done  # dev

# Через DNS
dig +short prod.$ZONE @ns1.mcs.mail.ru
curl -s -H "Host: prod.$ZONE" http://$FIP/
```

### 4. Unit-тест

```bash
cd tests
terraform init
terraform test
```

### 5. Генерация графа зависимостей

```bash
cd envs/prod
terraform init -backend=false
terraform graph -type=apply | dot -Tpng > ../../docs/graph.png
```

### 6. Удаление (в обратном порядке!)

```bash
cd envs/dev    && terraform destroy
cd ../prod     && terraform destroy
cd ../shared   && terraform destroy
```

## Структура проекта

```
hw9/
├── .gitignore
├── README.md
├── ИНСТРУКЦИЯ.md
├── envs/
│   ├── shared/          # Общая инфраструктура (LB, DNS, router)
│   ├── prod/            # Prod-окружение
│   └── dev/             # Dev-окружение
├── modules/
│   ├── router/          # Маршрутизатор
│   ├── network/         # Сети и подсети
│   ├── security_group/  # Группы безопасности
│   ├── loadbalancer/    # Балансировщик
│   ├── listener/        # Слушатели LB
│   ├── compute/         # Виртуальные машины
│   └── dns/             # DNS-зона и записи
├── templates/
│   ├── cloud-init.yaml.tftpl
│   ├── haproxy.cfg.tftpl
│   └── nginx.conf.tftpl
└── tests/
    ├── main.tf
    └── network.tftest.hcl
```

## Критерии оценивания

| Балл | Критерий | Реализация |
|------|----------|------------|
| 1 | Балансировка в 2 окружениях | `envs/shared` LB + `envs/prod` listener:80 + `envs/dev` listener:8080 |
| 2 | Модули + validation | `modules/*`, validation в `modules/network/variables.tf` (cidr), `modules/listener/variables.tf` (port) |
| 3 | Remote backend S3 | `backend.tf` в каждом окружении, разные `key` |
| 4 | `terraform_remote_state` | `envs/prod/data.tf`, `envs/dev/data.tf` читают `shared` |
| 5 | Unit-тест | `tests/network.tftest.hcl` |
