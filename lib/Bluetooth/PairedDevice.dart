import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:classic_bluetooth_vs/Bluetooth/sendmessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PairedDevices extends StatefulWidget {
  PairedDevices({Key? key}) : super(key: key);

  @override
  State<PairedDevices> createState() => _PairedDevicesState();
}

class _PairedDevicesState extends State<PairedDevices> {
  bool switchValue = false;
  // ignore: prefer_adjacent_string_concatenation
  String data = r"$VA,D,0x3f,5,3,1,1,#";

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  late BluetoothConnection connection;
  //bool get isConnected => connection != null && connection.isConnected;
  late int _deviceState;
  late int index_id;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the Bluetooth of the device is not enabled,
    // then request permission to turn on Bluetooth
    // as the app starts up
    //  enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // For retrieving the paired devices list
        getPairedDevices();
      });
    });
  }

  List<BluetoothDevice> _devicesList = [];

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    log("data = $data");
  }

  bool isDisconnecting = false;
  bool _connected = false;
  //late BluetoothDevice device;

  void _connect(int index) async {
    log("_connect Method called");

    BluetoothConnection connection = await BluetoothConnection.toAddress(
        _devicesList.elementAt(index).address);

    connection.input!.listen(_onDataReceived).onDone(() {
      log("_onDataReceived = ${_onDataReceived}");
      if (isDisconnecting) {
        print('Disconnecting locally!');
      } else {
        print('Disconnected remotely!');
      }
      if (this.mounted) {
        setState(() {});
      }
    });

    if (connection.isConnected) {
      log("Connected");

      connection.output
          .add(Uint8List.fromList(utf8.encode(r"$VA,D,0x3f,5,3,1,1,#")));

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SendMesssage()),
      // );
    } else {
      log("Not connected");
      Fluttertoast.showToast(
        msg: 'This is toast notification',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        // backgroundColor: Colors.red,
        // textColor: Colors.yellow
      );
    }
  }

  void _disconnect() async {
    // Closing the Bluetooth connection
    await connection.close();
    // show('Device disconnected');

    // Update the [_connected] variable
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
            title: Text("Enable Bluetooth"),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              future() async {
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
                await getPairedDevices();
              }

              future().then((_) {
                setState(() {
                  //switchValue = value;
                });
              });
            }),
        const Text(
          "Paired Devices",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: Color.fromARGB(255, 10, 10, 10),
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 200,
            width: double.infinity,
            child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (BuildContext context, int index) {
                  var name;
                  return ListTile(
                    leading: Text("Device Name : ${index + 1}"),

                    //Icon(Icons.list),
                    trailing: const Icon(Icons.add),
                    // Text(
                    //   "Device Name",
                    //   style: TextStyle(color: Colors.green, fontSize: 15),
                    // )

                    title: Text(_devicesList.elementAt(index).name.toString()),
                    onTap: () {
                      setState(() {
                        index_id = index;
                        log("indexid = $index_id    Device Name = ${_devicesList.elementAt(index_id).address}");
                      });
                      _connect(index_id);
                    },

                    // Text("List item $index")
                  );
                }),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Available Device",
          style: TextStyle(
              color: Color.fromARGB(255, 10, 10, 10),
              fontSize: 15,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}

// Future<bool> enableBluetooth() async {
//   // Retrieving the current Bluetooth state
//   _bluetoothState = await FlutterBluetoothSerial.instance.state;

//   // If the Bluetooth is off, then turn it on first
//   // and then retrieve the devices that are paired.
//   if (_bluetoothState == BluetoothState.STATE_OFF) {
//     await FlutterBluetoothSerial.instance.requestEnable();
//     //await getPairedDevices();
//     return true;
//   } else {
//     //await getPairedDevices();
//   }
//   return false;
// }
