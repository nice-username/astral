//
//  AstralStageEditorMenuStepper.swift
//  astral
//
//  Created by Joseph Haygood on 1/9/24.
//

import Foundation
import UIKit
import SpriteKit

class AstralStageEditorMenuStepper: SKNode {
    var minValue: CGFloat
    var maxValue: CGFloat
    var stepValue: CGFloat
    var currentValue: CGFloat {
        didSet {
                updateLabel()
                if previousValue != currentValue {
                    triggerHapticFeedback()
                }
                previousValue = currentValue
            }
        }
    var unitSuffix: String
    private var valueLabel: SKLabelNode
    private var upArrowButton: SKSpriteNode
    private var downArrowButton: SKSpriteNode
    private var accumulatedSwipeLength: CGFloat = 0
    private var previousValue: CGFloat = 0
    
    init(minValue: CGFloat, maxValue: CGFloat, stepValue: CGFloat, unitSuffix: String = "") {
        self.minValue = minValue
        self.maxValue = maxValue
        self.stepValue = stepValue
        self.unitSuffix = unitSuffix
        self.currentValue = minValue

        valueLabel = SKLabelNode(text: "\(currentValue)\(unitSuffix)")
        valueLabel.fontName = "AvenirNext-Regular"
        valueLabel.fontSize = 32
        valueLabel.fontColor = SKColor.white
        valueLabel.position = CGPoint(x: 0, y: -8)
        valueLabel.isUserInteractionEnabled = false

        upArrowButton = SKSpriteNode(imageNamed: "left_arrow")
        upArrowButton.zRotation = -.pi / 2.0
        upArrowButton.position = CGPoint(x: 0, y: 40)
        upArrowButton.name = "upArrowButton"
        upArrowButton.isUserInteractionEnabled = false
        upArrowButton.xScale = 0.5
        upArrowButton.yScale = 0.5

        downArrowButton = SKSpriteNode(imageNamed: "left_arrow")
        downArrowButton.zRotation = .pi / 2.0
        downArrowButton.position = CGPoint(x: 0, y: -40)
        downArrowButton.name = "downArrowButton"
        downArrowButton.isUserInteractionEnabled = false
        downArrowButton.xScale = 0.5
        downArrowButton.yScale = 0.5
        
        super.init()
        
        /*
        let bg = SKShapeNode(rect: calculateFrame())
        bg.fillColor = .red.withAlphaComponent(0.5)
        bg.isUserInteractionEnabled = false
        addChild(bg)
        */
        
        addChild(valueLabel)
        addChild(upArrowButton)
        addChild(downArrowButton)
        self.updateLabel()
        
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let swipeLength = touch.location(in: self).y - touch.previousLocation(in: self).y
        accumulatedSwipeLength += swipeLength

        if abs(accumulatedSwipeLength) >= CGFloat(stepValue) {
            if accumulatedSwipeLength > 0 {
                incrementValue(by: stepValue)
            } else {
                decrementValue(by: stepValue)
            }
            accumulatedSwipeLength = 0
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if upArrowButton.contains(location) {
            incrementValue(by: stepValue)
        } else if downArrowButton.contains(location) {
            decrementValue(by: stepValue)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        accumulatedSwipeLength = 0
    }
    
    private func incrementValue(by amount: CGFloat) {
        let newValue = roundToPlaces(value: min(maxValue, currentValue + amount), places: 2)
        if newValue != currentValue {
            previousValue = currentValue
            currentValue = newValue
        }
    }

    private func decrementValue(by amount: CGFloat) {
        let newValue = roundToPlaces(value: max(minValue, currentValue - amount), places: 2)
        if newValue != currentValue {
            previousValue = currentValue
            currentValue = newValue
        }
    }

    private func calculateChangeAmount(from swipeLength: CGFloat) -> Int {
        return Int(swipeLength / CGFloat(stepValue))
    }

    private func updateLabel() {
        let valueText: String

        if currentValue.truncatingRemainder(dividingBy: 1) == 0 {
            // If currentValue is effectively an integer, display it as one
            valueText = "\(Int(currentValue))"
        } else {
            valueText = "\(currentValue)"
        }

        valueLabel.text = "\(valueText)\(unitSuffix)"
    }
    
    private func triggerHapticFeedback() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    private func roundToPlaces(value: CGFloat, places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (value * divisor).rounded() / divisor
    }
    
    private func calculateFrame() -> CGRect {
        let frames = [valueLabel.frame, upArrowButton.frame, downArrowButton.frame]
        return frames.reduce(CGRect.null) { $0.union($1) }
    }
}
