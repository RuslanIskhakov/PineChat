//
//  SocketMessages.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import Foundation

protocol SocketMessageParserServerSideDelegate: AnyObject {
    func chatMessagesRequested(_ message: ChatMessagesRequest)
    func chatMessagesPosted(_ message: PostNewChatMessage)
}

protocol SocketMessageParserClientSideDelegate: AnyObject {
    func newChatMessagesAvailable(_ message: NewChatMessagesAvailable)
    func chatMessagesResponse(_ message: ChatMessagesResponse)
}

class SocketMessageCoder {

    weak var clientSideDelegate: SocketMessageParserClientSideDelegate?
    weak var serverSideDelegate: SocketMessageParserServerSideDelegate?

    func encodeMessage(_ message: Encodable) -> Data? {

        guard
            let messageData = try? JSONEncoder().encode(message)
        else { return nil }

        return messageData
    }

    @discardableResult
    func decodeClientMessage(from data: Data) -> Encodable? {

        if let message = try? JSONDecoder().decode(ChatMessagesRequest.self, from: data) {
            self.serverSideDelegate?.chatMessagesRequested(message)
            return message
        } else if let message = try? JSONDecoder().decode(PostNewChatMessage.self, from: data) {
            self.serverSideDelegate?.chatMessagesPosted(message)
            return message
        }
        return nil
    }

    @discardableResult
    func decodeServerMessage(from data: Data) -> Encodable? {

        if let message = try? JSONDecoder().decode(NewChatMessagesAvailable.self, from: data) {
            self.clientSideDelegate?.newChatMessagesAvailable(message)
            return message
        } else if let message = try? JSONDecoder().decode(ChatMessagesResponse.self, from: data) {
            self.clientSideDelegate?.chatMessagesResponse(message)
            return message
            }
        return nil
    }
}

// common messages

// client messages
public struct ChatMessagesRequest: Codable {
    let fromId: String
    let ahead: Bool
    let limit: Int
}

public struct PostNewChatMessage: Codable {
    let userName: String
    let message: String
}

// server messages
public struct PersistantChatMessage: Codable {
    let id: String
    let date: Date?
    let userName: String
    let text: String
}

public struct NewChatMessagesAvailable: Codable {
    let lastMessageId: String
}

public struct ChatMessagesResponse: Codable {
    let fromId: String
    let ahead: Bool
    let chatMessages: [PersistantChatMessage]
}

struct LocationBody: Codable {
    let latitude: Double
    let longitude: Double
}
