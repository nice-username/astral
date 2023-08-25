//
//  AstralParallaxBackgroundLayerPicker.swift
//  astral
//
//  Created by Joseph Haygood on 8/19/23.
//

import Foundation
import UIKit
import SpriteKit

class AstralParallaxBackgroundLayerPicker: UIViewController {
    public var gameState: AstralGameStateManager?
    public var currentAtlas: String?
    private var parallaxBackground: AstralParallaxBackgroundLayer2!
    private var titleLabel: UILabel!
    private var speedSlider: UISlider!
    private var directionSwitch: UISwitch!
    private var loopingButton: UIButton!
    private var confirmButton: UIButton!
    private var cancelButton: UIButton!
    private var topBlurView: UIVisualEffectView!
    private var bottomBlurView: UIVisualEffectView!
    private var skView: SKView!
    private var scene: AstralParallaxBackgroundLayerPickerScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameState = AstralGameStateManager.shared
        
        // Initialize SpriteKit scene
        self.setupSpriteKit(atlasNamed: "MainMenuBackground01")
        
        // Setup Parallax Background
        setupParallaxBackground()
        
        // Setup Blur Effect
        setupBlurEffect()
        
        // Setup Title Label
        setupTitleLabel()
        
        // Setup Scrolling Speed Slider
        // setupSpeedSlider()
        
        // Setup Direction Switch
        // setupDirectionSwitch()
        
        // Setup Looping Checkbox/Button
        // setupLoopingButton()
        
        // Setup Confirm and Cancel Buttons
        setupConfirmCancelButton()
    }
    
    
    
    private func setupSpriteKit(atlasNamed: String) {
        skView = SKView(frame: view.bounds)
        scene = AstralParallaxBackgroundLayerPickerScene(size: view.bounds.size)
        self.view.addSubview(skView)
        scene.view?.showsNodeCount = true
        scene.backgroundColor = .black
        
        skView.presentScene(scene)
    
        let scrollDown = CGVector(dx: 0, dy: 1)
        parallaxBackground = AstralParallaxBackgroundLayer2(atlasNamed: atlasNamed, direction: scrollDown, speed: 1.0, shouldLoop: true)
        
        // Position it behind everything
        parallaxBackground.zPosition = 1
        parallaxBackground.position = CGPoint(x: scene.size.width / 2.0, y: scene.size.height / 2.0)
        
        let debugRect = SKShapeNode(rectOf: scene.size)
        debugRect.strokeColor = .red
        scene.addChild(debugRect)

        
        // Add the parallax background to the scene
        scene.parallaxBackground = parallaxBackground
        scene.addChild(parallaxBackground)
        self.currentAtlas = atlasNamed
    }
    
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let topBlurEffectView = UIVisualEffectView(effect: blurEffect)
        let bottomBlurEffectView = UIVisualEffectView(effect: blurEffect)
        let heightOffset = 96.0
        
        topBlurEffectView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: heightOffset + 24.0)
        bottomBlurEffectView.frame = CGRect(x: 0, y: view.bounds.height - heightOffset, width: view.bounds.width, height: heightOffset)
        view.addSubview(topBlurEffectView)
        view.addSubview(bottomBlurEffectView)
        
        topBlurView = topBlurEffectView
        bottomBlurView = bottomBlurEffectView
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = self.currentAtlas
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        
        topBlurView.contentView.addSubview(titleLabel)
        
        // Set up constraints or frames for centering
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: topBlurView.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBlurView.contentView.centerYAnchor, constant: 12.0)
        ])
    }
    
    private func setupSpeedSlider() {
        speedSlider = UISlider()
        speedSlider.minimumValue = 0
        speedSlider.maximumValue = 20
        speedSlider.addTarget(self, action: #selector(speedSliderChanged), for: .valueChanged)
        topBlurView.contentView.addSubview(speedSlider)
        // Set up constraints or frames
    }
    
    @objc private func speedSliderChanged(sender: UISlider) {
        let speedValue = sender.value
        // Update the scrolling speed and label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topSafeAreaHeight = view.safeAreaInsets.top
        print("Top Safe Area Height: \(topSafeAreaHeight)")
    }
    
    
    private func setupLoopingButton() {
        loopingButton = UIButton(type: .custom)
        // Set images for selected and unselected state
        loopingButton.addTarget(self, action: #selector(toggleLooping), for: .touchUpInside)
        topBlurView.contentView.addSubview(loopingButton)
        // Set up constraints or frames
    }

    @objc private func toggleLooping(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        // Update the looping status
    }

    
    private func setupDirectionSwitch() {
        directionSwitch = UISwitch()
        // Additional setup if needed
        topBlurView.contentView.addSubview(directionSwitch)
        // Set up constraints or frames
    }
    
    private func setupConfirmCancelButton() {
        confirmButton = createRoundedButton(title: "Add Layer")
        cancelButton = createRoundedButton(title: "Cancel")
        
        var r = 224 / 255.0
        var g = 24 / 255.0
        var b = 36 / 255.0
        var a = 64 / 255.0
        cancelButton.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a)
        cancelButton.setTitleColor(.white, for: .normal)
        
        bottomBlurView.contentView.addSubview(confirmButton)
        bottomBlurView.contentView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.leftAnchor.constraint(equalTo: bottomBlurView.leftAnchor, constant: 24.0),
            cancelButton.widthAnchor.constraint(equalToConstant: 96.0),
            cancelButton.centerYAnchor.constraint(equalTo: bottomBlurView.contentView.centerYAnchor),
        ])
        
        r = 24 / 255.0
        g = 224 / 255.0
        b = 36 / 255.0
        a = 64 / 255.0
        confirmButton.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.rightAnchor.constraint(equalTo: bottomBlurView.rightAnchor, constant: -24.0),
            confirmButton.widthAnchor.constraint(equalToConstant: 96.0),
            confirmButton.centerYAnchor.constraint(equalTo: bottomBlurView.contentView.centerYAnchor),
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }


    private func createRoundedButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return button
    }


    private func setupParallaxBackground() {
        // Code to set up parallax background
    }
    
    
}

