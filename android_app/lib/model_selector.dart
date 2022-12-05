import 'package:flutter/material.dart';

import 'image_getter_page.dart';

class ModelSelector extends StatefulWidget {
  // late String b;
  // Selectmodel(String a) {
  //   this.b = a;
  // }

  @override
  State<ModelSelector> createState() => _SelectmodelState();
}

class _SelectmodelState extends State<ModelSelector> {
  List<String> model_items = ['model 1', 'model 2', 'model 3'];

  List<String> epoch_values = ['50', '500', '1000'];

  String model_value = 'model 1';
  String epoch_value = '50';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 300,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(children: [
              SizedBox(
                height: 120,
              ),
              Text('Select the model from list'),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 240,
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        enabledBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 3, color: Colors.red))),
                    value: model_value,
                    items: model_items
                        .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(fontSize: 24),
                            )))
                        .toList(),
                    onChanged: (item) {
                      setState(() {
                        model_value = item!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              /*
              SizedBox(
                width: 240,
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        enabledBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 3, color: Colors.red))),
                    value: epoch_value,
                    items: epoch_values
                        .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(fontSize: 24),
                            )))
                        .toList(),
                    onChanged: (item) {
                      setState(() {
                        epoch_value = item!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),*/
              TextButton(
                onPressed: () {
                  _navigateToImageGetterPage(context, model_value, epoch_value);
                  // _navigateToPaintingPage(context, a, model_value, epoch_value);
                },
                child: Text(
                  'IMAGE PAGE',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

// void _navigateToPaintingPage(BuildContext context, String a, String modelValue, epochValue) {
//   Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaintingScreen(a, modelValue, epochValue)));
// }

void _navigateToImageGetterPage(BuildContext context, String modelValue, epochValue) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImageGetterWidget(modelValue, epochValue)));
}
