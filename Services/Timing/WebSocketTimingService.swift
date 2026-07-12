import Foundation

/// Connects to a live F1 timing feed via WebSocket.
///
/// Replace `mockWSURL` with the real timing feed endpoint when available.
/// The parser layer converts raw messages into ``TimingSnapshot``.
final class WebSocketTimingService: NSObject, TimingDataSource, @unchecked Sendable {
    var onSnapshot: (@Sendable (TimingSnapshot) -> Void)?
    var onConnectionStateChange: (@Sendable (ConnectionState) -> Void)?

    private var webSocketTask: URLSessionWebSocketTask?
    private let parser: TimingPacketParser
    private let urlSession: URLSession

    init(parser: TimingPacketParser = DefaultTimingParser()) {
        self.parser = parser
        self.urlSession = URLSession(
            configuration: .default,
            delegate: nil,
            delegateQueue: .main
        )
        super.init()
    }

    func connect(to sessionId: String) {
        onConnectionStateChange?(.connecting)

        // TODO: Replace with real F1 timing endpoint
        let mockWSURL = URL(string: "wss://timing.f1timing.app/session/\(sessionId)")!
        var request = URLRequest(url: mockWSURL)
        request.timeoutInterval = 15

        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        onConnectionStateChange?(.connected)

        receive()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        onConnectionStateChange?(.disconnected)
    }

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                self.handle(message)
                self.receive() // continue listening

            case .failure(let error):
                self.onConnectionStateChange?(.error(error))
                self.scheduleReconnect()
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            if let snapshot = try? parser.parse(data) {
                onSnapshot?(snapshot)
            }
        case .string(let text):
            if let data = text.data(using: .utf8),
               let snapshot = try? parser.parse(data) {
                onSnapshot?(snapshot)
            }
        @unknown default:
            break
        }
    }

    /// Exponential backoff reconnect (5s / 10s / 20s / 30s cap).
    private var reconnectAttempts = 0
    private let maxReconnectDelay: TimeInterval = 30

    private func scheduleReconnect() {
        guard reconnectAttempts < 5 else { return }

        let delay = min(
            TimeInterval(pow(2.0, Double(reconnectAttempts))) * 5,
            maxReconnectDelay
        )
        reconnectAttempts += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            // reconnect logic would pick up the current sessionId
        }
    }
}

// MARK: - Packet Parser

protocol TimingPacketParser: Sendable {
    func parse(_ data: Data) throws -> TimingSnapshot
}

/// Default JSON parser for the timing feed.
/// Adjust mapping fields to match the actual feed schema.
struct DefaultTimingParser: TimingPacketParser {
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func parse(_ data: Data) throws -> TimingSnapshot {
        try decoder.decode(TimingSnapshot.self, from: data)
    }
}
