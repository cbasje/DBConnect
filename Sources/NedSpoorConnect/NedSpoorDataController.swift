//
//  NedSpoorDataController.swift
//
//
//  Created by Sebastiaan Benjamins on 05-10-2023.
//

import Foundation
import Combine
import Moya
import TrainConnect

extension DateFormatter {
    static let nedSpoorFormatter: DateFormatter = {
        // October, 09 2023 22:01:01 +0200
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, dd yyyy HH:mm:ss Z"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

public class NedSpoorDataController: NSObject, TrainDataController {
    public static let shared = NedSpoorDataController()
    
    override init() {
        super.init()
    }
    
    public func getProvider(demoMode: Bool) -> MoyaProvider<NedSpoorPortalAPI> {
        if demoMode {
            return MoyaProvider<NedSpoorPortalAPI>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            return MoyaProvider<NedSpoorPortalAPI>(stubClosure: MoyaProvider.neverStub)
        }
    }
    
    public func loadTrip(demoMode: Bool, completionHandler: @escaping (TrainTrip?, Error?) -> ()){
        self.loadDetails(demoMode: demoMode, completionHandler: {
            completionHandler($0?.trip, $1)
        })
    }
    
    private func loadDetails(demoMode: Bool, completionHandler: @escaping (TravelInfoResponse?, Error?) -> ()){
        let provider = getProvider(demoMode: demoMode)
        provider.request(.travelInfo) { result in
            switch result {
            case .success(let response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.nedSpoorFormatter)
                    let trip = try decoder.decode(TravelInfoResponse.self, from: response.data)
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
    
    public func loadTrainStatus(demoMode: Bool, completionHandler: @escaping (TrainStatus?, Error?) -> ()) {
        self.loadDetails(demoMode: demoMode, completionHandler: { (res, err) in
            guard let trainId = res?.trip.trainTypeFull else {
                completionHandler(nil, nil)
                return
            }
        
            completionHandler(NedSpoorConnect.Status(trainId: trainId), nil)
        })
    }
}
