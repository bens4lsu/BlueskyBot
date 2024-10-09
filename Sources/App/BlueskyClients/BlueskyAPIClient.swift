//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation

public class BlueskyAPIClient {
    public let host: String
    public let baseURL: URL

    let jsonEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    let jsonDecoder = JSONDecoder()
    
    public init?(host: String) {
        guard let baseURL = URL(string: "https://\(host)/xrpc") else { return nil }

        self.host = host
        self.baseURL = baseURL
    }

    func postRequest(method: String, data: Encodable) -> URLRequest {
        let url = baseURL.appendingPathComponent(method)
        let encodedData = try! jsonEncoder.encode(data)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func postBlob(method: String, data: Data) -> URLRequest {
        let url = baseURL.appendingPathComponent(method)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        return request
    }

    func send(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode / 100 == 2 {
                return data
            } else {
                throw BlueskyAPIError.invalidCode(response: httpResponse)
            }
        } else {
            throw BlueskyAPIError.invalidResponse(response: response)
        }
    }
}
