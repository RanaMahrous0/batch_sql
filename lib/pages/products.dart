import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/product_data.dart';
import 'package:batch_sql/pages/product_ops.dart';
import 'package:batch_sql/widgets/my_paginated_data_table.dart';
import 'package:batch_sql/widgets/my_search_text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyProductPage extends StatefulWidget {
  const MyProductPage({super.key});

  @override
  State<MyProductPage> createState() => _MyProductPageState();
}

class _MyProductPageState extends State<MyProductPage> {
  List<ProductData>? products;
  bool sortAscending = true;
  int sortColumnIndex = 0;
  @override
  void initState() {
    getProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductOpsPage(),
                ),
              );
              if (result ?? false) {
                getProducts();
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const MySearchTextField(tableName: 'products'),
            const SizedBox(
              height: 15,
            ),
            MyPaginatedDataTable(
                sortAscending: sortAscending,
                sortColumnIndex: sortColumnIndex,
                minWidth: 1300,
                source: ProductsDataSource(
                    productsEx: products,
                    onDelete: (productData) {
                      onDeleteRow(productData.id!);
                    },
                    onUpdate: (productData) async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductOpsPage(
                                    productData: productData,
                                  )));
                      if (result ?? false) {
                        getProducts();
                      }
                    }),
                columns: [
                  DataColumn(
                    onSort: (columnIndex, ascending) {},
                    label: const Text('ID'),
                  ),
                  const DataColumn(
                    label: Text('Name'),
                  ),
                  const DataColumn(
                    label: Text('Description'),
                  ),
                  DataColumn(
                    numeric: true,
                    label: const Text('Price'),
                    onSort: (columnIndex, ascending) {
                      sortColumnIndex = columnIndex;
                      sortAscending = ascending;
                      if (sortAscending == false) {
                        products!.sort(
                          (a, b) => a.price!.compareTo(b.price!),
                        );
                      } else {
                        products!.sort(
                          (a, b) => b.price!.compareTo(a.price!),
                        );
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    numeric: true,
                    label: const Text('Stock'),
                    onSort: (columnIndex, ascending) {
                      sortColumnIndex = columnIndex;
                      sortAscending = ascending;
                      if (sortAscending == false) {
                        products!.sort(
                          (a, b) => a.stock!.compareTo(b.stock!),
                        );
                      } else {
                        products!.sort(
                          (a, b) => b.stock!.compareTo(a.stock!),
                        );
                      }
                      setState(() {});
                    },
                  ),
                  const DataColumn(
                    label: Text('IsAvaliable'),
                  ),
                  const DataColumn(
                    label: Text('Image'),
                  ),
                  const DataColumn(
                    label: Text('CategoryId'),
                  ),
                  const DataColumn(
                    label: Text('CategoryName'),
                  ),
                  const DataColumn(
                    label: Text('CategoryDescription'),
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
          'products',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getProducts();
        }
      }
    } catch (e) {
      print('Error In Deleting Item');
    }
  }
}

class ProductsDataSource extends DataTableSource {
  List<ProductData>? productsEx;
  void Function(ProductData) onDelete;
  void Function(ProductData) onUpdate;

  ProductsDataSource(
      {required this.productsEx,
      required this.onDelete,
      required this.onUpdate});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${productsEx?[index].id}')),
      DataCell(Text('${productsEx?[index].name}')),
      DataCell(Text('${productsEx?[index].description}')),
      DataCell(Text('${productsEx?[index].price}')),
      DataCell(Text('${productsEx?[index].stock}')),
      DataCell(Text('${productsEx?[index].isAvaliable}')),
      DataCell(Center(
        child: Image.network(
          '${productsEx?[index].image}',
          fit: BoxFit.contain,
        ),
      )),
      DataCell(Text('${productsEx?[index].categoryId}')),
      DataCell(Text('${productsEx?[index].categoryName}')),
      DataCell(Text('${productsEx?[index].categoryDescription}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate(productsEx![index]);
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.blue,
            ),
          ),
          IconButton(
            onPressed: () {
              onDelete(productsEx![index]);
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
  int get rowCount => productsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
