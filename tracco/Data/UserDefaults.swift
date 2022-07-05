//
//  UserDefaults.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 22/06/22.
//

import Foundation
import UIKit

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

class SettingsBundle
{
    enum ThemeValue: Int, CaseIterable
    {
        case auto = 0, light = 1, dark = 2
        
        typealias StylingPair = (ThemeValue, UIUserInterfaceStyle)
        
        static let map: [StylingPair] = [(.auto, .unspecified), (.light, .light), (.dark, .dark)]
        
        var style: UIUserInterfaceStyle
        {
            get
            {
                let pair = ThemeValue.map.first(where: { $0.0 == self })
                return pair?.1 ?? .unspecified
            }
            set
            {
                let pair = ThemeValue.map.first(where: { $0.1 == newValue })
                self = pair?.0 ?? .auto
            }
        }
        
        static func from(_ value: Int?) -> ThemeValue
        {
            let theme = self.allCases.first(where: { $0.rawValue == value })
            return theme ?? .auto
        }
    }
    
    @UserDefaultObject<Int?>(key: "settings_theme")
    static var theme
}
