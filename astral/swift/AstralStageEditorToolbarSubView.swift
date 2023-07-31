//
//  AstralStageEditorToolbarSubView.swift
//  astral
//
//  Created by Joseph Haygood on 7/30/23.
//

import Foundation
import UIKit

class AstralStageEditorToolbarSubView: UIView {
    var stackView: UIStackView!
    
    init(options: [AstralStageEditorToolbarButton]) {
        super.init(frame: .zero)
        self.stackView = UIStackView()
        self.stackView.axis = .vertical
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 8 // Add spacing if you want
        self.addSubview(stackView)
        
        // Constraints for stackView...
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        setButtons(options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButtons(_ buttons: [AstralStageEditorToolbarButton]) {
        // Clear previous buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new buttons
        for button in buttons {
            self.stackView.addArrangedSubview(button)
        }
    }
}
