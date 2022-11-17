//
//  ConnectivityUtilsProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

protocol ConnectivityUtilsProtocol {
    var appModel: AppModelProtocol? {get set}
    func getIP() -> String?
    func getServerIpAddressPrefix(for ipAddress: String) -> String
}
