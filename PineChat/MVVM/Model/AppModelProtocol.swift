//
//  AppModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

enum AppMode {
    case server
    case client
}

protocol AppModelProtocol: AnyObject {
    var mode: AppMode? {get set}
    var appSettingsModel: AppSettingsModelProtocol {get}
    var connectivityUtils: ConnectivityUtilsProtocol {get}
}
