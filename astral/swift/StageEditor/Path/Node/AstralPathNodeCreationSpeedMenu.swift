//
//  AstralPathNodeCreationSpeedMenu.swift
//  astral
//
//  Created by Joseph Haygood on 5/14/24.
//

import Foundation

class AstralPathNodeCreationSpeedMenu: AstralStageEditorPopupMenu {
    private var countStepper: AstralStageEditorMenuStepper
    
    override init(size: CGSize, title: String = "") {
        countStepper = AstralStageEditorMenuStepper(minValue: 20, maxValue: 10000, stepValue: 10)
        countStepper.zPosition = 9
        super.init(size: size, title: title)
        
        name = title + "Menu"
        background.name = "nodeCreationMenuBackground"
        
        addChild(countStepper)
        
        addMenuOption(text: "Set movement speed to", fontSize: 32)
        addMenuOption(text: "", fontSize: 32)
        layoutMenuOptions()
        
        self.menuOptions[0].position.y -= 32
        countStepper.position = CGPoint(x: background.frame.maxX - 50, y: self.menuOptions[0].frame.midY - 2)
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
