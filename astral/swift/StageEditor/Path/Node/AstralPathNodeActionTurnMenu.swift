//
//  AstralPathNodeActionTurnMenu.swift
//  astral
//
//  Created by Joseph Haygood on 1/10/24.
//

import Foundation

class AstralPathNodeActionTurnMenu: AstralStageEditorPopupMenu {
    private var angleStepper: AstralStageEditorMenuStepper
    private var durationStepper: AstralStageEditorMenuStepper

    override init(size: CGSize, title: String = "") {
        angleStepper = AstralStageEditorMenuStepper(minValue: 0, maxValue: 360, stepValue: 15, unitSuffix: "°")
        durationStepper = AstralStageEditorMenuStepper(minValue: 0, maxValue: 8, stepValue: 0.1)
        angleStepper.zPosition = 9
        durationStepper.zPosition = 9

        super.init(size: size, title: title)
        
        name = title + "Menu"
        background.name = "nodeActionMenuBackground"

        addChild(angleStepper)
        addChild(durationStepper)
        addMenuOption(text: "Turn           over         seconds.", fontSize: 32)
        addMenuOption(text: "", fontSize: 32)

        self.layoutMenuOptions()
        
        self.menuOptions[0].position.y -= 32
        self.titleLabel.position.y -= 4
        angleStepper.position = CGPoint(x: background.frame.minX + 128, y: self.menuOptions[0].frame.midY - 6)
        durationStepper.position = CGPoint(x: background.frame.midX + 44, y: self.menuOptions[0].frame.midY - 6)
    }
    
    func getAngle() -> CGFloat {
        return angleStepper.currentValue
    }
    
    func setAngle(_ angle: CGFloat) {
        angleStepper.currentValue = angle
    }
    
    func getDuration() -> CGFloat {
        return durationStepper.currentValue
    }
    
    func setDuration(_ duration: CGFloat) {
        durationStepper.currentValue = duration
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
