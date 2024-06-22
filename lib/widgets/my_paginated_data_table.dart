import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class MyPaginatedDataTable extends StatelessWidget {
  final DataTableSource source;
  final List<DataColumn> columns;
  final double? minWidth;
  final bool sortAscending;
  final int sortColumnIndex;
  const MyPaginatedDataTable(
      {required this.source,
      required this.sortColumnIndex,
      this.minWidth = 600,
      required this.sortAscending,
      required this.columns,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PaginatedDataTable2(
        sortAscending: sortAscending,
        sortColumnIndex: sortColumnIndex ,
        empty: const Center(
          child: Text('No Data Found'),
        ),
        headingRowColor:
            MaterialStatePropertyAll(Theme.of(context).primaryColor),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        border: TableBorder.all(),
        columnSpacing: 20,
        minWidth: minWidth,
        horizontalMargin: 20,
        wrapInCard: false,
        rowsPerPage: 10,
        renderEmptyRowsInTheEnd: false,
        isHorizontalScrollBarVisible: true,
        columns: columns,
        source: source,
      ),
    );
  }
}
