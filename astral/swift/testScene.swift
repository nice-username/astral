//
//  testScene.swift
//  astral
//
//  Created by Joseph Haygood on 4/30/23.
//

import Foundation
import UIKit
import SceneKit

class SceneTestController: UIViewController {
    
    // SceneKit scene and camera
    let scene = SCNScene()
    let camera = SCNCamera()
    let cameraNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up SceneKit view
        let sceneView = self.view as! SCNView
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        
        // Set up camera
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 20.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 50, z: 0)
        cameraNode.eulerAngles.x = -Float.pi / 2.0
        scene.rootNode.addChildNode(cameraNode)
        
        // Create buildings
        let buildingGeometry = SCNBox(width: 5.0, height: 10.0, length: 5.0, chamferRadius: 0.0)
        let buildingMaterial = SCNMaterial()
        buildingMaterial.diffuse.contents = UIColor.gray
        buildingGeometry.materials = [buildingMaterial]
        let buildingSpacing = 10.0
        
        for x in stride(from: -50.0, through: 50.0, by: buildingSpacing) {
            for z in stride(from: -50.0, through: 50.0, by: buildingSpacing) {
                let buildingNode = SCNNode(geometry: buildingGeometry)
                buildingNode.position = SCNVector3(x: Float(x), y: 0.0, z: Float(z))
                scene.rootNode.addChildNode(buildingNode)
                
                // Add windows to building
                let windowGeometry = SCNBox(width: 1.0, height: 1.0, length: 0.1, chamferRadius: 0.0)
                let windowMaterial = SCNMaterial()
                windowMaterial.diffuse.contents = UIColor.yellow
                windowGeometry.materials = [windowMaterial]
                
                for y in stride(from: 1.0, through: 9.0, by: 2.0) {
                    let windowNode = SCNNode(geometry: windowGeometry)
                    windowNode.position = SCNVector3(x: 0.0, y: Float(y), z: 2.6)
                    buildingNode.addChildNode(windowNode)
                }
            }
        }
        
        // Create camera animation
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = 50.0
        animation.toValue = -50.0
        animation.duration = 10.0
        animation.repeatCount = .infinity
        cameraNode.addAnimation(animation, forKey: "cameraAnimation")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
