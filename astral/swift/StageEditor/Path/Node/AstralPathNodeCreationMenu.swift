//
//  AstralPathNodeCreationMenu.swift
//  astral
//
//  Created by Joseph Haygood on 4/6/24.
//

import Foundation

class AstralPathNodeCreationMenu: AstralStageEditorPopupMenu {
    override init(size: CGSize, title: String = "") {
        super.init(size: size, title: title)
        background.name = "nodeCreationMenuBackground"
        
        // Add options to the menu
        addMenuOption(text: "Move", fontSize: 32)
        addMenuOption(text: "Set count", fontSize: 32)
        addMenuOption(text: "Set type", fontSize: 32)
        addMenuOption(text: "Set speed", fontSize: 32)
        layoutMenuOptions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
