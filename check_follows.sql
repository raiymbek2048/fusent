-- Проверка данных подписок и постов

-- 1. Проверяем всех пользователей
SELECT id, email, role FROM app_user ORDER BY created_at;

-- 2. Проверяем всех мерчантов
SELECT id, owner_id, name FROM merchant ORDER BY created_at;

-- 3. Проверяем все подписки
SELECT
    f.id,
    f.follower_id,
    u.email as follower_email,
    f.target_type,
    f.target_id,
    f.created_at
FROM follow f
JOIN app_user u ON f.follower_id = u.id
ORDER BY f.created_at DESC;

-- 4. Проверяем все посты
SELECT
    p.id,
    p.owner_type,
    p.owner_id,
    CASE
        WHEN p.owner_type = 'MERCHANT' THEN m.name
        WHEN p.owner_type = 'USER' THEN u.email
        ELSE 'Unknown'
    END as owner_name,
    p.text,
    p.status,
    p.created_at
FROM post p
LEFT JOIN merchant m ON p.owner_type = 'MERCHANT' AND p.owner_id = m.id
LEFT JOIN app_user u ON p.owner_type = 'USER' AND p.owner_id = u.id
ORDER BY p.created_at DESC;

-- 5. Проверяем подписки конкретного пользователя (customer@fusent.kg)
-- и посты от тех, на кого подписан
SELECT
    'Подписки пользователя' as info,
    f.target_type,
    f.target_id,
    CASE
        WHEN f.target_type = 'MERCHANT' THEN m.name
        WHEN f.target_type = 'USER' THEN u2.email
    END as target_name
FROM follow f
JOIN app_user u1 ON f.follower_id = u1.id AND u1.email = 'customer@fusent.kg'
LEFT JOIN merchant m ON f.target_type = 'MERCHANT' AND f.target_id = m.id
LEFT JOIN app_user u2 ON f.target_type = 'USER' AND f.target_id = u2.id;

-- 6. Посты от подписок customer@fusent.kg
SELECT
    'Посты от подписок' as info,
    p.id,
    p.owner_type,
    p.owner_id,
    CASE
        WHEN p.owner_type = 'MERCHANT' THEN m.name
        WHEN p.owner_type = 'USER' THEN u_owner.email
    END as owner_name,
    p.text,
    p.status
FROM post p
LEFT JOIN merchant m ON p.owner_type = 'MERCHANT' AND p.owner_id = m.id
LEFT JOIN app_user u_owner ON p.owner_type = 'USER' AND p.owner_id = u_owner.id
WHERE EXISTS (
    SELECT 1 FROM follow f
    JOIN app_user u_follower ON f.follower_id = u_follower.id
    WHERE u_follower.email = 'customer@fusent.kg'
    AND (
        (f.target_type = 'MERCHANT' AND p.owner_type = 'MERCHANT' AND p.owner_id = f.target_id)
        OR
        (f.target_type = 'USER' AND p.owner_type = 'USER' AND p.owner_id = f.target_id)
    )
)
AND p.status = 'ACTIVE'
ORDER BY p.created_at DESC;
