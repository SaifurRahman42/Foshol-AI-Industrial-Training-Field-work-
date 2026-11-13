import '../utils/bd_pricing.dart';

class Review {
  final int rating;
  final String comment;
  final String reviewerName;

  const Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final List<Review> reviews;
  final String? shippingInformation;
  final String? availabilityStatus;
  final String? returnPolicy;
  final String? warrantyInformation;

  /// True for items created inside the app (the demo API does not store them).
  final bool isLocal;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.brand,
    this.thumbnail = '',
    this.images = const [],
    this.tags = const [],
    this.reviews = const [],
    this.shippingInformation,
    this.availabilityStatus,
    this.returnPolicy,
    this.warrantyInformation,
    this.isLocal = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Untitled';
    final usd = (json['price'] as num?)?.toDouble() ?? 0;
    return Product(
      id: (json['id'] as num).toInt(),
      title: title,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      // API gives US dollars; show the Bangladeshi market price in taka.
      price: BdPricing.priceFor(title, usd),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String?,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingInformation: json['shippingInformation'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
      returnPolicy: json['returnPolicy'] as String?,
      warrantyInformation: json['warrantyInformation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'stock': stock,
        'brand': brand,
        'thumbnail': thumbnail.startsWith('data:image/') ? '' : thumbnail,
      };


  /// Serializes the complete product for local persistent storage.
  /// Prices are already stored in BDT in the app, so this format must not
  /// pass through fromJson(), which applies the API price conversion.
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'brand': brand,
        'thumbnail': thumbnail,
        'images': images,
        'tags': tags,
        'reviews': reviews
            .map((r) => {
                  'rating': r.rating,
                  'comment': r.comment,
                  'reviewerName': r.reviewerName,
                })
            .toList(),
        'shippingInformation': shippingInformation,
        'availabilityStatus': availabilityStatus,
        'returnPolicy': returnPolicy,
        'warrantyInformation': warrantyInformation,
        'isLocal': isLocal,
      };

  factory Product.fromCacheJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'groceries',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String?,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      tags: (json['tags'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      reviews: (json['reviews'] as List? ?? [])
          .map((e) => Review.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      shippingInformation: json['shippingInformation'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
      returnPolicy: json['returnPolicy'] as String?,
      warrantyInformation: json['warrantyInformation'] as String?,
      isLocal: json['isLocal'] as bool? ?? false,
    );
  }

  List<String> get gallery {
    if (images.isNotEmpty) return images;
    if (thumbnail.isNotEmpty) return [thumbnail];
    return const [];
  }

  /// Price in taka, e.g. "৳300".
  String get priceLabel => BdPricing.format(price);

  /// Unit shown next to the price, e.g. "kg" (empty for unknown items).
  String get unit => BdPricing.unitFor(title) ?? '';

  /// "৳300 / kg" when the unit is known, otherwise "৳300".
  String get priceWithUnit => unit.isEmpty ? priceLabel : '$priceLabel / $unit';

  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    int? stock,
    String? brand,
    String? thumbnail,
    List<String>? images,
    bool? isLocal,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      tags: tags,
      reviews: reviews,
      shippingInformation: shippingInformation,
      availabilityStatus: availabilityStatus,
      returnPolicy: returnPolicy,
      warrantyInformation: warrantyInformation,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
