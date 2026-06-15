-- สคริปต์สำหรับสร้างฐานข้อมูลระบบจองคิวบน Supabase (นำไปรันใน SQL Editor ของ Supabase)

-- ลบตารางเดิมและ policy เดิมออกก่อน (เผื่อมีการรันสคริปต์ซ้ำ)
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS queues CASCADE;

-- 1. สร้างตารางเก็บรายการคิว (Queues)
CREATE TABLE queues (
    id SERIAL PRIMARY KEY,
    queue_number VARCHAR(20) NOT NULL,
    user_id VARCHAR(100) NOT NULL, -- LINE User ID
    user_name VARCHAR(150),
    service_type VARCHAR(50) NOT NULL,
    booking_date DATE NOT NULL,
    booking_time VARCHAR(20) NOT NULL,
    phone_number VARCHAR(20),
    status VARCHAR(20) DEFAULT 'WAITING', -- WAITING, CALLING, DONE, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. สร้างตารางเก็บผลประเมินความพึงพอใจ (Reviews)
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    queue_id INTEGER REFERENCES queues(id),
    user_id VARCHAR(100) NOT NULL,
    rating_speed INTEGER NOT NULL CHECK (rating_speed >= 1 AND rating_speed <= 5),
    rating_service INTEGER NOT NULL CHECK (rating_service >= 1 AND rating_service <= 5),
    rating_system INTEGER NOT NULL CHECK (rating_system >= 1 AND rating_system <= 5),
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. เปิดใช้งาน Row Level Security (RLS) เพื่อความปลอดภัย
ALTER TABLE queues ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- 4. สร้าง Policies (นโยบายการเข้าถึงข้อมูล) แบบง่ายสำหรับการพัฒนาเริ่มต้น
-- อนุญาตให้เพิ่มข้อมูล (Insert) ได้ทุกคน (สำหรับการจองคิวผ่าน LIFF)
CREATE POLICY "Allow anonymous insert for queues" ON queues FOR INSERT WITH CHECK (true);

-- อนุญาตให้อ่านข้อมูล (Select) ได้ทุกคน (สำหรับการแสดงผลหน้า Admin)
CREATE POLICY "Allow anonymous select for queues" ON queues FOR SELECT USING (true);

-- อนุญาตให้อัปเดตข้อมูล (Update) ได้ทุกคน (สำหรับการเรียกคิว/ปิดงาน)
CREATE POLICY "Allow anonymous update for queues" ON queues FOR UPDATE USING (true);

-- อนุญาตให้เพิ่มผลประเมินได้ทุกคน
CREATE POLICY "Allow anonymous insert for reviews" ON reviews FOR INSERT WITH CHECK (true);
