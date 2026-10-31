-- ============================================================================
-- BAGIAN 1 : MEMBUAT DATABASE
-- ============================================================================
DROP DATABASE IF EXISTS rumah_sakit;

CREATE DATABASE rumah_sakit
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE rumah_sakit;


-- ============================================================================
-- BAGIAN 2 : DDL - DATA DEFINITION LANGUAGE (8 TABEL BERSALING RELASI)
-- ============================================================================

-- 2.1 Tabel poliklinik (induk dokter)
CREATE TABLE poliklinik (
    id_poli        INT AUTO_INCREMENT PRIMARY KEY,
    nama_poli      VARCHAR(50) NOT NULL UNIQUE,
    lokasi_gedung  VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2.2 Tabel dokter (anak poliklinik, induk kunjungan)
CREATE TABLE dokter (
    id_dokter      INT AUTO_INCREMENT PRIMARY KEY,
    nama_dokter    VARCHAR(100) NOT NULL,
    spesialis      VARCHAR(50)  NOT NULL,
    jenis_kelamin  ENUM('L','P') NOT NULL,
    no_telp        VARCHAR(15) UNIQUE,
    id_poli        INT NOT NULL,
    CONSTRAINT fk_dokter_poli
        FOREIGN KEY (id_poli) REFERENCES poliklinik (id_poli)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2.3 Tabel pasien (induk kunjungan)
CREATE TABLE pasien (
    id_pasien      INT AUTO_INCREMENT PRIMARY KEY,
    no_rm          VARCHAR(12) NOT NULL UNIQUE COMMENT 'Nomor rekam medis',
    nama_pasien    VARCHAR(100) NOT NULL,
    jenis_kelamin  ENUM('L','P') NOT NULL,
    tgl_lahir      DATE NOT NULL,
    alamat         VARCHAR(150),
    no_telp        VARCHAR(15),
    gol_darah      ENUM('A','B','AB','O') NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2.4 Tabel kamar (induk opsional kunjungan)
CREATE TABLE kamar (
    id_kamar        INT AUTO_INCREMENT PRIMARY KEY,
    no_kamar        VARCHAR(8) NOT NULL UNIQUE,
    tipe_kamar      ENUM('VIP','Kelas 1','Kelas 2','Kelas 3') NOT NULL,
    harga_per_hari  DECIMAL(12,2) NOT NULL,
    status          ENUM('Kosong','Terisi','Perawatan') NOT NULL DEFAULT 'Kosong',
    CONSTRAINT chk_harga_kamar CHECK (harga_per_hari >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2.5 Tabel kunjungan (transaksi pusat; id_kamar NULL = rawat jalan)
CREATE TABLE kunjungan (
    id_kunjungan    INT AUTO_INCREMENT PRIMARY KEY,
    no_registrasi   VARCHAR(15) NOT NULL UNIQUE,
    id_pasien       INT NOT NULL,
    id_dokter       INT NOT NULL,
    id_kamar        INT NULL,
    tgl_kunjungan   DATE NOT NULL,
    tipe_kunjungan  ENUM('Rawat Jalan','Rawat Inap') NOT NULL,
    keluhan         VARCHAR(200),
    tgl_keluar      DATE NULL,
    status          ENUM('Aktif','Selesai','Batal') NOT NULL DEFAULT 'Aktif',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_kunjungan_pasien
        FOREIGN KEY (id_pasien) REFERENCES pasien (id_pasien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_kunjungan_dokter
        FOREIGN KEY (id_dokter) REFERENCES dokter (id_dokter)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_kunjungan_kamar
        FOREIGN KEY (id_kamar) REFERENCES kamar (id_kamar)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_tgl_keluar CHECK (tgl_keluar IS NULL OR tgl_keluar >= tgl_kunjungan)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2.6 Tabel obat (induk resep)
CREATE TABLE obat (
    id_obat      INT AUTO_INCREMENT PRIMARY KEY,
    nama_obat    VARCHAR(80) NOT NULL,
    jenis_obat   ENUM('Tablet','Kapsul','Sirup','Salep','Injeksi') NOT NULL,
    harga        DECIMAL(12,2) NOT NULL,
    stok         INT NOT NULL DEFAULT 0,
    kedaluwarsa  DATE,
    CONSTRAINT chk_harga_obat CHECK (harga >= 0),
    CONSTRAINT chk_stok CHECK (stok >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2.7 Tabel resep (anak kunjungan & obat)
CREATE TABLE resep (
    id_resep      INT AUTO_INCREMENT PRIMARY KEY,
    id_kunjungan  INT NOT NULL,
    id_obat       INT NOT NULL,
    jumlah        INT NOT NULL,
    dosis         VARCHAR(50),
    CONSTRAINT chk_jumlah_resep CHECK (jumlah > 0),
    CONSTRAINT fk_resep_kunjungan
        FOREIGN KEY (id_kunjungan) REFERENCES kunjungan (id_kunjungan)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resep_obat
        FOREIGN KEY (id_obat) REFERENCES obat (id_obat)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2.8 Tabel tagihan (satu tagihan per kunjungan -> UNIQUE id_kunjungan)
CREATE TABLE tagihan (
    id_tagihan      INT AUTO_INCREMENT PRIMARY KEY,
    no_tagihan      VARCHAR(15) NOT NULL UNIQUE,
    id_kunjungan    INT NOT NULL UNIQUE,
    tgl_tagihan     DATE NOT NULL,
    biaya_kamar     DECIMAL(12,2) NOT NULL DEFAULT 0,
    biaya_obat      DECIMAL(12,2) NOT NULL DEFAULT 0,
    biaya_tindakan  DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_biaya     DECIMAL(12,2) NOT NULL DEFAULT 0,
    status_bayar    ENUM('Belum Bayar','Lunas') NOT NULL DEFAULT 'Belum Bayar',
    CONSTRAINT fk_tagihan_kunjungan
        FOREIGN KEY (id_kunjungan) REFERENCES kunjungan (id_kunjungan)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- ============================================================================
-- BAGIAN 3 : DML - DATA MANIPULATION LANGUAGE (INSERT data dummy)
-- ============================================================================

-- 3.1 Data poliklinik (8 baris)
INSERT INTO poliklinik (nama_poli, lokasi_gedung) VALUES
('Poli Umum',       'Gedung A - Lantai 1'),
('Poli Gigi',       'Gedung A - Lantai 1'),
('Poli Anak',       'Gedung A - Lantai 2'),
('Poli Kandungan',  'Gedung A - Lantai 2'),
('Poli Jantung',    'Gedung B - Lantai 2'),
('Poli Mata',       'Gedung B - Lantai 1'),
('Poli THT',        'Gedung B - Lantai 1'),
('Poli Bedah',      'Gedung B - Lantai 3');

-- 3.2 Data dokter (10 baris)
INSERT INTO dokter (nama_dokter, spesialis, jenis_kelamin, no_telp, id_poli) VALUES
('dr. Andi Wijaya',     'Dokter Umum',          'L', '081234567001', 1),
('dr. Siti Rahmawati',  'Dokter Umum',          'P', '081234567002', 1),
('drg. Budi Santoso',   'Dokter Gigi',          'L', '081234567003', 2),
('dr. Maya Kusuma',     'Dokter Anak',          'P', '081234567004', 3),
('dr. Ratna Dewi',      'Spesialis Kandungan',  'P', '081234567005', 4),
('dr. Hendra Gunawan',  'Spesialis Jantung',    'L', '081234567006', 5),
('dr. Linda Anggraini', 'Spesialis Mata',       'P', '081234567007', 6),
('dr. Agus Prasetyo',   'Spesialis THT',        'L', '081234567008', 7),
('dr. Fitri Handayani', 'Spesialis Bedah',      'P', '081234567009', 8),
('dr. Rudi Hartono',    'Dokter Anak',          'L', '081234567010', 3);

-- 3.3 Data pasien (20 baris. pasien 18-20 sengaja belum pernah berobat
--     untuk mendemonstrasikan LEFT JOIN ... IS NULL)
INSERT INTO pasien (no_rm, nama_pasien, jenis_kelamin, tgl_lahir, alamat, no_telp, gol_darah) VALUES
('RM-2026-0001', 'Budi Setiawan',     'L', '1980-03-15', 'Jl. Merdeka No. 10, Bandung',       '081311110001', 'A'),
('RM-2026-0002', 'Siti Aminah',       'P', '1975-07-22', 'Jl. Sudirman No. 25, Cimahi',       '081311110002', 'B'),
('RM-2026-0003', 'Aisyah Putri',      'P', '2019-11-05', 'Jl. Asia Afrika No. 8, Bandung',    '081311110003', 'O'),
('RM-2026-0004', 'Dedi Kurniawan',    'L', '1968-01-30', 'Jl. Diponegoro No. 3, Bandung',     '081311110004', 'AB'),
('RM-2026-0005', 'Rina Marlina',      'P', '1990-09-12', 'Jl. Cihampelas No. 45, Bandung',    '081311110005', 'O'),
('RM-2026-0006', 'Ahmad Fauzi',       'L', '1955-04-18', 'Jl. Ahmad Yani No. 12, Bandung',    '081311110006', 'B'),
('RM-2026-0007', 'Dewi Lestari',      'P', '1985-12-01', 'Jl. Setiabudi No. 77, Bandung',     '081311110007', 'A'),
('RM-2026-0008', 'Joko Susilo',       'L', '1972-06-25', 'Jl. Pasteur No. 19, Bandung',       '081311110008', 'O'),
('RM-2026-0009', 'Sri Wahyuni',       'P', '1960-02-14', 'Jl. Dago No. 33, Bandung',          '081311110009', 'A'),
('RM-2026-0010', 'Bagus Pratama',     'L', '1995-08-08', 'Jl. Riau No. 5, Bandung',           '081311110010', NULL),
('RM-2026-0011', 'Citra Kirana',      'P', '1998-03-03', 'Jl. Sumur Bandung No. 15, Bandung', '081311110011', 'B'),
('RM-2026-0012', 'Eko Purnomo',       'L', '1963-10-20', 'Jl. Braga No. 2, Bandung',          '081311110012', 'A'),
('RM-2026-0013', 'Farida Hana',       'P', '1988-05-17', 'Jl. Cibaduyut No. 21, Bandung',     '081311110013', 'O'),
('RM-2026-0014', 'Gunawan Saputra',   'L', '1978-11-11', 'Jl. Soekarno Hatta No. 100, Bandung','081311110014','AB'),
('RM-2026-0015', 'Hesti Purwani',     'P', '1993-01-27', 'Jl. Kopo No. 88, Bandung',          '081311110015', 'B'),
('RM-2026-0016', 'Indra Gunawan',     'L', '1950-12-09', 'Jl. Cibiru No. 4, Bandung',         '081311110016', 'A'),
('RM-2026-0017', 'Julia Permata',     'P', '2001-04-06', 'Jl. Antapani No. 30, Bandung',      '081311110017', NULL),
('RM-2026-0018', 'Kevin Ramadhan',    'L', '2015-02-19', 'Jl. Buah Batu No. 60, Bandung',     '081311110018', 'O'),
('RM-2026-0019', 'Lina Budiarti',     'P', '1970-09-09', 'Jl. Gedebage No. 14, Bandung',      '081311110019', 'A'),
('RM-2026-0020', 'Muhammad Rizki',    'L', '1999-07-04', 'Jl. Padalarang No. 7, Bandung',     '081311110020', 'B');

-- 3.4 Data kamar 
INSERT INTO kamar (no_kamar, tipe_kamar, harga_per_hari, status) VALUES
('V-101', 'VIP',     1500000.00, 'Kosong'),
('V-102', 'VIP',     1500000.00, 'Kosong'),
('A-201', 'Kelas 1',  750000.00, 'Kosong'),
('A-202', 'Kelas 1',  750000.00, 'Kosong'),
('B-301', 'Kelas 2',  450000.00, 'Kosong'),
('B-302', 'Kelas 2',  450000.00, 'Kosong'),
('B-303', 'Kelas 2',  450000.00, 'Kosong'),
('C-401', 'Kelas 3',  250000.00, 'Kosong'),
('C-402', 'Kelas 3',  250000.00, 'Kosong'),
('C-403', 'Kelas 3',  250000.00, 'Kosong'),
('C-404', 'Kelas 3',  250000.00, 'Kosong'),
('C-405', 'Kelas 3',  250000.00, 'Perawatan');

-- 3.5 Data obat (12 baris. stok sengaja besar agar trigger pengurangan
--     stok tidak pernah membuat stok menjadi negatif)
INSERT INTO obat (nama_obat, jenis_obat, harga, stok, kedaluwarsa) VALUES
('Paracetamol 500 mg',           'Tablet',   5000.00,  1000, '2027-06-30'),
('Amoxicillin 500 mg',           'Kapsul',  12000.00,   800, '2027-03-31'),
('Cetirizine 10 mg',             'Tablet',   8000.00,   600, '2027-08-31'),
('Omeprazole 20 mg',             'Kapsul',  15000.00,   500, '2027-01-31'),
('Sirup Batuk Anak 100 ml',      'Sirup',   25000.00,   400, '2027-05-31'),
('Salep Kulit 15 g',             'Salep',   18000.00,   300, '2027-04-30'),
('Ceftriaxone 1 g (injeksi)',    'Injeksi', 45000.00,   250, '2027-02-28'),
('Vitamin B Complex',            'Tablet',  10000.00,   700, '2027-09-30'),
('Insulin 100 IU',               'Injeksi', 95000.00,   150, '2027-07-31'),
('Amlodipine 10 mg',             'Tablet',  20000.00,   600, '2027-10-31'),
('Sirup Penurun Demam 60 ml',    'Sirup',   22000.00,   450, '2027-03-31'),
('Antasida Tablet',              'Tablet',   6000.00,   650, '2027-11-30');

-- 3.6 Data kunjungan (21 baris: 10 rawat inap + 10 rawat jalan + 1 batal)
INSERT INTO kunjungan
(no_registrasi, id_pasien, id_dokter, id_kamar, tgl_kunjungan, tipe_kunjungan, keluhan, tgl_keluar, status) VALUES
('REG-2026-0001',  1, 1,  1, '2026-07-02', 'Rawat Inap', 'Demam tinggi dan sesak napas',        '2026-07-05', 'Selesai'),
('REG-2026-0002',  2, 2,  5, '2026-07-10', 'Rawat Inap', 'Ruam kulit luas dan demam',           '2026-07-14', 'Selesai'),
('REG-2026-0003',  3, 4,  2, '2026-08-01', 'Rawat Inap', 'Demam dan batuk berdahak',            '2026-08-04', 'Selesai'),
('REG-2026-0004',  4, 6,  3, '2026-08-15', 'Rawat Inap', 'Nyeri dada, dicurigai gangguan jantung','2026-08-20','Selesai'),
('REG-2026-0005',  5, 8,  7, '2026-09-01', 'Rawat Inap', 'Telinga berdenging dan pusing',       '2026-09-03', 'Selesai'),
('REG-2026-0006',  6, 9,  4, '2026-09-10', 'Rawat Inap', 'Apendisitis, perlu operasi',          '2026-09-18', 'Selesai'),
('REG-2026-0007',  7, 5,  8, '2026-10-01', 'Rawat Inap', 'Kehamilan risiko tinggi',             '2026-10-04', 'Selesai'),
('REG-2026-0008',  8, 6,  6, '2026-10-05', 'Rawat Inap', 'Nyeri dada berulang',                 NULL,         'Aktif'),
('REG-2026-0009',  9, 4,  9, '2026-10-10', 'Rawat Inap', 'Asma kambuh',                         NULL,         'Aktif'),
('REG-2026-0010', 10, 5, 10, '2026-10-15', 'Rawat Inap', 'Demam berdarah',                      NULL,         'Aktif'),
('REG-2026-0011', 11, 2, NULL, '2026-07-20', 'Rawat Jalan', 'Pilek dan batuk',                  NULL,         'Selesai'),
('REG-2026-0012', 12, 7, NULL, '2026-08-05', 'Rawat Jalan', 'Mata merah dan gatal',             NULL,         'Selesai'),
('REG-2026-0013', 13, 3, NULL, '2026-08-12', 'Rawat Jalan', 'Kontrol gigi bulanan',             NULL,         'Selesai'),
('REG-2026-0014', 14, 6, NULL, '2026-09-02', 'Rawat Jalan', 'Kontrol tekanan darah tinggi',     NULL,         'Selesai'),
('REG-2026-0015', 15, 1, NULL, '2026-09-08', 'Rawat Jalan', 'Sakit maag kambuh',                NULL,         'Selesai'),
('REG-2026-0016', 16, 4, NULL, '2026-09-22', 'Rawat Jalan', 'Batuk berkepanjangan',             NULL,         'Selesai'),
('REG-2026-0017', 17, 8, NULL, '2026-10-06', 'Rawat Jalan', 'Radang tenggorokan',               NULL,         'Selesai'),
('REG-2026-0018',  1, 7, NULL, '2026-10-12', 'Rawat Jalan', 'Penglihatan kabur',                NULL,         'Selesai'),
('REG-2026-0019',  2, 1, NULL, '2026-10-18', 'Rawat Jalan', 'Cek kesehatan rutin',              NULL,         'Selesai'),
('REG-2026-0020',  3, 4, NULL, '2026-10-20', 'Rawat Jalan', 'Kontrol pasca rawat inap',         NULL,         'Selesai'),
('REG-2026-0021', 17, 2, NULL, '2026-10-24', 'Rawat Jalan', 'Cek darah',                        NULL,         'Batal');

-- 3.7 Data resep (27 baris. pengurangan stok dilakukan otomatis pada
--     langkah 4.4 agar angka stok tetap konsisten dengan resep)
INSERT INTO resep (id_kunjungan, id_obat, jumlah, dosis) VALUES
( 1,  1, 20, '3x1 tablet sesudah makan'),
( 1,  7,  6, '1x1 intramuscular'),
( 1,  8, 10, '1x1 tablet sesudah makan'),
( 2,  1, 15, '3x1 tablet'),
( 2,  3, 10, '1x1 tablet malam'),
( 3,  2, 21, '3x1 kapsul'),
( 3,  5,  2, '3x1 sendok takar'),
( 3, 11,  1, '2x1 sendok takar'),
( 4,  9, 10, '2x1 unit injeksi'),
( 4, 10, 30, '1x1 tablet pagi'),
( 5,  6,  2, '2x1 aplikasi topikal'),
( 5,  1, 12, '3x1 tablet'),
( 6,  7, 16, '2x1 intravenous'),
( 6,  2, 28, '3x1 kapsul'),
( 6,  8, 20, '1x1 tablet'),
( 7,  4, 14, '2x1 kapsul'),
( 7, 12, 20, '3x1 tablet kunyah'),
( 8, 10, 30, '1x1 tablet pagi'),
( 9,  9,  5, '1x1 unit injeksi'),
(11,  1, 10, '3x1 tablet'),
(12,  3, 10, '1x1 tablet malam'),
(13, 12, 10, '2x1 tablet kunyah'),
(14,  2, 14, '2x1 kapsul'),
(15,  8, 10, '1x1 tablet'),
(16,  5,  2, '3x1 sendok takar'),
(17,  6,  1, '2x1 aplikasi topikal'),
(18, 11,  2, '2x1 sendok takar');

-- 3.8 Data tagihan (15 baris: 7 rawat inap selesai + 8 rawat jalan)
--     biaya_kamar = harga_per_hari x lama inap, biaya_obat dihitung otomatis
--     pada langkah 4.3, biaya_tindakan mengikuti tindakan medis yang dilakukan.
INSERT INTO tagihan
(no_tagihan, id_kunjungan, tgl_tagihan, biaya_kamar, biaya_tindakan, status_bayar) VALUES
('INV-2026-0001',  1, '2026-07-05', 4500000.00,  900000.00, 'Lunas'),
('INV-2026-0002',  2, '2026-07-14', 1800000.00,  600000.00, 'Lunas'),
('INV-2026-0003',  3, '2026-08-04', 4500000.00,  750000.00, 'Lunas'),
('INV-2026-0004',  4, '2026-08-20', 3750000.00, 1200000.00, 'Lunas'),
('INV-2026-0005', 11, '2026-07-20',       0.00,  150000.00, 'Lunas'),
('INV-2026-0006', 12, '2026-08-05',       0.00,  200000.00, 'Lunas'),
('INV-2026-0007',  5, '2026-09-03',  900000.00,  450000.00, 'Belum Bayar'),
('INV-2026-0008',  6, '2026-09-18', 6000000.00, 1500000.00, 'Belum Bayar'),
('INV-2026-0009', 13, '2026-08-12',       0.00,  150000.00, 'Lunas'),
('INV-2026-0010', 14, '2026-09-02',       0.00,  250000.00, 'Belum Bayar'),
('INV-2026-0011', 15, '2026-09-08',       0.00,  150000.00, 'Lunas'),
('INV-2026-0012',  7, '2026-10-04',  750000.00,  500000.00, 'Belum Bayar'),
('INV-2026-0013', 16, '2026-09-22',       0.00,  200000.00, 'Lunas'),
('INV-2026-0014', 17, '2026-10-06',       0.00,  150000.00, 'Belum Bayar'),
('INV-2026-0015', 18, '2026-10-12',       0.00,  300000.00, 'Lunas');


-- ============================================================================
-- BAGIAN 4 : DML - UPDATE DAN DELETE
-- ============================================================================

-- 4.1 UPDATE sederhana: koreksi alamat pasien
UPDATE pasien
   SET alamat = 'Jl. Riau No. 9, Bandung'
 WHERE no_rm = 'RM-2026-0010';

-- 4.2 UPDATE status pembayaran: tagihan INV-2026-0007 dinyatakan lunas
UPDATE tagihan
   SET status_bayar = 'Lunas'
 WHERE no_tagihan = 'INV-2026-0007';

-- 4.3 UPDATE dengan subquery (nested): itung biaya obat tiap tagihan
--     langsung dari tabel resep + obat, lalu total biaya dari ketiga komponen.
UPDATE tagihan t
   SET t.biaya_obat = COALESCE((
           SELECT SUM(o.harga * r.jumlah)
             FROM resep r
             JOIN obat o ON r.id_obat = o.id_obat
            WHERE r.id_kunjungan = t.id_kunjungan), 0);

UPDATE tagihan
   SET total_biaya = biaya_kamar + biaya_obat + biaya_tindakan;

-- 4.4 Sinkronkan stok obat dengan seluruh resep yang sudah tercatat
--     (pengurangan manual saat load data sama setelah ini trigger baru dibuat)
UPDATE obat o
   SET o.stok = o.stok - COALESCE((
           SELECT SUM(r.jumlah)
             FROM resep r
            WHERE r.id_obat = o.id_obat), 0);

-- 4.5 Sinkronkan status kamar dengan kunjungan rawat inap yang masih Aktif
UPDATE kamar k
   JOIN kunjungan kj ON kj.id_kamar = k.id_kamar AND kj.status = 'Aktif'
    SET k.status = 'Terisi';

-- 4.6 DELETE: hapus kunjungan berstatus Batal (relasi resep/tagihan ikut aman)
DELETE FROM kunjungan
 WHERE status = 'Batal';



-- ============================================================================
-- BAGIAN 5 : IMPLEMENTASI JOIN
-- ============================================================================

-- 5.1 INNER JOIN 4 tabel: daftar semua kunjungan (pasien, dokter, poliklinik)
SELECT kj.no_registrasi, p.nama_pasien, d.nama_dokter, pl.nama_poli,
       kj.tipe_kunjungan, kj.tgl_kunjungan, kj.status
  FROM kunjungan kj
  INNER JOIN pasien p      ON kj.id_pasien = p.id_pasien
  INNER JOIN dokter d      ON kj.id_dokter = d.id_dokter
  INNER JOIN poliklinik pl ON d.id_poli    = pl.id_poli
 ORDER BY kj.tgl_kunjungan;

-- 5.2 JOIN 5 tabel: detail rawat inap lengkap dengan kamar + lama inap
SELECT kj.no_registrasi, p.nama_pasien, d.nama_dokter, k.no_kamar,
       k.tipe_kamar, k.harga_per_hari,
       DATEDIFF(kj.tgl_keluar, kj.tgl_kunjungan) AS lama_inap_hari
  FROM kunjungan kj
  INNER JOIN pasien p ON kj.id_pasien = p.id_pasien
  INNER JOIN dokter d ON kj.id_dokter = d.id_dokter
  INNER JOIN kamar k  ON kj.id_kamar  = k.id_kamar
 WHERE kj.tipe_kunjungan = 'Rawat Inap'
 ORDER BY kj.tgl_kunjungan;

-- 5.3 LEFT JOIN + IS NULL: pasien yang BELUM PERNAH berobat
SELECT p.no_rm, p.nama_pasien, p.no_telp
  FROM pasien p
  LEFT JOIN kunjungan kj ON p.id_pasien = kj.id_pasien
 WHERE kj.id_kunjungan IS NULL;

-- 5.4 LEFT JOIN + IS NULL: kunjungan yang belum memiliki tagihan
SELECT kj.no_registrasi, p.nama_pasien, kj.tgl_kunjungan, kj.status
  FROM kunjungan kj
  INNER JOIN pasien p  ON kj.id_pasien  = p.id_pasien
  LEFT  JOIN tagihan t ON kj.id_kunjungan = t.id_kunjungan
 WHERE t.id_tagihan IS NULL;


-- ============================================================================
-- BAGIAN 6 : PENGGUNAAN ALIAS DAN OPERATOR SQL
-- ============================================================================

-- 6.1 Operator BETWEEN (rentang tanggal) dan AND
SELECT kj.no_registrasi, p.nama_pasien, kj.tgl_kunjungan, kj.tipe_kunjungan
  FROM kunjungan kj
  INNER JOIN pasien p ON kj.id_pasien = p.id_pasien
 WHERE kj.tgl_kunjungan BETWEEN '2026-10-01' AND '2026-10-31'
   AND kj.status <> 'Batal';

-- 6.2 Operator LIKE (pola teks) dan OR
SELECT p.no_rm, p.nama_pasien, p.alamat
  FROM pasien p
 WHERE p.nama_pasien LIKE '%wan%'
    OR p.alamat LIKE '%Cimahi%';

-- 6.3 Operator IN (anggota himpunan)
SELECT kj.no_registrasi, d.nama_dokter, d.spesialis, kj.tgl_kunjungan
  FROM kunjungan kj
  INNER JOIN dokter d ON kj.id_dokter = d.id_dokter
 WHERE kj.id_dokter IN (6, 9);

-- 6.4 Operator perbandingan + logika (AND, OR, tanda kurung)
SELECT o.nama_obat, o.jenis_obat, o.harga, o.stok
  FROM obat o
 WHERE (o.harga > 10000 AND o.stok < 500)
    OR o.jenis_obat = 'Injeksi';

-- 6.5 Operator IS NULL / IS NOT NULL
SELECT kj.no_registrasi, p.nama_pasien, kj.status
  FROM kunjungan kj
  INNER JOIN pasien p ON kj.id_pasien = p.id_pasien
 WHERE kj.id_kamar IS NOT NULL
   AND kj.tgl_keluar IS NULL;

-- 6.6 Alias kolom + fungsi teks CONCAT pada hasil
SELECT CONCAT(p.nama_pasien, ' (', p.no_rm, ')') AS identitas_pasien,
       p.gol_darah
  FROM pasien p
 ORDER BY p.nama_pasien;


-- ============================================================================
-- BAGIAN 7 : PENGGUNAAN FUNCTION (AGREGAT & SCALAR)
-- ============================================================================

-- 7.1 COUNT: jumlah baris data
SELECT COUNT(*) AS jumlah_pasien FROM pasien;
SELECT COUNT(*) AS jumlah_kunjungan_aktif FROM kunjungan WHERE status = 'Aktif';

-- 7.2 SUM, AVG, MAX, MIN + ROUND: statistik tagihan
SELECT COUNT(*)              AS jumlah_tagihan,
       SUM(total_biaya)      AS total_pendapatan,
       ROUND(AVG(total_biaya), 2) AS rata_rata_biaya,
       MAX(total_biaya)      AS tagihan_tertinggi,
       MIN(total_biaya)      AS tagihan_terendah
  FROM tagihan;

-- 7.3 Function tanggal (YEAR, DATEDIFF) dan COALESCE
SELECT p.nama_pasien,
       p.tgl_lahir,
       YEAR(CURDATE()) - YEAR(p.tgl_lahir) AS umur_tahun,
       COALESCE(p.gol_darah, 'Belum diperiksa') AS gol_darah_info
  FROM pasien p
 ORDER BY p.tgl_lahir
 LIMIT 5;


-- ============================================================================
-- BAGIAN 8 : GROUPING (GROUP BY, HAVING) DAN SORTING (ORDER BY, LIMIT)
-- ============================================================================

-- 8.1 GROUP BY: jumlah kunjungan per dokter (LEFT JOIN agar dokter tanpa
--     kunjungan tetap tampil dengan nilai 0)
SELECT d.nama_dokter, pl.nama_poli,
       COUNT(kj.id_kunjungan) AS jumlah_kunjungan
  FROM dokter d
  LEFT JOIN kunjungan kj ON d.id_dokter = kj.id_dokter
  INNER JOIN poliklinik pl ON d.id_poli = pl.id_poli
 GROUP BY d.id_dokter, d.nama_dokter, pl.nama_poli
 ORDER BY jumlah_kunjungan DESC, d.nama_dokter;

-- 8.2 GROUP BY + HAVING: tipe kamar dengan pendapatan kamar di atas 1 juta
SELECT k.tipe_kamar,
       SUM(t.biaya_kamar) AS total_pendapatan_kamar,
       COUNT(*)           AS banyak_pasien
  FROM tagihan t
  INNER JOIN kunjungan kj ON t.id_kunjungan = kj.id_kunjungan
  INNER JOIN kamar k      ON kj.id_kamar   = k.id_kamar
 GROUP BY k.tipe_kamar
HAVING SUM(t.biaya_kamar) > 1000000
 ORDER BY total_pendapatan_kamar DESC;

-- 8.3 GROUP BY 2 kolom: nilai resep per jenis obat
SELECT o.jenis_obat,
       COUNT(r.id_resep)     AS banyak_resep,
       SUM(o.harga * r.jumlah) AS total_nilai_resep
  FROM resep r
  INNER JOIN obat o ON r.id_obat = o.id_obat
 GROUP BY o.jenis_obat
 ORDER BY total_nilai_resep DESC;

-- 8.4 ORDER BY beberapa kolom + LIMIT: 5 tagihan terbesar
SELECT t.no_tagihan, p.nama_pasien, t.total_biaya, t.status_bayar
  FROM tagihan t
  INNER JOIN kunjungan kj ON t.id_kunjungan = kj.id_kunjungan
  INNER JOIN pasien p     ON kj.id_pasien  = p.id_pasien
 ORDER BY t.total_biaya DESC, t.no_tagihan ASC
 LIMIT 5;


-- ============================================================================
-- BAGIAN 9 : NESTED QUERY (SUBQUERY)
-- ============================================================================

-- 9.1 Nested + GROUP BY + HAVING di dalam subquery:
--     obat yang pernah diresepkan lebih dari 2 kali
SELECT o.nama_obat, o.jenis_obat, o.stok
  FROM obat o
 WHERE o.id_obat IN (
        SELECT r.id_obat
          FROM resep r
         GROUP BY r.id_obat
        HAVING COUNT(*) > 2);

-- 9.2 Nested query 3 tingkat: pasien dengan total tagihan di atas
--     rata-rata seluruh tagihan
SELECT p.no_rm, p.nama_pasien
  FROM pasien p
 WHERE p.id_pasien IN (
        SELECT kj.id_pasien
          FROM kunjungan kj
         WHERE kj.id_kunjungan IN (
                SELECT t.id_kunjungan
                  FROM tagihan t
                 WHERE t.total_biaya > (SELECT AVG(total_biaya) FROM tagihan)));

-- 9.3 Correlated subquery: dokter yang jumlah kunjangannya di atas
--     rata-rata kunjungan per dokter
SELECT d.nama_dokter, d.spesialis,
       (SELECT COUNT(*) FROM kunjungan kj WHERE kj.id_dokter = d.id_dokter)
           AS jumlah_kunjungan
  FROM dokter d
 WHERE (SELECT COUNT(*) FROM kunjungan kj WHERE kj.id_dokter = d.id_dokter)
           > (SELECT COUNT(*) / COUNT(DISTINCT id_dokter) FROM kunjungan);



-- ============================================================================
-- BAGIAN 10 : VIEW
-- ============================================================================

-- 10.1 View kamar yang tersedia (siap dipakai resepsionis)
CREATE VIEW vw_kamar_tersedia AS
SELECT id_kamar, no_kamar, tipe_kamar, harga_per_hari
  FROM kamar
 WHERE status = 'Kosong';

-- 10.2 View riwayat kunjungan lengkap (JOIN 5 tabel, siap pakai untuk laporan)
CREATE VIEW vw_riwayat_kunjungan AS
SELECT kj.no_registrasi,
       p.no_rm,
       p.nama_pasien,
       d.nama_dokter,
       pl.nama_poli,
       kj.tipe_kunjungan,
       kj.tgl_kunjungan,
       k.no_kamar,
       kj.status
  FROM kunjungan kj
  INNER JOIN pasien p      ON kj.id_pasien = p.id_pasien
  INNER JOIN dokter d      ON kj.id_dokter = d.id_dokter
  INNER JOIN poliklinik pl ON d.id_poli    = pl.id_poli
  LEFT  JOIN kamar k       ON kj.id_kamar  = k.id_kamar;

-- 10.3 View daftar tagihan yang belum dibayar
CREATE VIEW vw_tagihan_belum_bayar AS
SELECT t.no_tagihan,
       p.no_rm,
       p.nama_pasien,
       kj.no_registrasi,
       t.tgl_tagihan,
       t.total_biaya
  FROM tagihan t
  INNER JOIN kunjungan kj ON t.id_kunjungan = kj.id_kunjungan
  INNER JOIN pasien p     ON kj.id_pasien  = p.id_pasien
 WHERE t.status_bayar = 'Belum Bayar';

-- Menguji ketiga view
SELECT * FROM vw_kamar_tersedia;
SELECT * FROM vw_riwayat_kunjungan;
SELECT * FROM vw_tagihan_belum_bayar;


-- ============================================================================
-- BAGIAN 11 : STORED PROCEDURE (2 buah)
-- ============================================================================

-- 11.1 SP pencarian pasien berdasarkan nama / nomor rekam medis
-- PERBAIKAN: Menambahkan COLLATE utf8mb4_unicode_ci untuk mencegah Error 1267
CREATE PROCEDURE sp_daftar_pasien (IN p_keyword VARCHAR(100))
BEGIN
    SELECT p.no_rm, p.nama_pasien, p.jenis_kelamin,
           p.tgl_lahir, p.alamat, p.no_telp
      FROM pasien p
     WHERE p.nama_pasien COLLATE utf8mb4_unicode_ci LIKE CONCAT('%', p_keyword, '%')
        OR p.no_rm COLLATE utf8mb4_unicode_ci LIKE CONCAT('%', p_keyword, '%');
END;

-- 11.2 SP pendaftaran pasien baru dengan nomor rekam medis otomatis
CREATE PROCEDURE sp_tambah_pasien (
    IN  p_nama   VARCHAR(100),
    IN  p_jk     CHAR(1),
    IN  p_lahir  DATE,
    IN  p_alamat VARCHAR(150),
    IN  p_telp   VARCHAR(15),
    IN  p_gol    CHAR(2),
    OUT p_id     INT
)
BEGIN
    DECLARE v_nomor INT;
    DECLARE v_no_rm VARCHAR(12);

    -- nomor RM berurutan: RM-<tahun>-<urutan 4 digit>
    SELECT COALESCE(MAX(CAST(SUBSTRING(no_rm, 9) AS UNSIGNED)), 0) + 1
      INTO v_nomor
      FROM pasien;

    SET v_no_rm = CONCAT('RM-', YEAR(CURDATE()), '-', LPAD(v_nomor, 4, '0'));

    INSERT INTO pasien (no_rm, nama_pasien, jenis_kelamin, tgl_lahir,
                        alamat, no_telp, gol_darah)
    VALUES (v_no_rm, p_nama, p_jk, p_lahir, p_alamat, p_telp,
            NULLIF(p_gol, '-'));

    SET p_id = LAST_INSERT_ID();
END;

-- 11.3 SP penghitung ulang tagihan (biaya kamar + obat + tindakan)
CREATE PROCEDURE sp_hitung_tagihan (IN p_id_kunjungan INT)
BEGIN
    DECLARE v_biaya_kamar DECIMAL(12,2) DEFAULT 0;
    DECLARE v_biaya_obat  DECIMAL(12,2) DEFAULT 0;

    -- biaya kamar = harga per hari x lama inap (0 bila rawat jalan)
    SELECT COALESCE(k.harga_per_hari *
                    DATEDIFF(COALESCE(kj.tgl_keluar, CURDATE()),
                             kj.tgl_kunjungan), 0)
      INTO v_biaya_kamar
      FROM kunjungan kj
      LEFT JOIN kamar k ON kj.id_kamar = k.id_kamar
     WHERE kj.id_kunjungan = p_id_kunjungan;

    -- biaya obat = SUM(harga obat x jumlah) dari tabel resep
    SELECT COALESCE(SUM(o.harga * r.jumlah), 0)
      INTO v_biaya_obat
      FROM resep r
      INNER JOIN obat o ON r.id_obat = o.id_obat
     WHERE r.id_kunjungan = p_id_kunjungan;

    UPDATE tagihan
       SET biaya_kamar  = v_biaya_kamar,
           biaya_obat   = v_biaya_obat,
           total_biaya  = v_biaya_kamar + v_biaya_obat + biaya_tindakan
     WHERE id_kunjungan = p_id_kunjungan;
END;


-- Pemanggilan / pengujian stored procedure
CALL sp_daftar_pasien('siti');

CALL sp_tambah_pasien('Nadia Safira', 'P', '2002-06-15',
                      'Jl. Cimahi No. 5, Cimahi', '081322220001', 'A',
                      @id_pasien_baru);
SELECT * FROM pasien WHERE id_pasien = @id_pasien_baru;

SELECT no_tagihan, total_biaya FROM tagihan WHERE id_kunjungan = 6;
CALL sp_hitung_tagihan(6);
SELECT no_tagihan, total_biaya FROM tagihan WHERE id_kunjungan = 6;  


-- ============================================================================
-- BAGIAN 12 : TRIGGER (2 wajib + 1 bonus)
-- ============================================================================

-- 12.1 Trigger: pasien masuk rawat inap -> status kamar otomatis 'Terisi'
CREATE TRIGGER trg_kamar_terisi
AFTER INSERT ON kunjungan
FOR EACH ROW
BEGIN
    IF NEW.id_kamar IS NOT NULL THEN
        UPDATE kamar
           SET status = 'Terisi'
         WHERE id_kamar = NEW.id_kamar;
    END IF;
END;

-- 12.2 Trigger: resep baru -> stok obat otomatis berkurang,
--     dan menolak transaksi bila stok tidak mencukupi (SIGNAL)
CREATE TRIGGER trg_resep_kurangi_stok
AFTER INSERT ON resep
FOR EACH ROW
BEGIN
    DECLARE v_stok INT;

    SELECT stok INTO v_stok
      FROM obat
     WHERE id_obat = NEW.id_obat;

    IF v_stok < NEW.jumlah THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaksi ditolak: stok obat tidak mencukupi';
    ELSE
        UPDATE obat
           SET stok = stok - NEW.jumlah
         WHERE id_obat = NEW.id_obat;
    END IF;
END;

-- 12.3 Trigger (bonus): pasien pulang -> status kamar otomatis 'Kosong'
CREATE TRIGGER trg_kamar_kosong
AFTER UPDATE ON kunjungan
FOR EACH ROW
BEGIN
    IF NEW.id_kamar IS NOT NULL
       AND OLD.tgl_keluar IS NULL
       AND NEW.tgl_keluar IS NOT NULL THEN
        UPDATE kamar
           SET status = 'Kosong'
         WHERE id_kamar = NEW.id_kamar;
    END IF;
END;


-- ---- Pengujian trigger 1: kamar berubah Kosong -> Terisi ------------------
SELECT no_kamar, status FROM kamar WHERE id_kamar = 11;   -- sebelum: Kosong
INSERT INTO kunjungan
    (no_registrasi, id_pasien, id_dokter, id_kamar, tgl_kunjungan,
     tipe_kunjungan, keluhan, status)
VALUES
    ('REG-2026-0022', 18, 1, 11, '2026-10-28', 'Rawat Inap',
     'Demam 3 hari', 'Aktif');
SELECT no_kamar, status FROM kamar WHERE id_kamar = 11;   -- sesudah: Terisi

-- ---- Pengujian trigger 2: stok obat berkurang otomatis --------------------
SELECT nama_obat, stok FROM obat WHERE id_obat = 1;       -- sebelum: 943
INSERT INTO resep (id_kunjungan, id_obat, jumlah, dosis)
VALUES ((SELECT id_kunjungan FROM kunjungan WHERE no_registrasi = 'REG-2026-0022'),
        1, 5, '3x1 tablet');
SELECT nama_obat, stok FROM obat WHERE id_obat = 1;       -- sesudah: 938


-- ---- Pengujian trigger 3: kamar berubah Terisi -> Kosong ------------------
UPDATE kunjungan
   SET tgl_keluar = '2026-10-29', status = 'Selesai'
 WHERE no_registrasi = 'REG-2026-0022';
SELECT no_kamar, status FROM kamar WHERE id_kamar = 11;   -- sesudah: Kosong


-- ============================================================================
-- BAGIAN 13 : DCL - DATA CONTROL LANGUAGE (GRANT / REVOKE)
-- bagian ini tuh harus dijalankan sebagai root/admin. Perintah DROP USER
--          membuat file tetap bisa dijalankan ulang tanpa error.
-- ============================================================================

DROP USER IF EXISTS 'admin_rs'  @'localhost';
DROP USER IF EXISTS 'staf_rs'   @'localhost';

-- 13.1 Membuat 2 user dengan tingkat hak akses berbeda
CREATE USER 'admin_rs'@'localhost' IDENTIFIED BY 'Admin123!';
CREATE USER 'staf_rs'  @'localhost' IDENTIFIED BY 'Staf123!';

-- 13.2 Admin RS: hak penuh atas database rumah_sakit
GRANT ALL PRIVILEGES ON rumah_sakit.* TO 'admin_rs'@'localhost';

-- 13.3 Staf pendaftaran: hanya boleh melihat/mengisi data tertentu
GRANT SELECT, INSERT, UPDATE ON rumah_sakit.pasien     TO 'staf_rs'@'localhost';
GRANT SELECT, INSERT          ON rumah_sakit.kunjungan TO 'staf_rs'@'localhost';
GRANT SELECT                  ON rumah_sakit.tagihan   TO 'staf_rs'@'localhost';
GRANT SELECT                  ON rumah_sakit.obat      TO 'staf_rs'@'localhost';

-- 13.4 Hak akses sebelum dan sesudah REVOKE
SHOW GRANTS FOR 'staf_rs'@'localhost';
REVOKE INSERT ON rumah_sakit.pasien FROM 'staf_rs'@'localhost';
SHOW GRANTS FOR 'staf_rs'@'localhost';   -- INSERT pasien sudah hilang

-- 13.5 Mengaktifkan ulang konfigurasi hak akses
FLUSH PRIVILEGES;


-- ============================================================================
-- BAGIAN 14 : VERIFIKASI AKHIR (jumlah baris tiap tabel)
-- ============================================================================

SELECT 'poliklinik' AS tabel, COUNT(*) AS jumlah_baris FROM poliklinik
UNION ALL SELECT 'dokter',   COUNT(*) FROM dokter
UNION ALL SELECT 'pasien',   COUNT(*) FROM pasien
UNION ALL SELECT 'kamar',    COUNT(*) FROM kamar
UNION ALL SELECT 'kunjungan',COUNT(*) FROM kunjungan
UNION ALL SELECT 'obat',     COUNT(*) FROM obat
UNION ALL SELECT 'resep',    COUNT(*) FROM resep
UNION ALL SELECT 'tagihan',  COUNT(*) FROM tagihan;