//
//  AppModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxSwift

class AppModel: BaseModelInitialisable, AppModelProtocol {
    var mode: AppMode? = nil

    var appSettingsModel: AppSettingsModelProtocol
    var connectivityUtils: ConnectivityUtilsProtocol
    var serverModel: ServerModelProtocol
    var clientModel: ClientModelProtocol
    var coreDataModel: CoreDataModelProtocol
    var hapticFeedbackModel: HapticFeedbackModelProtocol

    let serverErrorEvents = PublishSubject<Void>()
    let clientErrorEvents = PublishSubject<Void>()
    let sendMessageErrorEvents = PublishSubject<Void>()

    init(
        coreDataModel: CoreDataModelProtocol,
        appSettingsModel: AppSettingsModelProtocol,
        connectivityUtils: ConnectivityUtilsProtocol,
        serverModel: ServerModelProtocol,
        clientModel: ClientModelProtocol,
        hapticFeedbackModel: HapticFeedbackModelProtocol
    ) {
        self.appSettingsModel = appSettingsModel
        self.connectivityUtils = connectivityUtils
        self.serverModel = serverModel
        self.clientModel = clientModel
        self.coreDataModel = coreDataModel
        self.hapticFeedbackModel = hapticFeedbackModel

        super.init()

        self.appSettingsModel.appModel = self
        self.connectivityUtils.appModel = self
        self.serverModel.appModel = self
        self.clientModel.appModel = self
        self.coreDataModel.appModel = self
        self.hapticFeedbackModel.appModel = self
    }
}
