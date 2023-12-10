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
    var titleLabel: UILabel?
    private var titleText: String = ""
    private var lastControlBottomAnchor: NSLayoutYAxisAnchor?
    private var lastSliderTag = 0
    
    
    init(minHeight: CGFloat, maxHeight: CGFloat, titleText: String = "") {
        self.titleText = titleText
        self.minimizedHeight = minHeight
        self.maximizedHeight = maxHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initialize the View
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlurEffect()
        createTitleLabel(titleText, height: 44.0)
        setupControlScrollView()
        setupPanGesture()
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
            controlScrollView.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor),
            controlScrollView.bottomAnchor.constraint(equalTo: bottomBlurView.bottomAnchor),
            controlScrollView.leadingAnchor.constraint(equalTo: bottomBlurView.leadingAnchor),
            controlScrollView.trailingAnchor.constraint(equalTo: bottomBlurView.trailingAnchor)
        ])
        controlScrollView.alpha = 0.0
        controlScrollView.isUserInteractionEnabled = true
        controlScrollView.isScrollEnabled = true
        controlScrollView.showsVerticalScrollIndicator = true

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
    
    // Function to dismiss the keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
        
    public func createTitleLabel(_ labelText: String, height: CGFloat) {
        let label = UILabel()
        label.text = labelText
        label.textAlignment = .center
        label.textColor = .white
        bottomBlurView.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bottomBlurView.topAnchor),
            label.leadingAnchor.constraint(equalTo: bottomBlurView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: bottomBlurView.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: height)
        ])
        lastControlBottomAnchor = label.bottomAnchor
        titleLabel = label
    }
    
        
    public func createCounterLabel(_ labelText: String, height: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = labelText
        label.textAlignment = .left
        label.textColor = .white
        controlScrollView.addSubview(label)
        
        let label2 = UILabel()
        label2.text = "0"
        label2.textAlignment = .left
        label2.textColor = .white
        controlScrollView.addSubview(label2)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: lastControlBottomAnchor ?? bottomBlurView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: bottomBlurView.leadingAnchor, constant: 8),
            label.widthAnchor.constraint(equalToConstant: 96),
            label.heightAnchor.constraint(equalToConstant: height),
            
            label2.topAnchor.constraint(equalTo: lastControlBottomAnchor ?? bottomBlurView.topAnchor, constant: 8),
            label2.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            label2.trailingAnchor.constraint(equalTo: bottomBlurView.trailingAnchor),
            label2.heightAnchor.constraint(equalToConstant: height)
        ])
        
        lastControlBottomAnchor = label.bottomAnchor
        updateScrollViewContentSize()
        return label2
    }
    
    private func configureSegmentedControlAppearance(segmentedControl: UISegmentedControl) {
        let unselectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        segmentedControl.setTitleTextAttributes(unselectedAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }

    
    public func setupSliderWithLabelAndTextField(sliderTitle: String, tag: Int, height: CGFloat) {
        // Label
        let label = UILabel()
        label.text = sliderTitle
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        controlScrollView.addSubview(label)

        // Slider
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tag = tag
        controlScrollView.addSubview(slider)

        // Numeric TextField
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.textAlignment = .right
        textField.tag = tag
        textField.textColor = .white
        textField.keyboardType = .decimalPad
        let borderColor = UIColor.white
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 4.0
        textField.layer.borderColor = borderColor.cgColor
        controlScrollView.addSubview(textField)
        
        // Add a toolbar with a 'Done' button to dismiss the keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        textField.inputAccessoryView = toolbar
        

        // Constraints
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bottomBlurView.leadingAnchor, constant: 8),
            label.widthAnchor.constraint(equalToConstant: 96),
            label.topAnchor.constraint(equalTo: lastControlBottomAnchor ?? bottomBlurView.topAnchor, constant: 8),
            label.heightAnchor.constraint(equalToConstant: height),

            slider.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            slider.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -8),
            slider.centerYAnchor.constraint(equalTo: label.centerYAnchor),

            textField.widthAnchor.constraint(equalToConstant: 60),
            textField.trailingAnchor.constraint(equalTo: bottomBlurView.trailingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])

        // Update lastControlBottomAnchor for the next control
        lastControlBottomAnchor = label.bottomAnchor
        updateScrollViewContentSize()
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
        updateScrollViewContentSize()
    }

    public func createdSegmentedControl(labelText: String = "", options: [String], height: CGFloat, defaultIndex: Int = 0, isFirstControl: Bool = false) {
        let label = UILabel()
        label.text = labelText
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        controlScrollView.addSubview(label)

        let segmentedControl = UISegmentedControl(items: options)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = defaultIndex
        configureSegmentedControlAppearance(segmentedControl: segmentedControl)
        controlScrollView.addSubview(segmentedControl)
        
        var topAnchor = label.topAnchor.constraint(equalTo: lastControlBottomAnchor ?? bottomBlurView.topAnchor, constant: 8)
        if isFirstControl {
            topAnchor = label.topAnchor.constraint(equalTo: controlScrollView.topAnchor, constant: 8)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bottomBlurView.leadingAnchor, constant: 8),
            label.widthAnchor.constraint(equalToConstant: 96),
            topAnchor,
            label.heightAnchor.constraint(equalToConstant: height),
            segmentedControl.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: bottomBlurView.trailingAnchor, constant: -8),
            segmentedControl.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: height)
        ])

        // Update lastControlBottomAnchor for the next control
        updateScrollViewContentSize()
        lastControlBottomAnchor = segmentedControl.bottomAnchor
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
        updateScrollViewContentSize()
        return (label, slider, valueLabel)
    }
    
    @objc func sliderUpdateValue(_ sender: UISlider) {
        if let valueLabel = self.view.viewWithTag(sender.tag + 1000) as? UILabel {
            valueLabel.text = String(format: "%.2f", sender.value)
        }
    }
    
    
    private func updateScrollViewContentSize() {
        controlScrollView.layoutIfNeeded()
        var contentRect = CGRect.zero
        for view in controlScrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        controlScrollView.contentSize = contentRect.size
    }
}
