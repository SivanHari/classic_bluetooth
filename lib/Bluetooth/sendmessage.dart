import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SendMesssage extends StatefulWidget {
  SendMesssage({Key? key}) : super(key: key);

  @override
  State<SendMesssage> createState() => _SendMesssageState();
}

class _SendMesssageState extends State<SendMesssage> {
  late String title;
  String text = "No Value Entered";
  void _setText() {
    setState(() {
      text = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send  Message "),
      ),
      body: Container(
        child: Center(
            child: Column(
          children: [
            Text("Send Message Screen Called"),
            TextField(
              decoration: InputDecoration(labelText: 'Message'),
              onChanged: (value) => title = value,
            )
          ],
        )),
      ),
    );
  }
}
