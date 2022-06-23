//
//  MoovitAPI.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 08/06/22.
//

import Foundation
import MapKit


// ref: https://moovit.com/developers/deeplinking/
class MoovitAPI
{
    static let moovitServiceURL = URL(string: "moovit://")!
    
    static let moovitAppDownloadURL = URL(string: "https://app.appsflyer.com/id498477945?pid=DL&c=")!
    
    static var canLink: Bool { get { return UIApplication.shared.canOpenURL(moovitServiceURL) }}
}

extension MoovitAPI
{
    class Direction
    {
        static let moovitDirectionURL = URL(string: "moovit://directions")!
        
        enum Token: String, CaseIterable
        {
            case originLatitude         = "orig_lat"
            case originLongitude        = "orig_lon"
            case originName             = "orig_name"
            case destinationLatitude    = "dest_lat"
            case destinationLongitude   = "dest_lon"
            case destinationName        = "dest_name"
            case autoRun                = "auto_run"
            case partnerId              = "partner_id"
            case date                   = "date"
        }
        
        public static func getDirectionsFromCurrent(origName: String?, dest: LocationCoordinate2D, destName: String?, autoRun: Bool = true, date: Date = .init()) -> URL?
        {
            return parser(params: [
                (.originName,           origName),
                (.destinationName,      destName),
                (.destinationLatitude,  String(dest.latitude)),
                (.destinationLongitude, String(dest.longitude)),
                (.autoRun,              String(autoRun)),
                (.partnerId,            nil),
                (.date,                 date.ISO8601Format())
            ])
        }
        
        public static func getDirectionsFrom(orig: LocationCoordinate2D, origName: String?, dest: LocationCoordinate2D, destName: String?, autoRun: Bool = true, date: Date = .init()) -> URL?
        {
            return parser(params: [
                (.originName,           origName),
                (.destinationName,      destName),
                (.originLatitude,       String(orig.latitude)),
                (.originLongitude,      String(orig.longitude)),
                (.destinationLatitude,  String(dest.latitude)),
                (.destinationLongitude, String(dest.longitude)),
                (.autoRun,              String(autoRun)),
                (.partnerId,            nil),
                (.date,                 date.ISO8601Format())
            ])
        }
        
        private static func parser(params: [(Token, String?)]) -> URL?
        {
            var comps = URLComponents(url: moovitDirectionURL, resolvingAgainstBaseURL: true)
            comps?.queryItems = []
            for (key, value) in params
            {
                if (value == nil) { continue }
                let queryItem = URLQueryItem(name: key.rawValue, value: value)
                comps?.queryItems?.append(queryItem)
            }
            return comps?.url
        }
    }
}

extension Date
{
    @available(iOS 10.0, *)
    public func ISO8601Format() -> String
    {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
