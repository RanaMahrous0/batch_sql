import 'package:batch_sql/models/order_data.dart';
import 'package:batch_sql/widgets/clients_drop_down_menu.dart';

import 'package:flutter/material.dart';

class SaleOpsPage extends StatefulWidget {
  final OrderData? order;
  const SaleOpsPage({this.order, super.key});

  @override
  State<SaleOpsPage> createState() => _SaleOpsPageState();
}

class _SaleOpsPageState extends State<SaleOpsPage> {
  String? orderLabel;
  int? selectedClientId;
  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    orderLabel = widget.order == null
        ? '#OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.id.toString();
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Label : $orderLabel'),
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
                          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
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
}
