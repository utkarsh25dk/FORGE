import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthManager
    @Environment(\.forge) private var forge
    var switchToSignUp: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = true
    @State private var enableFaceID = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            VStack(spacing: Space.md) {
                TextField("Email", text: $email)
                    .textFieldStyle(ForgeTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                PasswordField(placeholder: "Password", text: $password)
            }

            Toggle(isOn: $rememberMe) {
                Text("Remember me").font(.forgeBodyMedium(14)).foregroundStyle(forge.textSecondary)
            }
            .tint(forge.accent)

            if rememberMe {
                Toggle(isOn: $enableFaceID) {
                    Label("Unlock with Face ID", systemImage: "faceid")
                        .font(.forgeBodyMedium(14))
                        .foregroundStyle(forge.textSecondary)
                }
                .tint(forge.accent)
                .transition(.opacity)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.forgeCaption())
                    .foregroundStyle(forge.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                submit()
            } label: {
                Text("Log In").frame(maxWidth: .infinity)
            }
            .forgeGlassPrimary()
            .disabled(email.isEmpty || password.isEmpty)

            Button("Don't have an account? Sign Up", action: switchToSignUp)
                .font(.forgeBodyMedium(14))
                .foregroundStyle(forge.accent)
        }
        .padding(.horizontal, Space.xl)
    }

    private func submit() {
        let result = auth.logIn(email: email, password: password, rememberMe: rememberMe, enableFaceID: rememberMe && enableFaceID)
        switch result {
        case .success: errorMessage = nil
        case .failure(let err): errorMessage = err.errorDescription
        }
    }
}
