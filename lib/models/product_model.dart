class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String detailedDescription;
  final String image;
  final bool popular;
  final bool showInSlider;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.detailedDescription,
    required this.image,
    required this.popular,
    this.showInSlider = false,
  });

  factory Product.fromMap(
      String id,
      Map<dynamic, dynamic> data,
      ) {
    return Product(
      id: id,
      name: data['name']?.toString() ?? '',
      price: double.tryParse(data['price']?.toString() ?? '0',) ?? 0,
      category: data['category']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      detailedDescription:
      data['detailedDescription']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      popular: data['popular'] == true,
      showInSlider: data['showInSlider'] == true,
    );
  }

  Map<String, dynamic> toCoffeeMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'detailedDescription': detailedDescription,
      'price': price,
      'image': image,
      'category': category,
    };
  }
}