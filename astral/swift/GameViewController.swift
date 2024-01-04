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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gameStateManager = AstralGameStateManager.shared
        gameStateManager.viewController = self
        
        let scene = AstralMainMenuScene(size: view.bounds.size)
        if let view = self.view as! SKView? {
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS            = true
            view.showsNodeCount      = true
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
