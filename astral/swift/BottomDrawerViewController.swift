//
//  BottomDrawerViewController.swift
//  astral
//
//  Created by Joseph Haygood on 11/19/23.
//
import Foundation
import UIKit

class BottomDrawerViewController: UIViewController {
    var isMenuRevealed = false
    var controlScrollView: UIScrollView!
    var panGesture: UIPanGestureRecognizer!
    var bottomBlurView: UIVisualEffectView!
    var minimizedHeight: CGFloat
    var maximizedHeight: CGFloat
    private var lastControlBottomAnchor: NSLayoutYAxisAnchor?
    private var lastSliderTag = 0
    
    
    init(minHeight: CGFloat, maxHeight: CGFloat) {
        self.minimizedHeight = minHeight
        self.maximizedHeight = maxHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlurEffect()
        setupControlScrollView()
        setupPanGesture()
        
        let (label1,slider,label2) = createSliderControls(labelText: "Hello", minValue: 1, maxValue: 100, initialValue: 10)
        
        controlScrollView.addSubview(label1)
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        bottomBlurView = UIVisualEffectView(effect: blurEffect)
        bottomBlurView.frame = CGRect(x: 0, y: view.bounds.height - minimizedHeight, width: view.bounds.width, height: maximizedHeight)
        view.addSubview(bottomBlurView)
    }
    
    private func setupControlScrollView() {
        controlScrollView = UIScrollView()
        bottomBlurView.contentView.addSubview(controlScrollView)
        controlScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlScrollView.topAnchor.constraint(equalTo: bottomBlurView.topAnchor),
            controlScrollView.bottomAnchor.constraint(equalTo: bottomBlurView.bottomAnchor),
            controlScrollView.leadingAnchor.constraint(equalTo: bottomBlurView.leadingAnchor),
            controlScrollView.trailingAnchor.constraint(equalTo: bottomBlurView.trailingAnchor)
        ])
        controlScrollView.alpha = 0.0
    }

    
    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bottomBlurView.addGestureRecognizer(panGesture)
        panGesture.cancelsTouchesInView = false
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: bottomBlurView)
        let velocity = gesture.velocity(in: bottomBlurView)
        
        switch gesture.state {
        case .began, .changed:
            updateBottomView(translation: translation)
        case .ended, .cancelled:
            if isMenuRevealed {
                if shouldHideMenu(translation: translation, velocity: velocity) {
                    hideMenu()
                } else {
                    revealMenu()
                }
            } else {
                if shouldRevealMenu(translation: translation, velocity: velocity) {
                    revealMenu()
                } else {
                    hideMenu()
                }
            }
        default:
            break
        }
    }
    
    private func shouldRevealMenu(translation: CGPoint, velocity: CGPoint) -> Bool {
        return velocity.y < -500 || translation.y <= -64
    }
    
    private func shouldHideMenu(translation: CGPoint, velocity: CGPoint) -> Bool {
        return velocity.y > 500 || translation.y > 64
    }
    
    func revealMenu() {
        isMenuRevealed = true
        UIView.animate(withDuration: 0.166667) {
            self.bottomBlurView.frame.origin.y = (self.view.frame.height - self.bottomBlurView.frame.height)
            self.controlScrollView.alpha = 1.0
        }
    }
    
    func hideMenu() {
        isMenuRevealed = false
        UIView.animate(withDuration: 0.166667) {
            self.bottomBlurView.frame.origin.y = self.view.frame.height - self.minimizedHeight
            self.controlScrollView.alpha = 0.0
        }
    }
    
    private func updateBottomView(translation: CGPoint) {
        var targetY: CGFloat = 0.0
        
        if isMenuRevealed {
            targetY = self.view.frame.height - maximizedHeight + translation.y / 2
            targetY = max(self.view.frame.height - maximizedHeight, targetY)
        } else {
            targetY = self.view.frame.height - minimizedHeight + translation.y / 2
            targetY = min(self.view.frame.height - minimizedHeight, targetY)
        }
        
        // Clamp the targetY to ensure it does not exceed maximizedHeight
        targetY = min(self.view.frame.height - minimizedHeight, max(self.view.frame.height - maximizedHeight, targetY))
        
        // Update the bottomBlurView's position
        self.bottomBlurView.frame.origin.y = targetY
    }
    
    
    // Function to attach controls to labels and position them in the controlScrollView
    public func attachControlsToScrollView(label: UILabel, control: UIControl, valueLabel: UILabel? = nil) {
        label.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false
        valueLabel?.translatesAutoresizingMaskIntoConstraints = false

        controlScrollView.addSubview(label)
        controlScrollView.addSubview(control)
        if let valueLabel = valueLabel {
            controlScrollView.addSubview(valueLabel)
        }

        // Constraints for label
        label.topAnchor.constraint(equalTo: lastControlBottomAnchor ?? controlScrollView.topAnchor, constant: 22).isActive = true
        label.leftAnchor.constraint(equalTo: controlScrollView.leftAnchor, constant: 16).isActive = true
        label.widthAnchor.constraint(equalToConstant: 96).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true

        // Constraints for control
        control.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        control.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
        control.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        // Constraints for value label if it exists
        if let valueLabel = valueLabel {
            valueLabel.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
            valueLabel.rightAnchor.constraint(equalTo: bottomBlurView.rightAnchor, constant: -16).isActive = true
            valueLabel.widthAnchor.constraint(equalToConstant: 96).isActive = true
            valueLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true

            // Set the right anchor of the control to the left anchor of the value label
            control.rightAnchor.constraint(equalTo: valueLabel.leftAnchor, constant: -16).isActive = true
            // Update the last bottom anchor to the bottom of the value label
            lastControlBottomAnchor = valueLabel.bottomAnchor
        } else {
            // If there is no value label, control extends to the edge of the scroll view
            control.rightAnchor.constraint(equalTo: bottomBlurView.rightAnchor, constant: -16).isActive = true
            // Update the last bottom anchor to the bottom of the control
            lastControlBottomAnchor = control.bottomAnchor
        }
    }

    

    
    
    func createSliderControls(labelText: String, minValue: Float, maxValue: Float, initialValue: Float) -> (label: UILabel, slider: UISlider, valueLabel: UILabel) {
        let label = UILabel()
        label.text = labelText
        label.textColor = .white

        let slider = UISlider()
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = initialValue
        slider.addTarget(self, action: #selector(sliderUpdateValue(_:)), for: .valueChanged)
        self.lastSliderTag += 1
        slider.tag = self.lastSliderTag

        let valueLabel = UILabel()
        valueLabel.text = String(format: "%.2f", initialValue)
        valueLabel.textColor = .white
        valueLabel.tag = slider.tag + 1000
        valueLabel.textAlignment = .right
        
        attachControlsToScrollView(label: label, control: slider, valueLabel: valueLabel)
        return (label, slider, valueLabel)
    }
    
    @objc func sliderUpdateValue(_ sender: UISlider) {
        if let valueLabel = self.view.viewWithTag(sender.tag + 1000) as? UILabel {
            valueLabel.text = String(format: "%.2f", sender.value)
        }
    }
}
