import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/clients_data.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientsDropDownMenu extends StatefulWidget {
  final void Function(int?)? onChanged;
  final int? selectedValue;
  const ClientsDropDownMenu(
      {this.selectedValue, required this.onChanged, super.key});

  @override
  State<ClientsDropDownMenu> createState() => _ClientsDropDownMenuState();
}

class _ClientsDropDownMenuState extends State<ClientsDropDownMenu> {
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
    return clients == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : (clients?.isEmpty ?? false)
            ? const Center(
                child: Text('No Data Found'),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: DropdownButton(
                    value: widget.selectedValue,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text(
                      'Select Client',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    items: [
                      for (var client in clients!)
                        DropdownMenuItem(
                          alignment: AlignmentDirectional.centerStart,
                          value: client.id,
                          child: Text(client.name ?? 'No Name'),
                        ),
                    ],
                    onChanged: widget.onChanged),
              );
  }
}
