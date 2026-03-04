//
//  AppLinks.swift
//  XOX
//
//  Created by Codex on 3/4/26.
//

import Foundation

enum AppLinks {
    private static let baseURLString = "https://blitzdex27.github.io/XOX"

    static var baseURL: URL {
        URL(string: baseURLString)!
    }

    static var privacyPolicyURL: URL {
        baseURL.appendingPathComponent("privacy/")
    }

    static var supportURL: URL {
        baseURL.appendingPathComponent("contact/")
    }
}
