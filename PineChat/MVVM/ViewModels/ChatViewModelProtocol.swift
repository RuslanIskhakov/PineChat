//
//  ChatViewModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

protocol ChatViewModelProtocol: AnyObject {
    init(with appModel: AppModelProtocol)

    func configureView()
}
