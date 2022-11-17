//
//  ChatMessageEntity.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

public struct ChatMessageEntity {
    let id: String
    let date: Date?
    let userName: String
    let text: String
    let type: ChatMessageType
}
