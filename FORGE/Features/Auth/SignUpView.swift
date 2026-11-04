import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthManager
    @Environment(\.forge) private var forge
    var switchToLogin: () -> Void

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var rememberMe = true
    @State private var enableFaceID = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            VStack(spacing: Space.md) {
                TextField("Character name", text: $displayName)
                    .textFieldStyle(ForgeTextFieldStyle())
                    .autocorrectionDisabled()
                TextField("Email", text: $email)
                    .textFieldStyle(ForgeTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                PasswordField(placeholder: "Password", text: $password)
                PasswordField(placeholder: "Confirm password", text: $confirmPassword)
            }

            AuthPersistenceOptions(rememberMe: $rememberMe, enableFaceID: $enableFaceID)

            if let errorMessage {
                Text(errorMessage)
                    .font(.forgeCaption())
                    .foregroundStyle(forge.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                submit()
            } label: {
                Text("Create Account").frame(maxWidth: .infinity)
            }
            .forgeGlassPrimary()
            .disabled(displayName.isEmpty || email.isEmpty || password.isEmpty)

            AuthSwitchLink(question: "Already have an account?", action: "Log in", onTap: switchToLogin)
        }
    }

    private func submit() {
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match."
            return
        }
        let result = auth.signUp(email: email, password: password, displayName: displayName, rememberMe: rememberMe, enableFaceID: rememberMe && enableFaceID)
        switch result {
        case .success: errorMessage = nil
        case .failure(let err): errorMessage = err.errorDescription
        }
    }
}
