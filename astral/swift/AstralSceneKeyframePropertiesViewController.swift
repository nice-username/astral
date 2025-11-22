//
//  AstralSceneKeyframePropertiesViewController.swift
//  astral
//
//  Created by Joseph Haygood on 5/24/24.
//

import Foundation
import UIKit
import SceneKit

class AstralSceneKeyframePropertiesViewController: UIViewController {
    var sliders: [UISlider] = []
    var sliderValues: [Float?] = []
    var controlScrollView: UIScrollView!
    var sceneKitManager: AstralSceneKitManager!
    var keyframeManager: AstralSceneKeyframeManager!
    var selectedFrameIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraControlSliders()
        setAllSliderValues(values: sliderValues)
    }

    func setupCameraControlSliders() {
        controlScrollView = UIScrollView(frame: view.bounds)
        controlScrollView.contentSize = CGSize(width: view.bounds.width, height: 1000)
        controlScrollView.backgroundColor = .darkGray
        view.addSubview(controlScrollView)
        let positions = [20, 60, 100, 140, 180, 220]  // Update based on UI needs
        let labels = ["Rot. X", "Rot. Y", "Rot. Z", "Pos. X", "Pos. Y", "Pos. Z"]
        let values = [ [-CGFloat.pi, CGFloat.pi], [-CGFloat.pi, CGFloat.pi], [-CGFloat.pi, CGFloat.pi],
                       [-20, 20],                 [-20, 20],                 [-50, 50] ]
        
        for (index, labelText) in labels.enumerated() {
            let slider = UISlider(frame: CGRect(x: 70, y: positions[index], width: 250, height: 20))
            slider.minimumValue = Float(values[index][0])
            slider.maximumValue = Float(values[index][1])
            slider.tag = index  // Tag to identify the slider
            slider.addTarget(self, action: #selector(rotationSliderChanged(_:)), for: .valueChanged)
            sliders.append(slider)
            controlScrollView.addSubview(slider)
            
            let leftLabel = UILabel(frame: CGRect(x: 20, y: positions[index], width: 50, height: 20))
            leftLabel.text = "\(labelText)"
            leftLabel.textColor = .white
            leftLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
            controlScrollView.addSubview(leftLabel)
            
            let valueLabel = UILabel(frame: CGRect(x: 330, y: positions[index], width: 50, height: 20))
            valueLabel.text = "0.00"
            valueLabel.textColor = .white
            valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
            valueLabel.tag = index + 10  // Tags for labels
            controlScrollView.addSubview(valueLabel)
        }
    }
    
    
    func setAllSliderValues(values: [Float?]) {
        for i in 0 ... 5 {
            if let value = values[i] {
                setSliderValue(index: i, value: value)
            }
        }
    }
    
    func setSliderValue(index: Int, value: Float) {
        if index >= 0 && index < self.sliders.count {
            sliders[index].value = value
            rotationSliderChanged(sliders[index])
        }
    }
    
    func updateLabel(attatched to: UISlider) {
        let label = controlScrollView.viewWithTag(to.tag + 10) as? UILabel
        label?.text = String(format: "%.2f", to.value)
    }
    
    @objc func rotationSliderChanged(_ sender: UISlider) {
        let radians = CGFloat(sender.value)
        updateLabel(attatched: sender)
        
        switch sender.tag {
        case 0: // X-axis
            sceneKitManager.updateRotation(x: Float(radians), y: nil, z: nil)
        case 1: // Y-axis
            sceneKitManager.updateRotation(x: nil, y: Float(radians), z: nil)
        case 2: // Z-axis
            sceneKitManager.updateRotation(x: nil, y: nil, z: Float(radians))
        case 3: // Yaw
            sceneKitManager.updatePos(x: Float(radians), y: nil, z: nil)
        case 4: // Pitch
            sceneKitManager.updatePos(x: nil, y: Float(radians), z: nil)
        case 5: // Roll
            sceneKitManager.updatePos(x: nil, y: nil, z: Float(radians))
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let pos   = SCNVector3(x: sliders[3].value, y: sliders[4].value, z: sliders[5].value)
        let angle = SCNVector3(x: sliders[0].value, y: sliders[1].value, z: sliders[2].value)
        let keyframe = AstralSceneKeyframe(timeWait: 0.5, timeApply: 2, position: pos, eulerAngles: angle)
        keyframeManager.setKeyframe(at: selectedFrameIndex, from: keyframe)
    }
}
