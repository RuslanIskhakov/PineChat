//
//  ClientSettingsViewModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxRelay

class ClientSettingsViewModel: BaseViewModel, ClientSettingsViewModelProtocol {

    private let appModel: AppModelProtocol

    let usernameText = BehaviorRelay<String>(value: "")
    let ipAddressText = BehaviorRelay<String>(value: "")
    let portNumberText = BehaviorRelay<String>(value: "")

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    func configureView() {
        self.refreshIPAddress()
        self.refreshUsername()
    }

    func setUsername(_ username: String) {
        var settings = self.appModel.appSettingsModel
        settings.username = username
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
        self.appModel.mode = .client
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

    func refreshUsername() {
        let username = self.appModel.appSettingsModel.username
        self.usernameText.accept(username)
    }
}
