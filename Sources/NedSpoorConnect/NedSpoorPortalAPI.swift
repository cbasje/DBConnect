//
//  NedSpoorPortalAPI.swift
//
//
//  Created by Sebastiaan Benjamins on 07-10-2023.
//

import Foundation
import Moya

// URL http://portal.nstrein.ns.nl/nstrein:main/travelInfo

public enum NedSpoorPortalAPI {
    case travelInfo
}

extension NedSpoorPortalAPI: TargetType {
    public var baseURL: URL {
        URL(string: "http://portal.nstrein.ns.nl/nstrein:main")!
    }
    
    public var path: String {
        switch self {
        case .travelInfo:
            return "/travelInfo"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    private func data(for sample: String) -> Data {
        do {
            if let bundlePathURL = Bundle.module.path(forResource: sample, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: bundlePathURL))
                return data
            } else {
                print("File could not be found")
            }
        } catch {
            print(error.localizedDescription)
        }
        return Data()
    }
    
    public var sampleData: Data {
        switch self {
        case .travelInfo:
            return self.data(for: "travelInfo")
        }
    }
    
    public var task: Task {
        .requestPlain
    }
    
    public var headers: [String : String]? {
        return [:]
    }
}
