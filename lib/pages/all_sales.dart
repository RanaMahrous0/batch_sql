import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/order_data.dart';
import 'package:batch_sql/models/order_item_data.dart';
import 'package:batch_sql/models/product_data.dart';
import 'package:batch_sql/widgets/my_paginated_data_table.dart';
import 'package:batch_sql/widgets/my_search_text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllSalesPage extends StatefulWidget {
  final List<OrderItemData>? orderItemsData;
  const AllSalesPage({this.orderItemsData, super.key});

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  List<OrderData>? orders;
  List<OrderItemData>? orderItems;
  bool sortAscending = true;
  int sortColumnIndex = 0;
  List<ProductData>? products;
  List<OrderItemData> selectedOrderItem = [];

  @override
  void initState() {
    getOrders();
    getOrderProductItem();

    super.initState();
  }

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select O.* ,C.name as clientName,C.phone as clientPhone, C.address as clientAddress
      from orders O
      inner join clients C
      where O.clientId = C.id
      """);

      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders!.add(OrderData.fromJson(item));
        }
        print(orders);
      } else {
        orders = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Get Data $e '),
        ),
      );
    }
    setState(() {});
  }

  void getOrderProductItem() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select O.* ,P.name as productName,P.price as productPrice, P.image as productImage
      from orderProductItems O
      inner join products P
      where O.productId = P.id
      """);

      if (data.isNotEmpty) {
        orderItems = [];
        for (var item in data) {
          var productData = ProductData(
            id: item['productId'] as int?,
            name: item['productName'] as String?,
            price: item['productPrice'] as double?,
            image: item['productImage'] as String,
          );

          // Creating the order item with the product data
          var orderItemData =
              OrderItemData.fromJson(item as Map<String, dynamic>);
          orderItemData.product = productData;

          orderItems!.add(orderItemData);
        }
      } else {
        orderItems = [];
      }
      var printD = await sqlHelper.db!.query('orderProductItems');
      print(printD);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Get Data $e '),
        ),
      );
    }
    setState(() {});
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select P.* ,C.name as categoryName,C.description as categoryDescription 
      from products P
      inner join categories C
      where P.categoryId = C.id
      """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(ProductData.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Get Data $e '),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Sales',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MySearchTextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                var result = await sqlHelper.db!.rawQuery("""
        SELECT * FROM orders
        WHERE label LIKE '%$value%';
          """);
                print('values:$result');
              },
            ),
            const SizedBox(
              height: 15,
            ),
            MyPaginatedDataTable(
                sortAscending: sortAscending,
                sortColumnIndex: sortColumnIndex,
                minWidth: 1300,
                source: OrderDataSource(
                    orderEx: orders,
                    onDelete: (orderData) async {
                      await onDeleteRow(orderData.id!);
                    },
                    onShow: (orderData) async {
                      await onShow(orderData);
                    }),
                columns: [
                  DataColumn(
                    onSort: (columnIndex, ascending) {},
                    label: const Text('ID'),
                  ),
                  const DataColumn(
                    label: Text('label'),
                  ),
                  DataColumn(
                    label: const Text('Total Price'),
                    onSort: (columnIndex, ascending) {
                      sortColumnIndex = columnIndex;
                      sortAscending = ascending;
                      if (sortAscending == false) {
                        orders!.sort(
                          (a, b) => a.totalPrice!.compareTo(b.totalPrice!),
                        );
                      } else {
                        orders!.sort(
                          (a, b) => b.totalPrice!.compareTo(a.totalPrice!),
                        );
                      }
                      setState(() {});
                    },
                  ),
                  const DataColumn(
                    numeric: true,
                    label: Text('Discount'),
                  ),
                  const DataColumn(
                    label: Text('ClientName'),
                  ),
                  const DataColumn(
                    label: Text('ClientPhone'),
                  ),
                  const DataColumn(
                    label: Text('ClientAddress'),
                  ),
                  const DataColumn(
                    label: Center(
                      child: Text('Actions'),
                    ),
                  )
                ])
          ],
        ),
      ),
    );
  }

  Future<void> onShow(OrderData order) async {
    getOrderProductItem();

    List<OrderItemData> orderProducts =
        orderItems!.where((item) => item.orderId == order.id).toList();

    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: orderProducts.length,
                    itemBuilder: (context, index) {
                      var product = orderProducts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: product.product?.image != null
                              ? Image.network(product.product!.image!)
                              : const Icon(Icons.image_not_supported),
                          title: Text(
                            '${product.product?.name ?? 'No Name'}, ${product.productCount}X',
                          ),
                          trailing: Text(
                            '${(product.productCount ?? 0) * (product.product?.price ?? 0)}',
                          ),
                        ),
                      );
                    },
                  )),
                ],
              ),
            ),
          );
        });
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Product'),
              content:
                  const Text('Are you sure you want to delete this product?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });
      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'orders',
          where: 'id =?',
          whereArgs: [id],
        );

        if (result > 0) {
          getOrders();
          // getOrderProductItem();
        }
      }
    } catch (e) {
      print('Error In Deleting Item');
    }
  }
}

class OrderDataSource extends DataTableSource {
  List<OrderData>? orderEx;
  void Function(OrderData) onDelete;
  void Function(OrderData) onShow;

  OrderDataSource(
      {required this.orderEx, required this.onDelete, required this.onShow});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${orderEx?[index].id}')),
      DataCell(Text('${orderEx?[index].label}')),
      DataCell(Text('${orderEx?[index].totalPrice}')),
      DataCell(Text('${orderEx?[index].discount}')),
      DataCell(Text('${orderEx?[index].clientName}')),
      DataCell(Text('${orderEx?[index].clientPhone}')),
      DataCell(Text('${orderEx?[index].clientAddress}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onShow(orderEx![index]);
            },
            icon: const Icon(
              Icons.visibility,
              color: Colors.blue,
            ),
          ),
          IconButton(
            onPressed: () {
              onDelete(orderEx![index]);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      ))
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => orderEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
