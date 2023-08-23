//
//  AstralParallaxBackgroundLayerPicker.swift
//  astral
//
//  Created by Joseph Haygood on 8/19/23.
//

import Foundation
import UIKit

class AstralParallaxBackgroundLayerPicker: UIViewController {
    private var parallaxBackground: AstralParallaxBackground!
    private var titleLabel: UILabel!
    private var speedSlider: UISlider!
    private var directionSwitch: UISwitch!
    private var loopingButton: UIButton!
    private var confirmButton: UIButton!
    private var cancelButton: UIButton!
    private var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Parallax Background
        setupParallaxBackground()
        
        // Setup Blur Effect
        setupBlurEffect()
        
        // Setup Title Label
        setupTitleLabel()
        
        // Setup Scrolling Speed Slider
        setupSpeedSlider()
        
        // Setup Direction Switch
        setupDirectionSwitch()
        
        // Setup Looping Checkbox/Button
        setupLoopingButton()
        
        // Setup Confirm and Cancel Buttons
        setupConfirmCancelButton()
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Background Name" // Replace with the actual name
        titleLabel.textAlignment = .center
        // Additional styling
        blurEffectView.contentView.addSubview(titleLabel)
        // Set up constraints or frames
    }
    
    private func setupSpeedSlider() {
        speedSlider = UISlider()
        speedSlider.minimumValue = 0
        speedSlider.maximumValue = 20
        speedSlider.addTarget(self, action: #selector(speedSliderChanged), for: .valueChanged)
        blurEffectView.contentView.addSubview(speedSlider)
        // Set up constraints or frames
    }
    
    @objc private func speedSliderChanged(sender: UISlider) {
        let speedValue = sender.value
        // Update the scrolling speed and label
    }
    
    private func setupLoopingButton() {
        loopingButton = UIButton(type: .custom)
        // Set images for selected and unselected state
        loopingButton.addTarget(self, action: #selector(toggleLooping), for: .touchUpInside)
        blurEffectView.contentView.addSubview(loopingButton)
        // Set up constraints or frames
    }

    @objc private func toggleLooping(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        // Update the looping status
    }

    
    private func setupDirectionSwitch() {
        directionSwitch = UISwitch()
        // Additional setup if needed
        blurEffectView.contentView.addSubview(directionSwitch)
        // Set up constraints or frames
    }
    
    private func setupConfirmCancelButton() {
        confirmButton = createRoundedButton(title: "Confirm")
        cancelButton = createRoundedButton(title: "Cancel")
        // Assign actions and add to the view
        view.addSubview(confirmButton)
        view.addSubview(cancelButton)
    }

    private func createRoundedButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        // Additional styling
        return button
    }




    // Example:
    private func setupParallaxBackground() {
        // Code to set up parallax background
    }
    
    // More functions for handling user interactions will be defined here
}

