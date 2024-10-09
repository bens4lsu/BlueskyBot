//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//



import Foundation
import Logging

struct LoginData: Encodable {
    let identifier: String
    let password: String
}

struct CreateRecordData: Encodable {
    let repo: String
    let collection: String
    let record: PostData
}

    
struct ImageEmbed: Encodable {
        
    struct ImageRef: Encodable {
        let link: String
    }
    
    struct ImageInner: Encodable {
        let type = "blob"
        let ref: ImageRef
        let mimeType = "image/webp"
        let size: Int
    }
    
    struct ImageOuter: Encodable {
        let alt: String
        let image: ImageInner
    }
    
    struct Images: Encodable {
        let images: [ImageOuter]
    }

    let type = "app.bsky.embed.images"
    let embed: Images
    
}

struct LinkEmbed {
    
    struct Link: Encodable {
        let description: String
        let title: String
        let uri: String
    }
    
    let type = "app.bsky.embed.external"
    let external: Link
    
    init(description: String, title: String, uri: String) {
        self.external = Link(description: description, title: title, uri: uri)
    }
}

extension LinkEmbed: Encodable {
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case external
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(external, forKey: .external)
    }
}

// MARK: PostData

struct PostData {
    let text: String
    let createdAt: Date
    let embed: Encodable
}

extension PostData: Encodable {
    enum CodingKeys: String, CodingKey {
        case text
        case createdAt
        case embed
        //case imageEmbed
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(createdAt, forKey: .createdAt)

        if embed is LinkEmbed {
            let tmpEmbed = embed as! LinkEmbed
            try container.encode(tmpEmbed, forKey: .embed)
        }
    }
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
    
    private func postImage(data: Data) async throws -> Data {
        var request = super.postBlob(method: "com.atproto.repo.uploadBlob", data: data)
        request.setValue("Bearer \(credentials.accessJwt)", forHTTPHeaderField: "Authorization")
        return try await send(request)
    }

    public func createPost(text: String, link: String, dateString: String, imageFilePath: String) async throws {

        let imageData = try Data(contentsOf: URL(filePath: "Public/" + imageFilePath))
        let postImageData = try await postImage(data: imageData)
        
        print(String(data: postImageData, encoding: .utf8)!)
        
        let linkEmbed = LinkEmbed(description: "", title: "Picture of the Day from \(dateString)", uri: link)

        let post = PostData(text: text, createdAt: Date(), embed: linkEmbed)

        let json = try jsonEncoder.encode(post)
        let jsonString = String(data: json, encoding: .utf8)

        print (jsonString ?? "nil")
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
