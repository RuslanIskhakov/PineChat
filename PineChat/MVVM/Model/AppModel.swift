//
//  AppModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

class AppModel: BaseModelInitialisable, AppModelProtocol {
    var mode: AppMode? = nil

    var appSettingsModel: AppSettingsModelProtocol
    var connectivityUtils: ConnectivityUtilsProtocol
    var serverModel: ServerModelProtocol

    init(
        appSettingsModel: AppSettingsModelProtocol,
        connectivityUtils: ConnectivityUtilsProtocol,
        serverModel: ServerModelProtocol
    ) {
        self.appSettingsModel = appSettingsModel
        self.connectivityUtils = connectivityUtils
        self.serverModel = serverModel

        super.init()

        self.appSettingsModel.appModel = self
        self.connectivityUtils.appModel = self
        self.serverModel.appModel = self
    }
}
