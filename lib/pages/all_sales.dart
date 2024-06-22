import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/order_data.dart';
import 'package:batch_sql/models/order_item_data.dart';
import 'package:batch_sql/widgets/my_paginated_data_table.dart';
import 'package:batch_sql/widgets/my_search_text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllSalesPage extends StatefulWidget {
  const AllSalesPage({super.key});

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  List<OrderData>? orders;
  List<OrderItemData>? orderItems;
  bool sortAscending = true;
  int sortColumnIndex = 0;
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
          orderItems!.add(OrderItemData.fromJson(item));
        }
      } else {
        orderItems = [];
      }
      print(orderItems);
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
                tableName: 'orders'),
            const SizedBox(
              height: 15,
            ),
            MyPaginatedDataTable(
                sortAscending: sortAscending,
                sortColumnIndex: sortColumnIndex,
                minWidth: 1300,
                source: OrderDataSource(
                    orderEx: orders,
                    onDelete: (orderData) {},
                    onShow: (orderData) {
                      onShow();
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

  Future<void> onShow() {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog();
        });
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
