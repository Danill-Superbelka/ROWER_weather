//
//  NetworkError.swift
//  POWER
//
//  Created by Даниил  on 04.04.2026.
//

import Foundation


// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"

        case .invalidResponse:
            return "Invalid server response"

        case .httpError(let code, _):
            return "Server error (\(code))"

        case .decodingError:
            return "Failed to parse data"

        case .transport(let error):
            return error.localizedDescription
        }
    }
}
