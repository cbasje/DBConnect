//
//  NedSpoorModel.swift
//
//
//  Created by Sebastiaan Benjamins on 05-10-2023.
//

import Foundation
import TrainConnect
import CoreLocation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - TravelInfoResponse
struct TravelInfoResponse: Codable {
    let currentStation, nextStation, splitCombineContent: String
    let displayArrivalTimes, displayTravelInformation: Bool
    let finalDestination: Station
    let phase: Int
    let trip: Trip
    let transfer: [Transfer]
//    let disturbances: Disturbances
}

// MARK: - Disturbances
//struct Disturbances: Codable {
//    let ev, vtb: [JSONAny]
//}

// MARK: - Station
struct Station: Codable,TrainStation {
    let code, type: String
    let latitudeString, longitudeString: String
    let languages: Languages
    let defaultLanguageCode: DefaultLanguageCode
    
    public var name: String {
        self.languages.nl.longName
    }
    
    public var coordinates: CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: Double(latitudeString)!, longitude: Double(longitudeString)!)
    }
    
    private enum CodingKeys: String, CodingKey {
        case code
        case type
        case latitudeString = "latitude"
        case longitudeString = "longitude"
        case languages
        case defaultLanguageCode
    }
}

enum DefaultLanguageCode: String, Codable {
    case nl = "nl"
}

// MARK: - Languages
struct Languages: Codable {
    let nl: Nl
}

// MARK: - Nl
struct Nl: Codable {
    let shortName, middleName, longName: String
}

// MARK: - Transfer
struct Transfer: Codable {
    let trainNumber, trainType, trainTypeFull, fromDateTime: String
    let fromPlatform: String
    let platFormChanged: Bool
    let finalDestination: [Station]
    let fromDelay: Int
    let dataDateTime: String
}

// MARK: - Trip
struct Trip: Codable, TrainTrip {
    let isInternationalTrip: Bool
    let trainTypeFull: String
    let stops: [Stop]
//    let tripLanguages: [JSONAny]
    
    public var train: String {
        self.trainTypeFull
    }
    
    public var trainStops: [TrainConnect.TrainStop] {
        self.stops
    }
    
    public var vzn: String {
        ""
    }
}

// MARK: - Stop
struct Stop: Codable, TrainStop {
    let station: Station
    let stationCode: String
    let stationType: StationType
    let platform: String
    let platFormChanged: Bool
    let arrivalDelayInt, fromDelayInt: Int
    let arrivalDateTime: Date?
    let fromDateTime: Date?
    //    let dataDateTime: Date
    
    public var id: UUID = UUID()
    
    public var trainStation: TrainConnect.TrainStation {
        self.station
    }
    
    public var scheduledArrival: Date? {
        self.arrivalDateTime
    }
    
    public var actualArrival: Date? {
        self.scheduledArrival?.addingTimeInterval(TimeInterval(self.arrivalDelayInt) * -60)
    }
    
    public var scheduledDeparture: Date? {
        self.fromDateTime
    }
    
    public var actualDeparture: Date? {
        self.scheduledDeparture?.addingTimeInterval(TimeInterval(self.fromDelayInt) * -60)
    }
    
    public var departureDelay: String {
        if self.fromDelayInt != 0 {
            return "+\(self.fromDelayInt)"
        } else {
            return ""
        }
    }
    
    public var arrivalDelay: String {
        if self.arrivalDelayInt != 0 {
            return "+\(self.arrivalDelayInt)"
        } else {
            return ""
        }
    }
    
    public var trainTrack: TrainTrack? {
        if platFormChanged {
            return Track(scheduled: "-", actual: platform)
        }
        return Track(scheduled: platform, actual: platform)
    }
    
    public var hasPassed: Bool {
        guard let departure = self.actualDeparture else {
            return false
        }
        return departure < Date()
    }
    
    private enum CodingKeys: String, CodingKey {
        case station
        case stationCode
        case stationType
        case platform
        case platFormChanged
        case arrivalDelayInt = "arrivalDelay"
        case fromDelayInt = "fromDelay"
        case arrivalDateTime
        case fromDateTime
//        case dataDateTime
    }
}

enum StationType: String, Codable {
    case r = "r"
}

struct Track: TrainTrack {
    let scheduled: String
    let actual: String
}
