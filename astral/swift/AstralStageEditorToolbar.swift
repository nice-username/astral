//
//  AstralStageEditorToolbar.swift
//  astral
//
//  Created by Joseph Haygood on 7/30/23.
//

import Foundation
import UIKit

class AstralStageEditorToolbar: UIView {
    var stackView: UIStackView!
    var validGestureStarted = false
    var secondLevelToolbar: AstralStageEditorToolbarSubView!
    var secondaryToolbarOpened = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let r = CGFloat( 24 / 255.0 )
        let g = CGFloat( 64 / 255.0 )
        let b = CGFloat( 224 / 255.0 )
        let a = CGFloat( 128 / 255.0 )
        self.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a)
        
        var options: [AstralStageEditorToolbarButton] = []
        self.secondLevelToolbar = AstralStageEditorToolbarSubView(options: options)
        self.addSubview(secondLevelToolbar)
        
        self.stackView = UIStackView()
        self.stackView.axis = .vertical
        self.stackView.distribution = .equalSpacing
        
        self.addSubview(stackView)
        // Constraints for stackView...
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSecondLevelButtons(for primaryButton: AstralStageEditorToolbarButton) {
        // Here we'll decide which buttons to show on the second level based on which primary button is selected
        // This function will be called when we detect that a primary button is being selected
    }
    
    func setToolSubViews(_ subViews: [AstralStageEditorToolbarSubView]) {
        for subView in subViews {
            self.stackView.addArrangedSubview(subView)
        }
    }
}
