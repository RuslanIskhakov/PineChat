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

enum ChatMessageType {
    case incoming
    case outgoing
}

protocol AppModelProtocol: AnyObject {
    var mode: AppMode? {get set}
    var appSettingsModel: AppSettingsModelProtocol {get}
    var connectivityUtils: ConnectivityUtilsProtocol {get}
}
