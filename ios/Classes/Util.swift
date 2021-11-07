//
//  Util.swift
//  mapbox
//
//  Created by Dishant on 07/11/21.
//

import Foundation
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation

public class MapBoxRouteEvent : Codable
{
    let eventType: MapBoxEventType
    let data: String
    
    init(eventType: MapBoxEventType, data: String) {
        self.eventType = eventType
        self.data = data
    }
}

enum MapBoxEventType: Int, Codable
{
    case map_ready
    case route_building
    case route_built
    case route_build_failed
    case progress_change
    case user_off_route
    case milestone_event
    case navigation_running
    case navigation_cancelled
    case navigation_finished
    case faster_route_found
    case speech_announcement
    case banner_instruction
    case on_arrival
    case failed_to_reroute
    case reroute_along
}


public class Location : Codable
{
    let name: String
    let latitude: Double?
    let longitude: Double?
    let order: Int?
    
    init(name: String, latitude: Double?, longitude: Double?, order: Int? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.order = order
    }
}

public class MapBoxRouteLeg : Codable
{
    let profileIdentifier: String
    let name: String
    let distance: Double
    let expectedTravelTime: Double
    let source: Location
    let destination: Location
    var steps: [MapBoxRouteStep] = []
    
    init(leg: RouteLeg) {
        profileIdentifier = leg.profileIdentifier.rawValue
        name = leg.name
        distance = leg.distance
        expectedTravelTime = leg.expectedTravelTime
        source = Location(name: leg.source?.name ?? "source", latitude: leg.source?.coordinate.latitude, longitude: leg.source?.coordinate.longitude)
        destination = Location(name: leg.destination?.name ?? "source", latitude: leg.destination?.coordinate.latitude, longitude: leg.destination?.coordinate.longitude)
        for step in leg.steps {
            steps.append(MapBoxRouteStep(step: step))
        }
    }
}

public class MapBoxRouteStep : Codable
{
    let name: String?
    let instructions: String
    let distance: Double
    let expectedTravelTime: Double
    
    init(step: RouteStep){
        name = step.names?.first
        instructions = step.instructions
        distance = step.distance
        expectedTravelTime = step.expectedTravelTime
    }
}


public class MapBoxRouteProgressEvent : Codable
{
    let arrived: Bool
    let distance: Double
    let duration: Double
    let distanceTraveled: Double
    let currentLegDistanceTraveled: Double
    let currentLegDistanceRemaining: Double
    let currentStepInstruction: String
    let legIndex: Int
    let stepIndex: Int
    let currentLeg: MapBoxRouteLeg
    var priorLeg: MapBoxRouteLeg? = nil
    var remainingLegs: [MapBoxRouteLeg] = []
    
    init(progress: RouteProgress) {
        
        arrived = progress.isFinalLeg && progress.currentLegProgress.userHasArrivedAtWaypoint
        distance = progress.distanceRemaining
        distanceTraveled = progress.distanceTraveled
        duration = progress.durationRemaining
        legIndex = progress.legIndex
        stepIndex = progress.currentLegProgress.stepIndex
        
        currentLeg = MapBoxRouteLeg(leg: progress.currentLeg)
        
        if(progress.priorLeg != nil)
        {
            priorLeg = MapBoxRouteLeg(leg: progress.priorLeg!)
        }
        
        for leg in progress.remainingLegs
        {
            remainingLegs.append(MapBoxRouteLeg(leg: leg))
        }
        
        currentLegDistanceTraveled = progress.currentLegProgress.distanceTraveled
        currentLegDistanceRemaining = progress.currentLegProgress.distanceRemaining
        currentStepInstruction = progress.currentLegProgress.currentStep.description
    }
    
    
}
