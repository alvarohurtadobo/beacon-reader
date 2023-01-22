import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  String _tag = "BControl 2.0";
  String _beaconResult = 'Sin escanear aún.';
  int _nrMessagesReceived = 0;
  var isRunning = false;
  List<String> _results = [];
  bool _isInForeground = true;

  final ScrollController _scrollController = ScrollController();

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    print("init notif");
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('launcher_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    beaconEventsController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      //Prominent disclosure
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Background Locations",
          message:
              "[This app] collects location data to enable [feature], [feature], & [feature] even when the app is closed or not in use");

      //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
      //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
    }

    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        print("Method: ${call.method}");
        if (call.method == 'scannerReady') {
          _showNotification("Escaneo Beacon iniciado");
          await BeaconsPlugin.startMonitoring();
          setState(() {
            isRunning = true;
          });
        } else if (call.method == 'isPermissionDialogShown') {
          _showNotification(
              "Se muestra un mensaje de divulgación prominente al usuario!");
        }
      });
    } else if (Platform.isIOS) {
      _showNotification("Monitoreo Beacon iniciado");
      await BeaconsPlugin.startMonitoring();
      setState(() {
        isRunning = true;
      });
    }

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    await BeaconsPlugin.addRegion(
        "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");

    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

    beaconEventsController.stream.listen(
        (data) {
          print("Stream received $_isInForeground");
          if (data.isNotEmpty && isRunning) {
            setState(() {
              _beaconResult = data;
              _results.add(_beaconResult);
              _nrMessagesReceived++;
            });
            print("display bg notification");
            String myDatetime = DateTime.now().toIso8601String().substring(11,19);
            Map<String, dynamic> myData = json.decode(data);
            String myUuid = "No UUID";
            String distance = "Infinity";
            String proximity = "Far away";
            if (myData.containsKey("uuid")) {
              myUuid = myData["uuid"].toString();
              if (myUuid.length >= 12) {
                myUuid = myUuid.substring(myUuid.length - 12);
              }
            }
            if (myData.containsKey("distance")) {
              distance = myData["distance"];
            }
            if (myData.containsKey("proximity")) {
              proximity = myData["proximity"];
            }
            print("Beacons DataReceived ($myDatetime): " + data);
            print(
                "Decoded DataReceived: $myUuid, Distancia: $distance ($proximity)");
            if (!_isInForeground) {
              _showNotification(
                  "Beacon $myUuid detectado a hrs $myDatetime, Distancia: $distance ($proximity)");
            }
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Monitoreando Beacons",
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: const Color(0xfffec106),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
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
              Center(
                child: Text(
                  'Resultados totales: $_nrMessagesReceived',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xfffec106))),
                  onPressed: () async {
                    if (isRunning) {
                      await BeaconsPlugin.stopMonitoring();
                    } else {
                      initPlatformState();
                      await BeaconsPlugin.startMonitoring();
                    }
                    setState(() {
                      isRunning = !isRunning;
                    });
                  },
                  child: Text(isRunning ? 'Detener' : 'Empezar a escanear',
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
              Visibility(
                visible: _results.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xfffec106))),
                    onPressed: () async {
                      setState(() {
                        _nrMessagesReceived = 0;
                        _results.clear();
                      });
                    },
                    child: const Text("Borrar resultados",
                        style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(child: _buildResultsList())
            ],
          ),
        ),
      ),
    );
  }

  void _showNotification(String subtitle) {
    var rng = new Random();
    Future.delayed(Duration(seconds: 2)).then((result) async {
      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'your channel id', 'your channel name',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker');
      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin
          .show(rng.nextInt(100000), _tag, subtitle, platformChannelSpecifics,
              payload: 'item x')
          .onError((error, stackTrace) {
        print("Notification error is $error");
      });
    });
  }

  Widget _buildResultsList() {
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        controller: _scrollController,
        itemCount: _results.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 1,
          color: Colors.black,
        ),
        itemBuilder: (context, index) {
          DateTime now = DateTime.now();
          String formattedDate =
              DateFormat('yyyy-MM-dd – kk:mm:ss.SSS').format(now);
          final item = ListTile(
              title: Text(
                "Time: $formattedDate\n${_results[index]}",
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF1A1B26),
                      fontWeight: FontWeight.normal,
                    ),
              ),
              onTap: () {});
          return item;
        },
      ),
    );
  }
}
