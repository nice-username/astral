//
//  AstralPathNodeActionMenu.swift
//  astral
//
//  Created by Joseph Haygood on 1/5/24.
//

import Foundation

class AstralPathNodeActionMenu: AstralStageEditorPopupMenu {
    override init(size: CGSize, title: String = "") {
        super.init(size: size, title: title)
        background.name = "nodeActionMenuBackground"
        
        // Add options to the menu
        addMenuOption(text: "Move", fontSize: 32)
        addMenuOption(text: "Turn left", fontSize: 32)
        addMenuOption(text: "Turn right", fontSize: 32)
        addMenuOption(text: "Use weapon", fontSize: 32)
        addMenuOption(text: "Stop attacking", fontSize: 32)
        addMenuOption(text: "Delete", fontSize: 32)
        layoutMenuOptions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
