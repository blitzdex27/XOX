//
//  RemoteConfigManager.swift
//  XOX
//
//  Created by Dexter on 3/3/26.
//

import FirebaseRemoteConfig
import FirebaseAnalytics

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    private let config = RemoteConfig.remoteConfig()
    
    private(set) var apiKey: String?
    
    func configure() {
        let settings = RemoteConfigSettings()
#if DEBUG
        settings.minimumFetchInterval = 0
#else
        settings.minimumFetchInterval = (60 * 60) / 5.0
#endif
        RemoteConfig.remoteConfig().configSettings = settings
        RemoteConfig.remoteConfig().setDefaults(fromPlist: "remote_config_defaults")
    }
    
    func getQuoteConfig() async -> QuoteConfig? {
        do {
            let fetched = try await config.fetchAndActivate()
            switch fetched {
                
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                return try config["quote_config"].decoded(asType: QuoteConfig.self)
            case .error:
                return nil
            @unknown default:
                return nil
            }
        } catch {
            Analytics.logEvent("getQuoteConfig-error", parameters: [
                "description": error.localizedDescription
            ])
            return nil
        }
    }
}

extension RemoteConfigManager {
    struct QuoteConfig: Codable {
        var customQuote: QuoteModel?
        var apiUrl: String?
        var headers: [HeaderEntry]?
        
        func getHeaderDictionary() -> [String: String]? {
            headers?.reduce(into: [:]) { partialResult, entry in
                partialResult[entry.key] = entry.value
            }
        }
    }
    
    struct HeaderEntry: Codable {
        let key: String
        let value: String
    }
}
