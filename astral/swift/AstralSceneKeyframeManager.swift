//
//  AstralSceneKeyframeManager.swift
//  astral
//
//  Created by Joseph Haygood on 5/22/24.
//

import Foundation
import SceneKit

class AstralSceneKeyframeManager {
    private var keyframes: [AstralSceneKeyframe] = []
    
    func addTestData() {
        addKeyframe(name: "Keyframe 1", timeWait: 1.0, timeApply: 2.0, position: SCNVector3(x: 10, y: 0, z: 0), eulerAngles: SCNVector3(x: 3, y: 0, z: 0))
        addKeyframe(name: "Keyframe 2", timeWait: 1.5, timeApply: 2.5, position: SCNVector3(x: 0, y: 20, z: 0), eulerAngles: SCNVector3(x: 1, y: 2, z: 0))
        addKeyframe(name: "Keyframe 3", timeWait: 2.0, timeApply: 3.0, position: SCNVector3(x: 0, y: 0, z: 30), eulerAngles: SCNVector3(x: 1, y: -1, z: 0))
    }
    
    func addKeyframe(name: String, timeWait: TimeInterval, timeApply: TimeInterval, position: SCNVector3, eulerAngles: SCNVector3) {
        let keyframe = AstralSceneKeyframe(name: name, timeWait: timeWait, timeApply: timeApply, position: position, eulerAngles: eulerAngles)
        keyframes.append(keyframe)
    }
    
    func deleteKeyframe(at index: Int) {
        if index >= 0 && index < keyframes.count {
            keyframes.remove(at: index)
        }
    }
    
    func getKeyframe(at index: Int) -> AstralSceneKeyframe? {
        if index >= 0 && index < keyframes.count {
            return keyframes[index]
        }
        return nil
    }
    
    func setKeyframe(at index: Int, from keyframe: AstralSceneKeyframe) {
        if index >= 0 && index < keyframes.count {
            keyframes[index] = keyframe
        }
    }
    
    func getAllKeyframes() -> [AstralSceneKeyframe] {
        return keyframes
    }
}
