-- ============================================================
-- 缅甸房产平台数据库Schema
-- 数据库：PostgreSQL 15
-- 设计日期：2026-03-17
-- 版本：v1.0
-- ============================================================

-- 扩展启用
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- 1. 用户模块 (User Module)
-- ============================================================

-- 用户基础表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255),
    password_hash VARCHAR(255),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'deleted')),
    user_type VARCHAR(20) DEFAULT 'individual' CHECK (user_type IN ('individual', 'company', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    login_count INT DEFAULT 0
);

-- 用户实名认证表
CREATE TABLE user_verifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    real_name VARCHAR(100) NOT NULL,
    id_card_number VARCHAR(50) NOT NULL,
    id_card_front VARCHAR(500) NOT NULL,
    id_card_back VARCHAR(500),
    face_recognition_photo VARCHAR(500),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    reject_reason TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 用户资料表
CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    nickname VARCHAR(100),
    avatar VARCHAR(500),
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other', 'unknown')),
    birthday DATE,
    bio TEXT,
    preferred_city VARCHAR(50),
    preferred_districts VARCHAR(255),
    budget_min BIGINT,
    budget_max BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 用户第三方登录表
CREATE TABLE user_oauths (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(20) NOT NULL CHECK (provider IN ('facebook', 'google', 'apple')),
    provider_user_id VARCHAR(255) NOT NULL,
    provider_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider, provider_user_id)
);

-- 用户设备表
CREATE TABLE user_devices (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    device_type VARCHAR(20) CHECK (device_type IN ('ios', 'android', 'web', 'other')),
    device_model VARCHAR(100),
    os_version VARCHAR(50),
    app_version VARCHAR(50),
    push_token VARCHAR(500),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, device_id)
);

-- 用户收藏表
CREATE TABLE user_favorites (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    house_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, house_id)
);

-- 用户浏览历史表
CREATE TABLE user_browsing_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    house_id BIGINT NOT NULL,
    view_count INT DEFAULT 1,
    last_viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, house_id)
);

-- 短信验证码表
CREATE TABLE sms_verification_codes (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(20) NOT NULL,
    code VARCHAR(10) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('register', 'login', 'reset_password', 'bind_phone')),
    expired_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    attempt_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. 经纪人模块 (Agent Module)
-- ============================================================

-- 门店/公司表
CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    license_number VARCHAR(100),
    address TEXT,
    city VARCHAR(50),
    district VARCHAR(50),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    logo VARCHAR(500),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 经纪人表
CREATE TABLE agents (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    company_id BIGINT REFERENCES companies(id),
    employee_number VARCHAR(50),
    real_name VARCHAR(100) NOT NULL,
    id_card_number VARCHAR(50),
    license_number VARCHAR(100),
    work_city VARCHAR(50) NOT NULL,
    work_districts VARCHAR(255),
    avatar VARCHAR(500),
    bio TEXT,
    specialties VARCHAR(255),
    service_areas VARCHAR(255),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'suspended', 'resigned')),
    level VARCHAR(20) DEFAULT 'junior' CHECK (level IN ('junior', 'intermediate', 'senior', 'expert')),
    rating DECIMAL(2,1) DEFAULT 5.0,
    total_deals INT DEFAULT 0,
    total_gmv BIGINT DEFAULT 0,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 经纪人业绩统计表
CREATE TABLE agent_statistics (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT REFERENCES agents(id) ON DELETE CASCADE,
    stat_date DATE NOT NULL,
    new_houses INT DEFAULT 0,
    new_clients INT DEFAULT 0,
    showings_count INT DEFAULT 0,
    deals_count INT DEFAULT 0,
    gmv BIGINT DEFAULT 0,
    commission BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(agent_id, stat_date)
);

-- 团队表
CREATE TABLE teams (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT REFERENCES companies(id),
    leader_id BIGINT REFERENCES agents(id),
    name VARCHAR(200) NOT NULL,
    city VARCHAR(50),
    district VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 团队成员表
CREATE TABLE team_members (
    id BIGSERIAL PRIMARY KEY,
    team_id BIGINT REFERENCES teams(id) ON DELETE CASCADE,
    agent_id BIGINT REFERENCES agents(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('leader', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, agent_id)
);

-- ============================================================
-- 3. 房源模块 (House Module)
-- ============================================================

-- 城市表
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    name_my VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- 镇区/区域表
CREATE TABLE districts (
    id SERIAL PRIMARY KEY,
    city_id INT REFERENCES cities(id),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    name_my VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(city_id, code)
);

-- 商圈/小区表
CREATE TABLE communities (
    id BIGSERIAL PRIMARY KEY,
    district_id INT REFERENCES districts(id),
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    name_my VARCHAR(200),
    alias VARCHAR(500),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    build_year INT,
    total_buildings INT,
    total_units INT,
    property_type VARCHAR(50),
    developer VARCHAR(200),
    property_company VARCHAR(200),
    property_fee DECIMAL(10, 2),
    avg_price BIGINT,
    facilities JSONB,
    images JSONB,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 房源主表
CREATE TABLE houses (
    id BIGSERIAL PRIMARY KEY,
    house_code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    title_my VARCHAR(500),
    
    -- 交易类型和价格
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('sale', 'rent')),
    price BIGINT NOT NULL,
    price_unit VARCHAR(20) NOT NULL,
    price_note VARCHAR(255),
    original_price BIGINT,
    price_change_reason VARCHAR(255),
    
    -- 房源类型
    house_type VARCHAR(50) NOT NULL CHECK (house_type IN ('apartment', 'house', 'townhouse', 'land', 'commercial', 'office')),
    property_type VARCHAR(50) CHECK (property_type IN ('grant', 'license', 'contract', 'other')),
    
    -- 面积和户型
    area DECIMAL(10, 2) NOT NULL,
    usable_area DECIMAL(10, 2),
    rooms VARCHAR(20),
    bedrooms INT,
    living_rooms INT,
    bathrooms INT,
    kitchens INT,
    
    -- 楼层信息
    floor VARCHAR(20),
    total_floors INT,
    floor_type VARCHAR(20) CHECK (floor_type IN ('low', 'middle', 'high')),
    has_elevator BOOLEAN,
    
    -- 装修和朝向
    decoration VARCHAR(20) CHECK (decoration IN ('rough', 'simple', 'fine', 'luxury')),
    orientation VARCHAR(20),
    build_year INT,
    
    -- 位置信息
    city_id INT REFERENCES cities(id),
    district_id INT REFERENCES districts(id),
    community_id BIGINT REFERENCES communities(id),
    address TEXT NOT NULL,
    address_my TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- 特色描述
    description TEXT,
    description_my TEXT,
    highlights JSONB,
    facilities JSONB,
    
    -- 产权信息
    ownership_type VARCHAR(50),
    owner_name VARCHAR(100),
    owner_phone VARCHAR(20),
    owner_id_card VARCHAR(50),
    has_loan BOOLEAN DEFAULT FALSE,
    loan_amount BIGINT,
    property_certificate_no VARCHAR(100),
    
    -- 状态和归属
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'online', 'offline', 'sold', 'rented', 'expired')),
    entrant_id BIGINT REFERENCES agents(id),
    maintainer_id BIGINT REFERENCES agents(id),
    company_id BIGINT REFERENCES companies(id),
    
    -- 验真信息
    verification_status VARCHAR(20) DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'verifying', 'verified', 'failed')),
    verified_at TIMESTAMP WITH TIME ZONE,
    verifier_id BIGINT REFERENCES agents(id),
    
    -- 推广信息
    is_featured BOOLEAN DEFAULT FALSE,
    is_urgent BOOLEAN DEFAULT FALSE,
    featured_until TIMESTAMP WITH TIME ZONE,
    view_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    inquiry_count INT DEFAULT 0,
    showing_count INT DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP WITH TIME ZONE,
    offline_at TIMESTAMP WITH TIME ZONE
);

-- 房源图片表
CREATE TABLE house_images (
    id BIGSERIAL PRIMARY KEY,
    house_id BIGINT REFERENCES houses(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    type VARCHAR(20) DEFAULT 'interior' CHECK (type IN ('exterior', 'interior', 'floor_plan', 'community', 'property_doc')),
    sort_order INT DEFAULT 0,
    description VARCHAR(255),
    is_main BOOLEAN DEFAULT FALSE,
    uploaded_by BIGINT REFERENCES agents(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 房源视频表
CREATE TABLE house_videos (
    id BIGSERIAL PRIMARY KEY,
    house_id BIGINT REFERENCES houses(id) ON DELETE CASCADE,
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration INT,
    uploaded_by BIGINT REFERENCES agents(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 房源审核记录表
CREATE TABLE house_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    house_id BIGINT REFERENCES houses(id) ON DELETE CASCADE,
    action VARCHAR(20) NOT NULL CHECK (action IN ('submit', 'approve', 'reject', 'modify', 'offline', 'online')),
    operator_id BIGINT REFERENCES users(id),
    operator_type VARCHAR(20) CHECK (operator_type IN ('agent', 'admin', 'system')),
    remark TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 房源价格变更历史表
CREATE TABLE house_price_history (
    id BIGSERIAL PRIMARY KEY,
    house_id BIGINT REFERENCES houses(id) ON DELETE CASCADE,
    old_price BIGINT NOT NULL,
    new_price BIGINT NOT NULL,
    reason VARCHAR(255),
    changed_by BIGINT REFERENCES agents(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 4. 验真模块 (Verification Module)
-- ============================================================

-- 验真任务表
CREATE TABLE verification_tasks (
    id BIGSERIAL PRIMARY KEY,
    task_code VARCHAR(50) UNIQUE NOT NULL,
    house_id BIGINT REFERENCES houses(id) ON DELETE CASCADE,
    type VARCHAR(20) DEFAULT 'basic' CHECK (type IN ('basic', 'property', 'comprehensive')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'assigned', 'processing', 'completed', 'cancelled')),
    
    assignee_id BIGINT REFERENCES agents(id),
    assigned_at TIMESTAMP WITH TIME ZONE,
    deadline_at TIMESTAMP WITH TIME ZONE,
    
    completed_at TIMESTAMP WITH TIME ZONE,
    result VARCHAR(20) CHECK (result IN ('pass', 'fail', 'conditional')),
    score INT,
    report TEXT,
    
    commission_amount BIGINT,
    commission_status VARCHAR(20) DEFAULT 'pending' CHECK (commission_status IN ('pending', 'paid')),
    commission_paid_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 验真检查项表
CREATE TABLE verification_items (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT REFERENCES verification_tasks(id) ON DELETE CASCADE,
    category VARCHAR(20) NOT NULL CHECK (category IN ('basic', 'property', 'transaction')),
    item_name VARCHAR(100) NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'pass', 'fail', 'na')),
    remark TEXT,
    photos JSONB,
    checked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 验真照片表
CREATE TABLE verification_photos (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT REFERENCES verification_tasks(id) ON DELETE CASCADE,
    photo_type VARCHAR(50) NOT NULL,
    photo_url VARCHAR(500) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    taken_at TIMESTAMP WITH TIME ZONE,
    uploaded_by BIGINT REFERENCES agents(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 5. 客户模块 (Client Module)
-- ============================================================

-- 客户表
CREATE TABLE clients (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    wechat VARCHAR(100),
    gender VARCHAR(10),
    age_range VARCHAR(20),
    
    -- 需求信息
    demand_type VARCHAR(20) CHECK (demand_type IN ('buy', 'rent')),
    demand_city VARCHAR(50),
    demand_districts VARCHAR(255),
    budget_min BIGINT,
    budget_max BIGINT,
    preferred_house_types VARCHAR(255),
    preferred_area_min DECIMAL(10, 2),
    preferred_area_max DECIMAL(10, 2),
    preferred_rooms VARCHAR(50),
    move_in_date DATE,
    
    -- 来源和归属
    source VARCHAR(50) CHECK (source IN ('platform', 'referral', 'walk_in', 'online', 'other')),
    source_house_id BIGINT REFERENCES houses(id),
    introducer_id BIGINT REFERENCES agents(id),
    owner_id BIGINT REFERENCES agents(id),
    
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'showing', 'negotiating', 'deal', 'lost')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('high', 'normal', 'low')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 客户跟进记录表
CREATE TABLE client_follow_ups (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT REFERENCES clients(id) ON DELETE CASCADE,
    agent_id BIGINT REFERENCES agents(id),
    follow_up_type VARCHAR(20) CHECK (follow_up_type IN ('phone', 'wechat', 'meeting', 'showing', 'other')),
    content TEXT NOT NULL,
    next_follow_up_at TIMESTAMP WITH TIME ZONE,
    next_follow_up_content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 6. 预约带看模块 (Appointment Module)
-- ============================================================

-- 预约表
CREATE TABLE appointments (
    id BIGSERIAL PRIMARY KEY,
    appointment_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- 关联信息
    house_id BIGINT REFERENCES houses(id),
    client_id BIGINT REFERENCES clients(id),
    agent_id BIGINT REFERENCES agents(id),
    
    -- 预约信息
    appointment_date DATE NOT NULL,
    appointment_time_start TIME NOT NULL,
    appointment_time_end TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected', 'cancelled', 'completed', 'no_show')),
    
    -- 客户信息（快照）
    client_name VARCHAR(100),
    client_phone VARCHAR(20),
    client_note TEXT,
    
    -- 带看反馈
    actual_showing_at TIMESTAMP WITH TIME ZONE,
    showing_result VARCHAR(20) CHECK (showing_result IN ('interested', 'considering', 'not_interested', 'negotiating')),
    showing_feedback TEXT,
    
    -- 取消信息
    cancelled_by VARCHAR(20) CHECK (cancelled_by IN ('client', 'agent', 'system')),
    cancel_reason TEXT,
    
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 经纪人带看时间表（用于预约时段管理）
CREATE TABLE agent_schedules (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT REFERENCES agents(id) ON DELETE CASCADE,
    work_date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    max_appointments INT DEFAULT 3,
    booked_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(agent_id, work_date, time_slot)
);

-- ============================================================
-- 7. IM消息模块 (Message Module)
-- ============================================================

-- 会话表
CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    conversation_code VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(20) DEFAULT 'single' CHECK (type IN ('single', 'group')),
    
    -- 参与方
    user_id BIGINT REFERENCES users(id),
    agent_id BIGINT REFERENCES agents(id),
    house_id BIGINT REFERENCES houses(id),
    
    -- 最后消息
    last_message_id BIGINT,
    last_message_at TIMESTAMP WITH TIME ZONE,
    last_message_preview TEXT,
    
    -- 未读数
    user_unread_count INT DEFAULT 0,
    agent_unread_count INT DEFAULT 0,
    
    -- 状态
    is_blocked BOOLEAN DEFAULT FALSE,
    blocked_by BIGINT REFERENCES users(id),
    blocked_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, agent_id, house_id)
);

-- 消息表
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT REFERENCES conversations(id) ON DELETE CASCADE,
    message_code VARCHAR(50) UNIQUE NOT NULL,
    
    sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('user', 'agent', 'system')),
    sender_id BIGINT NOT NULL,
    
    message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('text', 'image', 'voice', 'video', 'location', 'house_card', 'system')),
    content TEXT,
    media_url VARCHAR(500),
    media_duration INT,
    media_size INT,
    
    -- 扩展数据
    extra_data JSONB,
    
    -- 状态
    status VARCHAR(20) DEFAULT 'sent' CHECK (status IN ('sending', 'sent', 'delivered', 'read', 'failed', 'recalled')),
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 快捷话术表
CREATE TABLE quick_replies (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT REFERENCES agents(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 8. ACN分佣模块 (ACN Commission Module)
-- ============================================================

-- ACN角色定义表
CREATE TABLE acn_roles (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    name_en VARCHAR(50),
    description TEXT,
    default_ratio DECIMAL(5, 2) NOT NULL,
    role_type VARCHAR(20) NOT NULL CHECK (role_type IN ('source', 'client')),
    sort_order INT DEFAULT 0
);

-- 初始化ACN角色
INSERT INTO acn_roles (code, name, name_en, description, default_ratio, role_type, sort_order) VALUES
('ENTRANT', '房源录入人', 'Entrant', '首个将房源录入平台的经纪人', 15.00, 'source', 1),
('MAINTAINER', '房源维护人', 'Maintainer', '负责房源日常维护、陪同看房的经纪人', 20.00, 'source', 2),
('INTRODUCER', '客源转介绍', 'Introducer', '首次将客户推荐给平台的经纪人', 10.00, 'client', 1),
('ACCOMPANIER', '带看人', 'Accompanier', '实际陪同客户看房的经纪人', 15.00, 'client', 2),
('CLOSER', '成交人', 'Closer', '最终促成签约成交的经纪人', 40.00, 'client', 3);

-- ACN成交单表
CREATE TABLE acn_transactions (
    id BIGSERIAL PRIMARY KEY,
    transaction_code VARCHAR(50) UNIQUE NOT NULL,
    house_id BIGINT REFERENCES houses(id),
    
    -- 成交信息
    deal_price BIGINT NOT NULL,
    commission_amount BIGINT NOT NULL,
    deal_date DATE NOT NULL,
    contract_image VARCHAR(500),
    
    -- 房源方
    entrant_id BIGINT REFERENCES agents(id),
    entrant_ratio DECIMAL(5, 2) DEFAULT 15.00,
    entrant_amount BIGINT,
    
    maintainer_id BIGINT REFERENCES agents(id),
    maintainer_ratio DECIMAL(5, 2) DEFAULT 20.00,
    maintainer_amount BIGINT,
    
    -- 客源方
    introducer_id BIGINT REFERENCES agents(id),
    introducer_ratio DECIMAL(5, 2) DEFAULT 10.00,
    introducer_amount BIGINT,
    
    accompanier_id BIGINT REFERENCES agents(id),
    accompanier_ratio DECIMAL(5, 2) DEFAULT 15.00,
    accompanier_amount BIGINT,
    
    closer_id BIGINT REFERENCES agents(id) NOT NULL,
    closer_ratio DECIMAL(5, 2) DEFAULT 40.00,
    closer_amount BIGINT,
    
    -- 平台服务费
    platform_ratio DECIMAL(5, 2) DEFAULT 10.00,
    platform_amount BIGINT,
    
    -- 状态
    status VARCHAR(20) DEFAULT 'pending_confirm' CHECK (status IN ('pending_confirm', 'confirmed', 'disputed', 'settled', 'cancelled')),
    
    -- 确认信息
    confirmed_at TIMESTAMP WITH TIME ZONE,
    confirmed_by JSONB,
    
    -- 结算信息
    settled_at TIMESTAMP WITH TIME ZONE,
    settlement_notes TEXT,
    
    -- 申报人
    reporter_id BIGINT REFERENCES agents(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ACN分佣明细表
CREATE TABLE acn_commission_details (
    id BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT REFERENCES acn_transactions(id) ON DELETE CASCADE,
    agent_id BIGINT REFERENCES agents(id),
    role_code VARCHAR(20) REFERENCES acn_roles(code),
    ratio DECIMAL(5, 2) NOT NULL,
    amount BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'disputed', 'paid')),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ACN争议申诉表
CREATE TABLE acn_disputes (
    id BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT REFERENCES acn_transactions(id),
    disputant_id BIGINT REFERENCES agents(id),
    dispute_type VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    evidence JSONB,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'resolved', 'rejected')),
    
    resolution TEXT,
    resolved_by BIGINT REFERENCES users(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 9. 财务管理模块 (Finance Module)
-- ============================================================

-- 账户余额表
CREATE TABLE agent_accounts (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT REFERENCES agents(id) ON DELETE CASCADE,
    balance BIGINT DEFAULT 0,
    frozen_amount BIGINT DEFAULT 0,
    total_earned BIGINT DEFAULT 0,
    total_withdrawn BIGINT DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(agent_id)
);

-- 账户流水表
CREATE TABLE agent_account_logs (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT REFERENCES agents(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('commission', 'bonus', 'penalty', 'withdrawal', 'refund')),
    amount BIGINT NOT NULL,
    balance_after BIGINT NOT NULL,
    related_id BIGINT,
    related_type VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 提现申请表
CREATE TABLE withdrawal_requests (
    id BIGSERIAL PRIMARY KEY,
    request_code VARCHAR(50) UNIQUE NOT NULL,
    agent_id BIGINT REFERENCES agents(id),
    amount BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'processing', 'completed', 'failed')),
    
    -- 收款信息
    bank_name VARCHAR(100),
    bank_account_name VARCHAR(100),
    bank_account_number VARCHAR(100),
    payment_method VARCHAR(20),
    
    -- 审核信息
    reviewed_by BIGINT REFERENCES users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_note TEXT,
    
    -- 支付信息
    paid_at TIMESTAMP WITH TIME ZONE,
    payment_reference VARCHAR(100),
    payment_proof VARCHAR(500),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 10. 地推模块 (Ground Promotion Module)
-- ============================================================

-- 地推人员表
CREATE TABLE promoters (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    promoter_code VARCHAR(50) UNIQUE NOT NULL,
    real_name VARCHAR(100) NOT NULL,
    id_card_number VARCHAR(50),
    phone VARCHAR(20),
    city VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    total_invited_agents INT DEFAULT 0,
    total_invited_owners INT DEFAULT 0,
    total_commission BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 地推任务表
CREATE TABLE promotion_tasks (
    id BIGSERIAL PRIMARY KEY,
    promoter_id BIGINT REFERENCES promoters(id),
    task_type VARCHAR(20) NOT NULL CHECK (task_type IN ('agent_register', 'house_publish', 'owner_register')),
    target_id BIGINT,
    target_type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
    commission_amount BIGINT,
    commission_status VARCHAR(20) DEFAULT 'pending',
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 11. 后台管理模块 (Admin Module)
-- ============================================================

-- 管理员表
CREATE TABLE admins (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(100) UNIQUE NOT NULL,
    real_name VARCHAR(100),
    role VARCHAR(50) NOT NULL,
    permissions JSONB,
    department VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 系统配置表
CREATE TABLE system_configs (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    config_type VARCHAR(20) DEFAULT 'string' CHECK (config_type IN ('string', 'number', 'boolean', 'json')),
    description TEXT,
    is_editable BOOLEAN DEFAULT TRUE,
    updated_by BIGINT REFERENCES admins(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Banner表
CREATE TABLE banners (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    image_url VARCHAR(500) NOT NULL,
    link_type VARCHAR(50) NOT NULL,
    link_value VARCHAR(500),
    position VARCHAR(50) DEFAULT 'home',
    city_id INT REFERENCES cities(id),
    sort_order INT DEFAULT 0,
    start_at TIMESTAMP WITH TIME ZONE,
    end_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    view_count INT DEFAULT 0,
    click_count INT DEFAULT 0,
    created_by BIGINT REFERENCES admins(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 操作日志表
CREATE TABLE operation_logs (
    id BIGSERIAL PRIMARY KEY,
    operator_id BIGINT REFERENCES users(id),
    operator_type VARCHAR(20) CHECK (operator_type IN ('user', 'agent', 'admin')),
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id BIGINT,
    before_data JSONB,
    after_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 索引创建
-- ============================================================

-- 用户相关索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_user_verifications_status ON user_verifications(status);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_house_id ON user_favorites(house_id);
CREATE INDEX idx_user_browsing_history_user_id ON user_browsing_history(user_id);

-- 房源相关索引
CREATE INDEX idx_houses_status ON houses(status);
CREATE INDEX idx_houses_transaction_type ON houses(transaction_type);
CREATE INDEX idx_houses_house_type ON houses(house_type);
CREATE INDEX idx_houses_city_id ON houses(city_id);
CREATE INDEX idx_houses_district_id ON houses(district_id);
CREATE INDEX idx_houses_community_id ON houses(community_id);
CREATE INDEX idx_houses_price ON houses(price);
CREATE INDEX idx_houses_area ON houses(area);
-- CREATE INDEX idx_houses_location ON houses USING GIST(location);  -- 需要PostGIS扩展
CREATE INDEX idx_houses_entrant_id ON houses(entrant_id);
CREATE INDEX idx_houses_maintainer_id ON houses(maintainer_id);
CREATE INDEX idx_houses_verification_status ON houses(verification_status);
CREATE INDEX idx_houses_created_at ON houses(created_at);

-- 搜索专用索引
CREATE INDEX idx_houses_search ON houses USING GIN (
    to_tsvector('simple', COALESCE(title, '') || ' ' || COALESCE(address, ''))
);

-- 经纪人相关索引
CREATE INDEX idx_agents_user_id ON agents(user_id);
CREATE INDEX idx_agents_company_id ON agents(company_id);
CREATE INDEX idx_agents_status ON agents(status);
CREATE INDEX idx_agents_work_city ON agents(work_city);

-- 客户相关索引
CREATE INDEX idx_clients_owner_id ON clients(owner_id);
CREATE INDEX idx_clients_status ON clients(status);
CREATE INDEX idx_clients_source ON clients(source);

-- 预约相关索引
CREATE INDEX idx_appointments_house_id ON appointments(house_id);
CREATE INDEX idx_appointments_agent_id ON appointments(agent_id);
CREATE INDEX idx_appointments_client_id ON appointments(client_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);

-- IM相关索引
CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_agent_id ON conversations(agent_id);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);

-- ACN相关索引
CREATE INDEX idx_acn_transactions_house_id ON acn_transactions(house_id);
CREATE INDEX idx_acn_transactions_status ON acn_transactions(status);
CREATE INDEX idx_acn_transactions_deal_date ON acn_transactions(deal_date);
CREATE INDEX idx_acn_commission_details_agent_id ON acn_commission_details(agent_id);
CREATE INDEX idx_acn_commission_details_status ON acn_commission_details(status);

-- ============================================================
-- 触发器函数
-- ============================================================

-- 自动更新时间戳函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为用户表创建触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agents_updated_at BEFORE UPDATE ON agents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_houses_updated_at BEFORE UPDATE ON houses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_acn_transactions_updated_at BEFORE UPDATE ON acn_transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_withdrawal_requests_updated_at BEFORE UPDATE ON withdrawal_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 初始化数据
-- ============================================================

-- 初始化城市数据（缅甸主要城市）
INSERT INTO cities (code, name, name_en, name_my, latitude, longitude, sort_order) VALUES
('YGN', '仰光', 'Yangon', 'ရန်ကုန်', 16.8661, 96.1951, 1),
('MDY', '曼德勒', 'Mandalay', 'မန္တလေး', 21.9813, 96.0823, 2),
('NPT', '内比都', 'Naypyidaw', 'နေပြည်တော်', 19.7633, 96.0785, 3),
('BGO', '勃固', 'Bago', 'ပဲခူး', 17.3350, 96.4814, 4),
('MYK', '毛淡棉', 'Mawlamyine', 'မော်လမြိုင်', 16.4905, 97.6283, 5);

-- 初始化仰光镇区
INSERT INTO districts (city_id, code, name, name_en, name_my) VALUES
(1, 'TAMWE', 'Tamwe', 'Tamwe', 'တာမွေ'),
(1, 'BAHAN', 'Bahan', 'Bahan', 'ဗဟန်း'),
(1, 'YANKIN', 'Yankin', 'Yankin', 'ရန်ကင်း'),
(1, 'SANCHAUNG', 'Sanchaung', 'Sanchaung', 'စမ်းချောင်း'),
(1, 'KYAUKTADA', 'Kyauktada', 'Kyauktada', 'ကျောက်တံတား'),
(1, 'LANMADAW', 'Lanmadaw', 'Lanmadaw', 'လမ်းမတော်'),
(1, 'THINGANGYUN', 'Thingangyun', 'Thingangyun', 'သိင်္ကြန်ဂျွန်း'),
(1, 'THAKETA', 'Thaketa', 'Thaketa', 'သာကေတ'),
(1, 'DAWbon', 'Dawbon', 'Dawbon', 'ဒေါပုံ'),
(1, 'PABEDAN', 'Pabedan', 'Pabedan', 'ပုသိမ်တောင်း');

-- 初始化系统配置
INSERT INTO system_configs (config_key, config_value, config_type, description) VALUES
('platform.name', '缅甸房产平台', 'string', '平台名称'),
('platform.commission.platform_ratio', '10', 'number', '平台服务费比例(%)'),
('platform.commission.min_withdrawal', '10000', 'number', '最小提现金额'),
('platform.house.max_images', '20', 'number', '房源最大图片数'),
('platform.house.max_active_per_agent', '50', 'number', '经纪人最大在线房源数'),
('platform.sms.daily_limit', '5', 'number', '每日短信发送限制'),
('platform.verification.expiry_days', '90', 'number', '验真有效期(天)'),
('platform.acn.source_protect_days', '30', 'number', '房源保护期(天)'),
('platform.acn.client_protect_days', '30', 'number', '客源保护期(天)');

-- ============================================================
-- 数据库Schema设计完成
-- ============================================================

COMMENT ON TABLE users IS '用户基础表';
COMMENT ON TABLE agents IS '经纪人表';
COMMENT ON TABLE houses IS '房源主表';
COMMENT ON TABLE appointments IS '预约带看表';
COMMENT ON TABLE acn_transactions IS 'ACN成交单表';
COMMENT ON TABLE conversations IS 'IM会话表';
COMMENT ON TABLE messages IS 'IM消息表';
