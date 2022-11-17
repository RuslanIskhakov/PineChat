//
//  ChatViewModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

class ChatViewModel: BaseViewModel, ChatViewModelProtocol {
    private let appModel: AppModelProtocol

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    func configureView() {
        
    }
}
