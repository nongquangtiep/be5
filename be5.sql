-- ====================================================================
-- DỰ ÁN QUICKFEED: KHỞI TẠO VÀ TỐI ƯU HÓA HỆ THỐNG
-- ====================================================================

-- 1. Khởi tạo CSDL nếu chưa có
CREATE DATABASE IF NOT EXISTS quickfeed_db;
USE quickfeed_db;

-- 2. Tạo bảng Posts và chèn cấu trúc ban đầu (Legacy Script của đề bài)
DROP TABLE IF EXISTS Posts;
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    post_type VARCHAR(10),       -- 'TEXT', 'IMAGE', 'VIDEO'
    is_visible BOOLEAN DEFAULT 1, -- 1 hoặc 0
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Thêm 5 Index ban đầu (Thảm họa Over-indexing)
CREATE INDEX idx_user_id ON Posts(user_id);
CREATE INDEX idx_content ON Posts(content(255));
CREATE INDEX idx_post_type ON Posts(post_type);
CREATE INDEX idx_is_visible ON Posts(is_visible);
CREATE INDEX idx_created_at ON Posts(created_at);

-- Thêm một số dữ liệu mẫu giả lập
INSERT INTO Posts (user_id, content, post_type, is_visible) VALUES
(101, 'Học MySQL cơ bản đến nâng cao tại QuickFeed...', 'TEXT', 1),
(102, 'Bức ảnh phong cảnh tuyệt đẹp vừa chụp chiều nay.', 'IMAGE', 1),
(101, 'Video hướng dẫn tối ưu cơ sở dữ liệu và Index.', 'VIDEO', 1),
(103, 'Trạng thái này tạm thời bị ẩn khỏi bảng tin.', 'TEXT', 0),
(104, 'Chia sẻ kinh nghiệm làm dự án phần mềm thực tế.', 'TEXT', 1);

-- --------------------------------------------------------------------
-- BƯỚC 1: KIỂM TRA DUNG LƯỢNG VÀ INDEX TRƯỚC KHI TỐI ƯU
-- --------------------------------------------------------------------
SELECT 
    table_name AS `Table`,
    ROUND(((data_length) / 1024 / 1024), 4) AS `Data_Size_MB`,
    ROUND(((index_length) / 1024 / 1024), 4) AS `Index_Size_MB`,
    ROUND(((data_length + index_length) / 1024 / 1024), 4) AS `Total_Size_MB`
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db' AND table_name = 'Posts';

-- Xem danh sách index ban đầu kèm Cardinality
SHOW INDEX FROM Posts;

-- --------------------------------------------------------------------
-- BƯỚC 2: "PHẪU THUẬT" DROP 3 INDEX GÂY NGHẼN HỆ THỐNG
-- --------------------------------------------------------------------
-- 1. Xóa idx_content: TEXT ngốn ổ cứng khủng khiếp, không tối ưu cho tìm kiếm
ALTER TABLE Posts DROP INDEX idx_content;

-- 2. Xóa idx_post_type: Cardinality cực thấp (chỉ có 3 giá trị)
ALTER TABLE Posts DROP INDEX idx_post_type;

-- 3. Xóa idx_is_visible: Boolean chỉ có 2 giá trị (0, 1), Optimizer luôn bỏ qua
ALTER TABLE Posts DROP INDEX idx_is_visible;

-- --------------------------------------------------------------------
-- BƯỚC 3: KIỂM TRA LẠI DUNG LƯỢNG VÀ TRẠNG THÁI SAU KHI TỐI ƯU
-- --------------------------------------------------------------------
SELECT 
    table_name AS `Table`,
    ROUND(((data_length) / 1024 / 1024), 4) AS `Data_Size_MB`,
    ROUND(((index_length) / 1024 / 1024), 4) AS `Index_Size_MB`,
    ROUND(((data_length + index_length) / 1024 / 1024), 4) AS `Total_Size_MB`
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db' AND table_name = 'Posts';

-- Xác nhận chỉ còn lại 2 Secondary Index có giá trị cao: idx_user_id và idx_created_at
SHOW INDEX FROM Posts;