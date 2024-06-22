import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/pages/catgories.dart';
import 'package:batch_sql/pages/clients.dart';

import 'package:batch_sql/pages/products.dart';
import 'package:batch_sql/pages/sale_ops.dart';
import 'package:batch_sql/widgets/my_gird_view_items.dart';
import 'package:batch_sql/widgets/my_header_items_home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isTableCreated = false;

  @override
  void initState() {
    createTables();
    super.initState();
  }

  void createTables() async {
    var sqlhelper = GetIt.I.get<SqlHelper>();
    isTableCreated = await sqlhelper.createTable();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(),
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height / 3 +
                      (kIsWeb ? 30 : 0),
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Nilu app',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 25,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: isLoading
                                  ? Transform.scale(
                                      scale: .4,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: isTableCreated
                                          ? Colors.green
                                          : Colors.red,
                                      radius: 8,
                                    ),
                            ),
                          ],
                        ),
                        const MyHeaderItem(
                            label: 'Exchange rate',
                            value: '1 EUR = 11,712.25 UZS'),
                        const MyHeaderItem(
                            label: 'Today \'s sales', value: '110,000.00 UZS')
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: const Color(0xfffbfafb),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    MyGirdViewItems(
                      icon: Icons.calculate,
                      color: Colors.orange,
                      label: 'All sales',
                      onTap: () {},
                    ),
                    MyGirdViewItems(
                      icon: Icons.inventory,
                      color: Colors.pink,
                      label: 'Products',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyProductPage(),
                          ),
                        );
                      },
                    ),
                    MyGirdViewItems(
                      icon: Icons.group,
                      color: Colors.blue,
                      label: 'Clients',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyClientsPage(),
                          ),
                        );
                      },
                    ),
                    MyGirdViewItems(
                      icon: Icons.point_of_sale,
                      color: Colors.green,
                      label: 'New sale',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SaleOpsPage(),
                          ),
                        );
                      },
                    ),
                    MyGirdViewItems(
                      icon: Icons.category,
                      color: Colors.yellow,
                      label: 'Categories',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyCatgoryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
