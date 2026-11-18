-- ============================================================
-- Chay 1 lan: tao database shop + toan bo bang
--   Trong PowerShell tai thu muc nay, go:
--     cmd /c "mysql -u root -p --default-character-set=utf8mb4"   roi nhap:  source schema_full.sql
-- ============================================================
CREATE DATABASE IF NOT EXISTS shop CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci;
USE shop;

-- ============================================================
-- Schema BTL2 - shopee-like (giu nguyen ban nhom da viet)
-- ============================================================

-- 1. Bảng Nguoi_dung
CREATE TABLE Nguoi_dung (
    ID_Nguoi_dung CHAR(9) PRIMARY KEY,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Ho VARCHAR(50),
    Ten VARCHAR(50),
    Ngay_sinh DATE,
    Mat_khau VARCHAR(255) NOT NULL,
    Dia_chi TEXT,
    Loai_nguoi_dung VARCHAR(50) NOT NULL CHECK (Loai_nguoi_dung IN ('Operator', 'End_user'))
);

-- 2. Bảng Nguoi_dung_So_dien_thoai
CREATE TABLE Nguoi_dung_So_dien_thoai (
    So_dien_thoai VARCHAR(10),
    ID_Nguoi_dung CHAR(9),
    PRIMARY KEY (ID_Nguoi_dung, So_dien_thoai),
    FOREIGN KEY (ID_Nguoi_dung) REFERENCES Nguoi_dung(ID_Nguoi_dung) ON DELETE CASCADE
);

-- 3. Bảng Nha_dieu_hanh (Kế thừa từ Nguoi_dung)
CREATE TABLE Nha_dieu_hanh (
    ID_Nha_dieu_hanh CHAR(9) PRIMARY KEY,
    FOREIGN KEY (ID_Nha_dieu_hanh) REFERENCES Nguoi_dung(ID_Nguoi_dung) ON DELETE CASCADE
);

-- 4. Bảng Nguoi_dung_cuoi (Kế thừa từ Nguoi_dung)
CREATE TABLE Nguoi_dung_cuoi (
    ID_Nguoi_dung_cuoi CHAR(9) PRIMARY KEY,
    FOREIGN KEY (ID_Nguoi_dung_cuoi) REFERENCES Nguoi_dung(ID_Nguoi_dung) ON DELETE CASCADE
);

-- 5. Bảng Khach_hang (Kế thừa từ Nguoi_dung_cuoi)
CREATE TABLE Khach_hang (
    ID_Khach_hang CHAR(9) PRIMARY KEY,
    FOREIGN KEY (ID_Khach_hang) REFERENCES Nguoi_dung_cuoi(ID_Nguoi_dung_cuoi) ON DELETE CASCADE
);

-- 6. Bảng Cua_hang (Kế thừa từ Nguoi_dung_cuoi và liên kết với Nha_dieu_hanh)
CREATE TABLE Cua_hang (
    ID_Cua_hang CHAR(9) PRIMARY KEY,
    Ten_Shop VARCHAR(100) UNIQUE NOT NULL,
    Anh_dai_dien_Shop TEXT,
    So_dien_thoai VARCHAR(20) UNIQUE,
    Dia_chi_Shop TEXT NOT NULL,
    Loai_shop VARCHAR(50),
    Mo_ta_Shop TEXT,
    ID_Nha_dieu_hanh CHAR(9) NOT NULL,
    FOREIGN KEY (ID_Cua_hang) REFERENCES Nguoi_dung_cuoi(ID_Nguoi_dung_cuoi) ON DELETE CASCADE,
    FOREIGN KEY (ID_Nha_dieu_hanh) REFERENCES Nha_dieu_hanh(ID_Nha_dieu_hanh)
);

-- 2. Bảng Shipper
CREATE TABLE Shipper (
    Ma_Shipper CHAR(9) PRIMARY KEY,
    Ten_Shipper VARCHAR(100) NOT NULL,
    So_dien_thoai_Shipper CHAR(10) NOT NULL,
    Giay_phep_lai_xe CHAR(20) NOT NULL,
    CCCD CHAR(20),
    Bien_so_xe VARCHAR(20),
    Loai_phuong_tien VARCHAR(20) NOT NULL
);

-- 5. Bảng Đơn hàng
CREATE TABLE Don_hang (
    Ma_Don_hang CHAR(9) PRIMARY KEY,
    Ngay_dat_don DATETIME NOT NULL,
    Phi_van_chuyen DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (Phi_van_chuyen >= 0),
    Ma_Shipper CHAR(9) NOT NULL,
    Trang_thai_don VARCHAR(20) NOT NULL CHECK (Trang_thai_don IN (  'Chờ xác nhận',
                                                                    'Chờ lấy hàng',
                                                                    'Chờ giao hàng',
                                                                    'Đang giao hàng',
                                                                    'Giao hàng thành công',
                                                                    'Đã hoàn thành',
                                                                    'Đã hủy',
                                                                    'Giao hàng thất bại',
                                                                    'Trả hàng' )),
    ID_Khach_hang CHAR(9) NOT NULL,
    FOREIGN KEY (Ma_Shipper) REFERENCES Shipper(Ma_Shipper),
    FOREIGN KEY (ID_Khach_hang) REFERENCES Khach_hang(ID_Khach_hang) ON DELETE CASCADE
);

-- 6. Bảng Giao dịch thanh toán (Quan hệ 1:1 với Đơn hàng)
CREATE TABLE Giao_dich_thanh_toan (
    Ma_Giao_dich CHAR(9) PRIMARY KEY,
    Phuong_thuc_thanh_toan VARCHAR(50) NOT NULL,
    So_tien_giao_dich DECIMAL(12,2) NOT NULL CHECK (So_tien_giao_dich > 0),
    Ma_Don_hang CHAR(9) NOT NULL UNIQUE, -- Đảm bảo quan hệ 1:1 với Đơn hàng
    Trang_thai_giao_dich VARCHAR(20) NOT NULL CHECK (Trang_thai_giao_dich IN (  'Đang xử lý',
                                                                                'Thành công',
                                                                                'Thất bại',
                                                                                'Đã hủy',
                                                                                'Đã hoàn tiền')),
    FOREIGN KEY (Ma_Don_hang) REFERENCES Don_hang(Ma_Don_hang)
);

CREATE TABLE Danh_muc (
    Ma_Danh_muc CHAR(9) PRIMARY KEY,
    Ten_danh_muc VARCHAR(255) NOT NULL,
    Ma_Danh_muc_Cha CHAR(9),
    FOREIGN KEY (Ma_Danh_muc_Cha) REFERENCES Danh_muc(Ma_Danh_muc)
);

CREATE TABLE San_pham (
    Ma_San_pham CHAR(9) PRIMARY KEY,
    Ten_san_pham VARCHAR(255) NOT NULL,
    Mo_ta_san_pham TEXT NOT NULL,
    Gia_ban_hien_tai DECIMAL(10, 2) NOT NULL CHECK (Gia_ban_hien_tai > 0),
    Trang_thai_san_pham VARCHAR(50) NOT NULL CHECK (Trang_thai_san_pham IN ('Đang bán',
                                                                            'Hết hàng',
                                                                            'Đã ẩn',
                                                                            'Tạm ngưng bán',
                                                                            'Đang chờ duyệt',
                                                                            'Bị khóa')),
    Ma_Danh_muc CHAR(9) NOT NULL,
    ID_Cua_hang CHAR(9) NOT NULL,
    FOREIGN KEY (Ma_Danh_muc) REFERENCES Danh_muc(Ma_Danh_muc),
    FOREIGN KEY (ID_Cua_hang) REFERENCES Cua_hang(ID_Cua_hang)
);

CREATE TABLE Chua_san_pham (
    Ma_Don_hang CHAR(9) NOT NULL,
    Ma_San_pham CHAR(9) NOT NULL,
    So_luong_mua INT NOT NULL CHECK (So_luong_mua > 0),
    Don_gia_luc_mua DECIMAL(12,2) NOT NULL CHECK (Don_gia_luc_mua > 0),
    PRIMARY KEY (Ma_Don_hang, Ma_San_pham),
    FOREIGN KEY (Ma_Don_hang)
        REFERENCES Don_hang(Ma_Don_hang),
    FOREIGN KEY (Ma_San_pham)
        REFERENCES San_pham(Ma_San_pham)
);

CREATE TABLE Bien_the_san_pham (
    Ma_San_pham CHAR(9),
    Ma_bien_the CHAR(9),
    Mau_sac VARCHAR(50) NOT NULL,
    Kich_co VARCHAR(50) NOT NULL,
    So_luong_ton_kho INT NOT NULL CHECK (So_luong_ton_kho >= 0),
    PRIMARY KEY (Ma_San_pham, Ma_bien_the),
    FOREIGN KEY (Ma_San_pham) REFERENCES San_pham(Ma_San_pham)
);

CREATE TABLE Gio_hang (
    ID_Khach_hang CHAR(9) PRIMARY KEY,
    FOREIGN KEY (ID_Khach_hang) REFERENCES Khach_hang(ID_Khach_hang)
);

CREATE TABLE Co (
    ID_Khach_hang CHAR(9),
    Ma_San_pham CHAR(9),
    So_luong_chon INT NOT NULL CHECK (So_luong_chon >= 0),
    PRIMARY KEY (ID_Khach_hang, Ma_San_pham),
    FOREIGN KEY (ID_Khach_hang) REFERENCES Gio_hang(ID_Khach_hang),
    FOREIGN KEY (Ma_San_pham) REFERENCES San_pham(Ma_San_pham)
);

CREATE TABLE Voucher (
    Ma_Voucher CHAR(9) PRIMARY KEY,
    So_luong_phat_hanh INT NOT NULL,
    So_ngay_hieu_luc INT NOT NULL,
    Gia_tri_giam_toi_da DECIMAL(12,2) NOT NULL,
    Phan_tram_giam DECIMAL(5,2) NOT NULL,
    Thoi_gian_bat_dau DATETIME NOT NULL,
    Thoi_gian_ket_thuc DATETIME NOT NULL,
    Loai_voucher VARCHAR(50) NOT NULL,
    Ten_voucher VARCHAR(255) NOT NULL,
    Nguon_voucher VARCHAR(20) NOT NULL,
    ID_Cua_hang CHAR(9),
    ID_Nha_dieu_hanh CHAR(9),
    FOREIGN KEY (ID_Cua_hang) REFERENCES Cua_hang(ID_Cua_hang),
    FOREIGN KEY (ID_Nha_dieu_hanh) REFERENCES Nha_dieu_hanh(ID_Nha_dieu_hanh),
    CONSTRAINT chk_id_phat_hanh CHECK (
    (ID_Cua_hang IS NOT NULL AND ID_Nha_dieu_hanh IS NULL) OR
    (ID_Cua_hang IS NULL AND ID_Nha_dieu_hanh IS NOT NULL)
    ),
    CONSTRAINT chk_voucher_so_luong CHECK (So_luong_phat_hanh > 0),
    CONSTRAINT chk_voucher_hieu_luc CHECK (So_ngay_hieu_luc > 0),
    CONSTRAINT chk_voucher_giam_toi_da CHECK (Gia_tri_giam_toi_da >= 0),
    CONSTRAINT chk_voucher_phan_tram CHECK (Phan_tram_giam BETWEEN 0 AND 100),
    CONSTRAINT chk_voucher_thoi_gian CHECK (Thoi_gian_bat_dau < Thoi_gian_ket_thuc),
    CONSTRAINT chk_voucher_nguon CHECK (Nguon_voucher IN ('Operator','Shop')),
    CONSTRAINT chk_voucher_ten CHECK (CHAR_LENGTH(TRIM(Ten_voucher)) > 0)
);

CREATE TABLE Luu (
    Ma_Voucher CHAR(9) NOT NULL,
    ID_Khach_hang CHAR(9) NOT NULL,
    Ngay_luu_ma DATETIME NOT NULL,
    PRIMARY KEY (Ma_Voucher, ID_Khach_hang),
    CONSTRAINT fk_luu_voucher FOREIGN KEY (Ma_Voucher) REFERENCES Voucher(Ma_Voucher),
    CONSTRAINT fk_luu_khach FOREIGN KEY (ID_Khach_hang) REFERENCES Khach_hang(ID_Khach_hang)
);

CREATE TABLE Ap_dung (
    Ma_Voucher CHAR(9) NOT NULL,
    Ma_Don_hang CHAR(9) NOT NULL,
    So_tien_duoc_giam DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (Ma_Voucher, Ma_Don_hang),
    CONSTRAINT fk_apdung_voucher FOREIGN KEY (Ma_Voucher) REFERENCES Voucher(Ma_Voucher),
    CONSTRAINT fk_apdung_don FOREIGN KEY (Ma_Don_hang) REFERENCES Don_hang(Ma_Don_hang),
    CONSTRAINT chk_apdung_giam CHECK (So_tien_duoc_giam >= 0)
);

CREATE TABLE Danh_gia (
    ID_Khach_hang CHAR(9) NOT NULL,
    Ma_San_pham CHAR(9) NOT NULL,
    So_sao TINYINT NOT NULL,
    Noi_dung_danh_gia TEXT,
    Ngay_danh_gia DATETIME NOT NULL,
    PRIMARY KEY (ID_Khach_hang, Ma_San_pham),
    CONSTRAINT fk_danhgia_khach FOREIGN KEY (ID_Khach_hang) REFERENCES Khach_hang(ID_Khach_hang),
    CONSTRAINT fk_danhgia_sanpham FOREIGN KEY (Ma_San_pham) REFERENCES San_pham(Ma_San_pham),
    CONSTRAINT chk_danhgia_sao CHECK (So_sao BETWEEN 1 AND 5)
);

CREATE TABLE Danh_gia_Hinh_anh_minh_hoa (
    ID_Khach_hang CHAR(9) NOT NULL,
    Ma_San_pham CHAR(9) NOT NULL,
    Hinh_anh_minh_hoa VARCHAR(500) NOT NULL,
    PRIMARY KEY (ID_Khach_hang, Ma_San_pham, Hinh_anh_minh_hoa),
    CONSTRAINT fk_anh_danhgia FOREIGN KEY (ID_Khach_hang, Ma_San_pham)
        REFERENCES Danh_gia(ID_Khach_hang, Ma_San_pham),
    CONSTRAINT chk_anh_khong_rong CHECK (CHAR_LENGTH(TRIM(Hinh_anh_minh_hoa)) > 0)
);
