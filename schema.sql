-- =====================================
-- 1. Table: queues (ข้อมูลการจองคิว)
-- =====================================
CREATE TABLE queues (
    id SERIAL PRIMARY KEY,
    queue_number VARCHAR(10) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    booking_date DATE NOT NULL,
    booking_time VARCHAR(10) NOT NULL,
    phone_number VARCHAR(15),
    status VARCHAR(20) DEFAULT 'WAITING', -- WAITING, CALLING, DONE, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE queues ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public insert for queues" ON queues FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public read queues" ON queues FOR SELECT USING (true);
CREATE POLICY "Allow update for queues" ON queues FOR UPDATE USING (true);

-- =====================================
-- 2. Table: reviews (ข้อมูลแบบประเมิน)
-- =====================================
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    queue_id INT REFERENCES queues(id) ON DELETE SET NULL,
    user_id VARCHAR(100) NOT NULL,
    rating_speed INT NOT NULL,
    rating_service INT NOT NULL,
    rating_system INT NOT NULL,
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public insert for reviews" ON reviews FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public read reviews" ON reviews FOR SELECT USING (true);

-- =====================================
-- 3. Table: staff_users (ข้อมูลเจ้าหน้าที่)
-- =====================================
CREATE TABLE staff_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    fullname VARCHAR(100) NOT NULL,
    permissions JSONB DEFAULT '{"manage_queues":true, "view_calendar":true, "view_dashboard":true, "manage_settings":true}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

ALTER TABLE staff_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read staff_users" ON staff_users FOR SELECT USING (true);
CREATE POLICY "Allow update for staff_users" ON staff_users FOR UPDATE USING (true);
CREATE POLICY "Allow insert for staff_users" ON staff_users FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for staff_users" ON staff_users FOR DELETE USING (true);

-- สร้างผู้ใช้ admin หลัก (รหัสผ่านเริ่มต้น: admin1234)
INSERT INTO staff_users (username, password, fullname, permissions) 
VALUES ('admin', 'admin1234', 'ผู้ดูแลระบบสูงสุด', '{"manage_queues":true, "view_calendar":true, "view_dashboard":true, "manage_settings":true}'::jsonb)
ON CONFLICT (username) DO NOTHING;

-- =====================================
-- 4. Table: time_slots (การตั้งค่าช่วงเวลาและการจำกัดคิว)
-- =====================================
CREATE TABLE time_slots (
    id SERIAL PRIMARY KEY,
    time_string VARCHAR(10) UNIQUE NOT NULL,
    max_capacity INT NOT NULL DEFAULT 5,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE time_slots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read time_slots" ON time_slots FOR SELECT USING (true);
CREATE POLICY "Allow public update time_slots" ON time_slots FOR ALL USING (true);

-- เพิ่มข้อมูลเวลาพื้นฐานตอนเริ่มต้น
INSERT INTO time_slots (time_string, max_capacity, is_active) VALUES
('09:00', 5, true),
('09:30', 5, true),
('10:00', 5, true),
('10:30', 5, true),
('11:00', 5, true),
('13:00', 5, true),
('13:30', 5, true),
('14:00', 5, true),
('14:30', 5, true)
ON CONFLICT (time_string) DO NOTHING;
