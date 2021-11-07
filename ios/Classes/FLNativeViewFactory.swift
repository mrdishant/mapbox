//
//  FLNativeViewFactory.swift
//  mapbox
//
//  Created by Dishant on 06/11/21.
//

import Foundation
import Flutter
import UIKit
import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections


class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    
    
    private var messenger: FlutterBinaryMessenger
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        print(args)
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class FLNativeView: NSObject, FlutterPlatformView , NavigationMapViewDelegate, NavigationViewControllerDelegate, FlutterStreamHandler, NavigationServiceDelegate {
    
    let channel: FlutterMethodChannel
    let eventChannel: FlutterEventChannel
    var routeResponse: RouteResponse?
    var params: NSDictionary?
    var simulate=false
    private var _view: UIView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        self.channel = FlutterMethodChannel(name: "flutter_mapbox_navigation/\(viewId)", binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "flutter_mapbox_navigation/\(viewId)/events", binaryMessenger: messenger)
        self.params=args as! NSDictionary?
        
        self.simulate=self.params!["simulateRoute"] as! Bool
        super.init()
        
        self.eventChannel.setStreamHandler(self)
        
        self.channel.setMethodCallHandler { [weak self](call, result) in
//
//            guard self != nil != nil else { return }
//
//            let arguments = call.arguments as? NSDictionary
            
            //            if(call.method == "getPlatformVersion")
            //            {
            //                result("iOS " + UIDevice.current.systemVersion)
            //            }
            //            else if(call.method == "buildRoute")
            //            {
            //                strongSelf.buildRoute(arguments: arguments, flutterResult: result)
            //            }
            //            else if(call.method == "clearRoute")
            //            {
            //                strongSelf.clearRoute(arguments: arguments, result: result)
            //            }
            //            else if(call.method == "getDistanceRemaining")
            //            {
            //                result(strongSelf._distanceRemaining)
            //            }
            //            else if(call.method == "getDurationRemaining")
            //            {
            //                result(strongSelf._durationRemaining)
            //            }
            //            else if(call.method == "finishNavigation")
            //            {
            //                strongSelf.endNavigation(result: result)
            //            }
            //            else if(call.method == "startNavigation")
            //            {
            //                strongSelf.startEmbeddedNavigation(arguments: arguments, result: result)
            //            }
            //            else
            //            {
            //                result("Method is Not Implemented");
            //            }
        }
        
        calculateDirections()
        
        
        // iOS views can be created here
        createNativeView(view: _view)
    }
    
    lazy var routeOptions: NavigationRouteOptions = {
        let destinationPoint = self.params!["destination"] as! [String:Any]
        let originPoint = self.params!["origin"] as! [String:Any]
        
        let origin = CLLocationCoordinate2DMake(originPoint["Latitude"] as! Double,originPoint["Longitude"] as! Double)
        let destination = CLLocationCoordinate2DMake(destinationPoint["Latitude"] as! Double,destinationPoint["Longitude"] as! Double)
        return NavigationRouteOptions(coordinates: [origin, destination])
    }()
    
    
    func calculateDirections() {
        Directions.shared.calculate(routeOptions) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.routeResponse = response
                strongSelf.startEmbeddedNavigation()
            }
        }
    }
    
    
    func startEmbeddedNavigation() {
        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        guard let routeResponse = routeResponse else { return }
        let bottomBanner = CustomBottomBarViewController()
        
        let navigationService = MapboxNavigationService(routeResponse: routeResponse, routeIndex: 0, routeOptions: routeOptions, simulating: simulate ? .always : .never)
        let navigationOptions = NavigationOptions(navigationService: navigationService,bottomBanner:bottomBanner)
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: routeOptions, navigationOptions: navigationOptions)
        
        navigationViewController.delegate = self
        
        let flutterViewController = UIApplication.shared.delegate?.window?!.rootViewController as! FlutterViewController
        flutterViewController.addChild(navigationViewController)
        let container = self.view()
        container.addSubview(navigationViewController.view)
        navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationViewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            navigationViewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            navigationViewController.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            navigationViewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
        let parentSafeArea = navigationViewController.view.safeAreaLayoutGuide
        let bannerHeight: CGFloat = 0.0
        let verticalOffset: CGFloat = 0.0
//        let horizontalOffset: CGFloat = 10.0

        //
        bottomBanner.view.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
        bottomBanner.view.bottomAnchor.constraint(equalTo: parentSafeArea.bottomAnchor, constant: -verticalOffset).isActive = true
        
        navigationViewController.modalPresentationStyle = .fullScreen
        flutterViewController.didMove(toParent: flutterViewController)
    }
    
    
    func view() -> UIView {
        return _view
    }
    
    func createNativeView(view: UIView){
        //        _view.backgroundColor = UIColor.blue
        //        let nativeLabel = UILabel()
        //        nativeLabel.text = "Native text from iOS"
        //        nativeLabel.textColor = UIColor.white
        //        nativeLabel.textAlignment = .center
        //        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
        //        _view.addSubview(nativeLabel)
        
    }
    
    
    var sink: FlutterEventSink?
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    //MARK: NavigationViewController Delegates
    public func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        //            _lastKnownLocation = location
        //            _distanceRemaining = progress.distanceRemaining
        //            _durationRemaining = progress.durationRemaining
        //            sendEvent(eventType: MapBoxEventType.navigation_running)
        //_currentLegDescription =  progress.currentLeg.description
        if(sink != nil)
        {
            let jsonEncoder = JSONEncoder()
            
            let progressEvent = MapBoxRouteProgressEvent(progress: progress)
            let progressEventJsonData = try! jsonEncoder.encode(progressEvent)
            guard let progressEventJson = String(data: progressEventJsonData, encoding: String.Encoding.ascii) else { return }
            
            sendEvent(eventType: MapBoxEventType.navigation_running,data: progressEventJson)
            
            if(progress.isFinalLeg && progress.currentLegProgress.userHasArrivedAtWaypoint)
            {
                sink = nil
            }
        }
    }
    
    public func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        
        //        sendEvent(eventType: MapBoxEventType.on_arrival, data: "true")
        //            if(!_wayPoints.isEmpty && IsMultipleUniqueRoutes)
        //            {
        //                continueNavigationWithWayPoints(wayPoints: [getLastKnownLocation(), _wayPoints.remove(at: 0)])
        //                return false
        //            }
        
        return true
    }
    
    
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        //        self._view.   dismiss(animated: true, completion: nil)
        print("On Dismiss Called")
    }
    
    func sendEvent(eventType: MapBoxEventType, data: String = "")
    {
        let routeEvent = MapBoxRouteEvent(eventType: eventType, data: data)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(routeEvent)
        let eventJson = String(data: jsonData, encoding: String.Encoding.utf8)
        if(sink != nil){
            sink!(eventJson)
        }
        
    }
}



class CustomBottomBarViewController: ContainerViewController  {
}
