//
//  TrainMapping.swift
//
//
//  Created by Sebastiaan on 16-10-2023.
//

import Foundation
import SwiftUI
import TrainConnect
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct Status: TrainStatus {
    public let trainId: String
    
    public var currentConnectivity: String? {
        nil
    }
    
    public var connectedDevices: Int? {
        nil
    }
    
    public var speed: Double {
        0
    }
    public var currentSpeed: Measurement<UnitSpeed> {
        Measurement<UnitSpeed>(value: self.speed, unit: .kilometersPerHour)
    }

    public var latitude: Double {
        0
    }
    public var longitude: Double {
        0
    }
    
    public var trainType: TrainType {
        NedSpoorTrainType(trainId: trainId)
    }
}

public struct NedSpoorTrainType: TrainType {
    enum NedSpoorModel: String {
        case sprinter = "Sprinter"
        case intercity = "Intercity"
    }
    
    let trainId: String
    
    public var trainModel: String {
        return self.model?.rawValue ?? self.trainId
    }
    
    private var model: NedSpoorModel? {
        switch self.trainId {
        case "Sprinter":
            return .sprinter
        case "Intercity":
            return .intercity
        default:
            return nil
        }
    }
    
    public var trainIcon: NSImage? {
        Bundle.module.image(forResource: self.icon)!
    }
    
    private var icon: String {
        guard let model = self.model else {
            return "icng"
        }
        switch model {
        case .sprinter:
            return "sng"
        case .intercity:
            return "virm"
        }
    }
}
