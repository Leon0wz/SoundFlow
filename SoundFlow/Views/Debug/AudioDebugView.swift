import SwiftUI

/// Debug view for verifying Phase 3 acceptance criteria.
/// Access via the wrench button in HomeView toolbar.
struct AudioDebugView: View {
    @Environment(AudioEngine.self) var engine
    @State private var currentType: GeneratorType? = nil
    @State private var currentSceneID: String? = nil
    @State private var isStressTesting = false
    @State private var stressTestCount = 0
    @State private var fadeProgress: Double = 0
    @State private var isFading = false
    @State private var stressTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            List {
                statusSection
                controlsSection
                scenesSection
                generatorSection(title: "Rauschen", types: [.whiteNoise, .pinkNoise, .brownNoise])
                generatorSection(title: "Regen", types: [.drizzle, .rain, .heavyRain])
                generatorSection(title: "Wasser", types: [.ocean, .waves, .stream, .river, .waterfall, .underwater])
                generatorSection(title: "Wind & Wetter", types: [.breeze, .wind, .gust, .thunder])
                generatorSection(title: "Natur", types: [.birds, .crickets, .frogs, .forest, .jungle])
                generatorSection(title: "Feuer", types: [.fire, .campfire])
                generatorSection(title: "Atmosphäre", types: [.city, .cafe, .traffic, .space, .drone])
                generatorSection(title: "Ambient", types: [.cave, .drops, .pad, .ambient, .binaural])
                stressTestSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.sfBackground)
            .navigationTitle("Audio Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.sfSurface, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        Section {
            HStack(spacing: 12) {
                Circle()
                    .fill(engine.isRunning ? Color.sfSuccess : Color.sfTextSecondary)
                    .frame(width: 10, height: 10)
                    .shadow(color: engine.isRunning ? Color.sfSuccess : .clear, radius: 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text(engine.isRunning ? "Läuft" : "Gestoppt")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(engine.isRunning ? Color.sfSuccess : Color.sfTextSecondary)
                    if let type = currentType {
                        Text(type.displayName)
                            .font(.caption)
                            .foregroundStyle(Color.sfTextSecondary)
                    } else if let id = currentSceneID {
                        Text("Szene: \(id)")
                            .font(.caption)
                            .foregroundStyle(Color.sfTextSecondary)
                    }
                }

                Spacer()

                if isFading {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Fade Out")
                            .font(.caption)
                            .foregroundStyle(Color.sfWarning)
                        ProgressView(value: fadeProgress)
                            .tint(Color.sfWarning)
                            .frame(width: 80)
                    }
                }
            }
            .listRowBackground(Color.sfSurface)
        } header: {
            sectionHeader("Status")
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        Section {
            // Stop
            Button {
                stopAll()
            } label: {
                Label("Stop sofort", systemImage: "stop.fill")
                    .foregroundStyle(Color.red)
            }
            .listRowBackground(Color.sfSurface)

            // FadeOut 5s (Schnelltest)
            Button {
                startFade(duration: 5)
            } label: {
                Label("Fade Out — 5 Sek (Schnelltest)", systemImage: "speaker.slash.fill")
                    .foregroundStyle(Color.sfWarning)
            }
            .disabled(!engine.isRunning || isFading)
            .listRowBackground(Color.sfSurface)

            // FadeOut 30s (Produktion)
            Button {
                startFade(duration: 30)
            } label: {
                Label("Fade Out — 30 Sek (Produktion)", systemImage: "speaker.slash")
                    .foregroundStyle(Color.sfWarning)
            }
            .disabled(!engine.isRunning || isFading)
            .listRowBackground(Color.sfSurface)
        } header: {
            sectionHeader("Steuerung")
        }
    }

    // MARK: - Scenes

    private var scenesSection: some View {
        Section {
            ForEach(SceneCatalog.allScenes) { scene in
                Button {
                    playScene(scene)
                } label: {
                    HStack {
                        Image(systemName: scene.iconName)
                            .frame(width: 28)
                            .foregroundStyle(Color.sfPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(scene.name)
                                .foregroundStyle(Color.sfTextPrimary)
                            Text("\(scene.layers.count) Layer\(scene.layers.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(Color.sfTextSecondary)
                        }
                        Spacer()
                        if scene.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(Color.sfWarning)
                        }
                        if currentSceneID == scene.id && engine.isRunning {
                            playingIndicator
                        }
                    }
                }
                .listRowBackground(Color.sfSurface)
            }
        } header: {
            sectionHeader("Szenen (echte Multi-Layer)")
        }
    }

    // MARK: - Generator Rows

    private func generatorSection(title: String, types: [GeneratorType]) -> some View {
        Section {
            ForEach(types, id: \.self) { type in
                Button {
                    playSingleGenerator(type)
                } label: {
                    HStack {
                        Image(systemName: type.iconName)
                            .frame(width: 28)
                            .foregroundStyle(Color.sfSecondary)
                        Text(type.displayName)
                            .foregroundStyle(Color.sfTextPrimary)
                        Spacer()
                        if currentType == type && engine.isRunning && currentSceneID == nil {
                            playingIndicator
                        }
                    }
                }
                .listRowBackground(Color.sfSurface)
            }
        } header: {
            sectionHeader(title)
        }
    }

    // MARK: - Stress Test

    private var stressTestSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Startet/stoppt Audio 10× in schneller Folge. Kein Knacksen, kein Absturz = bestanden.")
                    .font(.caption)
                    .foregroundStyle(Color.sfTextSecondary)

                HStack {
                    Button {
                        runStressTest()
                    } label: {
                        Label(
                            isStressTesting ? "Läuft… (\(stressTestCount)/10)" : "Stresstest starten",
                            systemImage: isStressTesting ? "bolt.fill" : "bolt"
                        )
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.sfTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isStressTesting ? Color.sfWarning : Color.sfPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(isStressTesting)

                    if isStressTesting {
                        Button {
                            stressTask?.cancel()
                            isStressTesting = false
                            stressTestCount = 0
                            engine.stop()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.red)
                                .font(.title2)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.sfSurface)
        } header: {
            sectionHeader("Glitch-Test (Start/Stop Spam)")
        }
    }

    // MARK: - Helpers

    private var playingIndicator: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.sfSuccess)
                    .frame(width: 3, height: 8 + CGFloat(i) * 4)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.sfTextSecondary)
            .textCase(nil)
    }

    private func playSingleGenerator(_ type: GeneratorType) {
        isFading = false
        fadeProgress = 0
        currentSceneID = nil
        currentType = type
        let scene = SoundScene(
            id: "debug_\(type.rawValue)",
            name: type.displayName,
            subtitle: "",
            category: .relax,
            layers: [SoundLayer(generatorType: type)],
            isPremium: false,
            gradientColors: [],
            iconName: type.iconName
        )
        engine.play(scene: scene)
    }

    private func playScene(_ scene: SoundScene) {
        isFading = false
        fadeProgress = 0
        currentType = nil
        currentSceneID = scene.id
        engine.play(scene: scene)
    }

    private func stopAll() {
        isFading = false
        fadeProgress = 0
        currentType = nil
        currentSceneID = nil
        stressTask?.cancel()
        isStressTesting = false
        stressTestCount = 0
        engine.stop()
    }

    private func startFade(duration: Double) {
        isFading = true
        fadeProgress = 0
        let steps = 30
        let interval = duration / Double(steps)
        var step = 0

        // Animate the progress bar in sync with the engine fade
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            step += 1
            withAnimation(.linear(duration: interval)) {
                fadeProgress = Double(step) / Double(steps)
            }
            if step >= steps {
                timer.invalidate()
                isFading = false
                currentType = nil
                currentSceneID = nil
            }
        }

        engine.fadeOut(duration: duration)
    }

    private func runStressTest() {
        isStressTesting = true
        stressTestCount = 0
        let scene = SoundScene(
            id: "debug_stress",
            name: "Stresstest",
            subtitle: "",
            category: .relax,
            layers: [SoundLayer(generatorType: .rain)],
            isPremium: false,
            gradientColors: [],
            iconName: "bolt"
        )

        stressTask = Task { @MainActor in
            for i in 1...10 {
                guard !Task.isCancelled else { break }
                stressTestCount = i
                engine.play(scene: scene)
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                engine.stop()
                try? await Task.sleep(nanoseconds: 150_000_000) // 0.15s
            }
            isStressTesting = false
            stressTestCount = 0
        }
    }
}

#Preview {
    AudioDebugView()
        .environment(AudioEngine.shared)
}
