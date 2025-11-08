# Fucent API Examples

Полное руководство по API эндпоинтам платформы Fucent Marketplace.

## Базовый URL
```
http://localhost:8080/api/v1
```

## Swagger UI
```
http://localhost:8080/swagger-ui.html
```

---

## 1. Social Module (`/social`)

### 1.1 Создать пост
```http
POST /api/v1/social/posts
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "ownerType": "SHOP",
  "ownerId": "550e8400-e29b-41d4-a716-446655440000",
  "text": "Новая коллекция зимней одежды! Скидки до 50%",
  "postType": "PHOTO",
  "visibility": "PUBLIC",
  "media": [
    {
      "mediaType": "IMAGE",
      "url": "https://minio.example.com/products/winter-collection.jpg",
      "thumbnailUrl": "https://minio.example.com/products/winter-collection-thumb.jpg",
      "sortOrder": 0
    }
  ],
  "tags": ["зима", "скидки", "одежда"],
  "placeIds": ["650e8400-e29b-41d4-a716-446655440001"]
}
```

**Response (201 Created):**
```json
{
  "id": "750e8400-e29b-41d4-a716-446655440002",
  "ownerType": "SHOP",
  "ownerId": "550e8400-e29b-41d4-a716-446655440000",
  "ownerName": "Fashion Store Bishkek",
  "text": "Новая коллекция зимней одежды! Скидки до 50%",
  "postType": "PHOTO",
  "geoLat": null,
  "geoLon": null,
  "visibility": "PUBLIC",
  "status": "ACTIVE",
  "likesCount": 0,
  "commentsCount": 0,
  "sharesCount": 0,
  "media": [...],
  "tags": ["зима", "скидки", "одежда"],
  "places": [...],
  "isLikedByCurrentUser": false,
  "createdAt": "2025-11-08T10:30:00Z",
  "updatedAt": "2025-11-08T10:30:00Z"
}
```

### 1.2 Получить публичную ленту
```http
GET /api/v1/social/feed/public?page=0&size=20
```

**Response (200 OK):**
```json
{
  "content": [
    {
      "id": "750e8400-e29b-41d4-a716-446655440002",
      "ownerType": "SHOP",
      "text": "Новая коллекция зимней одежды!",
      "likesCount": 125,
      "commentsCount": 18,
      "isLikedByCurrentUser": false,
      ...
    }
  ],
  "pageable": {...},
  "totalElements": 245,
  "totalPages": 13,
  "size": 20,
  "number": 0
}
```

### 1.3 Лайкнуть пост
```http
POST /api/v1/social/posts/{postId}/like
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
{
  "id": "850e8400-e29b-41d4-a716-446655440003",
  "postId": "750e8400-e29b-41d4-a716-446655440002",
  "userId": "450e8400-e29b-41d4-a716-446655440004",
  "userName": "user@example.com",
  "createdAt": "2025-11-08T10:35:00Z"
}
```

### 1.4 Добавить комментарий
```http
POST /api/v1/social/comments
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "postId": "750e8400-e29b-41d4-a716-446655440002",
  "text": "Отличные цены! Когда можно приехать посмотреть?"
}
```

**Response (201 Created):**
```json
{
  "id": "950e8400-e29b-41d4-a716-446655440005",
  "postId": "750e8400-e29b-41d4-a716-446655440002",
  "userId": "450e8400-e29b-41d4-a716-446655440004",
  "userName": "user@example.com",
  "text": "Отличные цены! Когда можно приехать посмотреть?",
  "isFlagged": false,
  "verifiedPurchase": true,
  "createdAt": "2025-11-08T10:40:00Z",
  "updatedAt": "2025-11-08T10:40:00Z"
}
```

---

## 2. Analytics Module (`/analytics`)

### 2.1 Отследить событие
```http
POST /api/v1/analytics/events
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "eventType": "shop_view",
  "userId": "450e8400-e29b-41d4-a716-446655440004",
  "targetId": "550e8400-e29b-41d4-a716-446655440000",
  "targetType": "SHOP",
  "context": {
    "source": "search",
    "referrer": "google"
  }
}
```

**Response (204 No Content)**

### 2.2 Получить метрики магазина за день
```http
GET /api/v1/analytics/shops/{shopId}/metrics/2025-11-08
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
{
  "id": "a50e8400-e29b-41d4-a716-446655440006",
  "shopId": "550e8400-e29b-41d4-a716-446655440000",
  "shopName": "Fashion Store Bishkek",
  "day": "2025-11-08",
  "views": 1542,
  "clicks": 287,
  "routeBuilds": 45,
  "chatsStarted": 23,
  "follows": 12,
  "unfollows": 2,
  "revenue": 125000.50,
  "createdAt": "2025-11-08T23:59:00Z"
}
```

### 2.3 Получить сводку метрик за период
```http
GET /api/v1/analytics/shops/{shopId}/metrics/summary?startDate=2025-11-01&endDate=2025-11-08
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
{
  "shopId": "550e8400-e29b-41d4-a716-446655440000",
  "shopName": "Fashion Store Bishkek",
  "startDate": "2025-11-01",
  "endDate": "2025-11-08",
  "totalViews": 12458,
  "totalClicks": 2341,
  "totalRouteBuilds": 342,
  "totalChatsStarted": 189,
  "totalFollows": 95,
  "totalUnfollows": 12,
  "totalRevenue": 985000.00,
  "avgViewsPerDay": 1557.25,
  "conversionRate": 18.79
}
```

### 2.4 Получить топ продуктов
```http
GET /api/v1/analytics/shops/{shopId}/top-products?startDate=2025-11-01&endDate=2025-11-08&sortBy=revenue&limit=10
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
[
  {
    "id": "b50e8400-e29b-41d4-a716-446655440007",
    "variantId": "c50e8400-e29b-41d4-a716-446655440008",
    "productName": "Зимняя куртка North Face",
    "variantSku": "NF-WJ-001-L-BLACK",
    "day": "2025-11-01",
    "views": 2341,
    "clicks": 456,
    "addToCart": 89,
    "orders": 45,
    "revenue": 225000.00,
    "createdAt": "2025-11-08T10:00:00Z"
  }
]
```

---

## 3. Ads Module (`/ads`)

### 3.1 Создать рекламную кампанию
```http
POST /api/v1/ads/campaigns
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "shopId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Зимняя распродажа 2025",
  "campaignType": "CPC",
  "startDate": "2025-11-10T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z",
  "budget": 50000.00,
  "dailyBudget": 2000.00,
  "targetAudience": {
    "cities": ["Бишкек", "Ош"],
    "ageRange": "18-45",
    "interests": ["мода", "одежда"]
  }
}
```

**Response (201 Created):**
```json
{
  "id": "d50e8400-e29b-41d4-a716-446655440009",
  "shopId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Зимняя распродажа 2025",
  "campaignType": "CPC",
  "status": "DRAFT",
  "budget": 50000.00,
  "spent": 0.00,
  "dailyBudget": 2000.00,
  "startDate": "2025-11-10T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z",
  "targetAudience": {...},
  "createdAt": "2025-11-08T11:00:00Z"
}
```

### 3.2 Записать событие рекламы
```http
POST /api/v1/ads/events
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "campaignId": "d50e8400-e29b-41d4-a716-446655440009",
  "day": "2025-11-10",
  "impressions": 1000,
  "clicks": 45,
  "spend": 1800.00
}
```

**Response (204 No Content)**

---

## 4. Chat Module (`/chat`)

### 4.1 Отправить сообщение
```http
POST /api/v1/chat/messages
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "recipientId": "e50e8400-e29b-41d4-a716-446655440010",
  "messageText": "Здравствуйте! Интересует зимняя куртка размера L. Есть в наличии?"
}
```

**Response (200 OK):**
```json
{
  "id": "f50e8400-e29b-41d4-a716-446655440011",
  "conversationId": "0123456789abcdef0123456789abcdef",
  "senderId": "450e8400-e29b-41d4-a716-446655440004",
  "senderName": "buyer@example.com",
  "recipientId": "e50e8400-e29b-41d4-a716-446655440010",
  "recipientName": "seller@example.com",
  "messageText": "Здравствуйте! Интересует зимняя куртка размера L. Есть в наличии?",
  "isRead": false,
  "isFlagged": false,
  "createdAt": "2025-11-08T11:15:00Z"
}
```

### 4.2 Получить сообщения в диалоге
```http
GET /api/v1/chat/conversations/{conversationId}/messages?page=0&size=50
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
{
  "content": [
    {
      "id": "f50e8400-e29b-41d4-a716-446655440011",
      "conversationId": "0123456789abcdef0123456789abcdef",
      "messageText": "Да, есть в наличии. Цена 15000 сом.",
      "isRead": true,
      ...
    }
  ],
  "totalElements": 8,
  "totalPages": 1,
  "size": 50,
  "number": 0
}
```

### 4.3 Получить все диалоги
```http
GET /api/v1/chat/conversations
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
[
  {
    "conversationId": "0123456789abcdef0123456789abcdef",
    "otherUserId": "e50e8400-e29b-41d4-a716-446655440010",
    "otherUserName": "seller@example.com",
    "lastMessage": "Да, есть в наличии. Цена 15000 сом.",
    "lastMessageAt": "2025-11-08T11:20:00Z",
    "unreadCount": 2
  }
]
```

### 4.4 Отметить сообщение как прочитанное
```http
PATCH /api/v1/chat/messages/{messageId}/read
Authorization: Bearer {jwt_token}
```

**Response (204 No Content)**

### 4.5 Получить количество непрочитанных
```http
GET /api/v1/chat/unread-count
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
{
  "count": 5
}
```

---

## 5. Media Module (`/media`)

### 5.1 Сгенерировать URL для загрузки
```http
POST /api/v1/media/upload-url
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "fileName": "winter-jacket-front.jpg",
  "folder": "products"
}
```

**Response (200 OK):**
```json
{
  "uploadUrl": "http://localhost:9000/fucent-media/products/550e8400-e29b-41d4-a716-winter-jacket-front.jpg?X-Amz-Algorithm=...",
  "fileKey": "products/550e8400-e29b-41d4-a716-winter-jacket-front.jpg",
  "publicUrl": "http://localhost:9000/fucent-media/products/550e8400-e29b-41d4-a716-winter-jacket-front.jpg",
  "expiresAt": "2025-11-08T11:45:00Z"
}
```

**Затем загрузите файл через PUT запрос:**
```http
PUT {uploadUrl}
Content-Type: image/jpeg
Body: [binary file data]
```

### 5.2 Удалить медиафайл
```http
DELETE /api/v1/media/{fileKey}
Authorization: Bearer {jwt_token}
```

**Response (204 No Content)**

### 5.3 Получить публичный URL
```http
GET /api/v1/media/url/{fileKey}
```

**Response (200 OK):**
```
http://localhost:9000/fucent-media/products/550e8400-e29b-41d4-a716-winter-jacket-front.jpg
```

---

## 6. Notifications Module (`/notifications`)

### 6.1 Получить настройки уведомлений
```http
GET /api/v1/notifications/preferences/USER/{userId}
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
[
  {
    "id": "g50e8400-e29b-41d4-a716-446655440012",
    "ownerType": "USER",
    "ownerId": "450e8400-e29b-41d4-a716-446655440004",
    "channel": "PUSH",
    "enableOrderUpdates": true,
    "enablePromotions": true,
    "enableChatMessages": true,
    "enableSystemAlerts": true,
    "createdAt": "2025-11-08T10:00:00Z"
  }
]
```

### 6.2 Обновить настройки уведомлений
```http
PUT /api/v1/notifications/preferences/USER/{userId}
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "channel": "PUSH",
  "enableOrderUpdates": true,
  "enablePromotions": false,
  "enableChatMessages": true,
  "enableSystemAlerts": true
}
```

**Response (200 OK):**
```json
{
  "id": "g50e8400-e29b-41d4-a716-446655440012",
  "ownerType": "USER",
  "ownerId": "450e8400-e29b-41d4-a716-446655440004",
  "channel": "PUSH",
  "enableOrderUpdates": true,
  "enablePromotions": false,
  "enableChatMessages": true,
  "enableSystemAlerts": true,
  "updatedAt": "2025-11-08T12:00:00Z"
}
```

### 6.3 Отправить уведомление (Admin/Seller)
```http
POST /api/v1/notifications/send
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "channel": "PUSH",
  "recipient": "user@example.com",
  "templateKey": "order_confirmed",
  "payloadJson": {
    "orderId": "h50e8400-e29b-41d4-a716-446655440013",
    "orderTotal": "15000 сом"
  }
}
```

**Response (202 Accepted)**

---

## Обработка ошибок

### Validation Error (400)
```json
{
  "status": 400,
  "message": "Validation failed",
  "errors": {
    "fileName": "must not be blank",
    "folder": "must not be blank"
  },
  "timestamp": "2025-11-08T12:05:00Z"
}
```

### Resource Not Found (404)
```json
{
  "status": 404,
  "message": "Shop not found with id: 550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2025-11-08T12:06:00Z"
}
```

### Unauthorized (403)
```json
{
  "status": 403,
  "message": "You can only delete your own comments",
  "timestamp": "2025-11-08T12:07:00Z"
}
```

### Media Storage Error (500)
```json
{
  "status": 500,
  "message": "Failed to generate upload URL",
  "timestamp": "2025-11-08T12:08:00Z"
}
```

---

## Типы событий аналитики

### События магазина:
- `shop_view` - Просмотр страницы магазина
- `shop_click` - Клик на магазин
- `shop_route_build` - Построение маршрута к магазину
- `shop_chat_started` - Начало чата с магазином
- `shop_follow` - Подписка на магазин
- `shop_unfollow` - Отписка от магазина

### События продукта:
- `product_view` - Просмотр товара
- `product_click` - Клик на товар
- `product_add_to_cart` - Добавление в корзину

---

## Роли и права доступа

| Endpoint | BUYER | SELLER | ADMIN |
|----------|-------|--------|-------|
| POST /social/posts | ✓ | ✓ | ✓ |
| DELETE /social/posts/{id} | own | own | ✓ |
| POST /ads/campaigns | ✗ | ✓ | ✓ |
| POST /notifications/send | ✗ | ✓ | ✓ |
| POST /notifications/templates | ✗ | ✗ | ✓ |
| GET /analytics/** | own | own | ✓ |

---

## Rate Limiting

Все эндпоинты имеют лимиты:
- **Аутентифицированные пользователи**: 1000 запросов/час
- **Неаутентифицированные**: 100 запросов/час

Headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 995
X-RateLimit-Reset: 1699456800
```
