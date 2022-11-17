//
//  ClientSettingsViewModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxRelay

class ClientSettingsViewModel: BaseViewModel, ClientSettingsViewModelProtocol {

    private let appModel: AppModelProtocol

    let ipAddressText = BehaviorRelay<String>(value: "")
    let portNumberText = BehaviorRelay<String>(value: "")

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    func configureView() {
        self.refreshIPAddress()
    }

    func setServerIPAddress(_ ipAddress: String) {
        var settings = self.appModel.appSettingsModel
        settings.serverIPAddress = ipAddress
    }

    func setPortNumber(_ portNumber: String) {
        var settings = self.appModel.appSettingsModel
        settings.portNumber = portNumber
    }

    func enterChatTap() {
        
    }
}

private extension ClientSettingsViewModel {

    func refreshIPAddress() {
        if let ipAddress = self.appModel.connectivityUtils.getIP() {
            let ipPrefix = self.appModel.connectivityUtils.getServerIpAddressPrefix(for: ipAddress)
            let serverIPAddress = self.appModel.appSettingsModel.serverIPAddress
            self.ipAddressText.accept(
                serverIPAddress.starts(with: ipPrefix) ?
                serverIPAddress :
                ipPrefix
            )
        } else {
            self.ipAddressText.accept("нет подключения")
        }

        self.portNumberText.accept(self.appModel.appSettingsModel.portNumber)
    }
}
