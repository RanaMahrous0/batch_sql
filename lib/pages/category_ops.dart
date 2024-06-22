import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/category_data.dart';
import 'package:batch_sql/widgets/add_elevated_button.dart';
import 'package:batch_sql/widgets/my_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoryOpsPage extends StatefulWidget {
  final CategoryData? categoryData;
  const CategoryOpsPage({this.categoryData, super.key});

  @override
  State<CategoryOpsPage> createState() => _CategoryOpsPageState();
}

class _CategoryOpsPageState extends State<CategoryOpsPage> {
  var formKey = GlobalKey<FormState>();

  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  @override
  void initState() {
    nameController = TextEditingController(text: widget.categoryData?.name);
    descriptionController =
        TextEditingController(text: widget.categoryData?.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                MyTextFormField(
                  controller: nameController,
                  label: 'Name',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                MyTextFormField(
                  controller: descriptionController,
                  label: 'Description',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                MyAppElevatedButton(
                  label: 'Submit',
                  onPressed: () {
                    onSubmit();
                  },
                )
              ],
            )),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.categoryData != null) {
          await sqlHelper.db!.update(
            'categories',
            {
              'name': nameController.text,
              'description': descriptionController.text
            },
            where: 'id =?',
            whereArgs: ['id'],
          );
        } else {
          await sqlHelper.db!.insert('categories', {
            'name': nameController.text,
            'description': descriptionController.text,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Data Saved Successfully'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Saving Data '),
        ),
      );
    }
  }
}
