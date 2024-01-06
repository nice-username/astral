//
//  AstralStageEditorPathNodeTypeMenu.swift
//  astral
//
//  Created by Joseph Haygood on 1/2/24.
//

import Foundation
import SpriteKit

class AstralStageEditorPathNodeTypeMenu: AstralStageEditorPopupMenu {
    override init(size: CGSize) {
        super.init(size: size)
        
        // Add options to the menu
        addMenuOption(text: "Creation", fontSize: 32)
        addMenuOption(text: "Action", fontSize: 32)
        addMenuOption(text: "Pathing", fontSize: 32)
        layoutMenuOptions()
        
        menuOptions[2].position.y -= 8
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
