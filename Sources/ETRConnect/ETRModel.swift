//
//  SNCFModel.swift
//  
//
//  Created by Leo Mehlig on 13.07.22.
//

import Foundation
import TrainConnect
import CoreLocation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Welcome
struct ETRInfo: Codable, TrainTrip, TrainStatus {
     
    let isGpsValid: Bool?
    let ultimaStazione, eta, speed: String?
    let isOdoValid: Bool?
    let tracknum: String?
    let statoPercorso: [StatoPercorso]
//    let m53: M53?
    let categoria, statename, onTimeInfo, prossimaStazione: String?
    let tracktitle, delay2: String?
//    let isM53Visible: Bool?
    let trackline: Trackline?
    let isTrackOnGPS: Bool?
    
    var train: String {
        self.tracknum ?? "N/A"
    }
    
    var trainStops: [TrainStop] {
        self.statoPercorso.map({ ETRStop(stato: $0, delay: self.delay2) })
    }
    
    var vzn: String {
        self.tracknum ?? "N/A"
    }
    
    var latitude: Double { 0 }
    
    var longitude: Double { 0 }
    
    var currentSpeed: Measurement<UnitSpeed> {
        if let speed = speed.flatMap(Double.init) {
            return .init(value: speed, unit: .kilometersPerHour)
        }
        return .init(value: 0, unit: .kilometersPerHour)
    }
    
    var currentConnectivity: String? {
        nil
    }
    
    var connectedDevices: Int? {
        nil
    }
    
    var trainType: TrainType {
        ETRTrainType(trainModel: tracknum ?? "")
    }
}

struct ETRTrainType: TrainType {
    var trainModel: String
    
    var trainIcon: NSImage? {
         nil
    }
    
    
}

extension DateFormatter {
    static let etrFormatter: DateFormatter = {
        //2022-07-13T11:58:00.000Z
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct ETRStop: TrainStop {
    

    
    var stato: StatoPercorso
    var delay: String?
    
    var id: UUID = UUID()
    
    var trainStation: TrainStation {
        ETRTrainStation(code: stato.statoPercorsoDescription ?? "",
                        name: stato.statoPercorsoDescription ?? "")
    }
    
    var scheduledArrival: Date? {
        DateFormatter.etrFormatter.date(from: stato.orario ?? "")
    }
    
    var actualArrival: Date? {
        DateFormatter.etrFormatter.date(from: stato.orario ?? "")
    }
    
    var scheduledDeparture: Date? {
        nil
    }
    
    var actualDeparture: Date? {
        nil
    }
    
    var departureDelay: String {
        self.delay ?? ""
    }
    
    var arrivalDelay: String {
        self.delay ?? ""
    }
    
    var trainTrack: TrainTrack? {
        nil
    }
    
    var hasPassed: Bool {
        stato.passed ?? false
    }
}

//// MARK: - M53
//struct M53: Codable {
//    let m53Elements: [M53Element]?
//    let m53Station, dateSnapshot: String?
//
//    enum CodingKeys: String, CodingKey {
//        case m53Elements = "m53elements"
//        case m53Station, dateSnapshot
//    }
//}

//// MARK: - M53Element
//struct M53Element: Codable {
//    let binario: String?
//    let binarioReale: JSONNull?
//    let categoria, destinazione, numTreno, orario: String?
//    let ritardo: String?
//}

// MARK: - StatoPercorso
struct StatoPercorso: Codable {
    let statoPercorsoDescription: String?
    let statoId: Int?
    let orario: String?
    let passed: Bool?
    let percent, stationState: Int?

    enum CodingKeys: String, CodingKey {
        case statoPercorsoDescription = "description"
        case statoId = "id", orario, passed, percent, stationState
    }
}

struct ETRTrainStation: TrainStation {
    var code: String
    
    var name: String
    
    var coordinates: CLLocationCoordinate2D? {
        nil
    }
    
    
}

// MARK: - Trackline
struct Trackline: Codable {
    let start: End?
    let trainprogress: Int?
    let postreno: Double?
    let mid, end: End?
}

// MARK: - End
struct End: Codable {
    let staz, orario: String?
}

struct ETRStatus: Codable {
    let bobStatus: BobStatus?

    enum CodingKeys: String, CodingKey {
        case bobStatus = "BobStatus"
    }
}

// MARK: - BobStatus
struct BobStatus: Codable {
    let train: Train?

    enum CodingKeys: String, CodingKey {
        case train = "Train"
    }
}

// MARK: - Train
struct Train: Codable {
    let id, token, mealStatus: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case token = "Token"
        case mealStatus = "MealStatus"
    }
}
