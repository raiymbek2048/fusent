# Test Accounts

Эти учетные записи автоматически создаются при первом запуске приложения.

## Администратор

**Email:** admin@fusent.kg
**Password:** admin123
**Role:** ADMIN

## Продавцы (Sellers)

### Fashion Store Bishkek
**Email:** fashion.store@fusent.kg
**Password:** seller123
**Role:** SELLER
**Shop:** Fashion Store Bishkek (Одежда)
**Address:** ТЦ Дордой, 2-этаж, бутик 245
**Products:** Зимние куртки, джинсы, платья

### TechnoWorld KG
**Email:** tech.shop@fusent.kg
**Password:** seller123
**Role:** SELLER
**Shop:** TechnoWorld KG (Электроника)
**Address:** пр. Чуй 156, ТЦ Vefa Center
**Products:** iPhone 15 Pro, Samsung S24 Ultra, AirPods Pro 2

### Уютный Дом
**Email:** home.decor@fusent.kg
**Password:** seller123
**Role:** SELLER
**Shop:** Уютный Дом (Дом и интерьер)
**Address:** ул. Токтогула 123
**Products:** Диваны, посуда

## Покупатели (Buyers)

**Email:** buyer1@test.kg - buyer5@test.kg
**Password:** buyer123
**Role:** BUYER

---

## Тестовые данные

### Категории (5):
- Одежда
- Электроника
- Дом и интерьер
- Обувь
- Спорт и отдых

### Магазины (3):
1. Fashion Store Bishkek
2. TechnoWorld KG
3. Уютный Дом

### Продукты (8):
- Зимняя куртка North Face (4 размера)
- Джинсы Levi's 501 (3 варианта)
- Платье вечернее (2 размера)
- iPhone 15 Pro (2 варианта)
- Samsung Galaxy S24 Ultra (2 варианта)
- AirPods Pro 2
- Диван угловой (2 цвета)
- Набор посуды Luminarc

### Посты в социальной ленте (7):
- Акции и новинки от магазинов
- С лайками и комментариями от покупателей

---

## Быстрый тест API

### 1. Логин как покупатель
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "buyer1@test.kg",
    "password": "buyer123"
  }'
```

### 2. Логин как продавец
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "fashion.store@fusent.kg",
    "password": "seller123"
  }'
```

### 3. Логин как админ
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@fusent.kg",
    "password": "admin123"
  }'
```

### 4. Получить публичную ленту (без авторизации)
```bash
curl http://localhost:8080/api/v1/social/feed/public?page=0&size=20
```

---

## Примечания

- Все пароли одинаковые для удобства тестирования
- В production обязательно использовать сложные пароли
- Seed data запускается только если база данных пустая
- Для пересоздания данных: `docker-compose down -v && docker-compose up -d`
