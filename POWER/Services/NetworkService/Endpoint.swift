//
//  Endpoint.swift
//  POWER
//
//  Created by Даниил  on 04.04.2026.
//

import Foundation


// MARK: - Endpoint

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }

    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension Endpoint {

    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Data? { nil }

    var url: URL? {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems
        return components?.url
    }

    var urlRequest: URLRequest? {
        guard let url = url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        headers.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        return request
    }
}
