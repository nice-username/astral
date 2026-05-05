//
//  AstralAudioManager.swift
//  
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation
import AVFoundation

// MARK: - Audio Manager (Singleton for global audio state)
class AstralAudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AstralAudioManager()

    private static let sfxPlayerCount = 32
    private static let fallbackPlayerCount = 16
    
    private var audioEngine: AVAudioEngine
    private var bgmNode: AVAudioPlayerNode
    private var sfxMixerNode: AVAudioMixerNode
    private var mainMixerNode: AVAudioMixerNode {
        audioEngine.mainMixerNode
    }
    private var sfxFormat: AVAudioFormat
    
    private var currentBGM: String?
    private var preloadedSFX: [String: AVAudioPCMBuffer] = [:]
    private var sfxPlayers: [AVAudioPlayerNode] = []
    private var busySFXPlayerIndices = Set<Int>()
    private var shouldUsePlayerFallback = false
    private var hasLoggedEngineFailure = false
    private var fallbackSFXPlayers: [AVAudioPlayer] = []
    
    private override init() {
        audioEngine = AVAudioEngine()
        bgmNode = AVAudioPlayerNode()
        sfxMixerNode = AVAudioMixerNode()
        sfxFormat = AstralAudioManager.defaultSFXFormat()
        sfxPlayers = (0..<Self.sfxPlayerCount).map { _ in AVAudioPlayerNode() }
        
        super.init()

        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )

            #if !targetEnvironment(simulator)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }

        sfxFormat = preferredSFXFormat()
        
        audioEngine.attach(bgmNode)
        audioEngine.attach(sfxMixerNode)
        for player in sfxPlayers {
            audioEngine.attach(player)
        }
        
        audioEngine.connect(bgmNode, to: mainMixerNode, format: nil)
        audioEngine.connect(sfxMixerNode, to: mainMixerNode, format: sfxFormat)
        for player in sfxPlayers {
            audioEngine.connect(player, to: sfxMixerNode, format: sfxFormat)
        }
        
        bgmNode.volume = 0.7
        sfxMixerNode.volume = 1.0
        
        audioEngine.prepare()
    }

    private static func defaultSFXFormat() -> AVAudioFormat {
        AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)!
    }

    private func preferredSFXFormat() -> AVAudioFormat {
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        guard outputFormat.sampleRate > 0, outputFormat.channelCount > 0 else {
            return Self.defaultSFXFormat()
        }

        return AVAudioFormat(
            standardFormatWithSampleRate: outputFormat.sampleRate,
            channels: min(outputFormat.channelCount, 2)
        ) ?? Self.defaultSFXFormat()
    }

    @discardableResult
    private func startAudioEngineIfNeeded() -> Bool {
        guard !audioEngine.isRunning else { return true }

        do {
            try audioEngine.start()
            return true
        } catch {
            shouldUsePlayerFallback = true

            if !hasLoggedEngineFailure {
                print("Failed to start audio engine; falling back to AVAudioPlayer SFX: \(error.localizedDescription)")
                hasLoggedEngineFailure = true
            }

            return false
        }
    }
    
    // MARK: - BGM Methods (Called by Scene)
    func playBGM(filename: String, loopCount: Int = -1) {
        guard filename != currentBGM else { return }

        guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
              let file = try? AVAudioFile(forReading: url) else {
            print("Failed to load BGM: \(filename)")
            return
        }

        guard startAudioEngineIfNeeded() else { return }
        
        bgmNode.stop()
        currentBGM = filename
        
        if loopCount == -1 {
            let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                        frameCapacity: AVAudioFrameCount(file.length))!
            try? file.read(into: buffer)
            bgmNode.scheduleBuffer(buffer, at: nil, options: .loops)
        } else {
            bgmNode.scheduleFile(file, at: nil)
        }
        
        bgmNode.play()
    }
    
    func stopBGM() {
        bgmNode.stop()
        currentBGM = nil
    }
    
    func setBGMVolume(_ volume: Float) {
        bgmNode.volume = volume
    }
    
    // MARK: - Audio Manager SFX Methods
    func preloadSFX(filename: String) {
        _ = loadSFXBuffer(filename: filename)
    }
    
    func playSFX(filename: String, volume: Float = 1.0) {
        if shouldUsePlayerFallback {
            playFallbackSFX(filename: filename, volume: volume)
            return
        }

        guard startAudioEngineIfNeeded() else {
            playFallbackSFX(filename: filename, volume: volume)
            return
        }

        guard let buffer = loadSFXBuffer(filename: filename),
              let playerIndex = sfxPlayers.indices.first(where: { !busySFXPlayerIndices.contains($0) }) else {
            return
        }
        
        let playerNode = sfxPlayers[playerIndex]
        busySFXPlayerIndices.insert(playerIndex)
        
        playerNode.volume = volume
        playerNode.scheduleBuffer(
            buffer,
            at: nil,
            options: [],
            completionCallbackType: .dataPlayedBack
        ) { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                playerNode.stop()
                playerNode.reset()
                self.busySFXPlayerIndices.remove(playerIndex)
            }
        }
        
        playerNode.play()
    }

    private func playFallbackSFX(filename: String, volume: Float) {
        guard fallbackSFXPlayers.count < Self.fallbackPlayerCount else { return }

        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Failed to find fallback SFX: \(filename)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.delegate = self
            player.prepareToPlay()

            guard player.play() else {
                print("Failed to play fallback SFX: \(filename)")
                return
            }

            fallbackSFXPlayers.append(player)
        } catch {
            print("Failed to load fallback SFX \(filename): \(error.localizedDescription)")
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        fallbackSFXPlayers.removeAll { $0 === player }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        fallbackSFXPlayers.removeAll { $0 === player }
    }

    private func loadSFXBuffer(filename: String) -> AVAudioPCMBuffer? {
        if let buffer = preloadedSFX[filename] {
            return buffer
        }

        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Failed to find SFX: \(filename)")
            return nil
        }

        do {
            let file = try AVAudioFile(forReading: url)
            guard let sourceBuffer = AVAudioPCMBuffer(
                pcmFormat: file.processingFormat,
                frameCapacity: AVAudioFrameCount(file.length)
            ) else {
                print("Failed to allocate SFX buffer: \(filename)")
                return nil
            }

            try file.read(into: sourceBuffer)
            guard let buffer = convertSFXBufferIfNeeded(sourceBuffer, filename: filename) else {
                return nil
            }

            preloadedSFX[filename] = buffer
            return buffer
        } catch {
            print("Failed to load SFX \(filename): \(error.localizedDescription)")
            return nil
        }
    }

    private func convertSFXBufferIfNeeded(_ sourceBuffer: AVAudioPCMBuffer, filename: String) -> AVAudioPCMBuffer? {
        guard !sourceBuffer.format.isEqual(sfxFormat) else {
            return sourceBuffer
        }

        guard let converter = AVAudioConverter(from: sourceBuffer.format, to: sfxFormat) else {
            print("Failed to create SFX converter: \(filename)")
            return nil
        }

        let sampleRateRatio = sfxFormat.sampleRate / sourceBuffer.format.sampleRate
        let outputCapacity = AVAudioFrameCount(ceil(Double(sourceBuffer.frameLength) * sampleRateRatio)) + 1
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: sfxFormat, frameCapacity: outputCapacity) else {
            print("Failed to allocate converted SFX buffer: \(filename)")
            return nil
        }

        var didProvideInput = false
        var conversionError: NSError?
        let status = converter.convert(to: outputBuffer, error: &conversionError) { _, outStatus in
            if didProvideInput {
                outStatus.pointee = .noDataNow
                return nil
            }

            didProvideInput = true
            outStatus.pointee = .haveData
            return sourceBuffer
        }

        if let conversionError = conversionError {
            print("Failed to convert SFX \(filename): \(conversionError.localizedDescription)")
            return nil
        }

        switch status {
        case .haveData, .inputRanDry, .endOfStream:
            return outputBuffer
        case .error:
            print("Failed to convert SFX: \(filename)")
            return nil
        @unknown default:
            print("Unexpected SFX conversion status for \(filename)")
            return nil
        }
    }
    
    func setSFXVolume(_ volume: Float) {
        sfxMixerNode.volume = volume
    }
    
    func setMasterVolume(_ volume: Float) {
        mainMixerNode.volume = volume
    }
}
