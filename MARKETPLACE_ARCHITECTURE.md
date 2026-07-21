# FloodStore Marketplace Architecture

## 1. Current Implementation Status

This document describes both the target architecture and the current implementation status of the Marketplace feature in FloodStore.

### Implemented Features (as of latest commit):
- ✅ Product browsing with search and filtering
- ✅ Product detail viewing
- ✅ Add to cart functionality with persistence
- ✅ Category browsing
- ✅ Home screen with featured products, trending items, and recommendations
- ✅ Search with client-side filtering on product title, description, and brand
- ✅ Basic product card UI with pricing and add-to-cart button
- ✅ Responsive layout adapting to different screen sizes
- ✅ Integration with Firebase Authentication for user identification
- ✅ Riverpod state management for cart and product data
- ✅ GoRouter navigation between screens

### Planned Features (to be implemented):
- 🔲 Wishlist functionality
- 🔲 Checkout and payment processing
- 🔲 Order management and history
- 🔲 Product reviews and ratings
- 🔲 Advanced filtering options (price ranges, brands, attributes)
- 🔲 Saved searches and alerts
- 🔲 Personalized recommendations
- 🔲 Shopping cart persistence (Firestore-backed)
- 🔲 Inventory management and stock indicators

## 2. Complete Marketplace Architecture

Building upon FloodStore's existing Clean Architecture foundation, the Marketplace feature extends the current structure with a new `marketplace` feature module while preserving all existing architectural principles:

```
lib/
  features/
    marketplace/          # FEATURE MODULE
      domain/             # Pure business logic (no Firebase/framework deps)
        entities/         # Product, Cart, Category, etc.
        repositories/     # Abstract interfaces (ProductRepository, CartRepository)
        services/         # Domain services (PricingService, SearchService)
      data/               # Firebase/Firestore implementations
        sources/          # Low-level data access
        repositories/     # Concrete implementations (FirestoreProductRepository)
        mappers/          # Entity <-> DTO conversion
      application/        # State management & business logic
        providers/        # Riverpod providers
        state/            # State classes
        use_cases/        # Application use cases
      presentation/       # UI layer
        screens/          # UI screens
        widgets/          # Reusable marketplace widgets
        themes/           # Marketplace-specific theme extensions
        constants/        # Marketplace-specific constants
```

### Key Architectural Decisions Implemented
- ✅ **Domain-Driven Design**: Clear bounded context for marketplace entities
- ✅ **Clean Architecture Layers**: Strict separation between domain, data, application, and presentation
- ✅ **Feature-Based Organization**: All marketplace-related code in `/features/marketplace/`
- ✅ **Riverpod State Management**: Providers for state management
- ⬜ **CQRS Pattern**: Separate read/write models for product catalog (planned)
- ⬜ **Event Sourcing Lite**: Order state transitions tracked via Firestore subcollections (planned)
- ⬜ **Feature Toggles**: Remote config for gradual feature rollout (planned)
- ⬜ **Backend-for-Frontend (BFF)**: Cloud Functions for complex aggregations (not used due to free tier constraints)
- ✅ **Multi-tenant Architecture**: Single Firestore instance with tenant isolation via document-level security (planned)

## 3. Firestore Database Schema (Planned)

The following schema represents the planned Firestore structure for when Firestore is fully implemented:

### Core Collections Structure
```
firestore/
├── users/{userId}                    # Extended from auth users
│   ├── profile                       # User profile document
│   ├── preferences                   # User preferences
│   ├── addresses                     # Subcollection: shipping/billing addresses
│   └── wallet                        # Wallet/balance information
│
├── products/{productId}              # Master product catalog
│   ├── base                          # Immutable product core data
│   │   └── metadata                  # Searchable metadata
│   ├── variants/{variantId}          # Product variants (size, color, etc.)
│   ├── inventory/{warehouseId}       # Inventory levels per location
│   ├── reviews/{reviewId}            # Product reviews (denormalized for reads)
│   └── analytics                     # Denormalized analytics counters
│
├── categories/{categoryId}           # Hierarchical category tree
│   └── children/{subCategoryId}      # Self-referential subcollection
│
├── carts/{userId}                    # Active shopping carts
│   └── items/{itemId}                # Cart items with snapshot pricing
│
├── orders/{orderId}                  # Order lifecycle management
│   ├── items/{itemId}                # Line items with priced snapshots
│   ├── payments                      # Payment attempts/subdocuments
│   ├── fulfillment                   # Shipping/tracking updates
│   └── history                       # Status change audit trail
│
├── sellers/{sellerId}                # Seller profiles
│   ├── store                         # Store configuration
│   ├── products                      # Denormalized product references
│   ├── orders                        # Seller-specific order view
│   └── analytics                     # Seller performance metrics
│
├── promotions/{promoId}              # Discounts, coupons, sales
│   └── applicableTo                  # Products/categories this applies to
│
└── search_indexes/{indexId}          # Denormalized search-optimized views
```

*Note: Currently using simulated data and in-memory storage for development. Firebase implementation planned for future phases.*

## 4. In-Memory Data Structure (Current Implementation)

### Product Model (lib/features/marketplace/domain/entities/product.dart)
```dart
class Product {
  final String id;
  final String sellerId;
  final String categoryId;
  final List<String> secondaryCategories;
  final ProductBase base;
  final ProductMetadata metadata;
  final ProductPricing pricing;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductStatus status;

  // Getters and factory methods...
}

class ProductBase {
  final String title;
  final String description;
  final String brand;
  final String sku;
  final double weight;
  final ProductDimensions dimensions;
  final List<String> materials;
  final String careInstructions;
  final bool isDigital;

  // Getters and factory methods...
}

class ProductDimensions {
  final double length;
  final double width;
  final double height;

  // Getters and factory methods...
}

class ProductMetadata {
  final List<String> tags;
  final PriceRange? ageRange;
  final Gender? gender;
  final List<Season> season;
  final List<String> occasion;
  final List<String> style;
  final List<String> color;
  final List<String> pattern;

  // Getters and factory methods...
}

class ProductPricing {
  final int basePrice; // in cents
  final String currency;
  final int? compareAtPrice; // in cents
  final String taxCode;
  final String shippingTier;

  // Getters and factory methods...
}
```

### Cart Model (Conceptual - to be implemented)
```dart
class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getters and factory methods...
}

class CartItem {
  final String id;
  final String productId;
  final String? variantId;
  final int quantity;
  final int unitPrice; // in cents
  final String productTitle;
  final Map<String, String> variantAttributes;

  // Getters and factory methods...
}
```

## 5. Data Flow and State Management

### Product Data Flow
```
Firestore (Planned) ←→ Firebase Database Service
        ↓                           ↓
ProductRepository (Interface) ←→ FirestoreProductRepository (Impl)
        ↓                           ↓
ProductProvider (Riverpod) ←→ ProductState (StateNotifier)
        ↓                           ↓
UI Widgets (Consumer) ←→ Product Data Display/Search Results
```

### Cart Data Flow (Implemented)
```
Shared Memory ←→ CartRepository (Interface) ←→ InMemoryCartRepository (Impl)
        ↓                           ↓
CartProvider (Riverpod) ←→ CartState (StateNotifier)
        ↓                           ↓
UI Widgets (Consumer) ←→ Cart Operations & Display
```

### Current In-Memory Implementation
- Uses simple in-memory storage with Map-based data structures
- Cart state managed via Riverpod StateNotifier
- Product data fetched from mock data service
- State updates trigger UI rebuilds via Consumer widgets

## 6. Search Implementation (Current)

### Client-Side Search (Implemented)
Located in: `lib/features/marketplace/data/sources/firestore_product_data_source.dart`

```dart
// Current implementation uses client-side filtering
List<Product> _filterProductsByQuery(List<Product> products, String query) {
  if (query.trim().isEmpty) return products;
  
  final lowerQuery = query.toLowerCase();
  return products.where((product) {
    return product.base.title.toLowerCase().contains(lowerQuery) ||
           product.base.description.toLowerCase().contains(lowerQuery) ||
           product.base.brand.toLowerCase().contains(lowerQuery) ||
           product.metadata.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }).toList();
}
```

### Planned Search Enhancements
- ✅ Basic text search on title, description, brand
- ⬜ Advanced filtering by price range, category, attributes
- ⬜ Faceted navigation (counts per filter category)
- ⬜ Sorting options (price, relevance, date, popularity)
- ⬜ Autocomplete and search suggestions
- ⬜ Spell correction and synonym handling
- ⬜ Search analytics and popular queries

## 7. Component Library

### Reusable Widgets (Implemented)
- **ProductCard**: Displays product image, title, price, and add-to-cart button
- **GlassCard**: Glassmorphic container used throughout the app
- **PremiumButton**: Styled button with gradient background
- **CategoryCard**: Displays category icon and name
- **SkeletonLoader**: Placeholder shimmer effect for loading states

### Planned Components
- ProductGrid/ProductList: Different layout options for product display
- PriceTag: Shows current price with optional original price strikethrough
- RatingStars: Displays product rating with half-star support
- AddToCartButton: Floating action button or inline button for cart operations
- ProductImageGallery: Image viewer with zoom and swipe support
- ProductVariations: Selector for product attributes (size, color, etc.)
- FilterPanel: Sidebar or modal for applying search filters
- SortDropdown: Selector for sorting options
- SearchBar: Enhanced search input with suggestions and voice search
- EmptyState: Illustrations and messaging for empty results
- LoadingStates: Various loading indicators (spinners, skeletons, progress bars)

## 8. State Management (Implemented)

### Product State
```dart
// In lib/features/marketplace/application/providers/product_provider.dart
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productRepositoryProvider));
});

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? selectedCategoryId;
  
  // Getters and copyWith methods...
}

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier(this._productRepository) : super(const ProductState());
  
  final ProductRepository _productRepository;
  
  // Methods to load products, search, filter, etc.
}
```

### Cart State (Implemented)
```dart
// In lib/features/marketplace/application/providers/cart_provider.dart
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.read(cartRepositoryProvider));
});

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  
  // Getters for total price, item count, etc.
  double get totalPrice => items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  // CopyWith methods...
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this._cartRepository) : super(const CartState());
  
  final CartRepository _cartRepository;
  
  // Methods to add/remove items, update quantities, clear cart
}
```

## 9. Navigation Flow (Implemented)

### Current Routes
- `/marketplace/` → Marketplace Home Screen
- `/marketplace/products` → Product Listing Screen (with search/category filtering)
- `/marketplace/products/{productId}` → Product Detail Screen
- `/marketplace/cart` → Shopping Cart Screen (to be implemented)
- `/marketplace/categories` → Category Browse Screen (to be implemented)

### Navigation Implementation
Uses GoRouter with typed routes from `core/router/app_router.dart`.

Example route definition:
```dart
GoRoute(
  path: '/marketplace/products/:productId',
  name: 'productDetail',
  builder: (context, state) => ProductDetailScreen(
    productId: state.params['productId']!,
  ),
),
```

## 10. Security Considerations

### Authentication & Authorization
- ✅ Integrated with Firebase Authentication via authRepositoryProvider
- ✅ Product browsing accessible to all users (including guests)
- ⬜ Cart operations require user identification (using anonymous/user ID)
- ⬜ User-specific features (wishlist, order history) require authentication
- ⬜ Role-based access for admin/moderator features (planned)

### Data Protection
- ⬜ Input validation and sanitization (planned)
- ⬜ Rate limiting on API endpoints (planned)
- ⬜ Secure storage of sensitive information (planned)
- ⬜ CORS and security headers (handled by Firebase hosting)
- ⬜ Regular security audits and penetration testing (planned)

## 11. Performance Optimizations

### Implemented
- ✅ Lazy loading of images (using placeholder until network image loads)
- ✅ Efficient list rendering with ListView.builder for product grids
- ⬜ Constant constructors where applicable for widget optimization
- ⬜ Minimal widget rebuilds using selective state updates
- ⬜ Proper disposal of controllers and subscriptions

### Planned
- ⬜ Image caching and optimization (various sizes/WebP formats)
- ⬜ HTTP caching for API requests
- ⬜ Database query optimization with proper indexing
- ⬜ Pagination and infinite scrolling for large product lists
- ⬜ Debouncing for search input to reduce API calls
- ⬜ Code splitting and lazy loading of feature modules
- ⬜ Bundle size optimization (tree shaking, deferred imports)
- ⬜ Memory leak detection and prevention

## 12. Error Handling and Logging

### Implemented
- ✅ Try/catch blocks around asynchronous operations
- ✅ Error state propagation through StateNotifiers
- ✅ User-friendly error messages in UI
- ✅ Loading states during async operations
- ✅ Retry mechanisms for failed operations

### Planned
- ⬜ Centralized error logging service
- ⬜ Error boundary widgets to catch unexpected errors
- ⬜ Analytics integration for error tracking
- ⬜ Graceful degradation when services are unavailable
- ⬜ User feedback mechanisms for reporting issues

## 13. Testing Strategy

### Unit Tests (Planned)
- Repository implementations
- Use cases and business logic
- State converters and data transformations
- Utility functions and helpers

### Widget Tests (Planned)
- Individual widget rendering with various states
- User interaction simulation (taps, text input)
- Navigation and route testing
- Theme and responsiveness testing

### Integration Tests (Planned)
- Complete user flows (browse → add to cart → checkout)
- Authentication flows
- Payment processing flows
- Critical path testing

### Test Coverage Goals
- Model classes: 90%+
- Repository implementations: 80%+
- Use cases: 85%+
- UI components: 70%+
- Overall project: 75%+

## 14. Implementation Roadmap

### Phase 1: Core Marketplace Functionality (In Progress)
- [x] Product browsing and search
- [x] Product detail viewing
- [x] Add to cart functionality
- [x] Basic cart UI
- [x] Home screen with featured content
- [x] Category browsing

### Phase 2: Shopping Experience (Next)
- [ ] Wishlist functionality
- [ ] Shopping cart persistence (Firestore-backed)
- [ ] Cart quantity management
- [ ] Save for later functionality
- [ ] Estimated totals (subtotal, tax, shipping)
- [ ] Checkout initiation

### Phase 3: Payment & Orders (Future)
- [ ] Payment integration (Stripe/PayPal)
- [ ] Order creation and confirmation
- [ ] Order history and tracking
- [ ] Invoice generation
- [ ] Payment method storage
- [ ] Reorder functionality

### Phase 4: User Engagement (Future)
- [ ] Product reviews and ratings
- [ ] User profiles and preferences
- [ ] Address book management
- [ ] Recently viewed items
- [ ] Personalized recommendations
- [ ] Email/SMS notifications

### Phase 5: Advanced Features (Future)
- [ ] Advanced filtering and sorting
- [ ] Product variants and options
- [ ] Inventory management and stock alerts
- [ ] Sales and promotions engine
- [ ] Loyalty programs and rewards
- [ ] Social sharing and wishlists
- [ ] AR product visualization
- [ ] Barcode/QR code scanning

## 15. Development Guidelines

### Code Organization
- Follow the exact folder structure outlined in CLAUDE.md
- Keep domain layer pure (no Firebase/UI dependencies)
- Put all Firebase/Firestore code in data/repositories/
- Put UI code only in presentation/
- Put state management and business logic in application/
- Use meaningful, descriptive names for classes and functions

### State Management
- Use Riverpod StateNotifier for complex state logic
- Use Provider for simple state or read-only data
- Separate UI state from business logic state
- Implement proper loading and error states
- Use freezed or similar for immutable state objects where beneficial

### UI/UX Guidelines
- Follow Material Design 3 principles
- Use the provided theme colors and text styles
- Create reusable widgets for common UI patterns
- Implement proper loading, error, and empty states
- Ensure accessibility standards are met
- Make UI responsive for all screen sizes
- Use animations purposefully to enhance UX

### Testing Practices
- Write tests as you develop features
- Mock external dependencies in unit tests
- Test edge cases and error conditions
- Keep tests focused and readable
- Run tests frequently during development

### Performance Considerations
- Use const constructors whenever possible
- Optimize rebuilds with selective state updates
- Implement proper disposal of controllers/streams
- Consider memory usage for lists and images
- Profile app performance regularly

## 16. Current Limitations and Workarounds

### Known Limitations
1. **Data Persistence**: Currently using in-memory storage only
   - Workaround: Data resets on app restart
   - Planned fix: Implement Firestore persistence

2. **Search Functionality**: Client-side filtering only
   - Workaround: Limited to loaded products (typically 20-50 items)
   - Planned fix: Server-side search with Firestore or search service

3. **Cart Persistence**: Not persisted across sessions
   - Workaround: Cart lost when app is closed
   - Planned fix: Firestore-backed cart with user ID association

4. **Product Variations**: Simple product model only
   - Workaround: No support for size/color options
   - Planned fix: Product variant system with attribute selection

5. **User Authentication**: Basic implementation
   - Workaround: Uses hardcoded/demo user IDs
   - Planned fix: Full Firebase Auth integration with proper user context

### Temporary Solutions
- Mock data services for development
- In-memory repositories for state management
- Basic UI components with planned enhancements
- Placeholder implementations for missing features
- Hardcoded values where dynamic data would normally be used