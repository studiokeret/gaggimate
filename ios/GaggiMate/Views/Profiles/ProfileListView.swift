import SwiftUI

struct ProfileListView: View {
    @EnvironmentObject var service: WebSocketService
    @State private var profiles: [Profile] = []
    @State private var isLoading = false
    @State private var searchText = ""

    private var filteredProfiles: [Profile] {
        if searchText.isEmpty { return profiles }
        return profiles.filter {
            $0.label.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var favoriteProfiles: [Profile] {
        filteredProfiles.filter { $0.favorite == true }
    }

    private var otherProfiles: [Profile] {
        filteredProfiles.filter { $0.favorite != true }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && profiles.isEmpty {
                    ProgressView("Loading profiles...")
                } else if profiles.isEmpty {
                    ContentUnavailableView(
                        "No Profiles",
                        systemImage: "cup.and.saucer",
                        description: Text("Connect to your GaggiMate to see brew profiles")
                    )
                } else {
                    profilesList
                }
            }
            .navigationTitle("Profiles")
            .searchable(text: $searchText, prompt: "Search profiles")
            .refreshable {
                loadProfiles()
            }
        }
        .onAppear {
            loadProfiles()
        }
        .onReceive(NotificationCenter.default.publisher(for: .profilesListReceived)) { notification in
            guard let data = notification.userInfo?["data"] as? Data,
                  let response = try? JSONDecoder().decode(ProfilesListResponse.self, from: data) else { return }
            profiles = response.profiles ?? []
            isLoading = false
        }
    }

    private func loadProfiles() {
        isLoading = true
        service.listProfiles()
    }

    @ViewBuilder
    private var profilesList: some View {
        List {
            if !favoriteProfiles.isEmpty {
                Section("Favorites") {
                    ForEach(favoriteProfiles) { profile in
                        ProfileCardView(
                            profile: profile,
                            isSelected: profile.id == service.status.selectedProfileId,
                            onSelect: { service.selectProfile(id: profile.id) },
                            onToggleFavorite: { toggleFavorite(profile) }
                        )
                    }
                }
            }

            Section(favoriteProfiles.isEmpty ? "All Profiles" : "Other Profiles") {
                ForEach(otherProfiles) { profile in
                    ProfileCardView(
                        profile: profile,
                        isSelected: profile.id == service.status.selectedProfileId,
                        onSelect: { service.selectProfile(id: profile.id) },
                        onToggleFavorite: { toggleFavorite(profile) }
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func toggleFavorite(_ profile: Profile) {
        let isFavorite = profile.favorite ?? false
        service.favoriteProfile(id: profile.id, favorite: !isFavorite)
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index].favorite = !isFavorite
        }
    }
}

struct ProfileCardView: View {
    let profile: Profile
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(profile.label)
                            .font(.headline)

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.subheadline)
                        }

                        Text(profile.type == .pro ? "Pro" : "Simple")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(profile.type == .pro ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                            )
                            .foregroundStyle(profile.type == .pro ? .purple : .blue)
                    }

                    if !profile.description.isEmpty {
                        Text(profile.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(isExpanded ? nil : 1)
                    }
                }

                Spacer()

                Button(action: onToggleFavorite) {
                    Image(systemName: profile.favorite == true ? "star.fill" : "star")
                        .foregroundStyle(profile.favorite == true ? .yellow : .gray)
                }
                .buttonStyle(.plain)
            }

            if let temp = profile.temperature {
                HStack(spacing: 16) {
                    Label(String(format: "%.0f\u{00B0}C", temp), systemImage: "thermometer.medium")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let phases = profile.phases {
                        Label("\(phases.count) phases", systemImage: "list.number")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        let totalDuration = phases.reduce(0) { $0 + $1.duration }
                        Label(String(format: "%.0fs", totalDuration), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if isExpanded, let phases = profile.phases, !phases.isEmpty {
                Divider()
                ForEach(phases) { phase in
                    HStack {
                        Circle()
                            .fill(phase.phase == .preinfusion ? .blue : .brown)
                            .frame(width: 8, height: 8)
                        Text(phase.name)
                            .font(.caption)
                        Spacer()
                        Text(String(format: "%.1fs", phase.duration))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !isSelected {
                Button("Select Profile") {
                    onSelect()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.brown)
                )
                .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}
