//
//  SNCFPortalAPI.swift
//  ICE Buddy
//
//  Created by Leo Mehlig on 13.07.22.
//

import Foundation
import Moya

// URL: https://wifi.sncf/router/api/train/details

public enum ETRPortalAPI {
    case infoVaggio
//    case train

    
}


extension ETRPortalAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .infoVaggio:
            return URL(string: "https://d6o.portalefrecce.it")!
//        case .info:
//            return URL(string: "https://www.portalefrecce.it")!

        }
    }
    
    public var path: String {
        switch self {
        case .infoVaggio:
            return "/PortaleFrecce/infoViaggioActionJson"
//        case .info:
//            return "/BobHttpLogger/info"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        switch self {
        case .infoVaggio:
            return self.data(for: "infoViaggioActionJson")
//        case .info:
//            return self.data(for: "Statistics-1")
        }
    }
    
    public var task: Task {
        return .requestParameters(parameters: [
            "ta": "1661765521216",
            "lang": "EN"
        ], encoding: URLEncoding.queryString)
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
    
    public var headers: [String : String]? {
        return [:]
    }
}

