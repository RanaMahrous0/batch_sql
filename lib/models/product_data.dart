class ProductData {
  int? id;
  String? name;
  String? description;
  double? price;
  int? stock;
  bool? isAvaliable;
  String? image;
  int? categoryId;
  String? categoryName;
  String? categoryDescription;
  String? label; // New field to indicate moreThan20 or lessThan20
  ProductData(
      {this.id,
      this.name,
      this.price,
      this.image,
      this.stock,
      this.categoryName,
      this.categoryDescription,
      this.label});

  ProductData.fromJson(Map<String, dynamic> data) {
    id = data['id'] as int?;
    name = data['name'] as String?;
    description = data['description'] as String?;
    price = data['price'] as double?;
    stock = data['stock'] as int?;
    isAvaliable = data['isAvaliable'] == 1 ? true : false;
    image = data['image'] as String?;
    categoryId = data['categoryId'] as int?;
    categoryName = data['categoryName'] as String?;
    categoryDescription = data['categoryDescription'] as String?;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'isAvaliable': isAvaliable,
      'image': image,
      'categoryId': categoryId
    };
  }
}
