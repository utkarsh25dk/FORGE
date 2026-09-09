import Foundation
import CommonCrypto
import Security

/// Password hashing for local accounts.
///
/// The original implementation ran a single SHA-256 pass over salt + password.
/// SHA-256 is designed to be fast, which is exactly wrong for passwords: a
/// commodity GPU tries billions of candidates a second against it. This uses
/// PBKDF2-HMAC-SHA256 with a deliberately large iteration count so each guess
/// costs real time.
///
/// PBKDF2 rather than Argon2 or bcrypt because it ships in CommonCrypto. The
/// project has no package manager, and adding one to get a hashing library is a
/// bigger change than this fix warrants — PBKDF2 at this iteration count remains
/// an accepted choice.
enum PasswordHasher {

    /// OWASP's current figure for PBKDF2-HMAC-SHA256. Measured at roughly 65 ms
    /// on an M-series Mac, so on the order of 100-150 ms on a phone: unnoticeable
    /// when logging in once, expensive when guessing.
    static let iterations: UInt32 = 600_000
    private static let saltBytes = 16
    private static let keyBytes = 32
    private static let prefix = "pbkdf2-sha256"

    // MARK: Hashing

    /// Produces a self-describing hash: `pbkdf2-sha256$<iterations>$<salt>$<key>`.
    /// Storing the parameters alongside the digest means the iteration count can
    /// be raised later without stranding existing accounts.
    static func hash(_ password: String) -> String {
        let salt = randomSalt()
        let key = derive(password, salt: salt, iterations: iterations)
        return "\(prefix)$\(iterations)$\(Data(salt).base64EncodedString())$\(Data(key).base64EncodedString())"
    }

    enum Verification {
        case failed
        case ok
        /// Correct, but stored in the old format — rehash and save.
        case okNeedsUpgrade
    }

    /// Verifies against either format. Legacy records are bare SHA-256 hex with
    /// the salt held separately on the account.
    static func verify(_ password: String, stored: String, legacySalt: String) -> Verification {
        if stored.hasPrefix(prefix + "$") {
            let parts = stored.split(separator: "$", omittingEmptySubsequences: false)
            guard parts.count == 4,
                  let iterations = UInt32(parts[1]),
                  let salt = Data(base64Encoded: String(parts[2])),
                  let expected = Data(base64Encoded: String(parts[3])) else { return .failed }
            let actual = derive(password, salt: [UInt8](salt), iterations: iterations)
            return constantTimeEquals(actual, [UInt8](expected)) ? .ok : .failed
        }

        // Legacy: single SHA-256 over salt + password, hex encoded.
        let legacy = legacyHash(password, salt: legacySalt)
        return constantTimeEquals(Array(legacy.utf8), Array(stored.utf8)) ? .okNeedsUpgrade : .failed
    }

    // MARK: Primitives

    private static func derive(_ password: String, salt: [UInt8], iterations: UInt32) -> [UInt8] {
        var out = [UInt8](repeating: 0, count: keyBytes)
        let pw = Array(password.utf8)
        _ = pw.withUnsafeBufferPointer { p in
            salt.withUnsafeBufferPointer { s in
                p.baseAddress!.withMemoryRebound(to: CChar.self, capacity: pw.count) { pwChars in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        pwChars, pw.count,
                        s.baseAddress!, salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), iterations,
                        &out, out.count
                    )
                }
            }
        }
        return out
    }

    /// `SecRandomCopyBytes` rather than a UUID. A UUID is a unique identifier,
    /// not a guaranteed source of cryptographic randomness, and its string form
    /// carries far less entropy per character than raw bytes.
    private static func randomSalt() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: saltBytes)
        if SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) != errSecSuccess {
            // Never expected on Apple platforms; fall back rather than ship a
            // predictable salt.
            bytes = (0..<saltBytes).map { _ in UInt8.random(in: 0...255) }
        }
        return bytes
    }

    /// Compares every byte regardless of where the first difference is, so the
    /// time taken doesn't leak how much of a guess was correct.
    private static func constantTimeEquals(_ a: [UInt8], _ b: [UInt8]) -> Bool {
        guard a.count == b.count else { return false }
        var diff: UInt8 = 0
        for i in 0..<a.count { diff |= a[i] ^ b[i] }
        return diff == 0
    }

    /// The original scheme, kept only so existing accounts can still log in once
    /// and be upgraded. Never used to store anything new.
    private static func legacyHash(_ password: String, salt: String) -> String {
        var ctx = CC_SHA256_CTX()
        CC_SHA256_Init(&ctx)
        let data = Array((salt + password).utf8)
        _ = data.withUnsafeBufferPointer { CC_SHA256_Update(&ctx, $0.baseAddress, CC_LONG(data.count)) }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256_Final(&digest, &ctx)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
