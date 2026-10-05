# Nhật Ký Tương Tác AI (AI Prompt Log)

### Prompt 1: Tìm hiểu cách đo lường dung lượng Data và Index
- **User Prompt:** "Hãy cho tôi xem truy vấn SQL sử dụng bảng information_schema.TABLES để in ra kích thước Data và kích thước Index của bảng 'Posts' tính theo đơn vị Megabyte (MB)."
- **AI Summary:** Sử dụng bảng `information_schema.TABLES`, lấy các trường `data_length` và `index_length` chia cho `1024 * 1024` rồi dùng hàm `ROUND(..., 2)` để quy đổi byte ra MB.

### Prompt 2: Tìm hiểu về Cardinality và chi phí của Index Boolean
- **User Prompt:** "Tại sao khi tôi truy vấn SELECT * FROM Posts WHERE is_visible = 1 trên một bảng có hàng triệu dòng (trong đó 99% bài viết là visible = 1), MySQL lại quyết định quét toàn bảng (Full Table Scan) thay vì sử dụng Index idx_is_visible đã tạo?"
- **AI Summary:** Do độ chọn lọc (Selectivity) quá thấp. Khi 99% bản ghi thỏa mãn điều kiện, việc duyệt qua Index đòi hỏi hàng triệu lần tra cứu con trỏ bản ghi (Random I/O), chậm hơn nhiều so với việc Engine đọc tuần tự các trang dữ liệu (Sequential I/O).

### Prompt 3: Giải pháp thay thế cho tìm kiếm nội dung dài
- **User Prompt:** "Nếu muốn tìm kiếm từ khóa bên trong cột content (kiểu TEXT) mà không bị tốn quá nhiều dung lượng như B-Tree Index, tôi nên sử dụng cơ chế nào của MySQL?"
- **AI Summary:** Nên sử dụng **FULLTEXT Index** kết hợp mệnh đề `MATCH(...) AGAINST(...)`, hoặc tích hợp các công cụ tìm kiếm chuyên dụng bên ngoài (như Elasticsearch) thay vì dùng B-Tree Index thông thường.
