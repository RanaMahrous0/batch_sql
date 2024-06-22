import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/category_data.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoriesDropDownMenu extends StatefulWidget {
  final void Function(int?)? onChanged;
  final int? selectedValue;
  const CategoriesDropDownMenu(
      {this.selectedValue, required this.onChanged, super.key});

  @override
  State<CategoriesDropDownMenu> createState() => _CategoriesDropDownMenuState();
}

class _CategoriesDropDownMenuState extends State<CategoriesDropDownMenu> {
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
    return categories == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : (categories?.isEmpty ?? false)
            ? const Center(
                child: Text('No Data Found'),
              )
            : Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: DropdownButton(
                      value: widget.selectedValue,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text(
                        'Select Category',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      items: [
                        for (var category in categories!)
                          DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name ?? 'No Name'),
                          ),
                      ],
                      onChanged: widget.onChanged),
                ),
              );
  }
}
