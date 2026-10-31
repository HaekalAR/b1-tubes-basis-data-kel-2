#  Tugas Besar Praktikum Basis Data - Kelas B1

Repositori ini berisi kode sumber (*source code*) dan laporan untuk Tugas Besar Praktikum Basis Data Lanjut. Proyek ini berfokus pada perancangan dan implementasi basis data relasional untuk **Sistem Informasi Manajemen Rumah Sakit** menggunakan MySQL/MariaDB.

##  Deskripsi Proyek

Proyek ini mensimulasikan kebutuhan basis data sebuah rumah sakit umum fiktif yang memiliki **8 poliklinik**. Sistem ini dirancang untuk mengelola data pasien, dokter, jadwal kunjungan (rawat jalan & rawat inap), ketersediaan kamar, resep obat, hingga transaksi tagihan pembayaran pasien.

Tujuan proyek ini adalah menerapkan konsep basis data secara komprehensif, mulai dari perancangan konseptual (ERD), transformasi ke skema relasional, hingga implementasi teknis menggunakan SQL (DDL, DML, DCL, View, Stored Procedure, dan Trigger).

##  Fitur Basis Data

Pada file SQL yang kami buat, terdapat beberapa fitur utama:

### 1. Relasi Kompleks
8 tabel yang saling berelasi (1:1, 1:N, dan M:N) yang dijaga oleh *Primary Key* dan *Foreign Key*.

### 2. Otomatisasi (Trigger)
- Status kamar otomatis berubah menjadi **'Terisi'** saat pasien di-insert ke rawat inap.
- Stok obat otomatis berkurang saat resep baru dicatat (dilengkapi validasi `SIGNAL` jika stok kurang).
- Status kamar kembali **'Kosong'** saat pasien di-update tanggal keluarnya.

### 3. Stored Procedure

| Nama | Fungsi |
|------|--------|
| `sp_daftar_pasien` | Pencarian pasien berdasarkan nama / no. RM |
| `sp_tambah_pasien` | Pendaftaran pasien baru dengan pembuatan nomor RM otomatis |
| `sp_hitung_tagihan` | Penghitungan ulang biaya total (kamar + obat + tindakan) |

### 4. View (Laporan Cepat)
View siap pakai untuk:
- Kamar tersedia
- Riwayat kunjungan lengkap
- Daftar tagihan belum dibayar

### 5. Keamanan (DCL)
Pengaturan hak akses terbatas (*Least Privilege*) untuk peran `admin_rs` dan `staf_rs`.

##  Struktur Repositori

```
 tubes-basis-data-rumah-sakit
 ┣  basda-rs.sql                      # File SQL utama (DDL, DML, View, SP, Trigger, DCL)
 ┣  Laporan_Tugas_Besar_Kelompok.pdf  # Laporan lengkap (ERD, Kamus Data, Pembahasan)
 ┗  README.md                         # Dokumentasi repositori ini
```

##  Cara Menjalankan

### Prasyarat
- MySQL terpasang dan berjalan di lokal
- Salah satu DBMS: Beekeeper Studio, DBeaver, atau phpMyAdmin

### Menggunakan Beekeeper Studio / DBeaver / phpMyAdmin

1. Buka aplikasi klien database kamu dan hubungkan ke server MySQL lokal.
2. **Jangan pilih database spesifik**, biarkan berada di level server (karena script akan membuat database `rumah_sakit` secara otomatis).
3. Buka tab **Query / SQL Editor** baru.
4. Copy seluruh isi file `basda-rs.sql` dan paste ke dalam editor.
5. Klik **Run All** (atau tekan `F5` / `Ctrl+Enter`) untuk mengeksekusi seluruh perintah.
6. Refresh panel database di sebelah kiri untuk melihat tabel yang sudah dibuat.

##  Anggota Kelompok

| Nama | NPM | Peran |
|------|-----|-------|
| Karel Desvalyudho | G1A025040 | Koordinator, Analisis Kebutuhan, ERD, Skema Relasi |
| Rackell Patrix Rakendra | G1A025020 | Implementasi DDL, DML, Data Dummy, UPDATE/DELETE |
| Haekal Abdillah Ramadhan | G1A025004 | Implementasi JOIN, Operator, Function, Grouping, Nested Query |
| Kaysa Naura | G1A025016 | Implementasi VIEW, Stored Procedure, Trigger |
| Rafi Andika | G1A025048 | Implementasi DCL, Pengujian, Export SQL, Laporan |
