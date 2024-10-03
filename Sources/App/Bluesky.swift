//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//



import Foundation

struct LoginData: Encodable {
    let identifier: String
    let password: String
}

struct CreateRecordData: Encodable {
    let repo: String
    let collection: String
    let record: PostData
}

struct PostData: Encodable {
    let text: String
    let createdAt: Date
}

public struct Credentials: Decodable {
    let did: String
    let handle: String
    let accessJwt: String
}

public enum BlueskyAPIError: LocalizedError, CustomStringConvertible {
    case invalidCode(response: HTTPURLResponse)
    case invalidResponse(response: URLResponse)

    public var description: String {
        switch self {
            case .invalidCode(let response):
                return "BlueskyAPIError.invalidCode(status: \(response.statusCode))"
            case .invalidResponse(let response):
                return "BlueskyAPIError.invalidResponse(\(response))"
        }
    }

    public var errorDescription: String? {
        return description
    }
}

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

public class BlueskyAuthentication: BlueskyAPIClient {

    public func getAuthenticatedClient(credentials: Credentials) -> BlueskyClient {
        return BlueskyClient(host: host, credentials: credentials)!
    }

    public func logIn(identifier: String, password: String) async throws -> Credentials {
        let params = LoginData(
            identifier: identifier,
            password: password
        )

        let request = postRequest(method: "com.atproto.server.createSession", data: params)
        let data = try await send(request)

        // TODO: the JSON object includes "accessJwt" and "refreshJwt"; this probably needs
        // to be extended with support for refreshing tokens periodically when they expire
      
        return try jsonDecoder.decode(Credentials.self, from: data)
    }
}

public class BlueskyClient: BlueskyAPIClient {

    public var credentials: Credentials

    public init?(host: String, credentials: Credentials) {
        self.credentials = credentials

        super.init(host: host)
    }

    public func createPost(text: String) async throws {
        let post = PostData(text: text, createdAt: Date())
        let record = CreateRecordData(
            repo: credentials.did,
            collection: "app.bsky.feed.post",
            record: post
        )

        let request = postRequest(method: "com.atproto.repo.createRecord", data: record)
        let _ = try await send(request)
    }

    override func postRequest(method: String, data: Encodable) -> URLRequest {
        var request = super.postRequest(method: method, data: data)
        request.setValue("Bearer \(credentials.accessJwt)", forHTTPHeaderField: "Authorization")
        return request
    }
}
