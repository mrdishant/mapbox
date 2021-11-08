import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'models/routeEvent.dart';
import 'models/waypoint.dart';

typedef void OnNavigationViewCreatedCallBack(
    MapBoxNavigationViewController controller);

class MapBoxNavigationView extends StatelessWidget {
  WayPoint destinationPoint, originPoint;
  var simulateRoute;
  final OnNavigationViewCreatedCallBack? onCreated;
  final ValueSetter<RouteEvent>? onRouteEvent;
  double? bottomOffset;
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  MapBoxNavigationView(
      {required this.destinationPoint,
      required this.originPoint,
      this.simulateRoute,
      this.bottomOffset,
      required this.onCreated,
      required this.onRouteEvent});

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'test-view';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    final destinationPointMap = <String, dynamic>{
      "Order": 1,
      "Name": destinationPoint.name,
      "Latitude": destinationPoint.latitude,
      "Longitude": destinationPoint.longitude,
    };

    final originPointMap = <String, dynamic>{
      "Order": 1,
      "Name": originPoint.name,
      "Latitude": originPoint.latitude,
      "Longitude": originPoint.longitude,
    };

    creationParams['origin'] = originPointMap;
    creationParams['destination'] = destinationPointMap;
    creationParams['simulateRoute'] = simulateRoute ?? false;
    creationParams['bottomOffset'] = bottomOffset ?? 0;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // return widget on Android.
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory:
              (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <
                  Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: _decoder,
            )
              ..addOnPlatformViewCreatedListener((value) {
                params.onPlatformViewCreated(value);
                _onPlatformViewCreated(value);
              })
              ..create();
          },
        );
      case TargetPlatform.iOS:
        // return widget on iOS.
        return UiKitView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: _decoder,
        );

      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }

  void _onPlatformViewCreated(int id) {
    if (onCreated == null) {
      return;
    }
    onCreated!(MapBoxNavigationViewController(id, onRouteEvent));
  }
}
