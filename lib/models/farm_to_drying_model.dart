import 'package:cloud_firestore/cloud_firestore.dart';

class BatchDetail {
  final int batchNumber;
  final double weightBeforeDrying;
  final double weightAfterDrying;
  final double? dryingPercentage;

  BatchDetail({
    required this.batchNumber,
    required this.weightBeforeDrying,
    required this.weightAfterDrying,
    this.dryingPercentage,
  });

  factory BatchDetail.fromMap(Map<String, dynamic> map) {
    return BatchDetail(
      batchNumber: map['batchNumber'] ?? 0,
      weightBeforeDrying: map['weightBeforeDrying']?.toDouble() ?? 0.0,
      weightAfterDrying: map['weightAfterDrying']?.toDouble() ?? 0.0,
      dryingPercentage: map['dryingPercentage']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batchNumber': batchNumber,
      'weightBeforeDrying': weightBeforeDrying,
      'weightAfterDrying': weightAfterDrying,
      'dryingPercentage': dryingPercentage,
    };
  }
}

class FarmToDryingModel {
  final String? id;
  final String productName;
  final DateTime purchaseDate;
  final String? productType;
  final String? purchaseLocation;
  final String? supplierName;
  final String? supplierPhone;

  // Financial details
  final double? dollarRate;
  final double? sackPrice;
  final double? agreedSackWeight;
  final double? actualSackWeight;
  final int sackCount;
  final double productCost;
  final double? unloadingLoadingCost;
  final double? taxCost;
  final double? newSacksCost;
  final double? transportationCost;
  final double? logisticsCost;
  final double totalCosts;

  // Logistics details
  final DateTime? logisticsTravelDate;
  final double? logisticsTransportationCost;
  final double? logisticsAccommodationCost;
  final double? logisticsMealsCost;
  final double? logisticsLocalTransportCost;
  final double? logisticsTotalCost;

  // Processing details
  final DateTime? arrivalDate;
  final int? processingDays;
  final int? dryingDays;
  final int? laborCount;
  final double? laborCost;
  final double? suppliesCost;

  // Weight and drying details
  final double? totalWeightBeforeDrying;
  final double? wasteWeight;
  final double? totalWeightToDryer;
  final double? totalWeightAfterDrying;
  final double? dryingPercentage;

  // Additional info
  final List<BatchDetail>? batchDetails;
  final List<String>? imageUrls;
  final String? notes;

  FarmToDryingModel({
    this.id,
    required this.productName,
    required this.purchaseDate,
    this.productType,
    this.purchaseLocation,
    this.supplierName,
    this.supplierPhone,
    this.dollarRate,
    this.sackPrice,
    this.agreedSackWeight,
    this.actualSackWeight,
    required this.sackCount,
    required this.productCost,
    this.unloadingLoadingCost,
    this.taxCost,
    this.newSacksCost,
    this.transportationCost,
    this.logisticsCost,
    required this.totalCosts,
    this.logisticsTravelDate,
    this.logisticsTransportationCost,
    this.logisticsAccommodationCost,
    this.logisticsMealsCost,
    this.logisticsLocalTransportCost,
    this.logisticsTotalCost,
    this.arrivalDate,
    this.processingDays,
    this.dryingDays,
    this.laborCount,
    this.laborCost,
    this.suppliesCost,
    this.totalWeightBeforeDrying,
    this.wasteWeight,
    this.totalWeightToDryer,
    this.totalWeightAfterDrying,
    this.dryingPercentage,
    this.batchDetails,
    this.imageUrls,
    this.notes,
  });

  factory FarmToDryingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse batch details if available
    List<BatchDetail>? batchDetails;
    if (data['batchDetails'] != null) {
      batchDetails =
          (data['batchDetails'] as List).map((batch) => BatchDetail.fromMap(batch as Map<String, dynamic>)).toList();
    }

    return FarmToDryingModel(
      id: doc.id,
      productName: data['productName'] ?? '',
      purchaseDate: data['purchaseDate'] != null ? (data['purchaseDate'] as Timestamp).toDate() : DateTime.now(),
      productType: data['productType'],
      purchaseLocation: data['purchaseLocation'],
      supplierName: data['supplierName'],
      supplierPhone: data['supplierPhone'],
      dollarRate: data['dollarRate']?.toDouble(),
      sackPrice: data['sackPrice']?.toDouble(),
      agreedSackWeight: data['agreedSackWeight']?.toDouble(),
      actualSackWeight: data['actualSackWeight']?.toDouble(),
      sackCount: data['sackCount'] ?? 0,
      productCost: data['productCost']?.toDouble() ?? data['totalPurchaseCost']?.toDouble() ?? 0,
      unloadingLoadingCost: data['unloadingLoadingCost']?.toDouble(),
      taxCost: data['taxCost']?.toDouble(),
      newSacksCost: data['newSacksCost']?.toDouble(),
      transportationCost: data['transportationCost']?.toDouble(),
      logisticsCost: data['logisticsCost']?.toDouble(),
      totalCosts: data['totalCosts']?.toDouble() ?? 0,
      logisticsTravelDate:
          data['logisticsTravelDate'] != null ? (data['logisticsTravelDate'] as Timestamp).toDate() : null,
      logisticsTransportationCost: data['logisticsTransportationCost']?.toDouble(),
      logisticsAccommodationCost: data['logisticsAccommodationCost']?.toDouble(),
      logisticsMealsCost: data['logisticsMealsCost']?.toDouble(),
      logisticsLocalTransportCost: data['logisticsLocalTransportCost']?.toDouble(),
      logisticsTotalCost: data['logisticsTotalCost']?.toDouble(),
      arrivalDate: data['arrivalDate'] != null ? (data['arrivalDate'] as Timestamp).toDate() : null,
      processingDays: data['processingDays'],
      dryingDays: data['dryingDays'],
      laborCount: data['laborCount'],
      laborCost: data['laborCost']?.toDouble(),
      suppliesCost: data['suppliesCost']?.toDouble(),
      totalWeightBeforeDrying: data['totalWeightBeforeDrying']?.toDouble(),
      wasteWeight: data['wasteWeight']?.toDouble(),
      totalWeightToDryer: data['totalWeightToDryer']?.toDouble(),
      totalWeightAfterDrying: data['totalWeightAfterDrying']?.toDouble(),
      dryingPercentage: data['dryingPercentage']?.toDouble(),
      batchDetails: batchDetails,
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'productType': productType,
      'purchaseLocation': purchaseLocation,
      'supplierName': supplierName,
      'supplierPhone': supplierPhone,
      'dollarRate': dollarRate,
      'sackPrice': sackPrice,
      'agreedSackWeight': agreedSackWeight,
      'actualSackWeight': actualSackWeight,
      'sackCount': sackCount,
      'productCost': productCost,
      'unloadingLoadingCost': unloadingLoadingCost,
      'taxCost': taxCost,
      'newSacksCost': newSacksCost,
      'transportationCost': transportationCost,
      'logisticsCost': logisticsCost,
      'totalCosts': totalCosts,
      'logisticsTravelDate': logisticsTravelDate != null ? Timestamp.fromDate(logisticsTravelDate!) : null,
      'logisticsTransportationCost': logisticsTransportationCost,
      'logisticsAccommodationCost': logisticsAccommodationCost,
      'logisticsMealsCost': logisticsMealsCost,
      'logisticsLocalTransportCost': logisticsLocalTransportCost,
      'logisticsTotalCost': logisticsTotalCost,
      'arrivalDate': arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
      'processingDays': processingDays,
      'dryingDays': dryingDays,
      'laborCount': laborCount,
      'laborCost': laborCost,
      'suppliesCost': suppliesCost,
      'totalWeightBeforeDrying': totalWeightBeforeDrying,
      'wasteWeight': wasteWeight,
      'totalWeightToDryer': totalWeightToDryer,
      'totalWeightAfterDrying': totalWeightAfterDrying,
      'dryingPercentage': dryingPercentage,
      'batchDetails': batchDetails?.map((batch) => batch.toMap()).toList(),
      'imageUrls': imageUrls,
      'notes': notes,
    };
  }

  factory FarmToDryingModel.fromMap(Map<String, dynamic> data) {
    List<BatchDetail>? batchDetails;
    if (data['batchDetails'] != null) {
      batchDetails = (data['batchDetails'] as List).map((batch) => BatchDetail.fromMap(batch)).toList();
    }

    // Handle different date formats
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is Timestamp) return dateValue.toDate();
      if (dateValue is String) return DateTime.parse(dateValue);
      return DateTime.now();
    }

    return FarmToDryingModel(
      id: data['id'],
      productName: data['productName'] ?? '',
      purchaseDate: parseDate(data['purchaseDate']),
      productType: data['productType'],
      purchaseLocation: data['purchaseLocation'],
      supplierName: data['supplierName'],
      supplierPhone: data['supplierPhone'],
      dollarRate: data['dollarRate']?.toDouble(),
      sackPrice: data['sackPrice']?.toDouble(),
      agreedSackWeight: data['agreedSackWeight']?.toDouble(),
      actualSackWeight: data['actualSackWeight']?.toDouble(),
      sackCount: data['sackCount'] ?? data['quantity'] ?? 0, // Handle both field names
      productCost: data['productCost']?.toDouble() ??
          data['totalPurchaseCost']?.toDouble() ??
          data['totalCosts']?.toDouble() ??
          0.0,
      unloadingLoadingCost: data['unloadingLoadingCost']?.toDouble(),
      taxCost: data['taxCost']?.toDouble(),
      newSacksCost: data['newSacksCost']?.toDouble(),
      transportationCost: data['transportationCost']?.toDouble(),
      logisticsCost: data['logisticsCost']?.toDouble(),
      totalCosts: data['totalCosts']?.toDouble() ?? 0.0,
      logisticsTravelDate: data['logisticsTravelDate'] != null ? parseDate(data['logisticsTravelDate']) : null,
      logisticsTransportationCost: data['logisticsTransportationCost']?.toDouble(),
      logisticsAccommodationCost: data['logisticsAccommodationCost']?.toDouble(),
      logisticsMealsCost: data['logisticsMealsCost']?.toDouble(),
      logisticsLocalTransportCost: data['logisticsLocalTransportCost']?.toDouble(),
      logisticsTotalCost: data['logisticsTotalCost']?.toDouble(),
      arrivalDate: data['arrivalDate'] != null ? parseDate(data['arrivalDate']) : null,
      processingDays: data['processingDays'],
      dryingDays: data['dryingDays'],
      laborCount: data['laborCount'],
      laborCost: data['laborCost']?.toDouble(),
      suppliesCost: data['suppliesCost']?.toDouble(),
      totalWeightBeforeDrying: data['totalWeightBeforeDrying']?.toDouble() ?? data['wholeWeight']?.toDouble(),
      wasteWeight: data['wasteWeight']?.toDouble(),
      totalWeightToDryer: data['totalWeightToDryer']?.toDouble(),
      totalWeightAfterDrying: data['totalWeightAfterDrying']?.toDouble(),
      dryingPercentage: data['dryingPercentage']?.toDouble(),
      batchDetails: batchDetails,
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      notes: data['notes'],
    );
  }
}
