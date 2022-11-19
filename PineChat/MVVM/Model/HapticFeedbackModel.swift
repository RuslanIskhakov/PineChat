//
//  HapticFeedbackModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 19.11.2022.
//

import UIKit

class HapticFeedbackModel: BaseModelInitialisable, HapticFeedbackModelProtocol {
    var appModel: AppModelProtocol?

    func makeFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
