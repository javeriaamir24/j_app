class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String detailedDescription;
  final String image;
  final bool popular;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.detailedDescription,
    required this.image,
    required this.popular,
  });

  factory Product.fromMap(
      String id,
      Map<dynamic, dynamic> data,
      ) {
    return Product(
      id: id,
      name: data['name']?.toString() ?? '',
      price: double.tryParse(
        data['price']?.toString() ?? '0',
      ) ??
          0,
      category: data['category']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      detailedDescription:
      data['detailedDescription']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      popular: data['popular'] == true,
    );
  }
}