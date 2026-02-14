import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String sku;
  final String name; // nom_produit
  final String unitOfMeasure; // unite_mesure
  final String? category; // categorie
  final bool isActive; // actif
  final int? unitsPerBundle; // colisage_fardeau
  final int? unitsPerPallet; // colisage_palette
  final double? volumePerUnit; // volume_pcs
  final double? weight; // poids
  final bool isStackable; // is_gerbable
  final double demandFrequency;
  final double receptionFrequency;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.unitOfMeasure = 'pcs',
    this.category,
    this.isActive = true,
    this.unitsPerBundle,
    this.unitsPerPallet,
    this.volumePerUnit,
    this.weight,
    this.isStackable = false,
    this.demandFrequency = 0.0,
    this.receptionFrequency = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, sku, name, isActive];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'nom_produit': name,
      'unite_mesure': unitOfMeasure,
      'categorie': category,
      'actif': isActive ? 1 : 0,
      'colisage_fardeau': unitsPerBundle,
      'colisage_palette': unitsPerPallet,
      'volume_pcs': volumePerUnit,
      'poids': weight,
      'is_gerbable': isStackable ? 1 : 0,
      'demand_frequency': demandFrequency,
      'reception_frequency': receptionFrequency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      sku: map['sku'] as String,
      name: map['nom_produit'] as String,
      unitOfMeasure: map['unite_mesure'] as String? ?? 'pcs',
      category: map['categorie'] as String?,
      isActive: (map['actif'] as int?) == 1,
      unitsPerBundle: map['colisage_fardeau'] as int?,
      unitsPerPallet: map['colisage_palette'] as int?,
      volumePerUnit: (map['volume_pcs'] as num?)?.toDouble(),
      weight: (map['poids'] as num?)?.toDouble(),
      isStackable: (map['is_gerbable'] as int?) == 1,
      demandFrequency: (map['demand_frequency'] as num?)?.toDouble() ?? 0.0,
      receptionFrequency: (map['reception_frequency'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      serverId: map['server_id'] as String?,
      syncPending: (map['sync_pending'] as int?) == 1,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'] as String)
          : null,
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId ?? id,
      'sku': sku,
      'nom_produit': name,
      'unite_mesure': unitOfMeasure,
      'categorie': category,
      'actif': isActive,
      'colisage_fardeau': unitsPerBundle,
      'colisage_palette': unitsPerPallet,
      'volume_pcs': volumePerUnit,
      'poids': weight,
      'is_gerbable': isStackable,
      'demand_frequency': demandFrequency,
      'reception_frequency': receptionFrequency,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json, {String? localId}) {
    return Product(
      id: localId ?? json['id'] as String,
      sku: json['sku'] as String,
      name: json['nom_produit'] as String,
      unitOfMeasure: json['unite_mesure'] as String? ?? 'pcs',
      category: json['categorie'] as String?,
      isActive: json['actif'] as bool? ?? true,
      unitsPerBundle: json['colisage_fardeau'] as int?,
      unitsPerPallet: json['colisage_palette'] as int?,
      volumePerUnit: (json['volume_pcs'] as num?)?.toDouble(),
      weight: (json['poids'] as num?)?.toDouble(),
      isStackable: json['is_gerbable'] as bool? ?? false,
      demandFrequency: (json['demand_frequency'] as num?)?.toDouble() ?? 0.0,
      receptionFrequency: (json['reception_frequency'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      serverId: json['id'] as String?,
      syncPending: false,
      lastSyncedAt: DateTime.now(),
      isDeleted: false,
    );
  }

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? unitOfMeasure,
    String? category,
    bool? isActive,
    int? unitsPerBundle,
    int? unitsPerPallet,
    double? volumePerUnit,
    double? weight,
    bool? isStackable,
    double? demandFrequency,
    double? receptionFrequency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      unitsPerBundle: unitsPerBundle ?? this.unitsPerBundle,
      unitsPerPallet: unitsPerPallet ?? this.unitsPerPallet,
      volumePerUnit: volumePerUnit ?? this.volumePerUnit,
      weight: weight ?? this.weight,
      isStackable: isStackable ?? this.isStackable,
      demandFrequency: demandFrequency ?? this.demandFrequency,
      receptionFrequency: receptionFrequency ?? this.receptionFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Convenience: stock status label for UI.
  String get stockStatusLabel {
    // This is computed from emplacement data, not product itself.
    return isActive ? 'Active' : 'Inactive';
  }
}
