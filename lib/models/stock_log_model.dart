import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String itemName;
  final String itemType; // 'raw_material', 'packaged_product', or 'empty_package'
  final double expectedQuantity;
  final double actualQuantity;
  final String? unit; // 'kg', 'count', etc.
  final double? difference;
  final String? reason;

  InventoryItem({
    required this.itemName,
    required this.itemType,
    required this.expectedQuantity,
    required this.actualQuantity,
    this.unit,
    this.difference,
    this.reason,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      itemName: map['itemName'] ?? '',
      itemType: map['itemType'] ?? 'raw_material',
      expectedQuantity: map['expectedQuantity']?.toDouble() ?? 0.0,
      actualQuantity: map['actualQuantity']?.toDouble() ?? 0.0,
      unit: map['unit'],
      difference: map['difference']?.toDouble(),
      reason: map['reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'itemType': itemType,
      'expectedQuantity': expectedQuantity,
      'actualQuantity': actualQuantity,
      'unit': unit,
      'difference': difference,
      'reason': reason,
    };
  }
}

class StockLogModel {
  final String? id;
  final DateTime logDate;
  final List<InventoryItem> inventoryItems;
  final bool hasDiscrepancies;
  final String? notes;
  final List<String>? imageUrls;
  final String createdBy;
  final DateTime createdAt;

  StockLogModel({
    this.id,
    required this.logDate,
    required this.inventoryItems,
    required this.hasDiscrepancies,
    this.notes,
    this.imageUrls,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse inventory items
    List<InventoryItem> inventoryItems = [];
    if (data['inventoryItems'] != null) {
      inventoryItems = (data['inventoryItems'] as List)
          .map((item) => InventoryItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return StockLogModel(
      id: doc.id,
      logDate: data['logDate'] != null 
          ? (data['logDate'] as Timestamp).toDate()
          : DateTime.now(),
      inventoryItems: inventoryItems,
      hasDiscrepancies: data['hasDiscrepancies'] ?? false,
      notes: data['notes'],
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logDate': Timestamp.fromDate(logDate),
      'inventoryItems': inventoryItems.map((item) => item.toMap()).toList(),
      'hasDiscrepancies': hasDiscrepancies,
      'notes': notes,
      'imageUrls': imageUrls,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
