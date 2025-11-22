//
//  AstralAudioManager.swift
//  
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation
import AVFoundation
import GameplayKit

// MARK: - Audio Manager (Singleton for global audio state)
class AstralAudioManager {
    static let shared = AstralAudioManager()
    
    private var audioEngine: AVAudioEngine
    private var bgmNode: AVAudioPlayerNode
    private var sfxMixerNode: AVAudioMixerNode
    private var mainMixerNode: AVAudioMixerNode
    
    private var currentBGM: String?
    private var preloadedSFX: [String: AVAudioFile] = [:]
    private var sfxPlayerPool: ObjectPool<AVAudioPlayerNode>
    
    private init() {
        audioEngine = AVAudioEngine()
        bgmNode = AVAudioPlayerNode()
        sfxMixerNode = AVAudioMixerNode()
        mainMixerNode = AVAudioMixerNode()
        
        sfxPlayerPool = ObjectPool(
            factory: { AVAudioPlayerNode() },
            reset: { node in
                node.stop()
                node.reset()
            },
            maxPoolSize: 32
        )
        
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        try? AVAudioSession.sharedInstance().setCategory(
            .ambient,
            mode: .default,
            options: [.mixWithOthers]
        )
        
        audioEngine.attach(bgmNode)
        audioEngine.attach(sfxMixerNode)
        audioEngine.attach(mainMixerNode)
        
        audioEngine.connect(bgmNode, to: mainMixerNode, format: nil)
        audioEngine.connect(sfxMixerNode, to: mainMixerNode, format: nil)
        audioEngine.connect(mainMixerNode, to: audioEngine.outputNode, format: nil)
        
        bgmNode.volume = 0.7
        sfxMixerNode.volume = 1.0
        
        try? audioEngine.start()
    }
    
    // MARK: - BGM Methods (Called by Scene)
    func playBGM(filename: String, loopCount: Int = -1) {
        guard filename != currentBGM,
              let url = Bundle.main.url(forResource: filename, withExtension: nil),
              let file = try? AVAudioFile(forReading: url) else {
            return
        }
        
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
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
              let file = try? AVAudioFile(forReading: url) else {
            print("Failed to preload SFX: \(filename)")
            return
        }
        preloadedSFX[filename] = file
    }
    
    func playSFX(filename: String, volume: Float = 1.0) {
        guard let file = preloadedSFX[filename] ?? (try? AVAudioFile(forReading: Bundle.main.url(forResource: filename, withExtension: nil)!)) else {
            return
        }
        
        let playerNode = sfxPlayerPool.obtain()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: sfxMixerNode, format: nil)
        
        playerNode.volume = volume
        playerNode.scheduleFile(file, at: nil) { [weak self] in
            guard let self = self else { return }
            // Ensure cleanup happens on the main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Check if the node is still attached before cleanup
                if self.audioEngine.attachedNodes.contains(playerNode) {
                    if playerNode.engine != nil {
                        self.audioEngine.disconnectNodeOutput(playerNode)
                    }
                    self.audioEngine.detach(playerNode)
                }
                self.sfxPlayerPool.recycle(playerNode)
            }
        }
        
        playerNode.play()
    }
    
    func setSFXVolume(_ volume: Float) {
        sfxMixerNode.volume = volume
    }
    
    func setMasterVolume(_ volume: Float) {
        mainMixerNode.volume = volume
    }
}
