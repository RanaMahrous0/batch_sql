import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/exchange_rate.dart';
import 'package:batch_sql/models/order_data.dart';
import 'package:batch_sql/pages/all_sales.dart';
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
  List<ExchangeRate>? exchangeRate;
  List<OrderData>? orders;
  double total = 0;

  @override
  void initState() {
    createTables();
    getExhangeRate();
    getOrders();

    // initPage();
    super.initState();
  }

  // void initPage() async {
  //   calculateTotalPrice;

  //   await getExhangeRate();
  // }

  void createTables() async {
    var sqlhelper = GetIt.I.get<SqlHelper>();
    isTableCreated = await sqlhelper.createTable();
    isLoading = false;

    setState(() {});
  }

  void getExhangeRate() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('exchangeRate');

      if (data.isNotEmpty) {
        exchangeRate = [];
        for (var item in data) {
          exchangeRate!.add(ExchangeRate.fromJson(item));
        }
      } else {
        exchangeRate = [];
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

  Future<void> getOrders() async {
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
        total = 0;
        setState(() {
          orders = data.map((item) => OrderData.fromJson(item)).toList();
          total = calculateTodaySales();
        });
      } else {
        setState(() {
          orders = [];
          total = 0;
        });
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

  double calculateTodaySales() {
    double calculatedTotal = 0;
    if (orders != null) {
      for (var order in orders!) {
        calculatedTotal += (order.totalPrice ?? 0);
      }
    }
    return calculatedTotal;
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
                        MyHeaderItem(
                          label: 'Exchange rate',
                          value:
                              '${(exchangeRate?.first.label) ?? 0} ERU = ${(exchangeRate?.first.value) ?? 0}',
                        ),
                        MyHeaderItem(label: 'Today \'s sales', value: '$total')
                      ],
                    ),
                  ),
                ),
              )
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllSalesPage(),
                          ),
                        );
                      },
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
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SaleOpsPage(),
                          ),
                        );
                        await getOrders();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var sqlHelper = GetIt.I.get<SqlHelper>();
          sqlHelper.db!.insert('exchangeRate', {'label': 1, 'value': 11712.25});
          sqlHelper.db!.insert('exchangeRate', {'label': 1, 'value': 11712.25});

          var results = await sqlHelper.db!.query('orders');
          var resultsex = await sqlHelper.db!.query('exchangeRate');
          print(results);
          print(resultsex);
        },
      ),
    );
  }
}
