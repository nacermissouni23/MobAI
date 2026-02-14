class Product {
  final String id;
  final String sku;
  final String nomProduit;
  final String uniteMesure;
  final String? categorie;
  final bool actif;
  final int? colisageFardeau;
  final int? colisagePalette;
  final double? volumePcs;
  final double? poids;
  final bool isGerbable;
  final double demandFreq;
  final double receptionFreq;
  final double deliveryFreq;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.sku,
    required this.nomProduit,
    this.uniteMesure = 'pcs',
    this.categorie,
    this.actif = true,
    this.colisageFardeau,
    this.colisagePalette,
    this.volumePcs,
    this.poids,
    this.isGerbable = false,
    this.demandFreq = 0.0,
    this.receptionFreq = 0.0,
    this.deliveryFreq = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      sku: json['sku'] ?? '',
      nomProduit: json['nom_produit'] ?? '',
      uniteMesure: json['unite_mesure'] ?? 'pcs',
      categorie: json['categorie'],
      actif: json['actif'] ?? true,
      colisageFardeau: json['colisage_fardeau'],
      colisagePalette: json['colisage_palette'],
      volumePcs: (json['volume_pcs'] as num?)?.toDouble(),
      poids: (json['poids'] as num?)?.toDouble(),
      isGerbable: json['is_gerbable'] ?? false,
      demandFreq: (json['demand_freq'] as num?)?.toDouble() ?? 0.0,
      receptionFreq: (json['reception_freq'] as num?)?.toDouble() ?? 0.0,
      deliveryFreq: (json['delivery_freq'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'sku': sku,
    'nom_produit': nomProduit,
    'unite_mesure': uniteMesure,
    'categorie': categorie,
    'actif': actif,
    'colisage_fardeau': colisageFardeau,
    'colisage_palette': colisagePalette,
    'volume_pcs': volumePcs,
    'poids': poids,
    'is_gerbable': isGerbable,
    'demand_freq': demandFreq,
    'reception_freq': receptionFreq,
    'delivery_freq': deliveryFreq,
  };
}
