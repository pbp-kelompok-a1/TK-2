# ParaWorld 🌟

**"Celebrating achievements, sharing stories, and connecting the world of Paralympic sports."**

ParaWorld adalah aplikasi berbasis web yang menghadirkan informasi seputar Paralympic Games internasional, mulai dari profil atlet dunia, berita terbaru, hingga jadwal event penting. Aplikasi ini bertujuan untuk memperluas pengetahuan masyarakat tentang olahraga difabel serta menjadi wadah apresiasi terhadap perjuangan dan prestasi para atlet Paralympic.

Di ParaWorld, pengguna dapat membaca berita terkini, memberikan komentar pada konten berita, serta melihat detail profil atlet yang mencakup data pribadi, cabang olahraga, dan rangkaian prestasi yang pernah diraih. Selain itu, pengguna dapat mengikuti cabang olahraga tertentu melalui fitur following. Cabang olahraga yang diikuti akan diprioritaskan pada bagian fitur berita dan events, sehingga informasi yang relevan tampil lebih dulu. Konten lainnya tetap tersedia namun ditampilkan dengan prioritas yang lebih rendah.

---

## 📅 Fitur Unggulan

- 🌍 **Berita Global (News)**: Update berita internasional tentang Paralympic Games, hasil pertandingan, dan tren olahraga difabel di seluruh dunia.
- 🏅 **Profil Atlet**: Informasi lengkap tentang atlet dari berbagai negara: biodata, cabang olahraga, prestasi, hingga riwayat medali.
- 📆 **Events & Jadwal**: Kalender berisi jadwal pertandingan Paralympic, kegiatan komunitas, serta event lain yang dibuat oleh admin maupun pengguna. Informasi mencakup detail cabang olahraga, lokasi, dan tanggal penyelenggaraan.
- 💬 **Comment**: Tempat bagi para pengguna dari berbagai negara untuk berdiskusi, berbagi opini, dan saling memberi dukungan kepada atlet Paralympic.  
- ⭐ **Following**: Pengguna dapat mengikuti cabang olahraga tertentu. News dan Events yang berkaitan dengan cabang tersebut akan diberikan prioritas lebih tinggi, sementara konten lain tetap tersedia namun ditampilkan dengan prioritas yang lebih rendah.

---

## ⚙️ Proses Integrasi

1. Backend (Django) sebagai Penyedia Data:
- Logic yang sudah dibuat pada proyek web sebelumnya dimanfaatkan kembali.
- Kita membuat view baru di Django yang mengembalikan respon dalam format JSON, bukan HTML.
- URL endpoint didefinisikan di urls.py untuk diakses oleh aplikasi mobile.
2. Pertukaran Data & Model (Flutter):
- Flutter melakukan HTTP Request (GET untuk mengambil data, POST untuk mengirim data) ke URL endpoint Django yang telah dibuat.
- Data JSON yang diterima dari Django akan dikonversi menjadi objek Dart menggunakan Model Class yang telah dibuat (bisa digenerate menggunakan Quicktype) agar tipe datanya terstruktur dan valid.
3. Autentikasi & State Management:
- Untuk menangani login dan logout, aplikasi menggunakan package/library pbp_django_auth (atau CookieRequest).
- Library ini berfungsi menyimpan Cookie session dari Django secara lokal di aplikasi Flutter. Hal tersebut memastikan server tahu siapa user yang sedang aktif melakukan request tanpa perlu login ulang di setiap halaman.
4. Tampilan Antarmuka (UI):
- UI aplikasi dibangun secara dinamis menggunakan widget FutureBuilder (untuk data async) yang akan me-render tampilan berdasarkan data JSON yang berhasil diambil dari server.

---

## 📚 Modul & Deskripsi

| Modul | Deskripsi | Developer | CRUD |
|-------|-----------|-----------|------|
| **Berita Global** | Admin dapat membuat, mengedit, dan menghapus berita. User terautentikasi dapat membaca & memberi komentar pada berita tersebut. user tidak terutentikasi hanya dapat membaca berita| Delila Isrina Aroyo |  👤_Guest_: Read Only <br> 👤✅ _Member_: R <br> 👑 _Admin_: C-R-U-D |
| **Comment** | User tidak terautentikasi hanya dapat membaca komentar. User terautentikasi dapat membuat, mengedit, dan menghapus komentar sendiri. Admin dapat membuat dan mengedit komentar serta memiliki akses untuk menghapus komentar orang lain. | Ilham Shahputra Hasim | 👤_Guest_: Read Only <br> 👤✅ _Member_: C-R-U-D(own comment) <br> 👑 _Admin_: C-U(own comment) and R-D(all comment)  |
| **Event & Jadwal** | Modul Event & Jadwal berfungsi sebagai pusat informasi event dengan pemisahan tegas antara konten umum dan pribadi. Inti dari modul ini adalah menginformasikan Event Global (acara resmi, pengumuman umum, atau kegiatan situs yang dikelola Administrator) dan memungkinkan Event Pribadi (agenda, jadwal latihan, atau sparring yang dibuat oleh pengguna terautentikasi untuk keperluan mereka sendiri). Pengguna yang tidak terautentikasi (guest) hanya bisa melihat informasi dan tidak bisa menambahkan event pribadi. | Ahmad Anggara Bayuadji Prawirosoenoto | 👤 _Guest_: Read Only <br> 👤✅ _Member_: C-R-U-D <br> 👑 _Admin_: C-R-U-D|
| **Profil Atlet** | Modul Profil Atlet berfungsi sebagai ensiklopedia digital mengenai para atlet Paralimpiade. Database-nya diisi secara efisien melalui impor data massal dari file CSV (_dataset_ Kaggle) untuk memastikan kelengkapan data. Modul ini menerapkan sistem hak akses berjenjang yang membedakan konten berdasarkan status _login_ pengguna: 👤 _Guest_ (Pengunjung Biasa), yaitu pengguna yang tidak _login_ sama sekali. Mereka hanya bisa membaca (_Read_) daftar nama atlet (_name_), negara asal (_country_), dan cabang olahraga (_discipline_) secara umum. Mereka tidak bisa melihat detail lengkap, membuat, mengedit, atau menghapus profil. 👤✅ _Member_ (Pengguna Terautentikasi), yaitu pengguna yang sudah mendaftar dan _login_. Hak akses mereka meningkat menjadi bisa membaca (_Read_) profil atlet secara lengkap dan mendetail, seperti _gender_, _birth_date_, _birth_place_, _birth_country_, _nationality_, bahkan _medal_type_ (Emas, Perak, Perunggu), _event_ (Contoh: Men's 100m Freestyle S5), _medal_date_ (Tahun atau tanggal medali diraih). Namun, mereka tetap tidak bisa membuat profil baru, mengedit data, atau menghapusnya. 👑 _Admin_ (_Administrator_), yaitu pengelola situs dengan hak akses tertinggi. Admin memiliki kontrol penuh. Mereka bisa Membuat (_Create_) profil atlet baru, Membaca (_Read_) semua data tanpa batasan, Mengedit (_Update_) semua informasi profil termasuk status visibilitas, dan Menghapus (_Delete_) profil dari _database_. Fitur visibilitas diatur agar admin dapat menyembunyikan sementara profil atlet dari publik, misalnya saat datanya belum lengkap atau perlu diverifikasi, tanpa harus menghapusnya secara permanen. | Nicholas Vesakha | 👤 _Guest_: R (_Read-Only_, Terbatas) <br> 👤✅ _Member_: R (_Read-Only_, Penuh) <br> 👑 _Admin_ (_Administrator_): C-R-U-D (Penuh) |
| **Following** | User dapat mengikuti cabang olahraga untuk update berita/event. | Angelo Benhanan Abinaya Fuun | 👤 _Guest_: - <br> 👤✅ _Member_: C-R-D <br> 👑 _Admin_ (_Administrator_): C-R-D |
| **Custom User** | User memiliki akun dengan atribut-atribut extra seperti full name, description, dan join date. | Angelo Benhanan Abinaya Fuun | 👤 _Guest_: R <br> 👤✅ _Member_: C-R-U (hanya dapat memodifikasi akun pribadi) <br> 👑 _Admin_ (_Administrator_): C-R-U-D (dapat memodifikasi setiap akun) |
| **Cabang Olahraga** | Cabang olahraga yang terdaftar. | Angelo Benhanan Abinaya Fuun | 👤 _Guest_: R <br> 👤✅ _Member_: R <br> 👑 _Admin_ (_Administrator_): C-R-U-D |

---

## 🕵️ Role / Peran Pengguna

| Role | Hak Akses |
|------|-----------|
| **Admin** | Memiliki kontrol penuh untuk mengelola seluruh data sistem, termasuk membuat dan memoderasi berita, event global, komentar, serta manajemen profil atlet dan akun pengguna secara menyeluruh. |
| **User Terautentikasi (Member)** | Dapat mengakses detail lengkap profil atlet, membuat event komunitas, berinteraksi melalui komentar, serta mempersonalisasi konten berita dan event menggunakan fitur following. |
| **User Tidak Terautentikasi (Guest)** | Hanya memiliki akses baca terbatas (read-only) untuk melihat berita, event umum, dan informasi dasar atlet tanpa fitur interaksi atau akses ke detail data mendalam. |

---

## 👥 Anggota Kelompok A01

| No | NPM | Nama |
|----|-----|------|
| 1 | 2406495514 | Ahmad Anggara Bayuadji Prawirosoenoto |
| 2 | 2406405374 | Delila Isrina Aroyo |
| 3 | 2406495804 | Nicholas Vesakha |
| 4 | 2406495432 | Angelo Benhanan Abinaya Fuun |
| 5 | 2406401193 | Ilham Shahputra Hasim |

---

## 🔗 Sumber Dataset

- [Tokyo 2020 Paralympics Dataset (Kaggle)](https://www.kaggle.com/datasets/piterfm/tokyo-2020-paralympics)  

---

## 🌐 Tautan APK & Design

- PARAWORLD [![Build Status](https://app.bitrise.io/app/d688ddf3-7cf2-4a80-a3d4-4d4a58b392da/status.svg?token=tfHoacHudyeeNWjK3nPGhQ&branch=master)](https://app.bitrise.io/app/d688ddf3-7cf2-4a80-a3d4-4d4a58b392da)
- **Link Download APK**: https://app.bitrise.io/app/d688ddf3-7cf2-4a80-a3d4-4d4a58b392da/installable-artifacts/743dcc717c677262/public-install-page/7f46b28b7417c0bd7c73ff7da2ac42cb
- **Link Design (Figma)**: https://www.figma.com/design/yqei3c8chnYDVT8bl7F4dD/Design-Web-A1?node-id=28-3&t=T5QoflADc6s3ku5s-1

--

## Tautan Planning Kelompok

- https://docs.google.com/spreadsheets/d/1TlfKbF008WlRihQfwOKttp3bL5nmnV653LTGLkguOJc/edit?gid=577760875#gid=577760875

--

## Video Promosi

- https://drive.google.com/drive/folders/17fbOdWcb2AZBSnRQObegiT5OKp7MFGbn











