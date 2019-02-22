//
//  SlackKitService.swift
//  App
//
//  Created by Jacob Wilson on 2/21/19.
//

import Vapor
import SlackKit
import Starscream

class SlackKitService: Service {
    var bot: SlackKit

    init() {
        bot = SlackKit()

        registerRTMConnection()
    }

    private func registerRTMConnection() {
        bot.addWebAPIAccessWithToken("xoxp-548586128101-547645124752-557599275843-7f43af1b0a56c236382e22e3f478ca0b")
        bot.addRTMBotWithAPIToken("xoxb-548586128101-557599279299-ZLx0RxuUKQw6vbkPtVsXN0WQ", rtm: MyRTM())

        bot.notificationForEvent(.message) { event, clientConnection in

            guard let channelId = event.channel?.id,
                    let connection = clientConnection,
                    let rtm = connection.rtm else {
                print("Something was null coming back ")
                return
            }

            let text = event.text ?? "Could not read message text"

            do {
                try rtm.sendMessage("Echo: \(text)", channelID: channelId)
            } catch {
                print("Error Sending Message: \(error)")
            }
        }
    }
}

// This is necessary so we can override .webSocket.callbackQueue.
// Need to investigate a better fix 
public class MyRTM: RTMWebSocket, WebSocketDelegate {

    public weak var delegate: RTMDelegate?
    private var webSocket: Starscream.WebSocket?

    public required init() {}

    // MARK: - RTM
    public func connect(url: URL) {
        self.webSocket = WebSocket(url: url)
        self.webSocket?.delegate = self
        self.webSocket?.callbackQueue = DispatchQueue(label: "Another queue")
        self.webSocket?.connect()
    }

    public func disconnect() {
        webSocket?.disconnect()
    }

    public func sendMessage(_ message: String) throws {
        guard webSocket != nil else {
            throw SlackError.rtmConnectionError
        }
        webSocket?.write(string: message)
    }

    public func ping() {
        webSocket?.write(ping: Data())
    }

    // MARK: - WebSocketDelegate
    public func websocketDidConnect(socket: Starscream.WebSocketClient) {
        delegate?.didConnect()
    }

    public func websocketDidDisconnect(socket: Starscream.WebSocketClient, error: Error?) {
        webSocket = nil
        delegate?.disconnected()
    }

    public func websocketDidReceiveMessage(socket: Starscream.WebSocketClient, text: String) {
        delegate?.receivedMessage(text)
    }

    public func websocketDidConnect(socket: Starscream.WebSocket) {
        delegate?.didConnect()
        print("WebSocket Did Connect")
    }

    public func websocketDidReceiveData(socket: Starscream.WebSocketClient, data: Data) {}
}
