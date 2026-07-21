enum InventoryStatus {
  /// Item is available for allocation/sale
  available,

  /// Item is reserved (in carts, pending orders, etc.)
  reserved,

  /// Item is allocated to a specific job/project
  allocated,

  /// Item is transferred between warehouses
  inTransit,

  /// Item is damaged or unusable
  damaged,

  /// Item is quarantined for inspection
  quarantined,

  /// Item is consumed/used (for consumables)
  consumed,

  /// Item is returned to inventory
  returned,

  /// Item is scrapped/disposed
  scrapped,
}