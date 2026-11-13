/// Bangladeshi market prices (BDT, approximate retail) for the items that the
/// DummyJSON "groceries" category returns. DummyJSON prices are in US dollars,
/// so each product is mapped to a realistic local price and unit instead.
class BdPricing {
  static const String symbol = '৳';

  // title (lower case) -> [price in BDT, unit]
  static const Map<String, List<Object>> _market = {
    'apple': [300, 'kg'],
    'beef steak': [800, 'kg'],
    'cat food': [900, 'pack'],
    'chicken meat': [230, 'kg'],
    'cooking oil': [190, 'litre'],
    'cucumber': [60, 'kg'],
    'dog food': [1200, 'pack'],
    'eggs': [140, 'dozen'],
    'fish steak': [450, 'kg'],
    'green bell pepper': [180, 'kg'],
    'green chili pepper': [120, 'kg'],
    'honey jar': [600, '500g'],
    'ice cream': [250, 'tub'],
    'juice': [120, 'litre'],
    'kiwi': [500, 'kg'],
    'lemon': [50, '4 pcs'],
    'milk': [100, 'litre'],
    'mulberry': [400, 'kg'],
    'nescafe coffee': [650, 'jar'],
    'potatoes': [50, 'kg'],
    'protein powder': [4500, 'tub'],
    'red onions': [90, 'kg'],
    'rice': [75, 'kg'],
    'soft drinks': [95, '1.5 litre'],
    'strawberry': [700, 'kg'],
    'tissue paper box': [120, 'box'],
    'water': [25, 'litre'],
  };

  /// USD -> BDT rate used only for products that are not in the table above.
  static const double usdToBdt = 120;

  /// Price in taka for a product coming from the API.
  static double priceFor(String title, double usdPrice) {
    final entry = _market[title.trim().toLowerCase()];
    if (entry != null) return (entry[0] as int).toDouble();
    return ((usdPrice * usdToBdt) / 5).round() * 5.0;
  }

  /// Unit (kg, litre, dozen...) or null when unknown.
  static String? unitFor(String title) =>
      _market[title.trim().toLowerCase()]?[1] as String?;

  /// "৳300" - whole taka, no decimals unless needed.
  static String format(double price) {
    final text = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return '$symbol$text';
  }
}
