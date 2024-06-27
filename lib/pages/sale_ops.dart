import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/order_data.dart';
import 'package:batch_sql/models/order_item_data.dart';
import 'package:batch_sql/models/product_data.dart';
import 'package:batch_sql/pages/all_sales.dart';
import 'package:batch_sql/widgets/add_elevated_button.dart';
import 'package:batch_sql/widgets/clients_drop_down_menu.dart';
import 'package:batch_sql/widgets/my_search_text_field.dart';

import 'package:flutter/material.dart';

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
  TextEditingController? controller;
  var discountController = TextEditingController();
  List<ProductData>? filteredList = [];

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
          filteredList = products;
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
                              icon: const Icon(Icons.add)),
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
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      for (var orderItem in selectedOrderItem)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading:
                                Image.network(orderItem.product?.image ?? ''),
                            title: Text(
                                '${(orderItem.product?.name ?? 'No Name')},${orderItem.productCount}X'),
                            trailing: Text(
                                '${(orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0)}'),
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            'Discount:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: discountController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  discountController.text = '';
                                } else {
                                  calculateTotalPrice;
                                }
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Total Price : $calculateTotalPrice',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyAppElevatedButton(
                  label: 'Add Order',
                  onPressed: () async {
                    await onAddOrder();
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => AllSalesPage(
                    //             orderItemsData: selectedOrderItem)));
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onAddOrder() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();

      var orderId = await sqlHelper.db!.insert('orders', {
        'label': orderLabel,
        'totalPrice': calculateTotalPrice,
        'discount': double.parse(discountController.text),
        'clientId': selectedClientId
      });
      var batch = sqlHelper.db!.batch();
      for (var orderItem in selectedOrderItem) {
        batch.insert('orderProductItems', {
          'orderId': orderId,
          'productId': orderItem.productId,
          'productCount': orderItem.productCount,
        });
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Data Saved Successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Saving Data '),
        ),
      );
    }
  }

  double get calculateTotalPrice {
    double total = 0;

    setState(() {
      for (var orderItem in selectedOrderItem) {
        total +=
            ((orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0));
      }
      double discount = double.tryParse(discountController.text) ?? 0;
      total = total - discount;
    });

    return total;
  }

  void onAddProduct() async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateEx) {
              return Dialog(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: (products?.isEmpty ?? false)
                    ? const Center(
                        child: Text('No Data Found'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Products',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MySearchTextField(
                            onChanged: (value) {
                              setStateEx(() {
                                onSearch(value);
                              });
                            },
                            controller: controller,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var product in filteredList!)
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
                                                    icon: const Icon(
                                                        Icons.remove)),
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
                                                    icon:
                                                        const Icon(Icons.add)),
                                              ],
                                            ),
                                      trailing: getOrderItem(product.id!) ==
                                              null
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
                                              icon: const Icon(Icons.delete)),
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

  void onSearch(value) {
    if (value.isEmpty) {
      filteredList = products;
    } else {
      filteredList = [];
      for (var product in products!) {
        if (product.name!.toLowerCase().contains(value.toLowerCase()) ||
            product.price
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase())) {
          filteredList!.add(product);
        }
      }
    }
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
