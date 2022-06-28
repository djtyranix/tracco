//
//  UserDefaults.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 22/06/22.
//

import Foundation

@propertyWrapper
struct UserDefault<T: Codable>
{
    let key: String
    var wrappedValue: T?
    {
        get
        {
            do
            {
                guard let data = UserDefaults.standard.object(forKey: key) as? Data
                else { return nil }
                let user = try PropertyListDecoder().decode(T.self, from: data)
                return user
            }
            catch { print("UserDefault get err: \(error)") }
            return nil
        }
        set
        {
            do
            {
                let encoded = try PropertyListEncoder().encode(newValue!)
                UserDefaults.standard.set(encoded, forKey: key)
            }
            catch { print("UserDefault set err: \(error)") }
        }
    }
}

@propertyWrapper
struct UserDefaultObject<T: Any>
{
    let key: String
    var wrappedValue: T
    {
        get { return UserDefaults.standard.object(forKey: key) as! T }
        set { UserDefaults.standard.set(newValue as Any, forKey: key) }
    }
}

class StoredModel
{
    @UserDefault<[TripModel]>(key: "history_model")
    static var history
    
    @UserDefault<ProfileModel>(key: "profile_model")
    static var profile
    
    @UserDefaultObject<Bool?>(key: "show_route_recommendation")
    static var showRouteRecommendation
}
