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
    private var activationProgressSlider: UISlider!
    private var deactivationProgressSlider: UISlider!
    private var endBehaviorSegmentedControl: UISegmentedControl!
    private var segmentCountLabel: UILabel!
    private var nodeCountLabel: UILabel!
    private var updateButton: UIButton!


    
    // MARK: - Properties
    var path: AstralStageEditorPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPathData()
    }

    // MARK: - Setup UI
    private func setupUI() {
        createdSegmentedControl(labelText: "Direction", options:["Forwards","Backwards"], height: 34.0, isFirstControl: true)
        setupSliderWithLabelAndTextField(sliderTitle: "Enter", tag: 1, height: 34.0)
        setupSliderWithLabelAndTextField(sliderTitle: "Exit", tag: 2, height: 34.0)
        createdSegmentedControl(labelText: "Ending", options:["Loop","Reverse","Stop"], height: 34.0)
        let _ = createCounterLabel("Segments", height: 34.0)
        let _ = createCounterLabel("Nodes", height: 34.0)
    }

    // MARK: - Load Data
    private func loadPathData() {
        // Load data from `astralPath` into UI components
    }

    // MARK: - Actions
    @objc private func updateButtonTapped() {
        // Handle the update logic here
        // Validate inputs and update `astralPath` properties
    }
}
