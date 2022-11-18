//
//  AppModelConfigurator.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

class AppModelConfigurator {
    static func configure() -> AppModelProtocol {
        AppModel(
            coreDataModel: CoreDataModel(),
            appSettingsModel: AppSettingsModel(),
            connectivityUtils: ConnectivityUtils(),
            serverModel: ServerModel(),
            clientModel: ClientModel()
        )
    }
}
