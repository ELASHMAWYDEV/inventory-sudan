import 'package:cloud_firestore/cloud_firestore.dart';

class SaleItem {
  final String productName;
  final int quantityOfPackages;
  final double pricePerPackage;
  final String packageType; // B2B, B2C
  final double totalPrice;

  SaleItem({
    required this.productName,
    required this.quantityOfPackages,
    required this.pricePerPackage,
    required this.packageType,
    required this.totalPrice,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productName: map['productName'] ?? '',
      quantityOfPackages: map['quantityOfPackages'] ?? 0,
      pricePerPackage: map['pricePerPackage']?.toDouble() ?? 0.0,
      packageType: map['packageType'] ?? '',
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantityOfPackages': quantityOfPackages,
      'pricePerPackage': pricePerPackage,
      'packageType': packageType,
      'totalPrice': totalPrice,
    };
  }
}

class SalesModel {
  final String? id;
  final DateTime saleDate;
  final List<SaleItem> items;
  final String buyerType; // Supermarket, Individual, Online Client
  final String buyerName;
  final String buyerLocation;
  final double totalAmount;
  final double collectedAmount;
  final double remainingAmount; // totalAmount - collectedAmount
  final String paymentStatus; // 'paid', 'unpaid', 'partial'
  final String? notes;
  final List<String>? imageUrls;
  final String createdBy;
  final DateTime createdAt;

  SalesModel({
    this.id,
    required this.saleDate,
    required this.items,
    required this.buyerType,
    required this.buyerName,
    required this.buyerLocation,
    required this.totalAmount,
    required this.collectedAmount,
    required this.remainingAmount,
    required this.paymentStatus,
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
      items = (data['items'] as List).map((item) => SaleItem.fromMap(item as Map<String, dynamic>)).toList();
    }

    double totalAmount = data['totalAmount']?.toDouble() ?? 0.0;
    double collectedAmount = data['collectedAmount']?.toDouble() ?? 0.0;
    double remainingAmount = totalAmount - collectedAmount;

    return SalesModel(
      id: doc.id,
      saleDate: data['saleDate'] != null ? (data['saleDate'] as Timestamp).toDate() : DateTime.now(),
      items: items,
      buyerType: data['buyerType'] ?? '',
      buyerName: data['buyerName'] ?? data['customerName'] ?? '', // Handle legacy field
      buyerLocation: data['buyerLocation'] ?? '',
      totalAmount: totalAmount,
      collectedAmount: collectedAmount,
      remainingAmount: data['remainingAmount']?.toDouble() ?? remainingAmount,
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      notes: data['notes'],
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'saleDate': Timestamp.fromDate(saleDate),
      'items': items.map((item) => item.toMap()).toList(),
      'buyerType': buyerType,
      'buyerName': buyerName,
      'buyerLocation': buyerLocation,
      'totalAmount': totalAmount,
      'collectedAmount': collectedAmount,
      'remainingAmount': remainingAmount,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'imageUrls': imageUrls,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SalesModel.fromMap(Map<String, dynamic> data) {
    // Parse sale items
    List<SaleItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List).map((item) => SaleItem.fromMap(item as Map<String, dynamic>)).toList();
    }

    double totalAmount = data['totalAmount']?.toDouble() ?? 0.0;
    double collectedAmount = data['collectedAmount']?.toDouble() ?? 0.0;
    double remainingAmount = totalAmount - collectedAmount;

    return SalesModel(
      id: data['id'],
      saleDate: data['saleDate'] != null ? DateTime.parse(data['saleDate']) : DateTime.now(),
      items: items,
      buyerType: data['buyerType'] ?? '',
      buyerName: data['buyerName'] ?? data['customerName'] ?? '',
      buyerLocation: data['buyerLocation'] ?? '',
      totalAmount: totalAmount,
      collectedAmount: collectedAmount,
      remainingAmount: data['remainingAmount']?.toDouble() ?? remainingAmount,
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      notes: data['notes'],
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
    );
  }
}
