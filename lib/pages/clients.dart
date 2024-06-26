import 'package:batch_sql/helpers/sqlHelper.dart';

import 'package:batch_sql/models/clients_data.dart';
import 'package:batch_sql/pages/client_ops.dart';
import 'package:batch_sql/widgets/my_paginated_data_table.dart';
import 'package:batch_sql/widgets/my_search_text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyClientsPage extends StatefulWidget {
  const MyClientsPage({super.key});

  @override
  State<MyClientsPage> createState() => _MyClientsPageState();
}

class _MyClientsPageState extends State<MyClientsPage> {
  List<ClientsData>? clients;
  List<ClientsData>? filteredList = [];
  bool sortAscending = true;
  int sortColumnIndex = 0;
  var searchController = TextEditingController();
  List<ClientsData>? selectedListData = [];
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
          filteredList = clients;
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

  void openFilterDialog() async {
    await FilterListDialog.display<ClientsData>(
      context,
      listData: clients!,
      selectedListData: selectedListData,
      choiceChipLabel: (user) => user!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (client, query) {
        return client.name!.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedListData = List.from(list!);
          filteredList = [];
        });
        Navigator.pop(context);
      },
    );
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
            Row(
              children: [
                Expanded(
                  child: MySearchTextField(
                    onChanged: (value) {
                      setState(() {
                        onSearch(value);
                      });
                    },
                    controller: searchController,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      openFilterDialog();
                    },
                    icon: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).primaryColor,
                    ))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            MyPaginatedDataTable(
                sortAscending: sortAscending,
                sortColumnIndex: sortColumnIndex,
                minWidth: 800,
                source: ClientsDataSource(
                    clientsEx: selectedListData!.isEmpty
                        ? filteredList
                        : selectedListData! + filteredList!,
                    onDelete: (clientData) {
                      onDeleteRow(clientData.id!);
                    },
                    onUpdate: (clientData) async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientOpsPage(
                                    clientsData: clientData,
                                  )));
                      if (result ?? false) {
                        getClients();
                      }
                    }),
                columns: [
                  const DataColumn(
                    label: Text('ID'),
                  ),
                  DataColumn(
                    label: const Text('Name'),
                    onSort: (columnIndex, ascending) {
                      sortAscending = ascending;
                      sortColumnIndex = columnIndex;

                      if (sortAscending == false) {
                        clients!.sort(
                          (a, b) => a.name!.compareTo(b.name!),
                        );
                      } else {
                        clients!.sort(
                          (a, b) => b.name!.compareTo(a.name!),
                        );
                      }

                      setState(() {});
                    },
                  ),
                  const DataColumn(
                    label: Text('Email'),
                  ),
                  const DataColumn(
                    label: Text('Phone'),
                  ),
                  const DataColumn(
                    label: Text('Address'),
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
              title: const Text('Delete Client'),
              content:
                  const Text('Are you sure you want to delete this client?'),
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
          'clients',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getClients();
        }
      }
    } catch (e) {
      print('Error In Deleting Item');
    }
  }

  void onSearch(value) {
    if (value.isEmpty) {
      filteredList = clients;
    } else {
      filteredList = [];
      for (var client in clients!) {
        if (client.name!.toLowerCase().contains(value.toLowerCase())) {
          filteredList!.add(client);
          selectedListData = [];
        }
      }
    }
  }
}

class ClientsDataSource extends DataTableSource {
  List<ClientsData>? clientsEx;

  void Function(ClientsData) onDelete;
  void Function(ClientsData) onUpdate;

  ClientsDataSource(
      {required this.clientsEx,
      required this.onDelete,
      required this.onUpdate});

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
            onPressed: () {
              onUpdate(clientsEx![index]);
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.blue,
            ),
          ),
          IconButton(
              onPressed: () {
                onDelete(clientsEx![index]);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ))
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
}
