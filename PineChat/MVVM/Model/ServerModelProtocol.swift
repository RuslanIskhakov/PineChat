//
//  ServerModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import Foundation

protocol ServerModelProtocol {
    var appModel: AppModelProtocol? {get set}
    func startServer()
    func stopServer()
}
