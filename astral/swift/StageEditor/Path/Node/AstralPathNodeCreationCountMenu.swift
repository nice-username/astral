//
//  AstralPathNodeCreationCountMenu.swift
//  astral
//
//  Created by Joseph Haygood on 5/6/24.
//

import Foundation

class AstralPathNodeCreationCountMenu: AstralStageEditorPopupMenu {
    private var countStepper: AstralStageEditorMenuStepper
    
    override init(size: CGSize, title: String = "") {
        countStepper = AstralStageEditorMenuStepper(minValue: 1, maxValue: 99, stepValue: 1)
        countStepper.zPosition = 9
        super.init(size: size, title: title)
        
        name = title + "Menu"
        background.name = "nodeCreationMenuBackground"
        
        addChild(countStepper)
        
        addMenuOption(text: "Create           entities", fontSize: 32)
        addMenuOption(text: "", fontSize: 32)
        layoutMenuOptions()
        
        self.menuOptions[0].position.y -= 32
        countStepper.position = CGPoint(x: background.frame.midX - 8, y: self.menuOptions[0].frame.midY - 6)
    }
    
    func setCount(_ count: Int) {
        self.countStepper.currentValue = CGFloat(count)
    }
    
    func getCount() -> Int {
        return Int(countStepper.currentValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
