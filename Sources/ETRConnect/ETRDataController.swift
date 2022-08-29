//
//  SNCFDataController.swift
//  ICE Buddy
//
//  Created by Leo Mehlig on 13.07.22.
//

import Foundation
import Combine
import Moya
import TrainConnect
import Alamofire

public class ETRDataController: NSObject, TrainDataController {
    public static let shared = ETRDataController()
    
    override init() {
        super.init()
    }
    
    public func getProvider(demoMode: Bool) -> MoyaProvider<ETRPortalAPI> {
        if demoMode {
            return MoyaProvider<ETRPortalAPI>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            let manager = ServerTrustManager(evaluators: ["d6o.portalefrecce.it": DisabledTrustEvaluator()])
            let session = Session(serverTrustManager: manager)
            return MoyaProvider<ETRPortalAPI>(stubClosure: MoyaProvider.neverStub, session: session)
        }
    }
    
    public func loadTrip(demoMode: Bool, completionHandler: @escaping (TrainTrip?, Error?) -> ()){
        self.loadInfo(demoMode: demoMode, completionHandler: {
            completionHandler($0, $1)
        })
    }
    
    public func loadTrainStatus(demoMode: Bool = false, completionHandler: @escaping (TrainStatus?, Error?) -> ()) {
        self.loadInfo(demoMode: demoMode, completionHandler: {
            completionHandler($0, $1)
        })
    }
    
    private func loadInfo(demoMode: Bool, completionHandler: @escaping (ETRInfo?, Error?) -> ()){
        
        let provider = getProvider(demoMode: demoMode)
        provider.request(.infoVaggio) { result in
            switch result {
            case .success(let response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    print(String(data: response.data, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    let trip = try decoder.decode(ETRInfo.self, from: response.data)
                    completionHandler(trip, nil)
                } catch DecodingError.dataCorrupted(let context) {
                    print(context)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print(error.localizedDescription)
                    completionHandler(nil, error)
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil, error)
                break
            }
        }
    }
    

//
//    private func loadGPS(demoMode: Bool = false, completionHandler: @escaping (GPSResponse?, Error?) -> ()) {
//        let provider = getProvider(demoMode: demoMode)
//        provider.request(.gps) { result in
//            switch result {
//            case .success(let response):
//                do {
//                    let response = try response.filterSuccessfulStatusCodes()
//                    let decoder = JSONDecoder()
//                    let status = try decoder.decode(GPSResponse.self, from: response.data)
//                    completionHandler(status, nil)
//                } catch DecodingError.dataCorrupted(let context) {
//                    print(context)
//                } catch DecodingError.keyNotFound(let key, let context) {
//                    print("Key '\(key)' not found:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch DecodingError.valueNotFound(let value, let context) {
//                    print("Value '\(value)' not found:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch DecodingError.typeMismatch(let type, let context) {
//                    print("Type '\(type)' mismatch:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch {
//                    print(error.localizedDescription)
//                    completionHandler(nil, error)
//                }
//                break
//            case .failure(let error):
//                print(error.localizedDescription)
//                completionHandler(nil, error)
//                break
//            }
//        }
//    }
    
//    private func loadStatistics(demoMode: Bool = false, completionHandler: @escaping (StatisticsResponse?, Error?) -> ()) {
//        let provider = getProvider(demoMode: demoMode)
//        provider.request(.statistics) { result in
//            switch result {
//            case .success(let response):
//                do {
//                    let response = try response.filterSuccessfulStatusCodes()
//                    let decoder = JSONDecoder()
//                    let status = try decoder.decode(StatisticsResponse.self, from: response.data)
//                    completionHandler(status, nil)
//                } catch DecodingError.dataCorrupted(let context) {
//                    print(context)
//                } catch DecodingError.keyNotFound(let key, let context) {
//                    print("Key '\(key)' not found:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch DecodingError.valueNotFound(let value, let context) {
//                    print("Value '\(value)' not found:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch DecodingError.typeMismatch(let type, let context) {
//                    print("Type '\(type)' mismatch:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch {
//                    print(error.localizedDescription)
//                    completionHandler(nil, error)
//                }
//                break
//            case .failure(let error):
//                print(error.localizedDescription)
//                completionHandler(nil, error)
//                break
//            }
//        }
//    }
}

//extension ICEDataController {
//    static public func sampleStop() -> JourneyStop? {
//        var stop: JourneyStop?
//        let dataController = self.shared
//        dataController.loadTripData(demoMode: true) { tripResponse, error in
//            if let tripResponse = tripResponse {
//                stop = tripResponse.trip.stops.filter({ stop in
//                    return stop.timetable.arrivalDelay != ""
//                }).first
//            }
//        }
//        return stop
//    }
//}

