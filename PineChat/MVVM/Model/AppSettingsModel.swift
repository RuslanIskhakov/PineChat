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

}
