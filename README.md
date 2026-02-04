# Orchestrator

Оркестратор для локальной разработки нескольких PHP‑сервисов (api‑profiles и api‑qr‑link) с общей инфраструктурой на базе Docker Compose: Nginx + PHP‑FPM + Postgres.

## Содержание

- [Архитектура и сервисы](#архитектура-и-сервисы)
- [Предварительные требования](#предварительные-требования)
- [Быстрый старт](#быстрый-старт)
- [Конфигурация окружения](#конфигурация-окружения)
- [Подмодули Git](#подмодули-git)
- [Запуск и остановка](#запуск-и-остановка)
- [Порты и хостнеймы](#порты-и-хостнеймы)
- [Полезные команды](#полезные-команды)
- [Структура репозитория](#структура-репозитория)
- [Типичные проблемы](#типичные-проблемы)

## Архитектура и сервисы

Docker Compose поднимает:

- **nginx** — проксирует запросы к сервисам:
  - `api-profiles` на порту `80`
  - `api-qr-link` на порту `81`
- **api-profiles** — PHP‑FPM контейнер (код в Git‑подмодуле `services/api-profiles`)
- **api-qr-link** — PHP‑FPM контейнер (код в Git‑подмодуле `services/api-qr-link`)
- **postgres** — база данных

Nginx конфигуры лежат в `docker/nginx/configs/conf.d/api-services.conf`, где определены два server‑блока и правила проксирования на соответствующие PHP‑FPM контейнеры.

## Предварительные требования

Установите:

- Docker 24+ (или актуальная версия)
- Docker Compose v2 (`docker compose`)
- Git
- Доступ по SSH к GitHub (подмодули указывают на `git@github.com:...`)

Проверьте доступность SSH‑ключа:

```bash
ssh -T git@github.com
```

## Быстрый старт

1. Склонируйте репозиторий **вместе с подмодулями**:

   ```bash
   git clone --recurse-submodules <repo-url>
   cd orchestrator
   ```

2. Создайте `.env` на основе примера:

   ```bash
   cp .env.example .env
   ```

3. Поднимите контейнеры:

   ```bash
   docker compose up -d --build
   ```

4. Добавьте хостнеймы в `/etc/hosts` (локально):

   ```text
   127.0.0.1 api-profiles.local
   127.0.0.1 api-qr-link.local
   ```

5. Проверьте доступность сервисов:

   ```bash
   curl -I http://api-profiles.local
   curl -I http://api-qr-link.local:81
   ```

## Конфигурация окружения

Все настройки лежат в `.env`. Пример — `.env.example`.

Ключевые параметры:

| Переменная | Назначение | Пример |
| --- | --- | --- |
| `COMPOSE_PROJECT_NAME` | Префикс контейнеров/сети | `tipsGrammBackendServices` |
| `SERVER_HOME` | Путь до корня репозитория | `./` |
| `PHP_ENV` | Режим PHP (dev/prod) | `dev` |
| `APP_ENV` | Режим приложения (dev/prod) | `dev` |
| `PORT_API_PROFILES` | Порт Nginx для api‑profiles | `80` |
| `PORT_API_QR_LINK` | Порт Nginx для api‑qr‑link | `81` |
| `PORT_POSTGRES` | Внешний порт Postgres | `5432` |

> 💡 В `docker/php/Dockerfile` определён образ PHP 8.4 с набором расширений, Xdebug включён для `PHP_ENV=dev`.

## Подмодули Git

Сервисы подключаются как Git‑подмодули.

### Инициализация подмодулей

Если репозиторий уже склонирован без `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

### Обновление подмодулей до последних коммитов ветки

```bash
git submodule update --remote --merge
```

### Проверка статуса подмодулей

```bash
git submodule status
```

## Запуск и остановка

### Запуск

```bash
docker compose up -d --build
```

### Остановка

```bash
docker compose down
```

### Перезапуск конкретного сервиса

```bash
docker compose restart api-profiles
```

### Сборка PHP‑образа без кеша

```bash
docker compose build --no-cache api-profiles
```

## Порты и хостнеймы

По умолчанию:

| Сервис | Хост | Порт |
| --- | --- | --- |
| api‑profiles | `api-profiles.local` | `80` |
| api‑qr‑link | `api-qr-link.local` | `81` |
| postgres | `localhost` | `5432` |

> Если порты заняты, измените `PORT_*` в `.env`.

## Полезные команды

### Логи Nginx

```bash
tail -f docker/nginx/logs/api-profiles-access.log
```

### Войти в контейнер PHP

```bash
docker compose exec api-profiles bash
```

### Установить зависимости composer внутри сервиса

```bash
docker compose exec api-profiles composer install
```

### Применить миграции (если есть в сервисе)

```bash
docker compose exec api-profiles php bin/console doctrine:migrations:migrate
```

## Структура репозитория

```
.
├── docker/                       # Docker-файлы и конфиги
│   ├── nginx/                    # Nginx конфигурация и логи
│   ├── php/                      # PHP Dockerfile и конфиги
│   └── postgres/                 # Данные и init-скрипты Postgres
├── services/                     # Git-подмодули сервисов
│   ├── api-profiles/             # сервис api-profiles
│   └── api-qr-link/              # сервис api-qr-link
├── docker-compose.yaml           # Compose конфиг
└── .env.example                  # пример окружения
```

## Типичные проблемы

### Подмодули пустые

Подмодули не были инициализированы. Выполните:

```bash
git submodule update --init --recursive
```

### Nginx не стартует — порт занят

Измените значения `PORT_API_PROFILES`/`PORT_API_QR_LINK` в `.env` и перезапустите:

```bash
docker compose down
docker compose up -d --build
```

### Ошибка доступа к GitHub по SSH

Проверьте SSH‑ключ и агент:

```bash
ssh -T git@github.com
```
