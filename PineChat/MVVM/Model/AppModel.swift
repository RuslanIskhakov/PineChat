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

    init(
        appSettingsModel: AppSettingsModelProtocol,
        connectivityUtils: ConnectivityUtilsProtocol
    ) {
        self.appSettingsModel = appSettingsModel
        self.connectivityUtils = connectivityUtils

        super.init()

        self.appSettingsModel.appModel = self
        self.connectivityUtils.appModel = self
    }
}
