import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) var appState
    @State private var showDebug = false

    var body: some View {
        @Bindable var appState = appState
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(SceneCategory.allCases, id: \.self) { category in
                                Button {
                                    appState.selectedCategory = category
                                } label: {
                                    Label(category.rawValue, systemImage: category.iconName)
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            appState.selectedCategory == category
                                                ? Color.accentColor
                                                : Color.sfSurface
                                        )
                                        .foregroundStyle(Color.sfTextPrimary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Scene Grid
                    let scenes = SceneCatalog.scenes(for: appState.selectedCategory)
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 12
                    ) {
                        ForEach(scenes) { scene in
                            SceneCard(scene: scene)
                                .overlay(alignment: .topTrailing) {
                                    if scene.isPremium {
                                        Image(systemName: "lock.fill")
                                            .font(.caption)
                                            .padding(6)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                            .padding(8)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color.sfBackground.ignoresSafeArea())
            .navigationTitle("SoundFlow")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDebug = true
                    } label: {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundStyle(Color.sfTextSecondary)
                    }
                }
            }
            .sheet(isPresented: $showDebug) {
                AudioDebugView()
            }
        }
    }
}
