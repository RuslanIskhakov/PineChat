//
//  ClientModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import Foundation

protocol ClientModelProtocol {
    var appModel: AppModelProtocol? {get set}
    func startClient()
    func stopClient()
}
