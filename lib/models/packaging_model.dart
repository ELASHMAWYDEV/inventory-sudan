import 'package:cloud_firestore/cloud_firestore.dart';

class RawMaterial {
  final String name;
  final double weight;

  RawMaterial({
    required this.name,
    required this.weight,
  });

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      name: map['name'] ?? '',
      weight: map['weight']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
    };
  }
}

class PackagedProduct {
  final String name;
  final String packageSize;
  final int count;

  PackagedProduct({
    required this.name,
    required this.packageSize,
    required this.count,
  });

  factory PackagedProduct.fromMap(Map<String, dynamic> map) {
    return PackagedProduct(
      name: map['name'] ?? '',
      packageSize: map['packageSize'] ?? '',
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'packageSize': packageSize,
      'count': count,
    };
  }
}

class EmptyPackage {
  final String type;
  final String size;
  final int count;

  EmptyPackage({
    required this.type,
    required this.size,
    required this.count,
  });

  factory EmptyPackage.fromMap(Map<String, dynamic> map) {
    return EmptyPackage(
      type: map['type'] ?? '',
      size: map['size'] ?? '',
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'size': size,
      'count': count,
    };
  }
}

class PackagingModel {
  final String? id;
  final DateTime inventoryDate;
  final List<RawMaterial> rawMaterials;
  final List<PackagedProduct> packagedProducts;
  final List<EmptyPackage> emptyPackages;
  final String? notes;
  final List<String>? imageUrls;
  final String createdBy;
  final DateTime createdAt;

  PackagingModel({
    this.id,
    required this.inventoryDate,
    required this.rawMaterials,
    required this.packagedProducts,
    required this.emptyPackages,
    this.notes,
    this.imageUrls,
    required this.createdBy,
    required this.createdAt,
  });

  factory PackagingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse raw materials
    List<RawMaterial> rawMaterials = [];
    if (data['rawMaterials'] != null) {
      rawMaterials = (data['rawMaterials'] as List)
          .map((material) => RawMaterial.fromMap(material as Map<String, dynamic>))
          .toList();
    }

    // Parse packaged products
    List<PackagedProduct> packagedProducts = [];
    if (data['packagedProducts'] != null) {
      packagedProducts = (data['packagedProducts'] as List)
          .map((product) => PackagedProduct.fromMap(product as Map<String, dynamic>))
          .toList();
    }

    // Parse empty packages
    List<EmptyPackage> emptyPackages = [];
    if (data['emptyPackages'] != null) {
      emptyPackages =
          (data['emptyPackages'] as List).map((pkg) => EmptyPackage.fromMap(pkg as Map<String, dynamic>)).toList();
    }

    return PackagingModel(
      id: doc.id,
      inventoryDate: data['inventoryDate'] != null ? (data['inventoryDate'] as Timestamp).toDate() : DateTime.now(),
      rawMaterials: rawMaterials,
      packagedProducts: packagedProducts,
      emptyPackages: emptyPackages,
      notes: data['notes'],
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inventoryDate': Timestamp.fromDate(inventoryDate),
      'rawMaterials': rawMaterials.map((material) => material.toMap()).toList(),
      'packagedProducts': packagedProducts.map((product) => product.toMap()).toList(),
      'emptyPackages': emptyPackages.map((pkg) => pkg.toMap()).toList(),
      'notes': notes,
      'imageUrls': imageUrls,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PackagingModel.fromMap(Map<String, dynamic> data) {
    // Parse raw materials
    List<RawMaterial> rawMaterials = [];
    if (data['rawMaterials'] != null) {
      rawMaterials = (data['rawMaterials'] as List)
          .map((material) => RawMaterial.fromMap(material as Map<String, dynamic>))
          .toList();
    }

    // Parse packaged products
    List<PackagedProduct> packagedProducts = [];
    if (data['packagedProducts'] != null) {
      packagedProducts = (data['packagedProducts'] as List)
          .map((product) => PackagedProduct.fromMap(product as Map<String, dynamic>))
          .toList();
    }

    // Parse empty packages
    List<EmptyPackage> emptyPackages = [];
    if (data['emptyPackages'] != null) {
      emptyPackages =
          (data['emptyPackages'] as List).map((pkg) => EmptyPackage.fromMap(pkg as Map<String, dynamic>)).toList();
    }

    return PackagingModel(
      id: data['id'],
      inventoryDate: data['inventoryDate'] != null ? DateTime.parse(data['inventoryDate']) : DateTime.now(),
      rawMaterials: rawMaterials,
      packagedProducts: packagedProducts,
      emptyPackages: emptyPackages,
      notes: data['notes'],
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
    );
  }
}
