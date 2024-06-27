import 'package:batch_sql/models/product_data.dart';

class OrderItemData {
  int? orderId;
  int? productId;
  int? productCount;
  ProductData? product;

  OrderItemData(
      {this.orderId, this.productId, this.productCount, this.product})  ;

  int get orId => orderId!;
  int get proId => orderId!;
  int get count => productCount!;
  ProductData get pro => product!;

  OrderItemData.fromJson(Map<String, dynamic> data) {
    orderId = data['orderId'];
    productId = data['productId'];
    productCount = data['productCount'];
    product = ProductData.fromJson(data);
  }
}
