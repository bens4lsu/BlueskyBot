//
//  ConfigurationSettings.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//


import Vapor
import NIOSSL

class ConfigurationSettings: Decodable {
    
    struct Database: Decodable {
        let hostname: String
        let port: Int
        let username: String
        let password: String
        let database: String
        let certificateVerificationString: String
    }
    
    struct Bluesky: Decodable {
        let host: String
        let identifier: String
        let password: String
    }
    
    let database: ConfigurationSettings.Database
    let logLevel: String
    let bluesky: Bluesky
    
    
    var certificateVerification: CertificateVerification {
        if database.certificateVerificationString == "noHostnameVerification" {
            return .noHostnameVerification
        }
        else if database.certificateVerificationString == "fullVerification" {
            return .fullVerification
        }
        return .none
    }
    
    var loggerLogLevel: Logger.Level {
        Logger.Level(rawValue: logLevel) ?? .error
    }
    
    init() {
        let path = DirectoryConfiguration.detect().resourcesDirectory
        let url = URL(fileURLWithPath: path).appendingPathComponent("Config.json")
        do {
            let data = try Data(contentsOf: url)
            let decoder = try JSONDecoder().decode(ConfigurationSettings.self, from: data)
            self.database = decoder.database
            self.logLevel = decoder.logLevel
            self.bluesky = decoder.bluesky
        }
        catch {
            print ("Could not initialize app from Config.json. \n \(error)")
            exit(0)
        }
    }
}

