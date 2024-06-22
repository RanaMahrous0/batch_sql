import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/order_data.dart';
import 'package:batch_sql/models/order_item_data.dart';
import 'package:batch_sql/models/product_data.dart';
import 'package:batch_sql/widgets/add_elevated_button.dart';
import 'package:batch_sql/widgets/clients_drop_down_menu.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class SaleOpsPage extends StatefulWidget {
  final OrderData? order;

  const SaleOpsPage({this.order, super.key});

  @override
  State<SaleOpsPage> createState() => _SaleOpsPageState();
}

class _SaleOpsPageState extends State<SaleOpsPage> {
  String? orderLabel;
  int? selectedClientId;
  List<ProductData>? products;
  List<OrderItemData> selectedOrderItem = [];
  @override
  void initState() {
    initPage();
    super.initState();
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

  void initPage() {
    orderLabel = widget.order == null
        ? '#OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.id.toString();

    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order != null ? 'Update' : 'Add New',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Label : $orderLabel',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ClientsDropDownMenu(
                          selectedValue: selectedClientId,
                          onChanged: (clientId) {
                            setState(() {
                              selectedClientId = clientId;
                            });
                          }),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                onAddProduct();
                              },
                              icon: Icon(Icons.add)),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'Add Product',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onAddProduct() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateEx) {
              return Dialog(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: (products?.isEmpty ?? false)
                    ? Center(
                        child: Text('No Data Found'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Products',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var product in products!)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: ListTile(
                                      leading: Image.network(
                                          product.image ?? 'No Image'),
                                      title: Text(product.name ?? 'No Name'),
                                      subtitle: getOrderItem(product.id!) ==
                                              null
                                          ? null
                                          : Row(
                                              children: [
                                                IconButton(
                                                    onPressed: getOrderItem(
                                                                    product
                                                                        .id!) !=
                                                                null &&
                                                            getOrderItem(product
                                                                        .id!)
                                                                    ?.productCount ==
                                                                1
                                                        ? null
                                                        : () {
                                                            var orderItem =
                                                                getOrderItem(
                                                                    product
                                                                        .id!);
                                                            orderItem
                                                                    ?.productCount =
                                                                (orderItem.productCount ??
                                                                        0) -
                                                                    1;
                                                            setStateEx(
                                                              () {},
                                                            );
                                                          },
                                                    icon: Icon(Icons.remove)),
                                                Text(getOrderItem(product.id!)!
                                                    .productCount
                                                    .toString()),
                                                IconButton(
                                                    onPressed: () {
                                                      var orderItem =
                                                          getOrderItem(
                                                              product.id!);
                                                      if ((orderItem
                                                                  ?.productCount ??
                                                              0) <
                                                          (product.stock ??
                                                              0)) {
                                                        orderItem
                                                                ?.productCount =
                                                            (orderItem.productCount ??
                                                                    0) +
                                                                1;
                                                      }
                                                      setStateEx(
                                                        () {},
                                                      );
                                                    },
                                                    icon: Icon(Icons.add)),
                                              ],
                                            ),
                                      trailing:
                                          getOrderItem(product.id!) == null
                                              ? IconButton(
                                                  onPressed: () {
                                                    onAddItem(product);
                                                    setStateEx(() {});
                                                  },
                                                  icon: Icon(Icons.add))
                                              : IconButton(
                                                  onPressed: () {
                                                    onDeleteItem(product.id!);
                                                    setStateEx(
                                                      () {},
                                                    );
                                                  },
                                                  icon: Icon(Icons.delete)),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyAppElevatedButton(
                              label: 'Back',
                              onPressed: () {
                                Navigator.pop(context);
                              })
                        ],
                      ),
              ));
            },
          );
        });
    setState(() {});
  }

  OrderItemData? getOrderItem(int productId) {
    for (var item in selectedOrderItem) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  void onAddItem(ProductData product) {
    selectedOrderItem.add(OrderItemData(
        productId: product.id, productCount: 1, product: product));
  }

  void onDeleteItem(int productId) {
    for (var i = 0; i < (selectedOrderItem.length); i++) {
      if (selectedOrderItem[i].productId == productId) {
        selectedOrderItem.removeAt(i);
        break;
      }
    }
  }
}
