# План тестирования подписок и ленты

## Проблема
Лента подписок (following feed) не возвращает посты от тех, на кого подписан пользователь.

## Что проверили

### 1. Схема БД (V2__social_module.sql, V17__fix_follow_constraint_to_uppercase.sql)
```sql
CREATE TABLE follow (
    id UUID PRIMARY KEY,
    follower_id UUID NOT NULL REFERENCES app_user(id),
    target_type VARCHAR(20) NOT NULL,  -- 'MERCHANT' или 'USER'
    target_id UUID NOT NULL,
    created_at TIMESTAMP,
    CONSTRAINT chk_follow_target_type CHECK (target_type IN ('MERCHANT', 'USER')),
    CONSTRAINT uq_follow UNIQUE (follower_id, target_type, target_id)
);
```
✅ **Схема корректна**

### 2. Сущность Follow (Follow.java)
```java
@Entity
public class Follow {
    @Id private UUID id;
    @ManyToOne private AppUser follower;
    @Enumerated(EnumType.STRING) private FollowTargetType targetType;
    private UUID targetId;
    private Instant createdAt;
}
```
✅ **Сущность корректна**, использует EnumType.STRING

### 3. Query для ленты подписок (PostRepository.java:24-45)
```java
@Query("""
    SELECT DISTINCT p FROM Post p
    WHERE EXISTS (
        SELECT 1 FROM Follow f
        WHERE f.follower.id = :followerId
        AND (
            (f.targetType = kg.bishkek.fucent.fusent.enums.FollowTargetType.MERCHANT
             AND p.ownerType = kg.bishkek.fucent.fusent.enums.OwnerType.MERCHANT
             AND p.ownerId = f.targetId)
            OR
            (f.targetType = kg.bishkek.fucent.fusent.enums.FollowTargetType.USER
             AND p.ownerType = kg.bishkek.fucent.fusent.enums.OwnerType.USER
             AND p.ownerId = f.targetId)
        )
    )
    AND p.status = :status
    """)
Page<Post> findFollowingFeedByUser(@Param("followerId") UUID followerId,
                                    @Param("status") PostStatus status,
                                    Pageable pageable);
```
✅ **Query выглядит правильно**

## Endpoints для тестирования

Создали debug endpoints для проверки:

### 1. Проверка данных текущего пользователя
```bash
GET /api/debug/follows-check
Authorization: Bearer <token>
```
**Возвращает:**
- Информацию о текущем пользователе
- Все подписки пользователя
- Все посты в системе
- Посты от подписок (через репозиторий)
- Посты от подписок (через native SQL)
- Прямую проверку первой подписки

### 2. Все подписки в системе
```bash
GET /api/debug/all-follows
Authorization: Bearer <token>
```
**Возвращает:**
- Все подписки во всей системе
- Всех пользователей

### 3. Создать подписку на seller
```bash
POST /api/test-data/follow-seller
Authorization: Bearer <token>
```
**Создает:**
- Подписку на MERCHANT (магазин seller'а)
- Подписку на USER (seller как пользователя)

### 4. Создать тестовые посты
```bash
POST /api/test-data/create-test-posts
Authorization: Bearer <token>
```
**Создает:**
- Пост от MERCHANT (магазин)
- Пост от USER (seller)

### 5. Очистить подписки
```bash
DELETE /api/test-data/cleanup
Authorization: Bearer <token>
```
**Удаляет все подписки текущего пользователя**

## Шаги для тестирования

1. **Запустить приложение**
   ```bash
   ./mvnw spring-boot:run
   ```

2. **Авторизоваться как customer**
   ```bash
   POST /api/auth/login
   {
     "email": "customer@fusent.kg",
     "password": "Customer123!"
   }
   ```
   Сохранить токен.

3. **Проверить текущее состояние**
   ```bash
   curl -H "Authorization: Bearer <token>" http://localhost:8080/api/debug/follows-check
   ```

4. **Создать подписку на seller**
   ```bash
   curl -X POST -H "Authorization: Bearer <token>" http://localhost:8080/api/test-data/follow-seller
   ```

5. **Создать тестовые посты**
   ```bash
   curl -X POST -H "Authorization: Bearer <token>" http://localhost:8080/api/test-data/create-test-posts
   ```

6. **Снова проверить состояние**
   ```bash
   curl -H "Authorization: Bearer <token>" http://localhost:8080/api/debug/follows-check
   ```

7. **Проверить ленту подписок через основной API**
   ```bash
   curl -H "Authorization: Bearer <token>" "http://localhost:8080/api/feed/following?page=0&size=20"
   ```

## Что искать в результатах

### В `/api/debug/follows-check`:
- `myFollows` - должны быть 2 подписки (MERCHANT и USER)
- `allPosts` - должны быть посты
- `followingFeedPosts` - **должны быть те же посты что и в manualQueryResults**
- `manualQueryResults` - результаты прямого SQL запроса
- Если `followingFeedPosts` пустой, но `manualQueryResults` содержит данные - проблема в JPQL query
- Если оба пустые, но есть подписки и посты - проблема в логике join

### Возможные причины проблемы:

1. **Нет подписок** - пользователь не подписался
2. **Нет постов** - нет активных постов от тех, на кого подписан
3. **Несоответствие типов** - например, подписка на MERCHANT, но пост создан от USER или наоборот
4. **Статус постов** - посты не ACTIVE
5. **Query проблема** - JPQL не работает корректно

## Как исправить если найдена проблема

### Если проблема в Query:
Заменить на более простой JOIN запрос:
```java
@Query("""
    SELECT DISTINCT p FROM Post p
    JOIN Follow f ON
        (f.targetType = 'MERCHANT' AND p.ownerType = 'MERCHANT' AND p.ownerId = f.targetId)
        OR
        (f.targetType = 'USER' AND p.ownerType = 'USER' AND p.ownerId = f.targetId)
    WHERE f.follower.id = :followerId
    AND p.status = :status
    ORDER BY p.createdAt DESC
    """)
```

### Если проблема в типах:
Убедиться что:
- В БД: `target_type` = 'MERCHANT' или 'USER' (uppercase)
- В БД: `owner_type` = 'MERCHANT' или 'USER' (uppercase)
- Enum значения совпадают с БД значениями
