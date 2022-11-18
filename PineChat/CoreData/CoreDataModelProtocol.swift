//
//  CoreDataModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import Foundation

protocol CoreDataModelProtocol {
    var appModel: AppModelProtocol? {get set}
    func getLastMessageId() -> String
}
