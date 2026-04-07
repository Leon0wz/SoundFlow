//
//  SoundFlowTests.swift
//  SoundFlowTests
//
//  Created by Leon Zimny on 07.04.26.
//

import Testing
@testable import SoundFlow

// MARK: - Generator Lifecycle Tests

struct GeneratorLifecycleTests {

    @Test func noiseGeneratorWhite() {
        let gen = NoiseGenerator(type: .whiteNoise)
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func noiseGeneratorPink() {
        let gen = NoiseGenerator(type: .pinkNoise)
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func noiseGeneratorBrown() {
        let gen = NoiseGenerator(type: .brownNoise)
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func rainGeneratorLifecycle() {
        let gen = RainGenerator(type: .rain)
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func drizzleGeneratorLifecycle() {
        let gen = RainGenerator(type: .drizzle)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func heavyRainGeneratorLifecycle() {
        let gen = RainGenerator(type: .heavyRain)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func waveGeneratorOcean() {
        let gen = WaveGenerator(type: .ocean)
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func waveGeneratorWaves() {
        let gen = WaveGenerator(type: .waves)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func windGeneratorLifecycle() {
        for type in [GeneratorType.wind, .breeze, .gust] {
            let gen = WindGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func thunderGeneratorLifecycle() {
        let gen = ThunderGenerator()
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func birdGeneratorLifecycle() {
        for type in [GeneratorType.birds, .crickets, .frogs] {
            let gen = BirdGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func fireGeneratorLifecycle() {
        for type in [GeneratorType.fire, .campfire] {
            let gen = FireGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func padGeneratorLifecycle() {
        for type in [GeneratorType.pad, .ambient] {
            let gen = PadGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func binauralGeneratorLifecycle() {
        let gen = BinauralGenerator()
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }

    @Test func forestGeneratorLifecycle() {
        for type in [GeneratorType.forest, .jungle] {
            let gen = ForestGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func cityGeneratorLifecycle() {
        for type in [GeneratorType.city, .cafe, .traffic] {
            let gen = CityGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func spaceGeneratorLifecycle() {
        for type in [GeneratorType.space, .drone] {
            let gen = SpaceGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func streamGeneratorLifecycle() {
        for type in [GeneratorType.stream, .river, .waterfall] {
            let gen = StreamGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func caveGeneratorLifecycle() {
        for type in [GeneratorType.cave, .drops] {
            let gen = CaveGenerator(type: type)
            #expect(gen.isRunning == false)
            gen.start()
            #expect(gen.isRunning == true)
            gen.stop()
            #expect(gen.isRunning == false)
        }
    }

    @Test func underwaterGeneratorLifecycle() {
        let gen = UnderwaterGenerator()
        #expect(gen.isRunning == false)
        gen.start()
        #expect(gen.isRunning == true)
        gen.stop()
        #expect(gen.isRunning == false)
    }
}

// MARK: - Generator Parameter Tests

struct GeneratorParameterTests {

    @Test func noiseGeneratorVolumeReadWrite() {
        let gen = NoiseGenerator(type: .whiteNoise)
        gen.volume = 0.42
        #expect(gen.volume == 0.42)
    }

    @Test func noiseGeneratorPitchReadWrite() {
        let gen = NoiseGenerator(type: .pinkNoise)
        gen.pitch = 1.5
        #expect(gen.pitch == 1.5)
    }

    @Test func noiseGeneratorIntensityReadWrite() {
        let gen = NoiseGenerator(type: .brownNoise)
        gen.intensity = 0.8
        #expect(gen.intensity == 0.8)
    }

    @Test func rainGeneratorParameters() {
        let gen = RainGenerator(type: .rain)
        gen.volume = 0.6
        gen.intensity = 0.9
        gen.pitch = 1.2
        #expect(gen.volume == 0.6)
        #expect(gen.intensity == 0.9)
        #expect(gen.pitch == 1.2)
    }

    @Test func binauralGeneratorParameters() {
        let gen = BinauralGenerator()
        gen.intensity = 0.7  // should map to ~29 Hz beat frequency
        gen.pitch = 1.5      // shifts base frequency to 300 Hz
        #expect(gen.intensity == 0.7)
        #expect(gen.pitch == 1.5)
    }

    @Test func thunderGeneratorGeneratorType() {
        let gen = ThunderGenerator()
        #expect(gen.generatorType == .thunder)
    }

    @Test func binauralGeneratorType() {
        let gen = BinauralGenerator()
        #expect(gen.generatorType == .binaural)
    }
}

// MARK: - Audio Engine Tests

@MainActor
struct AudioEngineTests {

    @Test func sharedIsAccessible() {
        let engine = AudioEngine.shared
        // Do not call play() or start() — that would activate the audio session
        #expect(engine.isRunning == false)
    }

    @Test func stopIsIdempotent() {
        let engine = AudioEngine.shared
        // Calling stop on an already-stopped engine should not crash
        engine.stop()
        #expect(engine.isRunning == false)
    }
}

// MARK: - Scene Catalog Tests

struct SceneCatalogTests {

    @Test func freeSceneCount() {
        #expect(SceneCatalog.freeScenes.count == 3)
    }

    @Test func allScenesHaveLayers() {
        for scene in SceneCatalog.allScenes {
            #expect(scene.layers.isEmpty == false, "Scene '\(scene.name)' has no layers")
        }
    }

    @Test func allLayerGeneratorTypesAreValid() {
        let allTypes = Set(GeneratorType.allCases)
        for scene in SceneCatalog.allScenes {
            for layer in scene.layers {
                #expect(allTypes.contains(layer.generatorType),
                        "Unknown type \(layer.generatorType) in scene '\(scene.name)'")
            }
        }
    }

    @Test func freeScenesAreNotPremium() {
        for scene in SceneCatalog.freeScenes {
            #expect(scene.isPremium == false)
        }
    }
}

// MARK: - SoundLayer Default Values Tests

struct SoundLayerTests {

    @Test func defaultValues() {
        let layer = SoundLayer(generatorType: .rain)
        #expect(layer.volume    == 0.7)
        #expect(layer.pitch     == 1.0)
        #expect(layer.intensity == 0.5)
        #expect(layer.pan       == 0.0)
        #expect(layer.isEnabled == true)
    }

    @Test func idIsUnique() {
        let a = SoundLayer(generatorType: .rain)
        let b = SoundLayer(generatorType: .rain)
        #expect(a.id != b.id)
    }
}
