import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MySearchTextField extends StatelessWidget {
  final String tableName;

  const MySearchTextField({required this.tableName ,super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                var result = await sqlHelper.db!.rawQuery("""
        SELECT * FROM $tableName
        WHERE name LIKE '%$value%' OR description LIKE '%$value%';
          """);
                print('values:$result');
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                label: const Text('Search'),
              ),
            );
  }
}