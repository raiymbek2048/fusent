# Резюме проверки ленты подписок

## Что было проверено

### ✅ 1. Схема БД
- Таблица `follow` создана правильно
- Поля: `follower_id`, `target_type` ('MERCHANT'/'USER'), `target_id`
- Миграция V17 обновила constraint на uppercase значения

### ✅ 2. Модель Follow
- Сущность использует `@Enumerated(EnumType.STRING)`
- Правильная связь с `AppUser` через `@ManyToOne`
- Все поля корректны

### ✅ 3. Логика подписки (FollowServiceImpl)
- Метод `follow()` правильно создает записи в БД
- Проверяет существование цели (merchant/user)
- Проверяет дубликаты подписок

### ✅ 4. Query для ленты (PostRepository)
```java
@Query("""
    SELECT DISTINCT p FROM Post p
    WHERE EXISTS (
        SELECT 1 FROM Follow f
        WHERE f.follower.id = :followerId
        AND (
            (f.targetType = MERCHANT AND p.ownerType = MERCHANT AND p.ownerId = f.targetId)
            OR
            (f.targetType = USER AND p.ownerType = USER AND p.ownerId = f.targetId)
        )
    )
    AND p.status = :status
    """)
```
**Query выглядит правильно** - использует EXISTS с правильным сопоставлением типов.

### ✅ 5. Endpoint
- `/api/feed/following` - правильно вызывает `postService.getFollowingFeed()`
- Использует пагинацию и сортировку по дате создания

## Созданные инструменты для диагностики

### 1. DebugController (`/api/debug/`)
- `GET /follows-check` - полная диагностика подписок и постов
- `GET /all-follows` - все подписки в системе

### 2. TestDataController (`/api/test-data/`)
- `POST /follow-seller` - создать подписку на тестового seller
- `POST /create-test-posts` - создать тестовые посты
- `DELETE /cleanup` - удалить все подписки текущего пользователя

### 3. SQL скрипт
- `check_follows.sql` - SQL запросы для проверки БД напрямую

## Возможные причины проблемы

Если лента подписок пустая, причины могут быть:

### 1. Нет данных
- ❓ Пользователь не подписался ни на кого
- ❓ Нет активных постов от тех, на кого подписан

### 2. Проблема с типами
- ❓ Подписка на MERCHANT, но пост создан от USER с тем же ownerId
- ❓ Несоответствие между `target_type` в follow и `owner_type` в post

### 3. Проблема со статусом
- ❓ Посты не в статусе ACTIVE

### 4. Проблема с Query
- ❓ JPQL query не работает корректно (маловероятно, код выглядит правильно)

## Следующие шаги

1. **Запустить приложение**
2. **Авторизоваться как customer@fusent.kg**
3. **Выполнить:**
   ```bash
   # Проверить текущее состояние
   GET /api/debug/follows-check

   # Создать подписку
   POST /api/test-data/follow-seller

   # Создать тестовые посты
   POST /api/test-data/create-test-posts

   # Снова проверить
   GET /api/debug/follows-check

   # Проверить основную ленту
   GET /api/feed/following?page=0&size=20
   ```

4. **Анализировать результаты:**
   - Сравнить `followingFeedPosts` и `manualQueryResults`
   - Если оба пустые - проблема с данными
   - Если manual работает, а JPQL нет - проблема с query
   - Если есть подписки и посты, но `directMatchCheck` не находит совпадений - проблема с типами

## Файлы

- `TESTING_FOLLOWS.md` - подробная инструкция
- `check_follows.sql` - SQL запросы для БД
- `DebugController.java` - endpoints для диагностики
- `TestDataController.java` - endpoints для создания тестовых данных
