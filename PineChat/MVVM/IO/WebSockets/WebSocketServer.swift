
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

class WebSocketServer: BaseIOInitialisable {
    private var listener: NWListener
    private var connectedClients: [NWConnection] = []
    private let serverQueue = DispatchQueue(label: "ServerQueue")

    let lastLocation = BehaviorRelay<LocationBody?>(value: nil)

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
                fatalError("Unable to start WebSocket server on port \(port)")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func startServer() {

        listener.newConnectionHandler = { [weak self ]newConnection in
            guard let self else { return }

            print("New connection connecting")

            func receive() {
                newConnection.receiveMessage { (data, context, isComplete, error) in
                    if let data = data, let context = context {
                        let someMessage = try? self.handleMessageFromClient(data: data, context: context, connection: newConnection)
                        receive()
                    }
                }
            }
            receive()

            newConnection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("Client ready")
                    self.sendConnectionAckToClient(connection: newConnection)
                case .failed(let error):
                    print("Client connection failed \(error.localizedDescription)")
                case .waiting(let error):
                    print("Waiting for long time \(error.localizedDescription)")
                default:
                    break
                }
            }

            newConnection.start(queue: self.serverQueue)
        }

        listener.stateUpdateHandler = { state in
            print(state)
            switch state {
            case .ready:
                print("Server Ready")
            case .failed(let error):
                print("Server failed with \(error.localizedDescription)")
            default:
                break
            }
        }

        listener.start(queue: serverQueue)
    }

    func stopServer() {
        listener.cancel()
    }

    private func sendMessageToClient(data: Data, client: NWConnection) throws {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])

        client.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // no-op
            }
        }))
    }

    private func handleMessageFromClient(data: Data, context: NWConnection.ContentContext, connection: NWConnection) throws -> Bool {

        if let location = try? JSONDecoder().decode(LocationBody.self, from: data) {
            print("dstest received location: \(location)")
            self.sendLocationAckToClient(connection: connection)
            return true
        }

        print("Invalid value from client")
        return false
    }

    private func sendConnectionAckToClient(connection: NWConnection) {

        let model = ConnectionAck(
            t: MessageType.connected.rawValue,
            lastLocation: self.lastLocation.value
        )
        let data = try! JSONEncoder().encode(model)

        try! self.sendMessageToClient(data: data, client: connection)
    }

    private func sendLocationAckToClient(connection: NWConnection) {

        let model = ConnectionAck(
            t: MessageType.locationAck.rawValue,
            lastLocation: self.lastLocation.value
        )
        let data = try! JSONEncoder().encode(model)

        try! self.sendMessageToClient(data: data, client: connection)
    }
}

struct LocationBody: Codable {
    let latitude: Double
    let longitude: Double
}

struct ConnectionAck: Codable {
    let t: String
    let lastLocation: LocationBody?
}

enum MessageType: String {
    case connected = "connect.connected"
    case locationAck = "location.ack"
}

