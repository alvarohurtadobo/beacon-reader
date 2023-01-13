
import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// final FlutterBlue flutterBlue = FlutterBlue.instance;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>  with WidgetsBindingObserver {
  Permission _permission = Permission.bluetooth;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  String _tag = "Beacons Plugin";
  String _beaconResult = 'Not Scanned Yet.';
  int _nrMessagesReceived = 0;
  var isRunning = false;
  List<String> _results = [];
  bool _isInForeground = true;

  final ScrollController _scrollController = ScrollController();

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();
      
  bool isAvailable = false;

  @override
  void initState() {
    // flutterBlue.isAvailable.then((available) {
    //   setState(() {
    //     isAvailable = available;
    //   });
    //   print("Updating status to available $isAvailable");
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xfffec106),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 40,
              ),
              Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    image: DecorationImage(
                        image: AssetImage("assets/icons/logo.png"))),
                child: Image.asset(
                  "assets/icons/logo.png",
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Resultados totales: 0',
              ),
              isAvailable
                  ? const Text(
                      'Resultados totales: 0',
                    )
                  : const Text(
                      'Este dispositivo no soporta bluetooth',
                    ),
              const SizedBox(
                height: 20,
              ),
              // StreamBuilder<BluetoothState>(
              //     stream: flutterBlue.state,
              //     builder: (context, snapshot) {
              //       print("Bluetooth state is ${snapshot.data}");
              //       if (snapshot.data! == BluetoothState.on) {
              //         return Container();
              //       }
              //       return const Text(
              //           "El bluetooth del dispositivo se encuentra apagado, por favor enciéndalo");
              //     }),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 320,
                height: 40,
                color: const Color(0xfffec106),
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Empezar a escanear",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
