# Firestore Collection Audit - July 26, 2026

## Collections in Use

This document confirms which Firestore collections are actively being used in the codebase as of July 26, 2026.

### Collections Verified in Use

| Collection Name | Usage Location(s) | Purpose |
|----------------|-------------------|---------|
| **transactions** | `lib\features\business\data\repositories\firestore_loyalty_repository.dart:22` | Loyalty program transaction history (subcollection under users) |
| **bundles** | `lib\features\marketplace\data\repositories\firestore_coupon_repository.dart:12` | Product bundles for promotions and discounts |
| **ad_campaigns** | `lib\features\business\data\repositories\firestore_analytics_repository.dart:18` | Advertising campaigns for sellers |
| **settings** | `lib\features\chat\data\repositories\firestore_notification_repository.dart:18` | User notification and app settings (subcollection under users) |
| **history** | `lib\features\marketplace\data\repositories\firestore_order_repository.dart:240,305,342,379,431` | Order history tracking (subcollection under orders) |
| **visual_search_history** | `lib\features\chat\data\repositories\firestore_visual_search_repository.dart:15` | User's visual search history (subcollection under users) |
| **visual_search_preferences** | `lib\features\chat\data\repositories\firestore_visual_search_repository.dart:19` | User preferences for visual search (subcollection under users) |

### Other Collections in Use

Additional collections confirmed to be in use throughout the codebase:

- `users` - Main user profiles
- `organizations` - Business/organization accounts
- `products` - Product catalog
- `categories` - Product categories
- `orders` - Customer orders
- `reviews` - Product reviews
- `business_accounts` - Seller business profiles
- `coupons` - Discount coupons
- `carts` - Shopping carts
- `wishlists` - User wishlists
- `notifications` - User notifications
- `chat_sessions` & `messages` - Chat functionality
- `loyalty` & `loyalty_tiers` - Loyalty program
- `inventory_items` - Procurement inventory
- `rfqs`, `rfq_items`, `rfq_responses`, `rfq_response_items` - Procurement RFQ system
- `warehouses` - Warehouse management
- `addresses` - User addresses
- Recently viewed items tracking
- Saved carts functionality

### Conclusion

All collections specified in the audit request (`transactions`, `bundles`, `ad_campaigns`, `settings`, `history`, `visual_search_*`) are confirmed to be actively used in the codebase. No collections mentioned in the audit request appear to be unused or orphaned.

This audit confirms that the collections referenced in the database schema documentation and migration matrix have actual implementations in the data access layer.

*Audit completed: July 26, 2026*