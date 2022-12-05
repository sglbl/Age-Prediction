import 'package:flutter/material.dart';

class HowToUsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How To Use ?'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 200.0,
            height: 100.0,
          ),
          SizedBox(
            width: 50.0,
            height: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
                'In this application, click on gallery or camera button to get a face photo.\nAfter you select the photo, press the button to predict',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black.withOpacity(0.6), fontSize: 22.5)),
          ),
        ],
      ),
    );
  }
}
