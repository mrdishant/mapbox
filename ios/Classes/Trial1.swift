////
////  FLNativeViewFactory.swift
////  mapbox
////
////  Created by Dishant on 06/11/21.
////
//
//import Foundation
//import Flutter
//import UIKit
//import MapboxMaps
//import MapboxCoreNavigation
//import MapboxNavigation
//import MapboxDirections
//
//class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
//    private var messenger: FlutterBinaryMessenger
//
//
//    init(messenger: FlutterBinaryMessenger) {
//        self.messenger = messenger
//        super.init()
//    }
//
//    func create(
//        withFrame frame: CGRect,
//        viewIdentifier viewId: Int64,
//        arguments args: Any?
//    ) -> FlutterPlatformView {
//        return FLNativeView(
//            frame: frame,
//            viewIdentifier: viewId,
//            arguments: args,
//            binaryMessenger: messenger)
//    }
//}
//
//class FLNativeView: NSObject, FlutterPlatformView , NavigationMapViewDelegate, NavigationViewControllerDelegate, FlutterStreamHandler, NavigationServiceDelegate {
//
//    //    let messenger: FlutterBinaryMessenger
//    let channel: FlutterMethodChannel
//    let eventChannel: FlutterEventChannel
//
//    private var _view: UIView
//    var navigationMapView: NavigationMapView!
//
//    var navigationRouteOptions: NavigationRouteOptions!
//    var currentRouteIndex = 0 {
//        didSet {
//            showCurrentRoute()
//        }
//    }
//    var currentRoute: Route? {
//        return routes?[currentRouteIndex]
//    }
//
//    var routes: [Route]? {
//        return routeResponse?.routes
//    }
//
//    var routeResponse: RouteResponse? {
//        didSet {
//            guard currentRoute != nil else {
//                navigationMapView.removeRoutes()
//                return
//            }
//            currentRouteIndex = 0
//        }
//    }
//
//    func showCurrentRoute() {
//        guard let currentRoute = currentRoute else { return }
//
//        var routes = [currentRoute]
//        routes.append(contentsOf: self.routes!.filter {
//            $0 != currentRoute
//        })
//        navigationMapView.show(routes)
//        navigationMapView.showWaypoints(on: currentRoute)
//    }
//
//    var startButton: UIButton!
//
//    init(
//        frame: CGRect,
//        viewIdentifier viewId: Int64,
//        arguments args: Any?,
//        binaryMessenger : FlutterBinaryMessenger?
//    ) {
//        _view = UIView()
//        self.channel = FlutterMethodChannel(name: "flutter_mapbox_navigation/\(viewId)", binaryMessenger: binaryMessenger as! FlutterBinaryMessenger)
//        self.eventChannel = FlutterEventChannel(name: "flutter_mapbox_navigation/\(viewId)/events", binaryMessenger: binaryMessenger as! FlutterBinaryMessenger)
//
//        super.init()
//
//        self.eventChannel.setStreamHandler(self)
//
//        self.channel.setMethodCallHandler { [weak self](call, result) in
//
//            guard let strongSelf = self else { return }
//
//            let arguments = call.arguments as? NSDictionary
//
//            //            if(call.method == "getPlatformVersion")
//            //            {
//            //                result("iOS " + UIDevice.current.systemVersion)
//            //            }
//            //            else if(call.method == "buildRoute")
//            //            {
//            //                strongSelf.buildRoute(arguments: arguments, flutterResult: result)
//            //            }
//            //            else if(call.method == "clearRoute")
//            //            {
//            //                strongSelf.clearRoute(arguments: arguments, result: result)
//            //            }
//            //            else if(call.method == "getDistanceRemaining")
//            //            {
//            //                result(strongSelf._distanceRemaining)
//            //            }
//            //            else if(call.method == "getDurationRemaining")
//            //            {
//            //                result(strongSelf._durationRemaining)
//            //            }
//            //            else if(call.method == "finishNavigation")
//            //            {
//            //                strongSelf.endNavigation(result: result)
//            //            }
//            //            else if(call.method == "startNavigation")
//            //            {
//            //                strongSelf.startEmbeddedNavigation(arguments: arguments, result: result)
//            //            }
//            //            else
//            //            {
//            //                result("Method is Not Implemented");
//            //            }
//        }
//
//
//
//
//        // iOS views can be created here
//        createNativeView(view: _view)
//    }
//
//    func view() -> UIView {
//        return _view
//    }
//
//    func createNativeView(view: UIView){
//        //        _view.backgroundColor = UIColor.blue
//        //        let nativeLabel = UILabel()
//        //        nativeLabel.text = "Native text from iOS"
//        //        nativeLabel.textColor = UIColor.white
//        //        nativeLabel.textAlignment = .center
//        //        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
//        //        _view.addSubview(nativeLabel)
//
//        navigationMapView = NavigationMapView(frame: view.bounds)
//        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        navigationMapView.delegate = self
//        navigationMapView.userLocationStyle = .puck2D()
//
//        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
//        navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
//        navigationViewportDataSource.followingMobileCamera.zoom = 13.0
//        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
//
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        navigationMapView.addGestureRecognizer(gesture)
//
//        view.addSubview(navigationMapView)
//        startButton = UIButton()
//        startButton.setTitle("Start Navigation", for: .normal)
//        startButton.translatesAutoresizingMaskIntoConstraints = false
//        startButton.backgroundColor = .blue
//        startButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
//        startButton.addTarget(self, action: #selector(tappedButton(sender:)), for: .touchUpInside)
//        startButton.isHidden = true
//        view.addSubview(startButton)
//
//        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
//        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        view.setNeedsLayout()
//    }
//
//    // Override layout lifecycle callback to be able to style the start button.
//    func viewDidLayoutSubviews() {
//        //        super.viewDidLayoutSubviews()
//
//        startButton.layer.cornerRadius = startButton.bounds.midY
//        startButton.clipsToBounds = true
//        startButton.setNeedsDisplay()
//    }
//
//    @objc func tappedButton(sender: UIButton) {
//        guard let routeResponse = routeResponse, let navigationRouteOptions = navigationRouteOptions else { return }
//        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
//        let navigationService = MapboxNavigationService(routeResponse: routeResponse,
//                                                        routeIndex: currentRouteIndex,
//                                                        routeOptions: navigationRouteOptions,
//                                                        simulating: false ? .always : .never)
//
//        let navigationOptions = NavigationOptions(navigationService: navigationService)
//        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: currentRouteIndex,
//                                                                   routeOptions: navigationRouteOptions,
//                                                                   navigationOptions: navigationOptions)
//        navigationViewController.delegate = self
//
//        let flutterViewController = UIApplication.shared.delegate?.window?!.rootViewController as! FlutterViewController
//        flutterViewController.addChild(navigationViewController)
//
//        let container = self.view()
//        container.addSubview(navigationViewController.view)
//        navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
//        constraintsWithPaddingBetween(holderView: container, topView: navigationViewController.view, padding: 0.0)
//        //navigationService.start()
//        flutterViewController.didMove(toParent: flutterViewController)
//
//        //        self.view.present(navigationViewController, animated: true, completion: nil)
//    }
//
//    func constraintsWithPaddingBetween(holderView: UIView, topView: UIView, padding: CGFloat) {
//        guard holderView.subviews.contains(topView) else {
//            return
//        }
//        topView.translatesAutoresizingMaskIntoConstraints = false
//        let pinTop = NSLayoutConstraint(item: topView, attribute: .top, relatedBy: .equal,
//                                        toItem: holderView, attribute: .top, multiplier: 1.0, constant: padding)
//        let pinBottom = NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal,
//                                           toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: padding)
//        let pinLeft = NSLayoutConstraint(item: topView, attribute: .left, relatedBy: .equal,
//                                         toItem: holderView, attribute: .left, multiplier: 1.0, constant: padding)
//        let pinRight = NSLayoutConstraint(item: topView, attribute: .right, relatedBy: .equal,
//                                          toItem: holderView, attribute: .right, multiplier: 1.0, constant: padding)
//        holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
//    }
//
//
//    var sink: FlutterEventSink?
//
//
//    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
//        sink = events
//        return nil
//    }
//
//
//    func onCancel(withArguments arguments: Any?) -> FlutterError? {
//        sink = nil
//
//        return nil
//    }
//
//    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        guard gesture.state == .ended else { return }
//        let location = navigationMapView.mapView.mapboxMap.coordinate(for: gesture.location(in: navigationMapView.mapView))
//
//        requestRoute(destination: location)
//    }
//
//    func requestRoute(destination: CLLocationCoordinate2D) {
//        guard let userLocation = navigationMapView.mapView.location.latestLocation else { return }
//
//        let location = CLLocation(latitude: userLocation.coordinate.latitude,
//                                  longitude: userLocation.coordinate.longitude)
//
//        let userWaypoint = Waypoint(location: location,
//                                    heading: userLocation.heading,
//                                    name: "user")
//
//        let destinationWaypoint = Waypoint(coordinate: destination)
//
//        let navigationRouteOptions = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
//
//        Directions.shared.calculate(navigationRouteOptions) { [weak self] (_, result) in
//            switch result {
//            case .failure(let error):
//                print(error.localizedDescription)
//            case .success(let response):
//                guard let self = self else { return }
//
//                self.navigationRouteOptions = navigationRouteOptions
//                self.routeResponse = response
//                self.startButton?.isHidden = false
//                if let routes = self.routes,
//                   let currentRoute = self.currentRoute {
//                    self.navigationMapView.show(routes)
//                    self.navigationMapView.showWaypoints(on: currentRoute)
//                }
//            }
//        }
//    }
//
//    // Delegate method called when the user selects a route
//    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
//        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
//    }
//
//    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
//        //        self._view.   dismiss(animated: true, completion: nil)
//    }
//}
//
