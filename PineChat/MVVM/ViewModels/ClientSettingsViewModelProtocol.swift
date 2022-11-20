//
//  ClientSettingsViewModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxRelay

protocol ClientSettingsViewModelProtocol {
    init(with appModel: AppModelProtocol)
    var usernameText: BehaviorRelay<String> {get}
    var ipAddressText: BehaviorRelay<String> {get}
    var portNumberText: BehaviorRelay<String> {get}
    func configureView()
    func setServerIPAddress(_ ipAddress: String)
    func setPortNumber(_ portNumber: String)
    func enterChatTap()
    func setUsername(_ username: String)
}
