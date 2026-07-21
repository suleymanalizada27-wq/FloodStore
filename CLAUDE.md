❯  FloodStore Codebase Reorganization Plan

   Context

   The FloodStore codebase currently violates the Clean Architecture and feature-based organization principles defined in CLAUDE.md. Specifically:
   - Entities and repositories that belong to other features (business, procurement, chat) are incorrectly placed in the marketplace feature
   - Core GROUP 1 features (checkout, payments, etc.) from CLAUDE.md are missing or incomplete
   - The codebase needs reorganization to match the TARGET FOLDER STRUCTURE before implementing new features

   This plan focuses on Phase 1: reorganizing existing code to match the target architecture, then implementing missing core B2C features.

   Problems Identified

   1. Misplaced Entities: Many entities in lib/features/marketplace/domain/entities/ belong to other features:
     - Business-related: business_account.dart, seller_analytics.dart, loyalty.dart
     - Procurement-related: inventory.dart, warehouse.dart
     - Chat-related: chat_message.dart, chat_session.dart, notification.dart, visual_search.dart
     - Others: recommendation.dart, review.dart, user.dart (user might be shared but needs review)
   2. Misplaced Repositories: Similar misplacement exists in domain and data repositories
   3. Missing Core Features: GROUP 1 features from CLAUDE.md are incomplete:
     - Checkout: Missing entirely
     - Payments: Missing entirely
     - Orders: Repository exists but may need completion
     - Reviews/Ratings: Entity exists but feature implementation missing
     - Wishlist: Repository exists but UI/incomplete
     - Advanced Filtering: Missing
     - Coupons/Campaigns: Entity exists but feature missing

   Solution Approach

   1. Reorganize Existing Code: Move misplaced entities/repositories to their correct features
   2. Create Missing Features: Implement missing GROUP 1 features following the MARKETPLACE_ARCHITECTURE.md structure
   3. Verify Architecture: Ensure all code follows Clean Architecture principles
   4. Incremental Implementation: Implement features one at a time, verifying each before moving to next

   Detailed Implementation Plan

   Phase 1: Code Reorganization (Week 1)

   Step 1: Move Business Logic to Business Feature

   - Create lib/features/business/ with domain/data/application/presentation structure
   - Move entities: business_account.dart, seller_analytics.dart, loyalty.dart
   - Move corresponding repositories and providers
   - Update all import statements

   Step 2: Verify Procurement Separation

   - Confirm procurement/ feature has correct structure from previous migration
   - Move inventory.dart and warehouse.dart from marketplace to procurement if not already done
   - Move corresponding repositories

   Step 3: Extract Chat Functionality

   - Create lib/features/chat/ feature
   - Move chat-related entities: chat_message.dart, chat_session.dart, notification.dart, visual_search.dart
   - Move corresponding repositories and providers
   - Update imports

   Step 4: Review Shared Entities

   - Analyze user.dart and product.dart - these may be correctly placed in marketplace as core B2C entities
   - category.dart and product_variant.dart appear correctly placed
   - cart.dart and order.dart are core marketplace and correctly placed
   - wishlist.dart is core marketplace and correctly placed

   Phase 2: Implement Missing GROUP 1 Features (Weeks 2-4)

   Following the execution order in PROGRESS.md and CLAUDE.md:

   Feature 1: Wishlist (Already has foundation)

   - Verify Wishlist entity is complete
   - Implement WishlistRepository if incomplete
   - Create wishlist_screen.dart in presentation/screens
   - Create wishlist widgets (WishlistItemTile, etc.)
   - Update providers in marketplace_providers.dart
   - Add routes to app_router.dart
   - Implement add/remove from wishlist functionality

   Feature 2: Shopping Cart Completion (Currently partial)

   - Verify Cart and CartItem entities are complete
   - Ensure FirestoreCartRepository implements all methods
   - Create complete cart_screen.dart (already exists, needs verification)
   - Implement cart persistence with Firestore
   - Add cart summary, checkout initiation
   - Test cart operations (add, remove, update quantity, clear)

   Feature 3: Checkout

   - Create Checkout entity in domain/entities
   - Create CheckoutRepository in domain/repositories
   - Create FirestoreCheckoutRepository in data/repositories
   - Create checkout provider in application/providers
   - Create checkout screens:
     - Checkout screen with shipping/billing address forms
     - Payment method selection
     - Order review screen
   - Implement checkout flow integration with cart and orders
   - Add routes to app_router.dart

   Feature 4: Payments

   - Research payment integration options compatible with Firebase free tier
   - Create payment entities and repositories
   - Integrate with checkout flow
   - Create payment screens/methods
   - Note: Avoid Cloud Functions due to free tier constraint

   Feature 5: Orders (Foundation exists)

   - Verify Order entity completeness
   - Ensure FirestoreOrderRepository is complete
   - Create order history screen: orders_screen.dart
   - Create order detail screen: order_detail_screen.dart
   - Implement order status tracking
   - Add routes to app_router.dart

   Feature 6: Reviews & Ratings

   - Verify Review entity is complete
   - Create ReviewRepository if needed
   - Create reviews screen: reviews_screen.dart
   - Create review form widget
   - Implement review submission and display
   - Add routes to app_router.dart

   Feature 7: Search Enhancement (Client-side implemented)

   - Verify current client-side search in firestore_product_data_source.dart
   - Consider if enhanced filtering is needed for GROUP 1
   - Add sorting options (price, relevance, date)
   - Add basic filtering UI in product listing

   Feature 8: Advanced Filtering

   - Create filter entities and models
   - Implement filter UI (sidebar/bottom sheet)
   - Connect to product search with filters (price range, category, brand, etc.)
   - Update product search provider to accept filter parameters

   Feature 9: Coupons & Campaigns

   - Verify Coupon entity completeness
   - Ensure FirestoreCouponRepository works
   - Create coupon management screens
   - Implement coupon application in cart/checkout
   - Create campaign entities if needed
   - Add routes to app_router.dart

   Phase 3: Verification & Quality Assurance

   - Run flutter analyze after each major change
   - Run flutter test to ensure no regressions
   - Test builds: flutter build apk --debug
   - Manual testing of each feature implementation
   - Verify Firestore reads/writes stay within free tier limits
   - Ensure code follows Clean Architecture strictly:
     - Domain: No Firebase/UI dependencies
     - Data: Only Firebase implementations
     - Application: Providers and state management only
     - Presentation: UI only

   Files to be Created/Moved

   New Feature Directories:

   lib/features/business/
   lib/features/chat/

   Files to Move FROM marketplace TO business:

   - lib/features/marketplace/domain/entities/business_account.dart
   - lib/features/marketplace/domain/entities/seller_analytics.dart
   - lib/features/marketplace/domain/entities/loyalty.dart
   - ... corresponding repositories and providers

   Files to Move FROM marketplace TO chat:

   - lib/features/marketplace/domain/entities/chat_message.dart
   - lib/features/marketplace/domain/entities/chat_session.dart
   - lib/features/marketplace/domain/entities/notification.dart
   - lib/features/marketplace/domain/entities/visual_search.dart
   - ... corresponding repositories and providers

   Files to Verify/Create for Missing Features:

   - lib/features/marketplace/domain/entities/checkout.dart
   - lib/features/marketplace/domain/repositories/checkout_repository.dart
   - lib/features/marketplace/data/repositories/firestore_checkout_repository.dart
   - lib/features/marketplace/application/providers/checkout_provider.dart
   - lib/features/marketplace/presentation/screens/checkout_screen.dart
   - lib/features/marketplace/presentation/screens/order_detail_screen.dart
   - lib/features/marketplace/presentation/screens/orders_screen.dart
   - lib/features/marketplace/presentation/screens/wishlist_screen.dart
   - lib/features/marketplace/presentation/screens/reviews_screen.dart
   - lib/features/marketplace/presentation/screens/payment_screen.dart
   - lib/features/marketplace/presentation/screens/reviews_screen.dart
   - lib/features/marketplace/presentation/screens/payment_screen.dart
   - ... corresponding widgets and state files

   Verification Criteria

   1. All entities in correct features per TARGET FOLDER STRUCTURE
   2. No entity imports Firebase or UI packages
   3. All repository implementations in data/ directory only
   4. All providers only in application/ directory
   5. All UI only in presentation/ directory
   6. Each GROUP 1 feature has:
     - Complete entity (if needed)
     - Complete repository implementation
     - Provider(s) for state management
     - Screen(s) for user interaction
     - Proper routing
     - Basic functionality implemented and tested

   Estimated Timeline

   - Phase 1 (Reorganization): 3-5 days
   - Phase 2 (Feature Implementation): 2-3 weeks (depending on complexity)
   - Phase 3 (Verification): Ongoing

   Next Immediate Action

   Begin Phase 1 by creating the business and chat features, then moving the clearly misplaced
  entitieshttps://github.com/suleymanalizada27-wq/FloodStore
