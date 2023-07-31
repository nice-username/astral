//
//  AstralStageEditorToolbarButton.swift
//  astral
//
//  Created by Joseph Haygood on 7/30/23.
//

import Foundation
import UIKit

class AstralStageEditorToolbarButton: UIButton {
    let action: () -> Void
    
    init(icon: UIImage, action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        self.setImage(icon, for: .normal)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTapped() {
        action()
    }
}
