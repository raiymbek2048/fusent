# Firebase Push Notifications Setup Guide

## Обзор
Система push-уведомлений реализована с использованием Firebase Cloud Messaging (FCM).

## Архитектура

### Backend (Spring Boot)
- **FcmToken** - модель для хранения FCM токенов устройств
- **FcmService** - сервис для отправки уведомлений
- **FcmController** - API endpoints для регистрации токенов
- **FirebaseConfig** - конфигурация Firebase Admin SDK

### Mobile (Flutter)
- **FirebaseMessagingService** - обработка уведомлений
- Автоматическая регистрация токенов на backend
- Обработка foreground/background уведомлений
- Навигация при клике на уведомление

## Типы уведомлений

| Тип | Описание | Действие при клике |
|-----|----------|-------------------|
| `LIKE` | Новый лайк на посте | Открыть пост |
| `COMMENT` | Новый комментарий | Открыть пост с комментариями |
| `MESSAGE` | Новое сообщение в чате | Открыть чат |
| `FOLLOW` | Новый подписчик | Открыть профиль подписчика |
| `ORDER` | Изменение статуса заказа | Открыть детали заказа |

## Настройка Backend

### 1. Firebase Admin SDK

1. Создайте проект в [Firebase Console](https://console.firebase.google.com/)
2. Перейдите в Project Settings → Service Accounts
3. Нажмите "Generate New Private Key"
4. Скачайте JSON файл и переименуйте его в `firebase-adminsdk.json`
5. Поместите файл в `src/main/resources/`

### 2. Конфигурация application.yml

```yaml
firebase:
  config:
    file: firebase-adminsdk.json # Путь к файлу с credentials
```

### 3. База данных

Миграция создается автоматически через Flyway:
```sql
-- V23__create_fcm_tokens.sql
CREATE TABLE fcm_tokens (
    id UUID PRIMARY KEY,
    token VARCHAR(500) NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    device_type VARCHAR(20),
    device_id VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Настройка Mobile

### 1. Firebase Configuration

#### Android (`android/app/google-services.json`)
1. В Firebase Console → Project Settings → General
2. Добавьте Android приложение
3. Укажите package name: `com.fusent.fusent_mobile`
4. Скачайте `google-services.json`
5. Поместите в `android/app/`

#### iOS (`ios/Runner/GoogleService-Info.plist`)
1. В Firebase Console → Project Settings → General
2. Добавьте iOS приложение
3. Укажите Bundle ID: `com.fusent.fusentMobile`
4. Скачайте `GoogleService-Info.plist`
5. Поместите в `ios/Runner/`

### 2. Android Manifest

Убедитесь что в `android/app/src/main/AndroidManifest.xml` есть:

```xml
<application>
    <!-- Other configuration -->

    <!-- Firebase Messaging -->
    <service
        android:name="com.google.firebase.messaging.FirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

### 3. iOS Push Notifications

1. В Xcode откройте Runner.xcworkspace
2. Выберите Runner target → Signing & Capabilities
3. Нажмите "+ Capability" → Push Notifications
4. Добавьте также "Background Modes" с галочкой "Remote notifications"

В Apple Developer Console:
1. Создайте APNs Key
2. Скачайте .p8 файл
3. В Firebase Console → Project Settings → Cloud Messaging → iOS app
4. Загрузите APNs Key

## API Endpoints

### POST /api/v1/fcm/register
Регистрация FCM токена устройства

**Request:**
```json
{
  "token": "fcm_token_here",
  "deviceType": "ANDROID", // or "IOS"
  "deviceId": "unique_device_id"
}
```

**Response:** `200 OK`

### POST /api/v1/fcm/unregister
Удаление FCM токена

**Request:**
```json
{
  "token": "fcm_token_to_remove"
}
```

**Response:** `200 OK`

### POST /api/v1/fcm/test
Отправить тестовое уведомление (для текущего пользователя)

**Response:** `200 OK`

## Использование в коде

### Отправка уведомлений с backend

```java
@Autowired
private FcmService fcmService;

// При создании лайка
fcmService.sendLikeNotification(
    post.getOwner().getId(),
    currentUser.getUsername(),
    post.getId()
);

// При новом комментарии
fcmService.sendCommentNotification(
    post.getOwner().getId(),
    currentUser.getUsername(),
    post.getId(),
    comment.getText()
);

// При новом сообщении
fcmService.sendMessageNotification(
    recipientUserId,
    senderName,
    conversationId,
    messageText
);

// При изменении заказа
fcmService.sendOrderNotification(
    order.getUser().getId(),
    order.getId(),
    "SHIPPED"
);
```

### Обработка уведомлений в Flutter

Уведомления обрабатываются автоматически в `FirebaseMessagingService`.

Для кастомной обработки:
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Foreground notification
  print('Got a message: ${message.messageId}');
});

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Background notification tap
  // Navigate to specific screen
});
```

## Тестирование

### 1. Через API
```bash
# Зарегистрируйте токен
curl -X POST http://localhost:8080/api/v1/fcm/register \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_FCM_TOKEN",
    "deviceType": "ANDROID",
    "deviceId": "test_device_123"
  }'

# Отправьте тестовое уведомление
curl -X POST http://localhost:8080/api/v1/fcm/test \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 2. Из Firebase Console
1. Firebase Console → Cloud Messaging → Send test message
2. Вставьте FCM token устройства
3. Отправьте уведомление

### 3. В приложении
- Выполните действие (лайк, комментарий)
- Уведомление должно прийти на целевое устройство

## Troubleshooting

### Уведомления не приходят
1. Проверьте что Firebase config файлы на месте
2. Убедитесь что backend запущен и firebase-adminsdk.json загружен
3. Проверьте логи: `Firebase Admin SDK initialized successfully`
4. Убедитесь что токен зарегистрирован в БД

### iOS уведомления не работают
1. Проверьте что APNs ключ загружен в Firebase Console
2. Убедитесь что Push Notifications capability включен
3. Проверьте Bundle ID совпадает с Firebase

### Android уведомления не работают
1. Проверьте google-services.json
2. Убедитесь что Package Name совпадает
3. Проверьте AndroidManifest.xml

## Безопасность

- FCM токены привязаны к пользователям через foreign key
- Токены автоматически деактивируются при неудачной отправке
- Поддержка multiple devices на одного пользователя
- Токены удаляются при logout через `/api/v1/fcm/unregister`

## Масштабирование

- Firebase FCM бесплатно до 500K сообщений/месяц
- Для больших нагрузок рассмотрите:
  - Batch отправку через FirebaseMessaging.sendAll()
  - Topic subscriptions для групповых уведомлений
  - Кэширование токенов в Redis
