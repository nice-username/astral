//
//  AstralParallaxBackgroundLayerPicker.swift
//  astral
//
//  Created by Joseph Haygood on 8/19/23.
//

import Foundation
import UIKit
import SpriteKit



protocol AstralParallaxPickerDelegate: AnyObject {
    func didPickLayer(_ layer: AstralParallaxBackgroundLayer2)
}



class AstralParallaxBackgroundLayerPicker: UIViewController {
    public var gameState: AstralGameStateManager?
    public var currentAtlas: String?
    public var delegate: AstralParallaxPickerDelegate?
    private var parallaxBackground: AstralParallaxBackgroundLayer2!
    private var titleLabel: UILabel!
    private var confirmButton: UIButton!
    private var cancelButton: UIButton!
    private var topBlurView: UIVisualEffectView!
    private var bottomBlurView: UIVisualEffectView!
    private var skView: SKView!
    private var scene: AstralParallaxBackgroundLayerPickerScene!
    private var panGesture: UIGestureRecognizer!

    
    
    // Layer Submenu Controls
    var controlsRevealed = false
    private var controlScrollView: UIScrollView!
    private var opacitySlider: UISlider!
    private var speedSlider: UISlider!
    private var directionSegment: UISegmentedControl!
    private var endingSegment: UISegmentedControl!
    private var opacityLabel: UILabel!
    private var speedLabel: UILabel!
    private var directionLabel: UILabel!
    private var endingLabel: UILabel!


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameState = AstralGameStateManager.shared
        
        // Initialize SpriteKit scene
        self.setupSpriteKit(atlasNamed: "MainMenuBackground01")
        
        // Setup Blur Effect
        setupBlurEffect()
        setupControlScrollView()
        
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
        bottomBlurEffectView.frame = CGRect(x: 0, y: view.bounds.height - heightOffset, width: view.bounds.width, height: heightOffset * 2.5)
        view.addSubview(topBlurEffectView)
        view.addSubview(bottomBlurEffectView)
        
        topBlurView = topBlurEffectView
        bottomBlurView = bottomBlurEffectView
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bottomBlurView.addGestureRecognizer(panGesture)
        panGesture.cancelsTouchesInView = false
    }
    
    
     
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: bottomBlurView)
        let velocity = gesture.velocity(in: bottomBlurView)
        
        // Update alpha during pan
        updateAlpha(translation: translation, isRevealed: controlsRevealed)

        switch gesture.state {
        case .began, .changed:
            updateBottomView(translation: translation, controlsRevealed: controlsRevealed)
        case .ended, .cancelled:
            print("Was \(controlsRevealed), \(velocity.y)")
            if controlsRevealed && (velocity.y > 500 || translation.y > 64) {
                resetControls()
            } else if !controlsRevealed && (velocity.y > 500 || translation.y <= -64) {
                revealControls()
            }
            if controlsRevealed && !(velocity.y > 500 || translation.y > 64) {
                revealControls()
            } else if !controlsRevealed && (velocity.y > 500 || translation.y > -64) {
                resetControls()
            }
            
        default:
            break
        }
    }
    
    func updateBottomView(translation: CGPoint, controlsRevealed: Bool) {
        var targetY: CGFloat = 0.0
        if controlsRevealed {
            targetY = (self.view.frame.height - self.bottomBlurView.frame.height) + translation.y / 2
        } else {
            targetY = self.view.frame.height + translation.y / 2 - 96.0
        }
        self.bottomBlurView.frame.origin.y = min(self.view.frame.height - 96.0, max(self.view.frame.height - self.bottomBlurView.frame.height, targetY))
    }

    func updateAlpha(translation: CGPoint, isRevealed: Bool) {
        let progress = min(abs(translation.y) / 100.0, 1.0)
        controlScrollView.alpha = controlsRevealed ? 1.0 - progress : progress
        confirmButton.alpha = 1.0 - controlScrollView.alpha
        cancelButton.alpha = 1.0 - controlScrollView.alpha
    }
    

    func revealControls() {
        self.controlsRevealed = true
        UIView.animate(withDuration: 0.166667) {
            // Move ScrollView to reveal position
            self.bottomBlurView.frame.origin.y = (self.view.frame.height - self.bottomBlurView.frame.height)
            // Fade out main buttons
            self.confirmButton.alpha = 0.0
            self.cancelButton.alpha = 0.0
            // Fade in controls
            self.controlScrollView.alpha = 1.0
        }
    }

    func resetControls() {
        self.controlsRevealed = false
        UIView.animate(withDuration: 0.166667) {
            // Reset ScrollView position
            self.bottomBlurView.frame.origin.y = self.view.frame.height - 96.0
            // Fade in main buttons
            self.confirmButton.alpha = 1.0
            self.cancelButton.alpha = 1.0
            // Fade out controls
            self.controlScrollView.alpha = 0.0
        }
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
    
    
    
    func setupControlScrollView() {
        // Initialize the ScrollView
        controlScrollView = UIScrollView()
        
        controlScrollView.alpha = 0.0
        bottomBlurView.contentView.addSubview(controlScrollView)
        
        controlScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlScrollView.leftAnchor.constraint(equalTo: bottomBlurView.leftAnchor, constant: 24.0),
            controlScrollView.rightAnchor.constraint(equalTo: bottomBlurView.rightAnchor, constant: -24.0),
            controlScrollView.topAnchor.constraint(equalTo: bottomBlurView.topAnchor, constant: 12.0),
            controlScrollView.bottomAnchor.constraint(equalTo: bottomBlurView.bottomAnchor, constant: -12.0)
        ])
        
        // Create control + label pairs
        let opacityPair = createSliderControlPair(labelText: "Opacity", 0.1, 1.0, 1.0)
        opacityLabel = opacityPair.label
        opacitySlider = opacityPair.control as? UISlider
        
        let speedPair = createSliderControlPair(labelText: "Speed", 0.0625, 8.0, Float(self.parallaxBackground.speed))
        speedLabel = speedPair.label
        speedSlider = speedPair.control as? UISlider
        
        let directionPair = createSegmentControlPair(labelText: "Direction", items: ["Up", "Down", "Left", "Right"], selectedItem: 1)
        directionLabel = directionPair.label
        directionSegment = directionPair.control as? UISegmentedControl
        
        let loopingPair = createSegmentControlPair(labelText: "Ending", items: ["Stop", "Loop", "Fade", "Rvrse"], selectedItem: 1)
        endingLabel = loopingPair.label
        endingSegment = loopingPair.control as? UISegmentedControl
        
        controlScrollView.addSubview(directionLabel)
        controlScrollView.addSubview(directionSegment)
        controlScrollView.addSubview(speedLabel)
        controlScrollView.addSubview(speedSlider)
        controlScrollView.addSubview(opacityLabel)
        controlScrollView.addSubview(opacitySlider)
        controlScrollView.addSubview(endingLabel)
        controlScrollView.addSubview(endingSegment)
        
        attachControlToLabel(label: directionLabel, control: directionSegment, topAnchor: controlScrollView.topAnchor, parent: controlScrollView)
        attachControlToLabel(label: speedLabel, control: speedSlider, topAnchor: directionSegment.bottomAnchor, parent: controlScrollView)
        attachControlToLabel(label: opacityLabel, control: opacitySlider, topAnchor: speedSlider.bottomAnchor, parent: controlScrollView)
        attachControlToLabel(label: endingLabel, control: endingSegment, topAnchor: opacitySlider.bottomAnchor, parent: controlScrollView)
        
        opacitySlider.addTarget(self, action: #selector(handleOpacityChange), for: .valueChanged)
        speedSlider.addTarget(self, action: #selector(handleSpeedChange), for: .valueChanged)
    }
    
    
    @objc func handleOpacityChange(sender: UISlider) {
        parallaxBackground.updateOpacity(opacity: CGFloat(sender.value))
    }

    @objc func handleSpeedChange(sender: UISlider) {
        parallaxBackground.updateSpeed(speed: CGFloat(sender.value))
    }

    
    func createSliderControlPair(labelText: String, _ min: Float, _ max: Float, _ initialValue: Float) -> (label: UILabel, control: UIControl) {
        let label = UILabel()
        label.text = labelText
        label.textColor = .white
        let control = UISlider()
        control.minimumValue = min
        control.maximumValue = max
        control.value = initialValue
        return (label, control)
    }

    func createSegmentControlPair(labelText: String, items: [String], selectedItem: Int) -> (label: UILabel, control: UIControl) {
        let label = UILabel()
        label.text = labelText
        label.textColor = .white
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedItem
        return (label, control)
    }
    
    private func attachControlToLabel(label: UILabel, control: UIControl, topAnchor: NSLayoutYAxisAnchor, parent: UIScrollView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 22).isActive = true
        label.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 16).isActive = true
        label.widthAnchor.constraint(equalToConstant: 96).isActive = true
        
        control.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        control.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        control.rightAnchor.constraint(equalTo: self.bottomBlurView.rightAnchor, constant: -32).isActive = true
    }
    
    @objc private func toggleLooping(sender: UIButton) {
        sender.isSelected = !sender.isSelected
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
            cancelButton.topAnchor.constraint(equalTo: bottomBlurView.contentView.topAnchor, constant: 24.0)
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
            confirmButton.topAnchor.constraint(equalTo: bottomBlurView.contentView.topAnchor, constant: 24.0)
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        NotificationCenter.default.post(name: .layerAdded, object: nil, userInfo: ["layer": parallaxBackground!])
        self.dismiss(animated: true)
    }


    private func createRoundedButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return button
    }
    
}

