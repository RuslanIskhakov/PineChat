//
//  ServerSettingsViewModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxRelay

class ServerSettingsViewModel: BaseViewModel, ServerSettingsViewModelProtocol {

    private let appModel: AppModelProtocol

    let ipAddressText = BehaviorRelay<String>(value: "")
    let portNumberText = BehaviorRelay<String>(value: "")

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    func configureView() {
        self.refreshIPAddress()
    }

    func setPortNumber(_ portNumber: String) {
        var settings = self.appModel.appSettingsModel
        settings.portNumber = portNumber
    }

    func startServerTap() {
        self.appModel.mode = .server
    }
}

private extension ServerSettingsViewModel {

    func refreshIPAddress() {
        if let ipAddress = self.appModel.connectivityUtils.getIP() {
            self.ipAddressText.accept(ipAddress)
            self.setPortNumber(self.appModel.appSettingsModel.portNumber)
        } else {
            self.ipAddressText.accept("нет подключения")
        }

        self.portNumberText.accept(self.appModel.appSettingsModel.portNumber)
    }
}
