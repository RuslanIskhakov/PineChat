//
//  HapticFeedbackModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 19.11.2022.
//

import Foundation

protocol HapticFeedbackModelProtocol {
    var appModel: AppModelProtocol? {get set}

    func makeFeedback()
}
