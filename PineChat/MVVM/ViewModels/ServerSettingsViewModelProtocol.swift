//
//  ServerSettingsViewModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxRelay

protocol ServerSettingsViewModelProtocol {
    init(with appModel: AppModelProtocol)
    var ipAddressText: BehaviorRelay<String> {get}
    var portNumberText: BehaviorRelay<String> {get}
    func configureView()
    func setPortNumber(_ portNumber: String)
    func startServerTap()
}
