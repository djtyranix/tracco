//
//  UserKeyStore.swift
//  carbonless
//
//  Created by Michael Ricky on 13/06/22.
//

import UIKit

class UserKeyStore: NSObject {
    struct Static {
        static var instance: UserKeyStore?
    }
    
    class var sharedInstance: UserKeyStore {
        if Static.instance == nil {
            Static.instance = UserKeyStore()
        }
        
        return Static.instance!
    }
    
    func disposeSingleton() {
        UserKeyStore.Static.instance = nil
        print("UserKeyStore Disposed")
    }
    
    var keyStore = NSUbiquitousKeyValueStore()
}
