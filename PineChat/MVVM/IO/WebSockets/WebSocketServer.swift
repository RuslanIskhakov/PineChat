
//
//  WebSocketServer.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//  based on https://github.com/jayesh15111988/SwiftWebSocket/tree/master
//

import Foundation
import Network
import RxSwift
import RxRelay

enum WebSocketServerStateEvents {
    case initial
    case errorMessage(String)
    case error(Error)
    case opened(String)
    case event(String)
}

protocol WebSocketServerDelegate: AnyObject {
    func newClientConnectionEstablished() -> Data?
    func dataReceived(_ data: Data) -> Data?
}

class WebSocketServer: BaseIOInitialisable {
    private var listener: NWListener?
    private var connectedClients: [NWConnection] = []
    private let serverQueue = DispatchQueue(label: "ServerQueue")

    let lastLocation = BehaviorRelay<LocationBody?>(value: nil)
    let stateEvents = BehaviorRelay<WebSocketServerStateEvents>(value: .initial)

    weak var delegate: WebSocketServerDelegate?

    required init(port: UInt16) {

        let parameters = NWParameters(tls: nil)
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true

        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true

        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

        do {
            if let port = NWEndpoint.Port(rawValue: port) {
                listener = try NWListener(using: parameters, on: port)
            } else {
                self.stateEvents.accept(.errorMessage("Unable to start WebSocket server on port \(port)"))
            }
        } catch {
            self.stateEvents.accept(.error(error))
        }
    }


    func startServer() {

        listener?.newConnectionHandler = { [weak self ]newConnection in
            guard let self else { return }

            self.connectedClients.append(newConnection)

            self.stateEvents.accept(.event("New connection"))

            func receive() {
                newConnection.receiveMessage {[unowned self] (data, context, isComplete, error) in
                    guard let data = data, let context = context else { return }

                    print("WebSocketServer: received data of \(data.count)")
                    self.handleReceived(data, for: newConnection)
                    self.serverQueue.asyncAfter(deadline: .now() + .microseconds(1000)) {
                        receive()
                    }
                }
            }
            receive()

            newConnection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    self.stateEvents.accept(.event("Client ready"))
                    self.sendGreetingsMessageTo(newConnection)
                case .failed(let error):
                    self.stateEvents.accept(.error(error))
                case .waiting(let error):
                    self.stateEvents.accept(.error(error))
                default:
                    break
                }
            }

            newConnection.start(queue: self.serverQueue)
        }

        listener?.stateUpdateHandler = { state in
            print(state)
            switch state {
            case .ready:
                self.stateEvents.accept(.opened("Server Ready"))
            case .failed(let error):
                self.stateEvents.accept(.error(error))
            default:
                break
            }
        }

        listener?.start(queue: serverQueue)
    }

    private func handleReceived(_ data: Data, for connection: NWConnection) {
        guard
            let responseData = self.delegate?.dataReceived(data)
        else { return }

        try? self.sendMessageToClient(data: responseData, client: connection)
    }

    private func sendGreetingsMessageTo(_ newConnection: NWConnection) {
        guard
            let data = self.delegate?.newClientConnectionEstablished()
        else { return }

        try? self.sendMessageToClient(data: data, client: newConnection)
    }

    private func sendMessageToClient(data: Data, client: NWConnection) throws {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])

        client.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                print(error.localizedDescription)
            } else {

            }
        }))
    }

    func stopServer() {
        listener?.cancel()
        listener = nil
    }
}


