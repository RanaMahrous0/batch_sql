import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/clients_data.dart';
import 'package:batch_sql/widgets/add_elevated_button.dart';
import 'package:batch_sql/widgets/my_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientOpsPage extends StatefulWidget {
  final ClientsData? clientsData;
  const ClientOpsPage({this.clientsData, super.key});

  @override
  State<ClientOpsPage> createState() => _ClientOpsPageState();
}

class _ClientOpsPageState extends State<ClientOpsPage> {
  var formkey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  @override
  void initState() {
    nameController = TextEditingController(text: widget.clientsData?.name);
    emailController = TextEditingController(text: widget.clientsData?.email);
    phoneController = TextEditingController(text: widget.clientsData?.phone);
    addressController =
        TextEditingController(text: widget.clientsData?.address);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.clientsData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              MyTextFormField(
                controller: nameController,
                label: 'Name',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Client Name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextFormField(
                controller: emailController,
                label: 'Email',
                validator: (value) {
                  if (value!.isEmpty) {
                    emailController.text = 'Null';
                  }
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextFormField(
                controller: phoneController,
                label: 'Phone',
                validator: (value) {
                  if (value!.isEmpty) {
                    phoneController.text = 'Null';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextFormField(
                controller: addressController,
                label: 'Address',
                validator: (value) {
                  if (value!.isEmpty) {
                    addressController.text = 'Null';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              MyAppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmit();
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formkey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.clientsData != null) {
          await sqlHelper.db!.update('clients', {
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'address': addressController.text,
          });
        } else {
          await sqlHelper.db!.insert('clients', {
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'address': addressController.text,
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
