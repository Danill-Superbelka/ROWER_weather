import Foundation
import OSLog

// MARK: - Network Service
protocol NetworkServicing {
    func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        retries: Int
    ) async throws(NetworkError) -> T
}

final class NetworkService: NetworkServicing {

    static let shared = NetworkService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger: Logger

    // MARK: - Init

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "NETWORK",
            category: "API"
        )
    }

    // MARK: - Public

    func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        retries: Int = 1
    ) async throws(NetworkError) -> T {

        guard let request = endpoint.urlRequest else {
            throw .invalidURL
        }

        return try await perform(request: request, retries: retries)
    }

    // MARK: - Internal

    private func perform<T: Decodable & Sendable>(
        request: URLRequest,
        retries: Int
    ) async throws(NetworkError) -> T {

        let start = CFAbsoluteTimeGetCurrent()

        do {
            logRequest(request)

            let (data, response) = try await session.data(for: request)

            logResponse(response, data: data, start: start)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.httpError(
                    statusCode: http.statusCode,
                    data: data
                )
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }

        } catch let error as NetworkError {
            throw error

        } catch {
            if retries > 0 {
                logger.debug("🔁 Retry left: \(retries)")
                return try await perform(request: request, retries: retries - 1)
            }

            throw NetworkError.transport(error)
        }
    }

    // MARK: - Logging

    private func logRequest(_ request: URLRequest) {
        logger.debug("➡️ \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("📦 Headers: \(headers)")
        }

        if let body = request.httpBody,
           let string = String(data: body, encoding: .utf8) {
            logger.debug("📨 Body: \(string)")
        }
    }

    private func logResponse(
        _ response: URLResponse,
        data: Data,
        start: CFAbsoluteTime
    ) {
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        guard let http = response as? HTTPURLResponse else {
            logger.error("❌ Invalid response")
            return
        }

        logger.debug("⬅️ Status: \(http.statusCode) in \(elapsed, format: .fixed(precision: 3))s")

        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let string = String(data: pretty, encoding: .utf8) {
            logger.debug("📄 \(string)")
        }
    }
}
