import SwiftUI
import UniformTypeIdentifiers

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var auth: AuthManager
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.forge) private var forge

    @State private var nameDraft = ""
    @State private var isEditingName = false
    @State private var showAvoidSheet = false
    @State private var showEquipmentSheet = false
    @State private var showIntake = false
    @State private var showImporter = false
    @State private var exportURL: IdentifiableURL?
    @State private var importMessage: String?
    @State private var showLogoutConfirm = false
    @State private var showWorkoutsDetail = false
    @State private var showBadgesDetail = false
    @State private var reminderEnabled = ReminderScheduler.isEnabled
    @State private var recapImage: IdentifiableImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                header
                accountCard
                statsRow
                CompletedProgramsCard()
                equipmentCard
                buildPlanCard
                preferencesCard
                avoidCard
                templatesCard
                shareRecapCard
                darebeeCreditCard
                dataCard
                logoutButton
                Spacer(minLength: 90)
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showAvoidSheet) { AvoidExercisesSheet() }
        .sheet(isPresented: $showEquipmentSheet) { MyEquipmentSheet() }
        .sheet(isPresented: $showIntake) { SetupIntakeView() }
        .sheet(isPresented: $showWorkoutsDetail) { TotalWorkoutsDetailSheet() }
        .sheet(isPresented: $showBadgesDetail) { BadgeDetailSheet() }
        .sheet(item: $exportURL) { url in
            ActivityShareSheet(activityItems: [url.url])
        }
        .sheet(item: $recapImage) { item in
            ActivityShareSheet(activityItems: [item.image])
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
            handleImport(result)
        }
        .alert("Import", isPresented: Binding(get: { importMessage != nil }, set: { if !$0 { importMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importMessage ?? "")
        }
    }

    private var equipmentCard: some View {
        Button { showEquipmentSheet = true } label: {
            HStack(spacing: Space.md) {
                CategoryIcon(systemName: "dumbbell.fill", size: 20, tint: forge.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("My Equipment")
                        .font(.forgeBodySemibold(16))
                        .foregroundStyle(forge.textPrimary)
                    Text(appState.hasSetUpEquipment
                         ? "\(appState.availableExerciseCount) of \(ExerciseLibrary.all.count) exercises available"
                         : "Tell FORGE what you have to train with")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(forge.textTertiary)
                    .font(.system(size: 13, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        }
        .buttonStyle(.plain)
    }

    private var buildPlanCard: some View {
        Button { showIntake = true } label: {
            HStack(spacing: Space.md) {
                CategoryIcon(systemName: "wand.and.stars", size: 20, tint: forge.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text(appState.hasCompletedIntake ? "Rebuild My Plan" : "Build My Plan")
                        .font(.forgeBodySemibold(16))
                        .foregroundStyle(forge.textPrimary)
                    Text(appState.hasCompletedIntake
                         ? "Answers changed? Generate a fresh plan"
                         : "Answer a few questions and get a plan built around you")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(forge.textTertiary)
                    .font(.system(size: 13, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        }
        .buttonStyle(.plain)
    }

    /// DAREBEE's licence asks for a mention and a link back rather than silence.
    /// They are a genuinely good free resource and cost nothing to credit.
    private var darebeeCreditCard: some View {
        Link(destination: DarebeeLinks.libraryURL) {
            HStack(spacing: Space.md) {
                CategoryIcon(systemName: "play.rectangle.fill", size: 20, tint: forge.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Exercise videos by DAREBEE")
                        .font(.forgeBodySemibold(16))
                        .foregroundStyle(forge.textPrimary)
                    Text("A free, ad-free, non-profit fitness library. Browse their demonstrations.")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(forge.textTertiary)
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        }
    }

    private var header: some View {
        Text("Profile").font(.forgeHeading(34)).foregroundStyle(forge.textPrimary).padding(.top, Space.md)
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack {
                ZStack {
                    Circle().fill(forge.raised).frame(width: 56, height: 56)
                    Text(String(appState.userData.characterName.prefix(1)).uppercased())
                        .font(.forgeHeading(20)).foregroundStyle(forge.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    if isEditingName {
                        TextField("Character name", text: $nameDraft, onCommit: saveName)
                            .font(.forgeBodySemibold(17))
                            .foregroundStyle(forge.textPrimary)
                    } else {
                        Text(appState.userData.characterName).font(.forgeBodySemibold(17)).foregroundStyle(forge.textPrimary)
                    }
                    Text(auth.currentAccount?.email ?? "").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                }
                Spacer()
                Button {
                    if isEditingName { saveName() } else { nameDraft = appState.userData.characterName; isEditingName = true }
                } label: {
                    Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle")
                        .foregroundStyle(forge.accent)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
            if let created = auth.currentAccount?.createdAt {
                Text("Member since \(created.formatted(.dateTime.month().year()))")
                    .font(.forgeCaption()).foregroundStyle(forge.textTertiary)
            }
        }
        .forgeCard()
    }

    private var statsRow: some View {
        HStack(spacing: Space.md) {
            Button { showWorkoutsDetail = true } label: {
                StatTile(value: "\(appState.totalCompletedWorkouts)", label: "total workouts", icon: "checkmark.seal.fill")
            }
            .buttonStyle(.plain)
            Button { showBadgesDetail = true } label: {
                StatTile(value: "\(appState.userData.game.earnedBadgeIds.count)", label: "badges earned", icon: "rosette")
            }
            .buttonStyle(.plain)
        }
    }

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            Text("Preferences").font(.forgeHeadingMedium(16)).foregroundStyle(forge.textPrimary)

            VStack(alignment: .leading, spacing: Space.sm) {
                Text("Appearance").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                Picker("Theme", selection: $themeManager.mode) {
                    ForEach(ThemeMode.allCases) { mode in Text(mode.label).tag(mode) }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                Text("Units").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                Picker("Units", selection: $appState.userData.unitSystem) {
                    ForEach(UnitSystem.allCases) { u in Text(u.label).tag(u) }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                HStack {
                    Text("Weekly goal").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                    Spacer()
                    Text("\(appState.userData.weeklyGoal) days").font(.forgeBodySemibold(14)).foregroundStyle(forge.textPrimary)
                }
                Stepper("", value: $appState.userData.weeklyGoal, in: 1...7).labelsHidden()
            }

            Toggle(isOn: Binding(
                get: { auth.biometricLockEnabled },
                set: { auth.setBiometricLock($0) }
            )) {
                Label("Unlock with Face ID", systemImage: "faceid")
                    .font(.forgeBodyMedium(15))
                    .foregroundStyle(forge.textPrimary)
            }
            .tint(forge.accent)

            Toggle(isOn: Binding(
                get: { reminderEnabled },
                set: { newValue in
                    let today = appState.checkIn(on: Date())
                    ReminderScheduler.setEnabled(
                        newValue,
                        hydrationDone: today.hydrationCount >= DailyCheckIn.hydrationGoal,
                        sleepDone: today.sleepConfirmed,
                        workoutLoggedToday: appState.dayStatus(for: Date()) != .none
                    ) { granted in
                        reminderEnabled = granted
                    }
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Label("Evening check-in reminder", systemImage: "bell.badge")
                        .font(.forgeBodyMedium(15))
                        .foregroundStyle(forge.textPrimary)
                    Text("8pm, only if water, sleep, or today's workout isn't logged yet")
                        .font(.forgeCaption(11))
                        .foregroundStyle(forge.textSecondary)
                }
            }
            .tint(forge.accent)
        }
        .forgeCard()
    }

    private var avoidCard: some View {
        Button { showAvoidSheet = true } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Exercises to Avoid").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                    Text("\(appState.userData.avoidExerciseIds.count) hidden from Suggest").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(forge.textTertiary).font(.system(size: 13, weight: .semibold))
            }
            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        }
        .buttonStyle(.plain)
    }

    private var templatesCard: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text("Saved Templates").font(.forgeHeadingMedium(16)).foregroundStyle(forge.textPrimary)
            if appState.userData.templates.isEmpty {
                Text("No templates saved yet.").font(.forgeCaption()).foregroundStyle(forge.textTertiary)
            } else {
                ForEach(appState.userData.templates) { template in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.name).font(.forgeBodyMedium(14)).foregroundStyle(forge.textPrimary)
                            Text("\(template.entries.count) exercise(s)").font(.forgeCaption(11)).foregroundStyle(forge.textSecondary)
                        }
                        Spacer()
                        Button {
                            appState.deleteTemplate(template)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(ForgeDestructiveIconButtonStyle())
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .forgeCard()
    }

    private var shareRecapCard: some View {
        Button {
            shareRecap()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share Weekly Recap").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                    Text("Streak, workouts, and category split as an image").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                }
                Spacer()
                Image(systemName: "square.and.arrow.up").foregroundStyle(forge.accent).font(.system(size: 16, weight: .semibold))
            }
            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        }
        .buttonStyle(.plain)
    }

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text("Your Data").font(.forgeHeadingMedium(16)).foregroundStyle(forge.textPrimary)
            HStack(spacing: Space.md) {
                Button {
                    exportData()
                } label: {
                    Text("Export").frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
                Button {
                    showImporter = true
                } label: {
                    Text("Import").frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
            }
        }
        .forgeCard()
    }

    private var logoutButton: some View {
        Button {
            showLogoutConfirm = true
        } label: {
            Text("Log Out").frame(maxWidth: .infinity)
        }
            .forgeGlassSecondary()
            .foregroundStyle(forge.danger)
            .confirmationDialog("Log out of FORGE?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) { auth.logOut() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can log back in anytime — your data stays saved on this device.")
            }
    }

    private func saveName() {
        let trimmed = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { isEditingName = false; return }
        appState.userData.characterName = trimmed
        auth.updateDisplayName(trimmed)
        isEditingName = false
    }

    @MainActor
    private func shareRecap() {
        let card = WeeklyRecapCard()
            .environmentObject(appState)
            .environment(\.forge, forge)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 2
        guard let uiImage = renderer.uiImage else { return }
        recapImage = IdentifiableImage(image: uiImage)
    }

    private func exportData() {
        guard let data = appState.exportJSON() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("FORGE-Export-\(Int(Date().timeIntervalSince1970)).json")
        try? data.write(to: url)
        exportURL = IdentifiableURL(url: url)
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url), appState.importJSON(data) else {
                importMessage = "Couldn't read that file."
                return
            }
            importMessage = "Data imported successfully."
        case .failure:
            importMessage = "Import cancelled."
        }
    }
}

struct IdentifiableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct IdentifiableImage: Identifiable {
    let image: UIImage
    let id = UUID()
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
