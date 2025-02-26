class ItemModel {
  final int originalIndex;
  final String itemName;
  final String quantity;
  final String minStockAlert;
  final String mrp;
  final double salePrice;
  final String unit;
  final String hsn;
  final String rate1;
  final String rate2;
  final int flag;

  ItemModel({
    required this.originalIndex,
    required this.itemName,
    required this.quantity,
    required this.minStockAlert,
    required this.mrp,
    required this.salePrice,
    required this.unit,
    required this.hsn,
    required this.rate1,
    required this.rate2,
    required this.flag,
  });

  ItemModel copy({
    int? originalIndex,
    String? itemName,
    String? quantity,
    String? minStockAlert,
    String? mrp,
    double? salePrice,
    String? unit,
    String? hsn,
    String? rate1,
    String? rate2,
    int? flag,
  }) =>
      ItemModel(
        originalIndex: originalIndex ?? this.originalIndex,
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        minStockAlert: minStockAlert ?? this.minStockAlert,
        mrp: mrp ?? this.mrp,
        salePrice: salePrice ?? this.salePrice,
        unit: unit ?? this.unit,
        hsn: hsn ?? this.hsn,
        rate1: rate1 ?? this.rate1,
        rate2: rate2 ?? this.rate2,
        flag: flag ?? this.flag,
      );

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      originalIndex: json['original_index'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      minStockAlert: json['min_stock_alert'],
      mrp: json['mrp'],
      salePrice: json['sale_price'].toDouble(),
      unit: json['unit'],
      hsn: json['hsn'],
      rate1: json['rate1'],
      rate2: json['rate2'],
      flag: json['flag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_index': originalIndex,
      'item_name': itemName,
      'quantity': quantity,
      'min_stock_alert': minStockAlert,
      'mrp': mrp,
      'sale_price': salePrice,
      'unit': unit,
      'hsn': hsn,
      'rate1': rate1,
      'rate2': rate2,
      'flag': flag,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          runtimeType == other.runtimeType &&
          originalIndex == other.originalIndex &&
          itemName == other.itemName &&
          quantity == other.quantity &&
          minStockAlert == other.minStockAlert &&
          mrp == other.mrp &&
          salePrice == other.salePrice &&
          unit == other.unit &&
          hsn == other.hsn &&
          rate1 == other.rate1 &&
          rate2 == other.rate2 &&
          flag == other.flag;

  @override
  int get hashCode =>
      originalIndex.hashCode ^
      itemName.hashCode ^
      quantity.hashCode ^
      minStockAlert.hashCode ^
      mrp.hashCode ^
      salePrice.hashCode ^
      unit.hashCode ^
      hsn.hashCode ^
      rate1.hashCode ^
      rate2.hashCode ^
      flag.hashCode;
}
