import 'package:flutter/material.dart';

import 'Bluetooth/PairedDevice.dart';

void main() {
  runApp(MaterialApp(
    title: "Classic Bluetooth",
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: Text("Classic Bluetooth"),
      ),
      body: Center(child: PairedDevices()),
    ),
  ));
}
