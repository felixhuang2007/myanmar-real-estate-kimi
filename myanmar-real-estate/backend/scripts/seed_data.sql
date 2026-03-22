-- 缅甸房产平台 - 测试数据种子
-- 执行: psql -h localhost -U myanmar_property -d myanmarhome -f seed_data.sql

BEGIN;

-- 1. 插入测试用户
INSERT INTO users (phone, password_hash, user_type, status, created_at, updated_at)
VALUES
('+95111111111', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjXAgN0sXZJ7L8sXq8QzE3qqNj6CJQG', 'individual', 'active', NOW(), NOW()),
('+95222222222', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjXAgN0sXZJ7L8sXq8QzE3qqNj6CJQG', 'individual', 'active', NOW(), NOW()),
('+95333333333', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjXAgN0sXZJ7L8sXq8QzE3qqNj6CJQG', 'individual', 'active', NOW(), NOW()),
('+95444444444', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjXAgN0sXZJ7L8sXq8QzE3qqNj6CJQG', 'individual', 'active', NOW(), NOW());

-- 2. 插入用户资料
INSERT INTO user_profiles (user_id, nickname, avatar, created_at, updated_at)
SELECT
    id,
    CASE phone
        WHEN '+95111111111' THEN '测试买家1'
        WHEN '+95222222222' THEN '测试买家2'
        WHEN '+95333333333' THEN '李经纪人'
        WHEN '+95444444444' THEN '王经纪人'
    END,
    'https://example.com/avatar.jpg',
    NOW(),
    NOW()
FROM users;

-- 3. 插入经纪公司
INSERT INTO companies (name, license_number, address, contact_phone, status, created_at)
VALUES
('仰光房产中介有限公司', 'YG-2024-001', '仰光市中心区', '+9511111111', 'active', NOW()),
('曼德勒置业集团', 'MDL-2024-002', '曼德勒商业区', '+9522222222', 'active', NOW());

-- 4. 插入经纪人信息
INSERT INTO agents (user_id, company_id, employee_number, real_name, work_city, status, created_at)
SELECT
    u.id,
    c.id,
    'AGT' || LPAD(ROW_NUMBER() OVER ()::TEXT, 4, '0'),
    p.nickname,
    'YG',
    'active',
    NOW()
FROM users u
JOIN user_profiles p ON p.user_id = u.id
CROSS JOIN (SELECT id FROM companies ORDER BY id LIMIT 1) c
WHERE u.phone IN ('+95333333333', '+95444444444');

-- 5. 城市数据已在 schema 中插入，跳过

-- 6. 插入区/县
INSERT INTO districts (city_id, code, name, name_en, is_active)
SELECT
    c.id,
    'DIST' || ROW_NUMBER() OVER (),
    d.name,
    d.name_en,
    true
FROM cities c
CROSS JOIN LATERAL (
    SELECT * FROM (VALUES
        ('市中心区', 'Downtown'),
        ('北市区', 'North District'),
        ('南市区', 'South District'),
        ('东市区', 'East District'),
        ('西市区', 'West District')
    ) AS t(name, name_en)
) d
WHERE c.code = 'YG';

-- 7. 插入小区
INSERT INTO communities (district_id, name, name_en, address, build_year, property_type, total_units, status, created_at)
SELECT
    d.id,
    '翡翠花园' || d.name,
    'Jade Garden ' || d.name_en,
    d.name || '123号',
    2015 + (d.id % 5),
    CASE WHEN d.id % 3 = 0 THEN 'apartment' WHEN d.id % 3 = 1 THEN 'villa' ELSE 'condo' END,
    100 + (d.id * 50),
    'active',
    NOW()
FROM districts d
WHERE d.city_id = (SELECT id FROM cities WHERE code = 'YG' LIMIT 1)
LIMIT 5;

-- 8. 插入测试房源
INSERT INTO houses (
    house_code, title, description,
    city_id, district_id, community_id,
    transaction_type, price, price_unit,
    house_type, area, bedrooms, bathrooms,
    address, latitude, longitude,
    orientation, decoration,
    status, entrant_id, created_at
)
SELECT
    'HS' || LPAD(ROW_NUMBER() OVER ()::TEXT, 6, '0'),
    CASE
        WHEN i % 5 = 0 THEN '豪华公寓 - 仰光市中心'
        WHEN i % 5 = 1 THEN '精装别墅 - 花园社区'
        WHEN i % 5 = 2 THEN '海景公寓 - 一线海景'
        WHEN i % 5 = 3 THEN '商业写字楼 - 黄金地段'
        ELSE '联排别墅 - 学区房源'
    END,
    '优质房源，地段优越，交通便利，配套设施完善。欢迎咨询看房。',
    (SELECT id FROM cities WHERE code = 'YG'),
    (SELECT id FROM districts WHERE city_id = (SELECT id FROM cities WHERE code = 'YG') LIMIT 1 OFFSET (i % 5)),
    (SELECT id FROM communities ORDER BY id LIMIT 1 OFFSET (i % 5)),
    CASE WHEN i % 2 = 0 THEN 'sale' ELSE 'rent' END,
    50000000 + (i * 10000000),
    'MMK',
    CASE WHEN i % 3 = 0 THEN 'apartment' WHEN i % 3 = 1 THEN 'house' ELSE 'townhouse' END,
    80 + (i * 10),
    2 + (i % 4),
    1 + (i % 3),
    '仰光市中心区' || i || '号',
    16.8661 + (i * 0.001),
    96.1951 + (i * 0.001),
    CASE WHEN i % 4 = 0 THEN 'south' WHEN i % 4 = 1 THEN 'north' WHEN i % 4 = 2 THEN 'east' ELSE 'west' END,
    CASE WHEN i % 3 = 0 THEN 'luxury' WHEN i % 3 = 1 THEN 'fine' ELSE 'simple' END,
    CASE WHEN i % 10 = 0 THEN 'pending' ELSE 'online' END,
    (SELECT id FROM agents LIMIT 1),
    NOW() - INTERVAL '1 day' * i
FROM generate_series(1, 50) AS i;

-- 9. 插入用户收藏
INSERT INTO user_favorites (user_id, house_id, created_at)
SELECT
    u.id,
    h.id,
    NOW()
FROM users u
CROSS JOIN houses h
WHERE u.phone IN ('+95111111111', '+95222222222') AND h.id <= 10
ORDER BY RANDOM()
LIMIT 20;

COMMIT;

-- 验证数据插入
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'User Profiles', COUNT(*) FROM user_profiles
UNION ALL
SELECT 'Agents', COUNT(*) FROM agents
UNION ALL
SELECT 'Companies', COUNT(*) FROM companies
UNION ALL
SELECT 'Cities', COUNT(*) FROM cities
UNION ALL
SELECT 'Districts', COUNT(*) FROM districts
UNION ALL
SELECT 'Communities', COUNT(*) FROM communities
UNION ALL
SELECT 'Houses', COUNT(*) FROM houses
UNION ALL
SELECT 'User Favorites', COUNT(*) FROM user_favorites;
