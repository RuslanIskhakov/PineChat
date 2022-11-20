//
//  AppSettingsModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

protocol AppSettingsModelProtocol {
    var appModel: AppModelProtocol? {get set}

    var username: String {get set}
    var serverIPAddress: String {get set}
    var portNumber: String {get set}
}
