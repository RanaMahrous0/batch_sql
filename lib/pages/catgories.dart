import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/category_data.dart';
import 'package:batch_sql/pages/category_ops.dart';
import 'package:batch_sql/widgets/my_paginated_data_table.dart';
import 'package:batch_sql/widgets/my_search_text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyCatgoryPage extends StatefulWidget {
  const MyCatgoryPage({super.key});

  @override
  State<MyCatgoryPage> createState() => _MyCatgoryPageState();
}

class _MyCatgoryPageState extends State<MyCatgoryPage> {
  List<CategoryData>? categories;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  void getCategories() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('categories');

      if (data.isNotEmpty) {
        categories = [];
        for (var item in data) {
          categories!.add(CategoryData.fromJson(item));
        }
      } else {
        categories = [];
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
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryOpsPage(),
                ),
              );
              if (result ?? false) {
                getCategories();
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
             MySearchTextField(onChanged:  (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                var result = await sqlHelper.db!.rawQuery("""
        SELECT * FROM categories
        WHERE name LIKE '%$value%' OR description LIKE '%$value%';
          """);
                print('values:$result');
              }, tableName: 'categories'),
            const SizedBox(
              height: 15,
            ),
            MyPaginatedDataTable(
                sortAscending: sortAscending,
                sortColumnIndex: sortColumnIndex,
                source: CategoriesDataSource(
                    categoriesEx: categories,
                    onDelete: (categoryData) {
                      onDeleteRow(categoryData.id!);
                    },
                    onUpdate: (categoryData) async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategoryOpsPage(
                                    categoryData: categoryData,
                                  )));
                      if (result ?? false) {
                        getCategories();
                      }
                    }),
                columns: [
                  const DataColumn(
                    label: Text('ID'),
                  ),
                  DataColumn(
                    onSort: (columnIndex, ascending) {
                      sortColumnIndex = columnIndex;
                      sortAscending = ascending;
                      if (sortAscending == false) {
                        categories!.sort(
                          (a, b) => a.name!.compareTo(b.name!),
                        );
                      } else {
                        categories!.sort(
                          (a, b) => b.name!.compareTo(a.name!),
                        );
                      }
                      setState(() {});
                    },
                    label: const Text('Name'),
                  ),
                  const DataColumn(
                    label: Text('Description'),
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
              title: const Text('Delete Category'),
              content:
                  const Text('Are you sure you want to delete this category?'),
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
          'categories',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getCategories();
        }
      }
    } catch (e) {
      print('Error In Deleting Item');
    }
  }
}

class CategoriesDataSource extends DataTableSource {
  List<CategoryData>? categoriesEx;
  void Function(CategoryData) onDelete;
  void Function(CategoryData) onUpdate;

  CategoriesDataSource(
      {required this.categoriesEx,
      required this.onDelete,
      required this.onUpdate});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${categoriesEx?[index].id}')),
      DataCell(Text('${categoriesEx?[index].name}')),
      DataCell(Text('${categoriesEx?[index].description}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate(categoriesEx![index]);
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.blue,
            ),
          ),
          IconButton(
            onPressed: () {
              onDelete(categoriesEx![index]);
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
  int get rowCount => categoriesEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
