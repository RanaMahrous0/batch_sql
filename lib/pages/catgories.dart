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
            const MySearchTextField(tableName: 'categories'),
            const SizedBox(
              height: 15,
            ),
            MyPaginatedDataTable(
                source: MyDataTableSource(categories, getCategories),
                columns: const [
                  DataColumn(
                    label: Text('ID'),
                  ),
                  DataColumn(
                    label: Text('Name'),
                  ),
                  DataColumn(
                    label: Text('Description'),
                  ),
                  DataColumn(
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
}

class MyDataTableSource extends DataTableSource {
  List<CategoryData>? categoriesEx;

  void Function() getCategories;

  MyDataTableSource(this.categoriesEx, this.getCategories);

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
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
          IconButton(
              onPressed: () async {
                await onDeleteRow(categoriesEx?[index].id ?? 0);
              },
              icon: const Icon(Icons.delete))
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

  Future<void> onDeleteRow(int id) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var result = await sqlHelper.db!.delete(
        'categories',
        where: 'id =?',
        whereArgs: [id],
      );
      if (result > 0) {
        getCategories();
      }
    } catch (e) {
      print('Error In Deleting Item');
    }
  }
}
