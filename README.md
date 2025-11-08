# Fucent - Маркетплейс для Кыргызстана

Многосторонний маркетплейс (аналог Wildberries) с картой рынков/магазинов, социальной витриной, чатом покупатель-продавец, каталогом, заказами, POS-интеграцией, оплатой, доставкой, рекламой и аналитикой.

## Технологический стек

### Backend
- **Java 21** - основной язык программирования
- **Spring Boot 3.5.7** - фреймворк
- **PostgreSQL 15+** - основная база данных
- **Flyway** - миграции БД
- **Redis** - кеширование
- **Apache Kafka** - обработка событий
- **MinIO** - S3-совместимое хранилище для медиа

### Frontend (планируется)
- **React** - веб-приложение
- **Flutter 3.x** - мобильные приложения (Android/iOS)

### Дополнительные технологии
- **JWT** - аутентификация
- **Swagger/OpenAPI** - документация API
- **Maven** - сборка проекта

## Быстрый старт

### Требования

- Java 21+
- Maven 3.8+
- Docker и Docker Compose

### 1. Клонирование репозитория

```bash
git clone https://github.com/raiymbek2048/fusent.git
cd fusent
```

### 2. Запуск инфраструктуры (PostgreSQL, Redis, Kafka, MinIO)

```bash
docker-compose up -d
```

Это запустит:
- PostgreSQL на порту `5432`
- Redis на порту `6379`
- Kafka на портах `9092` (внешний) и `29092` (внутренний)
- Zookeeper на порту `2181`
- MinIO на портах `9000` (API) и `9001` (Console)

### 3. Проверка статуса контейнеров

```bash
docker-compose ps
```

Все контейнеры должны быть в статусе `Up` и `healthy`.

### 4. Настройка переменных окружения (опционально)

Скопируйте файл примера и отредактируйте при необходимости:

```bash
cp .env.example .env
```

Файл `.env` используется для переопределения настроек по умолчанию.

### 5. Сборка и запуск приложения

```bash
# Сборка проекта
./mvnw clean install

# Запуск приложения
./mvnw spring-boot:run
```

Приложение будет доступно по адресу: `http://localhost:8080`

При первом запуске автоматически создаются тестовые данные (см. [TEST_ACCOUNTS.md](TEST_ACCOUNTS.md)):
- 9 пользователей (1 admin, 3 sellers, 5 buyers)
- 3 магазина в Бишкеке
- 8 продуктов с вариантами
- Посты в социальной ленте

### 6. Проверка работоспособности

Откройте в браузере:
- API Documentation (Swagger): http://localhost:8080/swagger-ui.html
- Health Check: http://localhost:8080/actuator/health
- MinIO Console: http://localhost:9001 (логин: `minioadmin`, пароль: `minioadmin`)

### 7. Тестовые аккаунты

После запуска доступны тестовые аккаунты (подробнее в [TEST_ACCOUNTS.md](TEST_ACCOUNTS.md)):

**Администратор:**
- Email: `admin@fusent.kg`
- Password: `admin123`

**Продавцы:**
- Email: `fashion.store@fusent.kg` / `tech.shop@fusent.kg` / `home.decor@fusent.kg`
- Password: `seller123`

**Покупатели:**
- Email: `buyer1@test.kg` - `buyer5@test.kg`
- Password: `buyer123`

**Пример логина:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "buyer1@test.kg",
    "password": "buyer123"
  }'
```

## Структура проекта

```
fusent/
├── docs/                           # Документация проекта
│   └── Техническое задание (ТЗ) fucent.pdf
├── src/
│   ├── main/
│   │   ├── java/kg/bishkek/fucent/fusent/
│   │   │   ├── common/            # Общие компоненты (ApiError, GlobalExceptionHandler)
│   │   │   ├── config/            # Конфигурации (Security, Swagger)
│   │   │   ├── controller/        # REST контроллеры
│   │   │   ├── dto/               # Data Transfer Objects
│   │   │   ├── enums/             # Перечисления
│   │   │   ├── model/             # Entity классы (JPA)
│   │   │   ├── repository/        # Spring Data JPA репозитории
│   │   │   ├── security/          # Security компоненты (JWT, Auth)
│   │   │   └── service/           # Бизнес-логика
│   │   │       └── impl/          # Реализации сервисов
│   │   └── resources/
│   │       ├── application.yml    # Основные настройки
│   │       └── db/migration/      # Flyway миграции
│   └── test/                      # Тесты
├── docker-compose.yml             # Docker инфраструктура
├── .env.example                   # Пример переменных окружения
├── pom.xml                        # Maven конфигурация
└── README.md                      # Этот файл
```

## Основные модули

### 1. Auth (Аутентификация)
- Регистрация пользователей
- Вход через JWT
- Роли: `BUYER`, `SELLER`, `ADMIN`

### 2. Merchant (Продавцы)
- Управление профилем продавца
- Настройка payout-аккаунта
- Подписки (FREE/PRO/ENTERPRISE)

### 3. Catalog (Каталог)
- Иерархия категорий
- Товары и варианты (SKU)
- Управление остатками

### 4. POS Integration (Смарт-POS)
- Синхронизация продаж
- Автоматическое обновление остатков
- Heartbeat мониторинг
- Buy Eligibility (право на онлайн-покупку)

### 5. Orders (Заказы)
- Создание заказов
- Обработка платежей
- Статусы заказов

### 6. Social (Социальная витрина)
- Instagram-подобные посты
- Лента подписок (Following)
- Лента рекомендаций (Explore)
- Комментарии с верификацией покупок
- Лайки и подписки

### 7. Analytics (Аналитика)
- Метрики магазинов
- Метрики товаров
- Отчеты для продавцов
- Сырые события (retention 13 месяцев)

### 8. Ads (Реклама) - в разработке
- Boost-посты
- Баннеры
- Поисковая реклама

### 9. Notifications (Уведомления) - в разработке
- Push-уведомления
- SMS
- Email

## API Endpoints

### Здоровье и мониторинг
```
GET  /health              - Health check
GET  /actuator/health     - Actuator health
GET  /actuator/metrics    - Метрики
```

### Аутентификация
```
POST /api/auth/register   - Регистрация
POST /api/auth/login      - Вход
```

### Каталог
```
GET  /api/catalog/public         - Публичный каталог
GET  /api/catalog/categories     - Категории
GET  /api/catalog/products/{id}  - Товар по ID
```

### Продавцы (требует аутентификации)
```
GET  /api/merchants/{id}                 - Профиль продавца
PUT  /api/merchants/{id}                 - Обновить профиль
GET  /api/merchants/{id}/eligibility     - Проверка buy eligibility
POST /api/merchants/{id}/payout/onboard  - Подключение выплат
```

### POS (требует роли SELLER)
```
POST /api/pos/sales      - Отправить продажу
POST /api/pos/heartbeat  - Heartbeat от POS
GET  /api/pos/status     - Статус POS
```

### Заказы
```
POST /api/orders         - Создать заказ
GET  /api/orders/{id}    - Получить заказ
GET  /api/orders/my      - Мои заказы
```

Полная документация доступна в Swagger UI: http://localhost:8978/swagger-ui.html

## База данных

### Flyway миграции

Миграции применяются автоматически при запуске приложения:

- **V1__init_schema.sql** - Основные таблицы (users, merchants, shops, catalog, orders, pos)
- **V2__social_module.sql** - Social модуль (posts, comments, likes, follows)
- **V3__ads_and_analytics.sql** - Реклама и аналитика
- **V4__notifications_and_extras.sql** - Уведомления и дополнительные функции

### Подключение к БД

```bash
# Через Docker контейнер
docker exec -it fucent-postgres psql -U postgres -d fucent

# Локально (если установлен psql)
psql -h localhost -p 5432 -U postgres -d fucent
```

Пароль: `1234`

## Конфигурация

### Основные настройки (application.yml)

Все настройки поддерживают переменные окружения:

| Параметр | Переменная окружения | По умолчанию |
|----------|---------------------|--------------|
| Database URL | `DB_URL` | `jdbc:postgresql://localhost:5432/fucent` |
| Database User | `DB_USERNAME` | `postgres` |
| Database Password | `DB_PASSWORD` | `1234` |
| Redis Host | `REDIS_HOST` | `localhost` |
| Kafka Servers | `KAFKA_BOOTSTRAP_SERVERS` | `localhost:9092` |
| S3 Endpoint | `S3_ENDPOINT` | `http://localhost:9000` |
| Server Port | `SERVER_PORT` | `8978` |
| JWT Secret | `JWT_SECRET` | (см. .env.example) |

### Профили Spring

- **dev** (по умолчанию) - разработка, подробное логирование
- **prod** - продакшн, минимум логов

Изменить профиль:
```bash
export SPRING_PROFILE=prod
./mvnw spring-boot:run
```

## Разработка

### Запуск в IDE

1. Импортируйте проект как Maven проект
2. Убедитесь, что используется Java 21
3. Запустите `docker-compose up -d` для инфраструктуры
4. Запустите `FusentApplication.java`

### Горячая перезагрузка (Spring DevTools)

Spring DevTools включен в режиме разработки. Изменения в коде будут применяться автоматически.

### Логирование

Уровни логирования настраиваются через переменные окружения:

```bash
export LOG_LEVEL=DEBUG
export SQL_LOG_LEVEL=DEBUG
```

### Тестирование

```bash
# Запуск всех тестов
./mvnw test

# Запуск с покрытием
./mvnw test jacoco:report
```

## Остановка и очистка

### Остановка приложения
```bash
# Ctrl+C в терминале где запущен Spring Boot
```

### Остановка инфраструктуры
```bash
# Остановить контейнеры
docker-compose stop

# Остановить и удалить контейнеры
docker-compose down

# Удалить все (включая volumes с данными)
docker-compose down -v
```

## Troubleshooting

### Проблема: Не могу подключиться к PostgreSQL

**Решение:**
```bash
# Проверьте статус контейнера
docker-compose ps postgres

# Проверьте логи
docker-compose logs postgres

# Пересоздайте контейнер
docker-compose down
docker-compose up -d postgres
```

### Проблема: Flyway миграции не применяются

**Решение:**
```bash
# Проверьте настройки в application.yml
# Убедитесь что spring.flyway.enabled=true

# Очистите БД и примените миграции заново
docker-compose down -v
docker-compose up -d
./mvnw spring-boot:run
```

### Проблема: Kafka не запускается

**Решение:**
```bash
# Kafka требует Zookeeper
docker-compose up -d zookeeper
# Подождите 10-15 секунд
docker-compose up -d kafka

# Проверьте логи
docker-compose logs kafka
```

### Проблема: MinIO buckets не создаются

**Решение:**
```bash
# Пересоздайте minio-init
docker-compose restart minio-init
docker-compose logs minio-init
```

## Участие в разработке

1. Создайте feature branch от `main`
2. Внесите изменения
3. Создайте Pull Request
4. Дождитесь code review

### Соглашения о коде

- Используйте Lombok для уменьшения boilerplate кода
- Все API должны быть задокументированы в Swagger
- Пишите unit и integration тесты
- Следуйте архитектуре: Controller → Service → Repository

## Лицензия

[Уточните лицензию проекта]

## Контакты

- GitHub: https://github.com/raiymbek2048/fusent
- Документация: см. папку `docs/`

---

**Статус проекта:** В активной разработке (MVP)

**Последнее обновление:** 2025-11-08
