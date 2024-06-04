import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/widgets/add_elevated_button.dart';
import 'package:batch_sql/widgets/my_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoryOpsPage extends StatefulWidget {
  const CategoryOpsPage({super.key});

  @override
  State<CategoryOpsPage> createState() => _CategoryOpsPageState();
}

class _CategoryOpsPageState extends State<CategoryOpsPage> {
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New'),
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
                MyAddElevatedButton(
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
        await sqlHelper.db!.insert('categories', {
          'name': nameController.text,
          'description': descriptionController.text,
        });
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
