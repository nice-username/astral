//
//  AstralStageEditorPathManagerViewController.swift
//  astral
//
//  Created by Joseph Haygood on 11/13/23.
//

import Foundation
import UIKit
import SpriteKit

class AstralStageEditorPathManagerViewController: BottomDrawerViewController {
    // MARK: - UI Components
    private var nameTextField: UITextField!
    private var directionSwitch: UISegmentedControl!
    private var activationSlider: UISlider!
    private var deactivationSlider: UISlider!
    private var endBehaviorControl: UISegmentedControl!
    private var segmentCountLabel: UILabel!
    private var nodeCountLabel: UILabel!
    private var updateButton: UIButton!
    private var gameState: AstralGameStateManager!

    // MARK: - Properties
    var path: AstralStageEditorPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameState = AstralGameStateManager.shared
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        let floatHeight = Float(gameState.stageHeight)
        directionSwitch = createdSegmentedControl(labelText: "Direction", options:["Forwards","Backwards"], height: 34.0, isFirstControl: true)
        activationSlider = setupSliderWithLabelAndTextField(sliderTitle: "Enter", maxValue: floatHeight, height: 34.0)
        deactivationSlider = setupSliderWithLabelAndTextField(sliderTitle: "Exit", maxValue: floatHeight, height: 34.0, initialValue: floatHeight)
        endBehaviorControl = createdSegmentedControl(labelText: "Ending", options:["Loop","Reverse","Stop"], height: 34.0)
        let _ = createCounterLabel("Segments", height: 34.0)
        let _ = createCounterLabel("Nodes", height: 34.0)
        let applyBtn = createFullWidthButton(labelText: "Apply", backgroundColor: .clear, borderColor: .systemGreen, textColor: .white, height: 34.0)
        let cancelBtn = createFullWidthButton(labelText: "Cancel", backgroundColor: .clear, borderColor: .white, textColor: .white, height: 34.0)
        let deleteBtn = createFullWidthButton(labelText: "Delete", backgroundColor: .clear, borderColor: .systemRed, textColor: .white, height: 34.0)
        
        cancelBtn.addAction {
            self.gameState.dismissPathManager()
        }
        
        applyBtn.addAction {
            self.savePathData()
            self.hideMenu()
        }
        
        deleteBtn.addAction {
            NotificationCenter.default.post(name: .pathDelete, object: nil)
            self.gameState.dismissPathManager()
        }
    }

    // MARK: - Load Data
    public func loadPathData(_ path: AstralStageEditorPath) {
        self.path = path

        self.titleLabel?.text = path.name
        activationSlider.value = path.activationProgress
        deactivationSlider.value = path.deactivationProgress
        sliderUpdateTextTag(activationSlider)
        sliderUpdateTextTag(deactivationSlider)
        
        switch path.direction {
        case .forwards:
            directionSwitch.selectedSegmentIndex = 0
        case .backwards:
            directionSwitch.selectedSegmentIndex = 1
        }
        
        switch path.endBehavior {
        case .loop:
            endBehaviorControl.selectedSegmentIndex = 0
        case .reverse:
            endBehaviorControl.selectedSegmentIndex = 1
        case .stop:
            endBehaviorControl.selectedSegmentIndex = 2
        }
    }
    
    public func savePathData() {
        path?.activationProgress = activationSlider.value
        path?.deactivationProgress = deactivationSlider.value
        
        switch directionSwitch.selectedSegmentIndex {
        case 0:
            path?.direction = .forwards
        case 1:
            path?.direction = .backwards
        default:
            break
        }
        
        switch endBehaviorControl.selectedSegmentIndex {
        case 0:
            path?.endBehavior = .loop
        case 1:
            path?.endBehavior = .reverse
        case 2:
            path?.endBehavior = .stop
        default:
            break
        }
        
        NotificationCenter.default.post(name: .pathApplyChanges, object: nil, userInfo: ["path": path!])
    }

    // MARK: - Actions
    @objc private func updateButtonTapped() {
        // Handle the update logic here
        // Validate inputs and update `astralPath` properties
    }
}
