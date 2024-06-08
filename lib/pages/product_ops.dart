import 'package:batch_sql/helpers/sqlHelper.dart';
import 'package:batch_sql/models/product_data.dart';
import 'package:batch_sql/widgets/add_elevated_button.dart';
import 'package:batch_sql/widgets/categories_drop_down_menu.dart';
import 'package:batch_sql/widgets/my_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class ProductOpsPage extends StatefulWidget {
  final ProductData? productData;
  const ProductOpsPage({this.productData, super.key});

  @override
  State<ProductOpsPage> createState() => _ProductOpsPageState();
}

class _ProductOpsPageState extends State<ProductOpsPage> {
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var priceController = TextEditingController();
  var stockController = TextEditingController();
  var imageController = TextEditingController();
  bool isAvaliable = false;
  int? selectedCategoryId;
  @override
  void initState() {
    setInitialData();
    super.initState();
  }

  void setInitialData() {
    nameController = TextEditingController(text: widget.productData?.name);
    descriptionController =
        TextEditingController(text: widget.productData?.description);
    priceController =
        TextEditingController(text: '${widget.productData?.price ?? ''}');
    imageController = TextEditingController(text: widget.productData?.image);
    stockController =
        TextEditingController(text: '${widget.productData?.stock ?? ''}');
    isAvaliable = widget.productData?.isAvaliable ?? false;
    selectedCategoryId = widget.productData?.categoryId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: priceController,
                          label: 'Price',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'price is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: MyTextFormField(
                          controller: stockController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          label: 'Stock',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Stock is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyTextFormField(
                    controller: imageController,
                    label: 'Image URL',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Image Url is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Switch(
                          value: isAvaliable,
                          onChanged: (value) {
                            setState(() {
                              isAvaliable = value;
                            });
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Is Avaliable')
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CategoriesDropDownMenu(
                      selectedValue: selectedCategoryId,
                      onChanged: (categoryId) {
                        setState(() {
                          selectedCategoryId = categoryId;
                        });
                      }),
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
              ),
            )),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.productData != null) {
          await sqlHelper.db!.update('products', {
            'name': nameController.text,
            'description': descriptionController.text,
            'price': priceController.text,
            'stock': stockController.text,
            'image': imageController.text,
            'isAvaliable': isAvaliable,
            'categoryId': selectedCategoryId,
          });
        } else {
          await sqlHelper.db!.insert('products', {
            'name': nameController.text,
            'description': descriptionController.text,
            'price': priceController.text,
            'stock': stockController.text,
            'image': imageController.text,
            'isAvaliable': isAvaliable,
            'categoryId': selectedCategoryId,
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
