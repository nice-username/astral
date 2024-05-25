//
//  AstralSceneKitManager.swift
//  astral
//
//  Created by Joseph Haygood on 5/15/24.
//

import Foundation
import SceneKit
import UIKit

class AstralSceneKitManager {
    var scnView: SCNView!
    var cameraNode: SCNNode!
    var ship: SCNNode?
    var rightEngine: SCNNode?
    var leftEngine: SCNNode?
    var parentView: UIView
    var controlScrollView: UIScrollView!
    var playbackControlsView: UIView!

    init(view: UIView, sceneName: String) {
        parentView = view
        
        let rect = view.bounds
        scnView = SCNView(frame: rect)
        scnView.scene = SCNScene(named: sceneName)
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = false
        ship = scnView!.scene!.rootNode.childNodes[0]
        
        addEngines()
        setupCamera()
        setupLighting()
        setupMaterial()
        
        view.addSubview(scnView)
        view.sendSubviewToBack(scnView)
    }

    
    func updateRotation(x: Float?, y: Float?, z: Float?) {
        if let x = x {
            ship?.eulerAngles.x = x
        }
        if let y = y {
            ship?.eulerAngles.y = y
        }
        if let z = z {
            ship?.eulerAngles.z = z
        }
    }
    
    func updatePos(x: Float?, y: Float?, z: Float?) {
        if let x = x {
            ship?.position.x = x
        }
        if let y = y {
            ship?.position.y = y
        }
        if let z = z {
            ship?.position.z = z
        }
    }
    
    func updateCameraOrientation(yaw: CGFloat?, pitch: CGFloat?, roll: CGFloat?) {
        if let yaw = yaw {
            cameraNode.eulerAngles.y = Float(yaw)
        }
        if let pitch = pitch {
            cameraNode.eulerAngles.x = Float(pitch)
        }
        if let roll = roll {
            cameraNode.eulerAngles.z = Float(roll)
        }
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 25)
        scnView.scene?.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode
        scnView.rendersContinuously = true  // May increase power consumption
        scnView.isJitteringEnabled = true   // Helps reduce aliasing
        scnView.antialiasingMode = .multisampling4X
        
        // Set the camera to look at the model
        // let constraint = SCNLookAtConstraint(target: ship)
        // cameraNode.constraints = [constraint]
        
        // Idle camera animation
        let rotation = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi * 1, duration: 6)
        let repeatRotation = SCNAction.repeatForever(rotation)
        // ship?.runAction(repeatRotation)
    }
    
    private func setupMaterial() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemMint
        material.fillMode = .lines
        ship?.geometry?.materials = [material]
    }
    
    private func setupLighting() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .directional
        lightNode.light!.color = UIColor.white
        lightNode.light!.intensity = 500
        lightNode.position = SCNVector3(x: 0, y: 0, z: -5)
        scnView.scene?.rootNode.addChildNode(lightNode)
    }
    
    private func addEngines() {
        rightEngine = scnView!.scene!.rootNode.childNodes[0].childNodes[0]
        leftEngine = scnView!.scene!.rootNode.childNodes[0].childNodes[1]
        
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = UIColor.systemBlue
        glowMaterial.fillMode = .fill
    

        // rightEngine?.geometry?.materials = [glowMaterial]
        // leftEngine?.geometry?.materials = [glowMaterial]
        
        highlightNode(rightEngine!, highlight: true)
        highlightNode(leftEngine!, highlight: true)
    }
    
    func highlightNode(_ node: SCNNode, highlight: Bool) {
        let material = SCNMaterial()
        material.diffuse.contents = highlight ? UIColor.white : UIColor.black
        material.diffuse.intensity = highlight ? 1.0 : 0.0
        material.transparency = 1

        
        let wireframeMaterial = SCNMaterial()
        wireframeMaterial.diffuse.contents = UIColor.green
        wireframeMaterial.fillMode = .lines

        
        if highlight {
            let pulseAnimation = CABasicAnimation(keyPath: "diffuse.intensity")
            pulseAnimation.fromValue = 0.0
            pulseAnimation.toValue = 0.8
            pulseAnimation.duration = 1.0
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = .infinity
            material.addAnimation(pulseAnimation, forKey: "pulse")
            wireframeMaterial.addAnimation(pulseAnimation, forKey: "pulse")
        } else {
            material.removeAnimation(forKey: "pulse")
        }
        node.geometry?.materials = [material]
    }
    

    
    func updateCameraPosition(x: Float, y: Float, z: Float) {
        cameraNode.position = SCNVector3(x: x, y: y, z: z)
    }
    
    
    func setupPlaybackControls(view: UIView) {
        playbackControlsView = UIView(frame: CGRect(x: 0, y: view.bounds.height - 230, width: view.bounds.width, height: 35))
        playbackControlsView.backgroundColor = .black
        view.addSubview(playbackControlsView)
        
        let playButton = UIButton(frame: CGRect(x: 20, y: 10, width: 30, height: 30))
        playButton.setTitle("▶️", for: .normal)
        playButton.addTarget(self, action: #selector(playback), for: .touchUpInside)
        playbackControlsView.addSubview(playButton)
        
        let pauseButton = UIButton(frame: CGRect(x: 80, y: 10, width: 30, height: 30))
        pauseButton.setTitle("⏸", for: .normal)
        pauseButton.addTarget(self, action: #selector(pausePlayback), for: .touchUpInside)
        playbackControlsView.addSubview(pauseButton)
        
        let stopButton = UIButton(frame: CGRect(x: 140, y: 10, width: 30, height: 30))
        stopButton.setTitle("⏹", for: .normal)
        stopButton.addTarget(self, action: #selector(stopPlayback), for: .touchUpInside)
        playbackControlsView.addSubview(stopButton)
    }
    
    @objc func playback() {
        // Implement playback logic
    }
    
    @objc func pausePlayback() {
        // Implement pause logic
    }
    
    @objc func stopPlayback() {
        // Implement stop logic
    }
}



