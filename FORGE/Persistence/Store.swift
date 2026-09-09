import Foundation
import CryptoKit

enum Store {
    private static var supportDir: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FORGE", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private static var accountsURL: URL { supportDir.appendingPathComponent("accounts.json") }
    private static func userDataURL(_ accountId: String) -> URL {
        supportDir.appendingPathComponent("user_\(accountId).json")
    }

    // MARK: Accounts

    static func loadAccounts() -> [Account] {
        guard let data = try? Data(contentsOf: accountsURL) else { return [] }
        return (try? JSONDecoder.forge.decode([Account].self, from: data)) ?? []
    }

    static func saveAccounts(_ accounts: [Account]) {
        guard let data = try? JSONEncoder.forge.encode(accounts) else { return }
        try? data.write(to: accountsURL, options: .atomic)
    }

    // MARK: User data

    static func loadUserData(accountId: String) -> UserData? {
        guard let data = try? Data(contentsOf: userDataURL(accountId)) else { return nil }
        return try? JSONDecoder.forge.decode(UserData.self, from: data)
    }

    static func saveUserData(_ userData: UserData) {
        guard let data = try? JSONEncoder.forge.encode(userData) else { return }
        try? data.write(to: userDataURL(userData.accountId), options: .atomic)
    }

    // MARK: Export / Import

    static func exportData(_ userData: UserData) -> Data? {
        try? JSONEncoder.forge.encode(userData)
    }

    static func importData(_ data: Data) -> UserData? {
        try? JSONDecoder.forge.decode(UserData.self, from: data)
    }
}

extension JSONEncoder {
    static let forge: JSONEncoder = {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return enc
    }()
}

extension JSONDecoder {
    static let forge: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }()
}
