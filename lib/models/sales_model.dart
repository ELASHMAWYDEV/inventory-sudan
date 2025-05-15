import 'package:cloud_firestore/cloud_firestore.dart';

class SaleItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

class SalesModel {
  final String? id;
  final DateTime saleDate;
  final String customerName;
  final List<SaleItem> items;
  final double totalAmount;
  final String paymentStatus; // 'paid', 'unpaid', 'partial'
  final double? amountPaid;
  final String? notes;
  final List<String>? imageUrls;
  final String createdBy;
  final DateTime createdAt;

  SalesModel({
    this.id,
    required this.saleDate,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.paymentStatus,
    this.amountPaid,
    this.notes,
    this.imageUrls,
    required this.createdBy,
    required this.createdAt,
  });

  factory SalesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse sale items
    List<SaleItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => SaleItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return SalesModel(
      id: doc.id,
      saleDate: data['saleDate'] != null 
          ? (data['saleDate'] as Timestamp).toDate()
          : DateTime.now(),
      customerName: data['customerName'] ?? '',
      items: items,
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      amountPaid: data['amountPaid']?.toDouble(),
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
      'saleDate': Timestamp.fromDate(saleDate),
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'notes': notes,
      'imageUrls': imageUrls,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
