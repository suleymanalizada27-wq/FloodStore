Floodstore tam hesabat · MDFloodStore — Tam Layihə Hesabatı

Mənbə: https://github.com/suleymanalizada27-wq/FloodStore
Analiz tarixi: 2026-07-20 · Son commit: 4915ad4 — "feat(product-detail): add product detail screen and provider"
Metod: Repo canlı klon edilib, bütün fayllar (kod, config, sənədləşdirmə) birbaşa oxunub.


1. Layihə nədir

FloodStore — Flutter ilə yazılan, Firebase backend-li premium marketplace (bazar yeri) tətbiqi. İki əsas hissəsi var:


Auth modulu — tam hazır, geniş inkişaf etmiş autentifikasiya sistemi
Marketplace modulu — aktiv inkişafda, əsas skelet qurulub, bəzi əsas funksiyalar (səbətə əlavə) hələ bağlanmayıb


Layihə həm mobil (Android/iOS), həm masaüstü (Windows/macOS/Linux), həm də web platformaları hədəfləyir — Flutter-in standart multi-platform şablonu ilə yaradılıb.


2. Texnologiya yığını

KateqoriyaTexnologiyaFrameworkFlutter (Dart SDK >=3.3.0 <4.0.0), Material 3State managementflutter_riverpod ^2.5.1Routinggo_router ^14.2.0BackendFirebase: firebase_core, firebase_auth, firebase_storage, cloud_firestoreSosial girişgoogle_sign_in, sign_in_with_apple (GitHub/Microsoft → Firebase-in generic OAuthProvider-i ilə)Təhlükəsizlikflutter_secure_storage (token), local_auth (biometrik), shared_preferencesDigərimage_picker, url_launcher, lottie (animasiya), equatable, uuid, google_fontsTestflutter_test, flutter_lints ^4.0.0Ödəniş❌ Yoxdur — Stripe çıxarılıb, checkout simulyasiyadır


3. Firebase — real layihəyə bağlıdır

Bu vacib bir tapıntıdır: layihə placeholder deyil, real bir Firebase layihəsinə bağlanıb:


Firebase project ID: floodstore-fbece
android/app/google-services.json reponun içinə commit edilib (gitignore-da deyil)
lib/firebase_options.dart FlutterFire CLI tərəfindən generasiya olunub və real konfiqurasiya dəyərlərini saxlayır


⚠️ Təhlükəsizlik qeydi: google-services.json-un public repoda olması özlüyündə kritik təhlükə deyil (Firebase Android açarları "sirr" sayılmır, əsas qoruma Firestore Security Rules-dadır), AMMA bu repoda heç bir firestore.rules və ya storage.rules faylı tapılmadı. Bu o deməkdir ki, Firestore təhlükəsizlik qaydaları ya konsoldan əl ilə idarə olunur (versiyalanmır), ya da default/açıq qala bilər — bu, production üçün yoxlanılmalı ən vacib məqamlardan biridir.


4. Arxitektura

Clean Architecture, feature-based modul quruluşu:

lib/
  core/                          → cross-cutting: constants, router, theme, servislər, ortaq widget-lər
  features/
    splash/presentation/         → 1 ekran
    auth/{domain,data,application,presentation}/
    marketplace/{domain,data,application,presentation}/
  firebase_options.dart
  main.dart

Qat qaydası (CLAUDE.md-də təsbit olunub): domain qatı heç bir Firebase importu etmir; bütün Firebase/Firestore məntiqi yalnız data/repositories/-də cəmlənib. Presentation yalnız application (provider/state) qatına bağlıdır.

Router: GoRouter, mərkəzi app_router.dart-da 15 route təyin olunub: splash, auth (login), register, forgot-password, phone-auth, verify-email, organization-onboarding, security-center, home, marketplace-products, product-detail, cart, checkout, order-confirmation, order-detail, business-account-register.

main.dart: Firebase main()-də init olunur, tema (light/dark/system) SharedPreferences-də saxlanılır, authStateChangesProvider dəyişəndə security repository-yə sessiya qeydi yazılır.


5. AUTH modulu — tam siyahı

Ekranlar (9)

EkranFaylSplashsplash_screen.dartLoginlogin_screen.dartRegister (5 addımlı wizard)register_screen.dart + register_steps/ (account-info, personal-info, security, verification, finish)Forgot Passwordforgot_password_screen.dartEmail Verificationemail_verification_screen.dartPhone OTPphone_otp_screen.dartOrganization Onboardingorganization_onboarding_screen.dartSecurity Centersecurity_center_screen.dart

Domain entity-lər (5)

account_mode, app_user, device_session, mfa_method, organization

Repository-lər (3, Firestore/Firebase Auth implementasiyalı)

firebase_auth_repository, firestore_organization_repository, firestore_security_repository

Xüsusiyyətlər


Email/parol + Google/Apple/Microsoft/Phone ilə giriş
Parol gücü ölçən servis (password_strength_service.dart) və UI göstərici (password_strength_meter.dart)
Rate limiting (auth_rate_limiter.dart) — brute-force qarşısını almaq üçün
Secure token servisi (secure_token_service.dart) — Keychain/Keystore-encrypted saxlama
Sessiya servisi (session_service.dart) + Security Center-də device session-ların görüntülənməsi
Organization/Business rejimi — ayrıca "switcher" widget-i ilə (organization_switcher.dart)
"Guest mode" düyməsi (guest_mode_button.dart)
Draft storage servisi (draft_storage_service.dart) — register wizard-da yarımçıq məlumatın saxlanması üçün ehtimal


⚠️ Kod təmizliyi qeydi

lib/features/auth/presentation/screens/login_screen.dart.backup — 192 sətirlik backup fayl reponun içində qalıb. Bu, Dart build sisteminə təsir etmir (.dart uzantısı deyil), amma kod bazasını tərtib edən nöqsandır və silinməlidir.


6. MARKETPLACE modulu — tam siyahı

Ekranlar (9)

home, products (kataloq), product-detail (ən son əlavə), product-search, cart, checkout, order-confirmation, order-detail, business-account-registration

Domain entity-lər (17)

business_account, cart, category, chat_message, chat_session, coupon, loyalty, notification, order, price_history, product, product_variant, recommendation, review, seller_analytics, user, visual_search

Repository-lər (10, Firestore implementasiyalı)

analytics, business-account, cart, chat, coupon, loyalty, notification, order, product, user, visual-search (11 əslində — user_repository də var)

Nə işə yarayır, nə yaramır

✅ İşlək/mövcud:


Məhsul kataloqu göstərmə (products_screen, product_card)
Məhsul detalları (yeni əlavə olunub)
Checkout axını (simulyasiya edilmiş ödəniş ilə)
Sifariş təsdiqi və detalları ekranları
Business account qeydiyyatı


❌ Bağlanmayıb (kod daxilində TODO kimi qeyd olunub):

FaylProblemhome_screen.dart:615Add-to-cart bağlanmayıbproduct_detail_screen.dart:83Add-to-cart bağlanmayıb (yeni ekranda da)products_screen.dart:465Add-to-cart bağlanmayıbproduct_card.dart:97Add-to-cart bağlanmayıborder_detail_screen.dart:317PDF generasiya/yükləmə yoxdurfirestore_product_data_source.dart:136Mətn axtarışı implement edilməyib

→ Nəticə: CartRepository mövcuddur və işlək backend metodları var, amma UI-nin heç bir yerindən çağırılmır. İstifadəçi hazırda məhsula baxa bilir, amma səbətə əlavə edə bilmir. Bu, marketplace-in ən kritik boşluğudur.

📄 MARKETPLACE_ARCHITECTURE.md — nəhəng bir dizayn sənədi, amma çoxu implement edilməyib

Bu fayl 2,761 sətirdir və olduqca ambisiyalı bir sistem dizaynı təsvir edir:


CQRS pattern, "event sourcing lite" order state-ləri üçün
Multi-tenant Firestore arxitekturası
Çox təfərrüatlı Firestore schema (products/variants/inventory/reviews/analytics alt-kolleksiyaları, sellers, promotions, search_indexes və s.)
Cloud Functions ilə BFF (Backend-for-Frontend)
Remote Config ilə feature toggles


Faktiki kodda bunların çox az hissəsi görünür — hazırkı repository-lər əsas CRUD səviyyəsindədir, sənəddəki mürəkkəb subcollection strukturu, CQRS ayrımı, event sourcing və Cloud Functions kodda tapılmadı. Bu sənəd, deməli, gələcək plan/vizyon kimi oxunmalıdır, "artıq tikilib" kimi yox.


7. Testlər

Cəmi 1 test faylı: test/widget_test.dart — və o da yalnız "app compile olub açılır mı" yoxlayan bir smoke test:

darttestWidgets('App builds successfully', (WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: FloodStoreApp()));
});

Repository, domain, use-case, ya da widget səviyyəsində heç bir başqa unit/widget test yoxdur. 24,762 sətirlik kod bazası üçün bu, test əhatəsi baxımından çox aşağı səviyyədir.


8. CI/CD

.github/workflows/opencode.yml mövcuddur — adi flutter analyze && flutter test && flutter build işlədən standart Flutter CI-dan fərqli olaraq, bu OpenCode AI-agent workflow-udur (deməli GitHub Actions-da avtomatik test/build pipeline-i yoxdur, sadəcə AI-agent inteqrasiyası var).


9. Platform dəstəyi

Repo bütün Flutter platform qovluqlarını daxil edir: android/, ios/, web/, windows/, linux/, macos/. Bunlar əsasən Flutter-in özünün yaratdığı standart boilerplate-dir (native runner kodu), əl ilə çox toxunulmayıb — istisna olaraq Android tərəfində minSdk 23, Gradle 8.4, AGP 8.3 kimi konfiqurasiya dəyişiklikləri edilib (əvvəlki sessiyalarda build xətalarını həll etmək üçün).

AndroidManifest.xml-də açıq şəkildə əlavə edilmiş uses-permission qeydi tapılmadı — bu deməkdir ki, kamera/lokasiya kimi icazələr ya plugin-lərin öz manifest-ləri vasitəsilə avtomatik "merge" olunur (image_picker, local_auth və s. üçün normaldır), ya da hələ əl ilə əlavə edilməyib.


10. Sənədləşdirmə vəziyyəti

FaylVəziyyətREADME.md⚠️ Köhnəlib — yalnız auth axınını təsvir edir, marketplace modulundan (10 repo, 9 ekran) heç bəhs etmirCLAUDE.mdAI-agent üçün development təlimatları — auth modulunu düzgün əks etdirir, amma marketplace-i əhatə etmirMARKETPLACE_ARCHITECTURE.md2,761 sətirlik geniş dizayn sənədi — çoxu hələ implement edilməyib, gələcək plan kimi baxılmalıdırAGENT_PROGRESS.mdƏvvəlki AI-sessiyaların iş qeydləri — son commit-dən sonra yenilənməyib


11. Ümumi say göstəriciləri

MetrikaDəyərDart sətri (lib/)24,762Dart fayl sayı132Auth ekranları9Marketplace ekranları9Domain entity (cəmi)22 (5 auth + 17 marketplace)Repository implementasiyası (cəmi)13 (3 auth + 10 marketplace)Test faylı1 (yalnız smoke test)GitHub Actions workflow1 (AI-agent, standart CI deyil)Firestore security rules faylı0 ❌


12. Ən vacib tapıntılar (xülasə)


Add-to-cart bağlanmayıb — 4 fərqli yerdə TODO qalıb, marketplace-in ən kritik funksional boşluğu
Firestore security rules repoda yoxdur — production riski, mütləq yoxlanılmalıdır
Real Firebase layihəsinə bağlıdır (floodstore-fbece) — demo deyil
MARKETPLACE_ARCHITECTURE.md böyük ölçüdə aspirasion — kodun özündən qat-qat mürəkkəb bir sistem təsvir edir, real vəziyyəti çaşdıra bilər
Test əhatəsi demək olar yoxdur — 24K+ sətir koda qarşı 1 smoke test
README köhnəlib — marketplace-i ümumiyyətlə əks etdirmir
Ödəniş simulyasiyadır — Stripe çıxarılıb, real ödəniş inteqrasiyası yoxdur
Backup fayl reponun içində unudulub (login_screen.dart.backup)
Merge tarixçəsi göstərir ki, paralel iş axınları toqquşanda əvvəllər bağlanmış iş (add-to-cart) itə bilir



13. Tövsiyə olunan prioritet sırası


Firestore/Storage security rules yaz və versiyaya qoş (firestore.rules, storage.rules)
Add-to-cart-ı bir ortaq controller/use-case ilə 4 yerdə eyni anda bağla
login_screen.dart.backup faylını sil
README.md-i marketplace-i əhatə edəcək şəkildə yenilə
Ən azı cart/order axını üçün unit test yaz
MARKETPLACE_ARCHITECTURE.md-i "hazır" deyil "roadmap" kimi işarələ (məsələn sənədin başına status qeydi əlavə et)
Real ödəniş provideri inteqrasiya et
Standart Flutter CI (flutter analyze && flutter test && flutter build) əlavə et — hazırkı workflow bunu etmir



Bu hesabat 2026-07-20 tarixində repo-nun canlı klonu üzərində aparılan tam kod-səviyyəli analizə əsaslanır. Sənəd əl ilə yazılan qeydlərə deyil, faktiki fayl məzmununa istinad edir.
