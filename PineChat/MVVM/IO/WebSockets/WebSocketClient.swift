//
//  WebSocketClient.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxSwift
import RxRelay

enum WebSocketClientStateEvents {
    case initial
    case postChatMessageError
    case errorMessage(String)
    case error(Error)
    case opened(String)
    case event(String)
}

protocol WebSocketClientDelegate: AnyObject {
    func messageReceived(_ data: Data)
}

final class WebSocketClient: NSObject {

    private let queue = DispatchQueue(label: "WebSocketClient", qos: .utility)

    private var webSocket: URLSessionWebSocketTask?

    private var opened = false

    private var urlString = ""

    let stateEvents = BehaviorRelay<WebSocketClientStateEvents>(value: .initial)
    let serverLocation = PublishRelay<LocationBody>()

    weak var delegate: WebSocketClientDelegate?

    init(ipAddress: String, port: String) {
        self.urlString = "ws://\(ipAddress):\(port)"
        print("WebSocketClient init: \(self.urlString)")
    }

    func subscribeToService() {

        self.queue.async {[unowned self] in
            if !self.opened {
                self.openWebSocket()
                self.stateEvents.accept(.opened("WebSocketClient: socket is opened \(String(describing: self.webSocket?.state))"))
            }

            guard let webSocket = self.webSocket else {
                self.stateEvents.accept(.errorMessage("webSocket is nil!!!"))
                return
            }

            webSocket.receive(completionHandler: { [weak self] result in

                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    self.stateEvents.accept(.errorMessage(error.localizedDescription))
                case .success(let webSocketTaskMessage):
                    switch webSocketTaskMessage {
                    case .string:
                        self.stateEvents.accept(.event("string webSocketTaskMessage"))
                    case .data(let data):
                        self.stateEvents.accept(.event("data of \(data.count) bytes length received"))
                        self.delegate?.messageReceived(data)
                        self.subscribeToService()
                    default:
                        self.stateEvents.accept(.event("Failed. Received unknown data format."))
                    }
                }
            })
        }
    }

    func send(_ data: Data, postingChatMessage: Bool = false) {
        self.queue.async {[unowned self] in
            guard let webSocket = self.webSocket else {
                return
            }
            webSocket.send(URLSessionWebSocketTask.Message.data(data)) {error in
                if let error = error {
                    print("send data error: \(error.localizedDescription)")
                    if postingChatMessage {self.stateEvents.accept(.postChatMessageError)}
                }
            }
        }
    }

    private func openWebSocket() {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            self.opened = true
            self.webSocket?.resume()
        } else {
            webSocket = nil
        }
    }

    func closeSocket() {
        self.queue.sync {
            self.webSocket?.cancel(with: .goingAway, reason: nil)
            self.opened = false
            self.webSocket = nil
            print("WebSocketClient: socket is closed")
        }
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        opened = true
    }


    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.webSocket = nil
        self.opened = false
    }
}
