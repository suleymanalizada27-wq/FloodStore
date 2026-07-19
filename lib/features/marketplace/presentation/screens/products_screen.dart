import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';

final _uuid = const Uuid();

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  Future<List<Product>>? _productsFuture;
  static const int _pageSize = 20;
  String? _lastDocumentId;
  bool _isLoadingMore = false;
  List<Product> _products = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    final productRepository = ref.read(productRepositoryProvider);

    try {
      final sampleProducts = await productRepository.getProductsByCategory(
        'default',
        limit: 1,
      );

      if (sampleProducts.isEmpty) {
        await _createSampleData();
      }
    } catch (e) {
      await _createSampleData();
    }

    _loadProducts();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _createSampleData() async {
    try {
      final productRepository = ref.read(productRepositoryProvider);

      // Create categories
      final categories = [
        Category(id: 'home_appliances', name: 'Ev Aletleri', level: 0, sortOrder: 1, isActive: true),
        Category(id: 'electronics', name: 'Elektronik', level: 0, sortOrder: 2, isActive: true),
        Category(id: 'building_materials', name: 'İnşaat Malzemeleri', level: 0, sortOrder: 3, isActive: true),
        Category(id: 'tools', name: 'El Aletleri', level: 0, sortOrder: 4, isActive: true),
        Category(id: 'lighting', name: 'Aydınlatma', level: 0, sortOrder: 5, isActive: true),
      ];

      for (final category in categories) {
        try {
          await productRepository.createCategory(category);
        } catch (e) {
          // Category might already exist
        }
      }

      // Create subcategories
      final subcategories = [
        // Home Appliances
        Category(id: 'refrigerators', name: 'Buzdolapları', level: 1, sortOrder: 1, isActive: true, parentId: 'home_appliances'),
        Category(id: 'washing_machines', name: 'Çamaşır Makineleri', level: 1, sortOrder: 2, isActive: true, parentId: 'home_appliances'),
        Category(id: 'dishwashers', name: 'Bulaşık Makineleri', level: 1, sortOrder: 3, isActive: true, parentId: 'home_appliances'),
        Category(id: 'ovens', name: 'Fırınlar', level: 1, sortOrder: 4, isActive: true, parentId: 'home_appliances'),
        Category(id: 'vacuums', name: 'Elektrikli Süpürgeler', level: 1, sortOrder: 5, isActive: true, parentId: 'home_appliances'),
        // Electronics
        Category(id: 'smartphones', name: 'Akıllı Telefonlar', level: 1, sortOrder: 1, isActive: true, parentId: 'electronics'),
        Category(id: 'laptops', name: 'Laptoplar', level: 1, sortOrder: 2, isActive: true, parentId: 'electronics'),
        Category(id: 'tablets', name: 'Tabletler', level: 1, sortOrder: 3, isActive: true, parentId: 'electronics'),
        Category(id: 'wearables', name: 'Akıllı Saatler', level: 1, sortOrder: 4, isActive: true, parentId: 'electronics'),
        Category(id: 'audio', name: 'Ses Sistemleri', level: 1, sortOrder: 5, isActive: true, parentId: 'electronics'),
        // Building Materials
        Category(id: 'cement', name: 'Çimento', level: 1, sortOrder: 1, isActive: true, parentId: 'building_materials'),
        Category(id: 'bricks', name: 'Tuğla', level: 1, sortOrder: 2, isActive: true, parentId: 'building_materials'),
        Category(id: 'steel', name: 'Çelik', level: 1, sortOrder: 3, isActive: true, parentId: 'building_materials'),
        Category(id: 'paint', name: 'Boya', level: 1, sortOrder: 4, isActive: true, parentId: 'building_materials'),
        Category(id: 'insulation', name: 'İzolasyon', level: 1, sortOrder: 5, isActive: true, parentId: 'building_materials'),
      ];

      for (final category in subcategories) {
        try {
          await productRepository.createCategory(category);
        } catch (e) {
          // Category might already exist
        }
      }

      // Sample products for each category
      final products = [
        // Refrigerators
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-beko',
          categoryId: 'refrigerators',
          secondaryCategories: ['home_appliances'],
          base: ProductBase(
            title: 'Beko 368L No-Frost Buzdolabı',
            description: 'A+ enerji sınıfında, No-Frost teknolojili, 368 litre hacimli buzdolabı. Active Fresh Blue Light teknolojisi ile meyve ve sebzeler daha uzun taze kalır.',
            brand: 'Beko',
            sku: 'BEKO-RN368NF-001',
            weight: 65000.0,
            dimensions: ProductDimensions(length: 60.0, width: 65.0, height: 185.0),
            materials: ['Metal', 'Cam', 'Plastik'],
            careInstructions: 'İç kısım nemli bez ile silinir',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['buzdolabı', 'no-frost', 'enerji-verimli', 'beyaz-eşya'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['home'],
            style: ['modern'],
            color: ['beyaz', 'gümüş', 'siyah'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 1899900,
            currency: 'TRY',
            compareAtPrice: 2199900,
            taxCode: 'standard',
            shippingTier: 'large',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-bosch',
          categoryId: 'refrigerators',
          secondaryCategories: ['home_appliances'],
          base: ProductBase(
            title: 'Bosch Series 6 450L French Door Buzdolabı',
            description: 'Serie 6, VitaFresh Plus teknolojisi, Home Connect uygulaması ile uzaktan kontrol, 450 litre kapasite.',
            brand: 'Bosch',
            sku: 'BSH-KFN96APEA-001',
            weight: 95000.0,
            dimensions: ProductDimensions(length: 70.0, width: 75.0, height: 190.0),
            materials: ['Metal', 'Cam', 'Plastik'],
            careInstructions: 'İç kısım nemli bez ile silinir',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['buzdolabı', 'french-door', 'vitafresh', 'premium'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['home'],
            style: ['modern', 'premium'],
            color: ['inox', 'beyaz'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 4299900,
            currency: 'TRY',
            compareAtPrice: 4799900,
            taxCode: 'standard',
            shippingTier: 'large',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Washing Machines
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-arcelik',
          categoryId: 'washing_machines',
          secondaryCategories: ['home_appliances'],
          base: ProductBase(
            title: 'Arçelik 9kg 1400 Devir Çamaşır Makinesi',
            description: 'ProSmart Inverter motoru, 9kg kapasite, 1400 devir/dakika, Hygiene+ programı, yıkama performansı A.',
            brand: 'Arçelik',
            sku: 'ARC-9140HP-001',
            weight: 72000.0,
            dimensions: ProductDimensions(length: 60.0, width: 60.0, height: 85.0),
            materials: ['Metal', 'Paslanmaz Çelik', 'Plastik'],
            careInstructions: 'Deterjan kasası düzenli temizlenmelidir',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['çamaşır-makinesi', 'inverter', 'hijyen', 'enerji-verimli'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['home'],
            style: ['modern'],
            color: ['beyaz', 'gümüş'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 1599900,
            currency: 'TRY',
            compareAtPrice: 1799900,
            taxCode: 'standard',
            shippingTier: 'large',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Smartphones
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-samsung',
          categoryId: 'smartphones',
          secondaryCategories: ['electronics'],
          base: ProductBase(
            title: 'Samsung Galaxy S24 Ultra 256GB',
            description: '6.8" Dynamic AMOLED 2X, Snapdragon 8 Gen 3, 200MP ana kamera, 5000mAh batarya, S Pen dahil.',
            brand: 'Samsung',
            sku: 'SAM-S24U-256-001',
            weight: 232.0,
            dimensions: ProductDimensions(length: 7.9, width: 16.2, height: 0.86),
            materials: ['Cam', 'Alüminyum', 'Titanyum'],
            careInstructions: 'Suya dayanıklı (IP68), yumuşak bezle temizlenir',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['akıllı-telefon', 'flagship', 's-pen', '200mp-kamera'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['personal', 'business'],
            style: ['premium', 'modern'],
            color: ['titanyum-siyah', 'titanyum-gri', 'titanyum-mor', 'titanyum-sarı'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 4999900,
            currency: 'TRY',
            compareAtPrice: 5499900,
            taxCode: 'standard',
            shippingTier: 'small',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-apple',
          categoryId: 'smartphones',
          secondaryCategories: ['electronics'],
          base: ProductBase(
            title: 'iPhone 15 Pro Max 256GB',
            description: '6.7" Super Retina XDR, A17 Pro çip, 48MP Ana Kamera, Titanyum tasarım, USB-C, 29 saat video oynatma.',
            brand: 'Apple',
            sku: 'APL-IP15PM-256-001',
            weight: 221.0,
            dimensions: ProductDimensions(length: 7.67, width: 15.99, height: 0.83),
            materials: ['Titanyum', 'Cam', 'Seramik'],
            careInstructions: 'Suya dayanıklı (IP68), yumuşak bezle temizlenir',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['iphone', 'pro-max', 'a17-pro', 'titanyum', 'usb-c'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['personal', 'business'],
            style: ['premium', 'minimalist'],
            color: ['doğal-titanyum', 'beyaz-titanyum', 'siyah-titanyum', 'mavi-titanyum'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 5499900,
            currency: 'TRY',
            compareAtPrice: 5999900,
            taxCode: 'standard',
            shippingTier: 'small',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Laptops
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-lenovo',
          categoryId: 'laptops',
          secondaryCategories: ['electronics'],
          base: ProductBase(
            title: 'Lenovo ThinkPad X1 Carbon Gen 12',
            description: '14" WUXGA IPS, Intel Core Ultra 7 155H, 32GB RAM, 1TB SSD, Intel Arc Grafik, 57Wh batarya, 980g.',
            brand: 'Lenovo',
            sku: 'LNV-X1C12-U7-001',
            weight: 980.0,
            dimensions: ProductDimensions(length: 21.4, width: 31.5, height: 1.5),
            materials: ['Karbon Fiber', 'Magnezyum Alüminyum'],
            careInstructions: 'Yumuşak bezle temizlenir, sıvı kaçırmayın',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['laptop', 'ultrabook', 'thinkpad', 'carbon-fiber', 'iş-laptoptu'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['business', 'education'],
            style: ['professional', 'minimalist'],
            color: ['karbon-siyah'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 3899900,
            currency: 'TRY',
            compareAtPrice: 4299900,
            taxCode: 'standard',
            shippingTier: 'medium',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Building Materials - Cement
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-cimsa',
          categoryId: 'cement',
          secondaryCategories: ['building_materials'],
          base: ProductBase(
            title: 'Çimsa CEM I 42.5R Portland Çimento - 50kg',
            description: 'Yüksek erken dayanımlı, TS EN 197-1 standardında, beton ve tuğla yapımında kullanım için ideal.',
            brand: 'Çimsa',
            sku: 'CMS-CEM1-425R-50KG',
            weight: 50000.0,
            dimensions: ProductDimensions(length: 40.0, width: 30.0, height: 15.0),
            materials: ['Klinker', 'Jips', 'Kalsiyum Karbonat'],
            careInstructions: 'Kuru ve nem almayan ortamda saklanmalıdır',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['çimento', 'portland', 'yapı-malzemesi', 'beton'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['construction'],
            style: ['industrial'],
            color: ['gri'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 18500,
            currency: 'TRY',
            compareAtPrice: 20000,
            taxCode: 'standard',
            shippingTier: 'heavy',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 40)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Steel
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-erdemis',
          categoryId: 'steel',
          secondaryCategories: ['building_materials'],
          base: ProductBase(
            title: 'Erdemir S235JR Yapı Çeliği - Ø12mm 12m',
            description: 'TS 706 standardında, S235JR kalitesinde, betonarme yapılar için nervurlu beton çeliği.',
            brand: 'Erdemir',
            sku: 'ERD-S235JR-12MM-12M',
            weight: 8880.0, // 12m * 0.74 kg/m
            dimensions: ProductDimensions(length: 1200.0, width: 1.2, height: 1.2),
            materials: ['Demir', 'Karbon', 'Mangan'],
            careInstructions: 'Nemden korunmalı, paslanma önleyici yağı ile saklanmalı',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['çelik', 'betonarme', 'nervurlu', 's235jr', 'yapı-çeliği'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['construction'],
            style: ['industrial'],
            color: ['gri', 'siyah'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 45000,
            currency: 'TRY',
            compareAtPrice: 50000,
            taxCode: 'standard',
            shippingTier: 'heavy',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 35)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Paint
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-marshall',
          categoryId: 'paint',
          secondaryCategories: ['building_materials'],
          base: ProductBase(
            title: 'Marshall Akrilik Satin Duvar Boyası - 15L Beyaz',
            description: 'Yüksek kaplama gücü, yıkanabilir, mat-satin görünüm, iç mekanlar için, düşük VOC.',
            brand: 'Marshall',
            sku: 'MRS-AKR-SAT-15L-BEYAZ',
            weight: 18000.0,
            dimensions: ProductDimensions(length: 30.0, width: 30.0, height: 40.0),
            materials: ['Akrilik Polimer', 'Pigment', 'Su', 'Katkı Maddeler'],
            careInstructions: 'Kapak kapalı, serin ve kuru yerde saklanmalı',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['boya', 'akrilik', 'satin', 'iç-mekân', 'beyaz'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['renovation', 'home-improvement'],
            style: ['modern', 'classic'],
            color: ['beyaz', 'krem', 'gri', 'bej', 'mavi', 'yeşil'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 85000,
            currency: 'TRY',
            compareAtPrice: 95000,
            taxCode: 'standard',
            shippingTier: 'medium',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Tools
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-bosch-tools',
          categoryId: 'tools',
          secondaryCategories: ['electronics'],
          base: ProductBase(
            title: 'Bosch Professional GSB 18V-55 Cordless Çekiceli Matkap',
            description: '18V, 55Nm tork, brushless motor, 2x 4.0Ah battery, L-Boxx valiz, 2 hız, LED ışık.',
            brand: 'Bosch Professional',
            sku: 'BSH-GSB18V55-SET',
            weight: 1800.0,
            dimensions: ProductDimensions(length: 25.0, width: 8.5, height: 22.0),
            materials: ['Metal', 'Plastik', 'Lityum-İyon Batarya'],
            careInstructions: 'Bataryalar soğuk ortamda saklanmalı, düzenli şarj edilmeli',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['matkap', 'çekiceli', 'akülü', 'brushless', 'profesyonel', 'bosch'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['construction', 'diy', 'renovation'],
            style: ['professional', 'industrial'],
            color: ['mavi', 'siyah'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 429900,
            currency: 'TRY',
            compareAtPrice: 479900,
            taxCode: 'standard',
            shippingTier: 'medium',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
        // Lighting
        Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-philips',
          categoryId: 'lighting',
          secondaryCategories: ['home_appliances'],
          base: ProductBase(
            title: 'Philips Hue White & Color Ambiance Starter Kit E27',
            description: '3 adet akıllı ampul + Bridge, 16 milyon renk, Bluetooth + Zigbee, uygulama/ses kontrolü, zamanlayıcı.',
            brand: 'Philips Hue',
            sku: 'PHL-HUE-WCA-STARTER-E27',
            weight: 450.0,
            dimensions: ProductDimensions(length: 12.0, width: 12.0, height: 15.0),
            materials: ['Cam', 'Alüminyum', 'Plastik'],
            careInstructions: 'Yumuşak kuru bezle temizlenir',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['akıllı-ampul', 'philips-hue', 'rgb', 'iot', 'akıllı-ev', 'aydınlatma'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['home', 'ambiance'],
            style: ['modern', 'smart-home'],
            color: ['beyaz', 'renkli'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 129900,
            currency: 'TRY',
            compareAtPrice: 149900,
            taxCode: 'standard',
            shippingTier: 'small',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        ),
      ];

      for (final product in products) {
        await productRepository.createProduct(product);
      }
    } catch (e) {
      debugPrint('Error creating sample data: $e');
    }
  }

  void _loadProducts() {
    final productRepository = ref.read(productRepositoryProvider);
    _productsFuture = productRepository.getProductsByCategory(
      'default',
      limit: _pageSize,
    );
    _productsFuture!.then((products) {
      if (mounted) {
        setState(() {
          _products = products;
          _lastDocumentId = products.isNotEmpty ? products.last.id : null;
        });
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _refreshProducts() async {
    _loadProducts();
  }

  void _loadMoreProducts() {
    if (_isLoadingMore || _lastDocumentId == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    final productRepository = ref.read(productRepositoryProvider);
    productRepository
        .getProductsByCategory(
      'default',
      limit: _pageSize,
      lastDocumentId: _lastDocumentId,
    )
        .then((moreProducts) {
      if (mounted) {
        setState(() {
          _products.addAll(moreProducts);
          _lastDocumentId =
              moreProducts.isNotEmpty ? moreProducts.last.id : null;
          _isLoadingMore = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more products: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _addSampleProduct() async {
    try {
      final productRepository = ref.read(productRepositoryProvider);

      final sampleProduct = Product(
        id: _uuid.v4(),
        sellerId: 'demo-seller-id',
        categoryId: 'default',
        secondaryCategories: const [],
        base: ProductBase(
          title: 'Sample Product ${DateTime.now().millisecondsSinceEpoch}',
          description: 'This is a sample product for demonstration purposes.',
          brand: 'SampleBrand',
          sku: 'SAMPLE-${_uuid.v4().substring(0, 8).toUpperCase()}',
          weight: 250.0,
          dimensions: const ProductDimensions(
            length: 10.0,
            width: 10.0,
            height: 5.0,
          ),
          materials: ['Cotton', 'Polyester'],
          careInstructions: 'Machine wash cold, tumble dry low',
          isDigital: false,
        ),
        metadata: ProductMetadata(
          tags: ['sample', 'demo', 'test'],
          ageRange: null,
          gender: null,
          season: ['all'],
          occasion: ['casual'],
          style: ['modern'],
          color: ['blue', 'white'],
          pattern: ['solid'],
        ),
        pricing: ProductPricing(
          basePrice: 1999,
          currency: 'USD',
          compareAtPrice: 2499,
          taxCode: 'standard',
          shippingTier: 'standard',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: ProductStatus.active,
      );

      await productRepository.createProduct(sampleProduct);
      _loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample product added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      final userId = ref.read(currentUserIdProvider) ?? 'demo-user-id';
      final cartRepository = ref.read(cartRepositoryProvider);
      await cartRepository.addItem(
        userId,
        product.id,
        null,
        1,
        product.pricing.basePrice,
        product.base.title,
        {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.base.title} added to cart!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Products',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          if (bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Sample Product',
              onPressed: _addSampleProduct,
            ),
        ],
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshProducts,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search,
                            color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Product>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: AppColors.error),
                            ),
                          );
                        }

                        final products = snapshot.data ?? [];

                        if (products.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.store_outlined,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: TextStyle(
                                      color: AppColors.textTertiary),
                                ),
                                const SizedBox(height: 8),
                                if (bool.fromEnvironment(
                                        'dart.vm.product') ==
                                    false)
                                  ElevatedButton.icon(
                                    onPressed: _addSampleProduct,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Sample Product'),
                                  ),
                              ],
                            ),
                          );
                        }

                        return NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                    scrollInfo.metrics.maxScrollExtent *
                                        0.8 &&
                                !_isLoadingMore) {
                              _loadMoreProducts();
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                onAddToCart: () => _addToCart(product),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSampleProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Sample'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.base.title,
                    style: AppTextStyles.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(product.pricing.basePrice / 100).toStringAsFixed(2)}',
                    style: AppTextStyles.textTheme.bodyLarge!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    child: PremiumButton(
                      onPressed: onAddToCart,
                      label: 'Add to Cart',
                      icon: Icons.add_shopping_cart,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}