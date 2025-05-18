1.Proje Özeti

-Bu bir araç servis randevu ve parça sipariş yönetim sistemi. 
Fonksiyonlar-
-“Admin” ve “User” rolleri ayrı ayrı yetkilendirme.
-Müşteriler araçları için randevu oluşturur ve parça siparişi verir.
-Admin tarafı hizmet, personel, parça ve siparişleri yönetir.

2.Geliştirme Ortamı
-Veritabanı: MySQL (XAMPP)
-Backend: Next.js (Node.js v18+)
-Frontend: Flutter (Channel stable, Flutter 3.29.3)
-IDE’ler: VS Code (backend & Flutter), Android Studio (emülatör)

3. Kurulum & Çalıştırma
-XAMPP Kontrol Panel’den Apache ve MySQL’i başlatın.
-phpMyAdmin üzerinden car_service_db veritabanını import edin.
-VS Code ile proje klasörünü açın.
-"cd backend
 cp .env.example .env
 #  .env içine MySQL ve JWT ayarlarını girin
 npm install
 npm run dev" kodlarını proje kökünde terminale girin ve backendi çalıştırın.
-Android Studio'yu açın. AVD Manager ile bir cihaz oluşturup çalıştırın.
-"cd frontend
flutter pub get
flutter run" kodları ile frontendi çalıştırın.
-Bu işlemler sonrası uygulama emilatörde otomatik olarak başlayacaktır.

