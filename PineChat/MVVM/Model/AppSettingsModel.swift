//
//  AppSettingsModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

class AppSettingsModel: BaseModelInitialisable, AppSettingsModelProtocol {

    private let defaults = UserDefaults.standard

    private let serverIPAddressKey = "serveripaddress"
    private let portNumberKey = "portnumber"
    private let usernameKey = "username"

    weak var appModel: AppModelProtocol?
    
    var serverIPAddress: String {
        set {
            self.defaults.set(newValue, forKey: self.serverIPAddressKey)
        }
        get {
            return self.defaults.string(forKey: self.serverIPAddressKey) ?? ""
        }
    }

    var portNumber: String {
        set {
            self.defaults.set(newValue, forKey: self.portNumberKey)
        }
        get {
            return self.defaults.string(forKey: self.portNumberKey) ?? "8080"
        }
    }

    var username: String {
        set {
            self.defaults.set(newValue, forKey: self.usernameKey)
        }
        get {
            return self.defaults.string(forKey: self.usernameKey) ?? ""
        }
    }

}
