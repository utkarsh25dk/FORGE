import Foundation
import LocalAuthentication

enum AuthError: LocalizedError {
    case emailInUse
    case invalidCredentials
    case weakPassword
    case invalidEmail
    case nameRequired

    var errorDescription: String? {
        switch self {
        case .emailInUse: return "An account with that email already exists."
        case .invalidCredentials: return "Email or password is incorrect."
        case .weakPassword: return "Password must be at least 6 characters."
        case .invalidEmail: return "Enter a valid email address."
        case .nameRequired: return "Give your character a name."
        }
    }
}

final class AuthManager: ObservableObject {
    @Published private(set) var currentAccount: Account?
    @Published private(set) var biometricLockEnabled: Bool
    /// False while a remembered session is restored but still waiting on Face ID.
    @Published var isUnlocked: Bool = true
    private var accounts: [Account]

    private static let rememberedKey = "forge.rememberedAccountId"
    private static let biometricKey = "forge.biometricLockEnabled"

    init() {
        accounts = Store.loadAccounts()
        biometricLockEnabled = UserDefaults.standard.bool(forKey: Self.biometricKey)
        if let rememberedId = UserDefaults.standard.string(forKey: Self.rememberedKey),
           let account = accounts.first(where: { $0.id == rememberedId }) {
            currentAccount = account
            isUnlocked = !biometricLockEnabled
        }
    }

    var isAuthenticated: Bool { currentAccount != nil }

    static var biometricsAvailable: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    func setBiometricLock(_ enabled: Bool) {
        biometricLockEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Self.biometricKey)
        // Face ID lock only makes sense on top of a remembered session.
        if enabled, let id = currentAccount?.id {
            UserDefaults.standard.set(id, forKey: Self.rememberedKey)
        }
    }

    func authenticateWithBiometrics(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(false, error?.localizedDescription ?? "Face ID isn't set up on this device.")
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock FORGE") { [weak self] success, evalError in
            DispatchQueue.main.async {
                if success { self?.isUnlocked = true }
                completion(success, evalError?.localizedDescription)
            }
        }
    }

    func lock() {
        guard biometricLockEnabled else { return }
        isUnlocked = false
    }

    /// Replaces a legacy SHA-256 record with a PBKDF2 one. Called only after the
    /// password has already been verified.
    private func upgradeStoredPassword(for accountId: String, password: String) {
        guard let idx = accounts.firstIndex(where: { $0.id == accountId }) else { return }
        accounts[idx].passwordHash = PasswordHasher.hash(password)
        accounts[idx].salt = ""
        Store.saveAccounts(accounts)
    }

    private func normalize(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    @discardableResult
    func signUp(email: String, password: String, displayName: String, rememberMe: Bool, enableFaceID: Bool = false) -> Result<Account, AuthError> {
        let normalized = normalize(email)
        guard isValidEmail(normalized) else { return .failure(.invalidEmail) }
        guard password.count >= 6 else { return .failure(.weakPassword) }
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return .failure(.nameRequired) }
        guard !accounts.contains(where: { $0.email == normalized }) else { return .failure(.emailInUse) }

        let account = Account(
            id: UUID().uuidString,
            email: normalized,
            passwordHash: PasswordHasher.hash(password),
            // Only legacy records use this field; the new format carries its
            // own salt inside the hash string.
            salt: "",
            displayName: trimmedName,
            createdAt: Date()
        )
        accounts.append(account)
        Store.saveAccounts(accounts)
        Store.saveUserData(.fresh(accountId: account.id, characterName: trimmedName))

        currentAccount = accounts.first { $0.id == account.id } ?? account
        isUnlocked = true
        if rememberMe {
            UserDefaults.standard.set(account.id, forKey: Self.rememberedKey)
            setBiometricLock(enableFaceID)
        } else {
            setBiometricLock(false)
        }
        return .success(account)
    }

    @discardableResult
    func logIn(email: String, password: String, rememberMe: Bool, enableFaceID: Bool = false) -> Result<Account, AuthError> {
        let normalized = normalize(email)
        guard let account = accounts.first(where: { $0.email == normalized }) else {
            return .failure(.invalidCredentials)
        }
        switch PasswordHasher.verify(password, stored: account.passwordHash, legacySalt: account.salt) {
        case .failed:
            return .failure(.invalidCredentials)
        case .ok:
            break
        case .okNeedsUpgrade:
            // Correct password stored under the old scheme. Rehash now, while we
            // have the plaintext, so the account is upgraded without the user
            // ever being asked to reset anything.
            upgradeStoredPassword(for: account.id, password: password)
        }

        currentAccount = account
        isUnlocked = true
        if rememberMe {
            UserDefaults.standard.set(account.id, forKey: Self.rememberedKey)
            setBiometricLock(enableFaceID)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.rememberedKey)
            setBiometricLock(false)
        }
        return .success(account)
    }

    func logOut() {
        currentAccount = nil
        isUnlocked = true
        UserDefaults.standard.removeObject(forKey: Self.rememberedKey)
        setBiometricLock(false)
    }

    func updateDisplayName(_ name: String) {
        guard var account = currentAccount, let idx = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        account.displayName = name
        accounts[idx] = account
        currentAccount = account
        Store.saveAccounts(accounts)
    }
}
