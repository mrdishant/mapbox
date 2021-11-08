import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox/controller.dart';
import 'package:mapbox/mapbox.dart';
import 'package:mapbox/models/waypoint.dart';
import 'package:mapbox/navigation_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await Mapbox.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  late MapBoxNavigationViewController _controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Plugin example app'),
        // ),
        body: Stack(
          children: [
            MapBoxNavigationView(
              destinationPoint: WayPoint(
                  latitude: 30.899609,
                  longitude: 75.864070,
                  name: "Destination"),
              originPoint: WayPoint(
                  latitude: 30.903921, longitude: 75.873315, name: "Origin"),
              onRouteEvent: _onEmbeddedRouteEvent,
              onCreated: (MapBoxNavigationViewController controller) async {
                _controller = controller;
                controller.initialize();
              },
              bottomOffset: 100,
              simulateRoute: true,
            ),
            Positioned(
              top: 50,
              left: 50,
              child: IconButton(
                  onPressed: () async {
                    var r = await _controller.finishNavigation();
                    print(r);
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.clear)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    // print(e);
    // print(e.eventType);
    // _distanceRemaining = await _directions.distanceRemaining;
    // _durationRemaining = await _directions.durationRemaining;
    // // print(e.eventType);
    // // print(e.data);
    // switch (e.eventType) {
    //   case MapBoxEvent.progress_change:
    //     var progressEvent = e.data as RouteProgressEvent;
    //     if (progressEvent.currentStepInstruction != null)
    //       _instruction = progressEvent.currentStepInstruction;
    //     break;
    //   case MapBoxEvent.route_building:
    //   case MapBoxEvent.route_built:
    //     setState(() {
    //       _routeBuilt = true;
    //     });
    //     break;
    //   case MapBoxEvent.route_build_failed:
    //     setState(() {
    //       _routeBuilt = false;
    //     });
    //     break;
    //   case MapBoxEvent.navigation_running:
    //     setState(() {
    //       _isNavigating = true;
    //     });
    //     break;
    //   case MapBoxEvent.on_arrival:
    //     if (!_isMultipleStop) {
    //       await Future.delayed(Duration(seconds: 3));
    //       await _controller.finishNavigation();
    //     } else {}
    //     break;
    //   case MapBoxEvent.navigation_finished:
    //   case MapBoxEvent.navigation_cancelled:
    //     setState(() {
    //       _routeBuilt = false;
    //       _isNavigating = false;
    //     });
    //     break;
    //   default:
    //     break;
    // }
    setState(() {});
  }
}
