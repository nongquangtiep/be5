# Báo Cáo Tối Ưu Hóa Tài Nguyên & Hiệu Năng Bảng Posts (QuickFeed)

## 1. Phân tích nguyên nhân sự cố (Root Cause)
Hệ thống QuickFeed gặp lỗi Timeout khi đăng bài (INSERT) và cạn kiệt ổ cứng do hiện tượng **Over-Indexing** (tạo chỉ mục vô tội vạ trên mọi cột):
- **Sự đánh đổi Write - Read:** Index giúp tăng tốc `SELECT`, nhưng mỗi thao tác `INSERT` phải ghi dữ liệu vào bảng chính (Clustered Index), đồng thời cập nhật và cân bằng lại toàn bộ 5 cây B-Tree phụ (Secondary Indexes). Thao tác này gây nghẽn I/O đĩa cục bộ.
- **Index lãng phí:** Cột `is_visible` (Boolean: 0/1) và `post_type` (3 giá trị) có **Cardinality (độ phân biệt dữ liệu) cực thấp**. MySQL Optimizer nhận thấy chi phí duyệt cây B-Tree rồi quay lại tra cứu ngẫu nhiên (Random Disk Lookup/Bookmark Lookup) tốn kém hơn nhiều so với việc quét tuần tự (Full Table Scan), khiến các Index này hoàn toàn vô dụng khi đọc nhưng lại tiêu tốn tài nguyên bảo trì khi ghi.
- **Index phình to:** `idx_content` cắt 255 ký tự kiểu TEXT đẩy kích thước cây B-Tree phình to gấp đôi dữ liệu thực tế.

## 2. Kết quả sau khi tối ưu
- Loại bỏ 3 Index: `idx_content`, `idx_post_type`, `idx_is_visible`.
- Giữ lại 2 Index thiết yếu: `idx_user_id` (lọc trang cá nhân) và `idx_created_at` (sắp xếp Newsfeed).
- **Hiệu năng:** Thao tác `INSERT` giảm tải được 3 lần ghi đĩa cập nhật cây B-Tree. `Index_length` được giải phóng đáng kể, chấm dứt cảnh báo Disk Full.
