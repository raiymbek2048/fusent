# Fucent Marketplace - Setup Instructions

## Предварительные требования

- Java 21+
- Docker и Docker Compose
- Maven 3.9+

## Быстрый старт

### 1. Запустить инфраструктуру

```bash
docker-compose up -d
```

Это запустит:
- **PostgreSQL** (порт 5432) - База данных
- **Redis** (порт 6379) - Кеш
- **Kafka** (порт 9092) - Message broker
- **Zookeeper** (порт 2181) - Kafka coordinator
- **MinIO** (порты 9000, 9001) - S3-совместимое хранилище

### 2. Проверить статус сервисов

```bash
docker-compose ps
```

Все сервисы должны быть в статусе `healthy`.

### 3. Собрать и запустить приложение

```bash
mvn clean install -DskipTests
mvn spring-boot:run
```

Или используя JAR:

```bash
mvn clean package -DskipTests
java -jar target/fusent-0.0.1-SNAPSHOT.jar
```

### 4. Проверить запуск

- **Health Check**: http://localhost:8080/actuator/health
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **MinIO Console**: http://localhost:9001 (login: minioadmin / minioadmin)

## Endpoints

### Аутентификация

#### Регистрация
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "role": "BUYER"
  }'
```

#### Логин
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Response:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 86400,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "test@example.com",
    "role": "BUYER",
    "createdAt": "2025-11-08T10:00:00Z"
  }
}
```

#### Использовать токен

```bash
curl -X GET http://localhost:8080/api/v1/social/feed/public \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Роли пользователей

- **BUYER** - Обычный покупатель
- **SELLER** - Продавец с магазином
- **ADMIN** - Администратор платформы

## Переменные окружения

Создайте `.env` файл (опционально):

```env
# Database
DB_URL=jdbc:postgresql://localhost:5432/fusent
DB_USERNAME=fusent_user
DB_PASSWORD=fusent_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Kafka
KAFKA_BOOTSTRAP_SERVERS=localhost:9092

# MinIO
MINIO_URL=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=fucent-media

# JWT
JWT_SECRET=YOUR_STRONG_SECRET_KEY_HERE
JWT_EXPIRATION=86400000
JWT_REFRESH_EXPIRATION=604800000

# Server
SERVER_PORT=8080
```

## Остановка сервисов

```bash
docker-compose down
```

Удалить все данные:
```bash
docker-compose down -v
```

## Troubleshooting

### Порт уже занят

Если порт 8080 занят, измените в `application.yml`:
```yaml
server:
  port: 8081
```

### База данных не подключается

Проверьте логи PostgreSQL:
```bash
docker logs fusent-postgres
```

### Kafka не работает

Проверьте что Zookeeper запущен:
```bash
docker logs fusent-zookeeper
docker logs fusent-kafka
```

### MinIO bucket не создался

Вручную создайте bucket:
```bash
docker exec -it fusent-minio-create-bucket sh
mc alias set myminio http://minio:9000 minioadmin minioadmin
mc mb myminio/fucent-media
mc anonymous set public myminio/fucent-media
```

## Миграции базы данных

Flyway автоматически применяет миграции при старте приложения.

Миграции находятся в: `src/main/resources/db/migration/`

## Swagger Documentation

После запуска приложения, API документация доступна по адресу:

http://localhost:8080/swagger-ui.html

Все эндпоинты задокументированы с примерами запросов и ответов.

## Production Checklist

Перед деплоем в production:

- [ ] Изменить JWT secret
- [ ] Настроить CORS для production домена
- [ ] Настроить HTTPS
- [ ] Изменить пароли баз данных
- [ ] Настроить rate limiting
- [ ] Включить мониторинг (Prometheus)
- [ ] Настроить логирование
- [ ] Настроить backup баз данных
