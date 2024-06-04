import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/clients_data.dart';
import 'package:batch_sql/pages/client_ops.dart';
import 'package:batch_sql/widgets/my_paginated_data_table.dart';
import 'package:batch_sql/widgets/my_search_text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyClientsPage extends StatefulWidget {
  const MyClientsPage({super.key});

  @override
  State<MyClientsPage> createState() => _MyClientsPageState();
}

class _MyClientsPageState extends State<MyClientsPage> {
  List<ClientsData>? clients;
  @override
  void initState() {
    getClients();
    super.initState();
  }

  void getClients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');

      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(ClientsData.fromJson(item));
        }
      } else {
        clients = [];
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
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Clients'),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientOpsPage(),
                  ),
                );
                if (result ?? false) {
                  getClients();
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const MySearchTextField(tableName: 'clients'),
            const SizedBox(
              height: 15,
            ),
            MyPaginatedDataTable(
                source: MyDataTableSource(clients, getClients),
                columns: const [
                  DataColumn(
                    label: Text('ID'),
                  ),
                  DataColumn(
                    label: Text('Name'),
                  ),
                  DataColumn(
                    label: Text('Email'),
                  ),
                  DataColumn(
                    label: Text('Phone'),
                  ),
                  DataColumn(
                    label: Text('Address'),
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
  List<ClientsData>? clientsEx;

  void Function() getClients;

  MyDataTableSource(this.clientsEx, this.getClients);

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${clientsEx?[index].id}')),
      DataCell(Text('${clientsEx?[index].name}')),
      DataCell(Text('${clientsEx?[index].email}')),
      DataCell(Text('${clientsEx?[index].phone}')),
      DataCell(Text('${clientsEx?[index].address}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
          IconButton(
              onPressed: () async {
                await onDeleteRow(clientsEx?[index].id ?? 0);
              },
              icon: const Icon(Icons.delete))
        ],
      ))
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clientsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
  Future<void> onDeleteRow(int id) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var result = await sqlHelper.db!.delete(
        'clients',
        where: 'id =?',
        whereArgs: [id],
      );
      if (result > 0) {
        getClients();
      }
    } catch (e) {
      print('Error In Deleting Item');
    }
  }
}


