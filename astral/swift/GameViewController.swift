//
//  GameViewController.swift
//  astral
//
//  Created by Joseph Haygood on 4/29/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var sceneKitManager: AstralSceneKitManager!
    var keyframeViewController: AstralSceneKeyframeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gameStateManager = AstralGameStateManager.shared
        gameStateManager.viewController = self
        
        
        // let scene = AstralMainMenuScene(size: view.bounds.size)
        let scene = AstralMainMenuScene(size: view.bounds.size)
        if let view = self.view as! SKView? {
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS            = true
            view.showsNodeCount      = true
            
            /*
            let lowerThird = CGRect(x: 0, y: view.frame.height * 2/3, width: view.frame.width, height: view.frame.height / 3)
            sceneKitManager = AstralSceneKitManager(view: view, sceneName: "IkarugaSplit1")
            keyframeViewController = AstralSceneKeyframeViewController(collectionViewLayout: UICollectionViewFlowLayout())

            keyframeViewController.keyframeManager = AstralSceneKeyframeManager()
            keyframeViewController.sceneKitManager = sceneKitManager
            
            
            // Embed KeyframeViewController in UINavigationController
            let keyframeNavController = UINavigationController(rootViewController: keyframeViewController)
            addChild(keyframeNavController)
            view.addSubview(keyframeNavController.view)
            keyframeNavController.view.frame = lowerThird
            keyframeNavController.didMove(toParent: self)
            
            keyframeViewController.keyframeManager.addTestData()
             */
        }
        
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
