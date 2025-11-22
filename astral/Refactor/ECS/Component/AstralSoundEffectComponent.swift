//
//  AstralSoundEffectComponent.swift
//  astral
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation
import GameplayKit

class AstralSoundEffectComponent: GKComponent {
    private var soundEffects: [String: String] = [:]  // Map of effect names to filenames
    private let audioManager: AstralAudioManager

    init(audioManager: AstralAudioManager = .shared) {
        self.audioManager = audioManager
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registerSound(_ name: String, filename: String, preload: Bool = true) {
        soundEffects[name] = filename
        if preload {
            AstralAudioManager.shared.preloadSFX(filename: filename)
        }
    }
    
    func playSound(_ name: String, volume: Float = 1.0) {
        guard let filename = soundEffects[name] else { return }
        AstralAudioManager.shared.playSFX(filename: filename, volume: volume)
    }
}
