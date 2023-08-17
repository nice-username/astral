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
    var secondaryToolbarOpened = false
    var subViewFullyOpen = false
    
    var toolbarSubMenu: AstralStageEditorToolbarSubView!
    var lastSelectedSubmenuType: AstralStageEditorToolbarSubViewType = .file
    var selectedSubmenuType: AstralStageEditorToolbarSubViewType = .file
    let selectionCursor: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 128 / 255.0)
        view.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        view.layer.zPosition = 3
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let r = CGFloat( 24 / 255.0 )
        let g = CGFloat( 32 / 255.0 )
        let b = CGFloat( 48 / 255.0 )
        let a = CGFloat( 255 / 255.0 )
        self.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a)
        self.addSubview(selectionCursor)
    
        self.stackView = UIStackView()
        self.stackView.axis = .vertical
        self.stackView.distribution = .equalSpacing
        self.stackView.alignment = .center
        self.stackView.spacing = 0
        self.addSubview(stackView)
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 64 * 4 + 4)
        ])
        
        self.toolbarSubMenu = AstralStageEditorToolbarSubView(type: self.selectedSubmenuType)
        self.addSubview(toolbarSubMenu)
        
        toolbarSubMenu.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbarSubMenu.leftAnchor.constraint(equalTo: self.rightAnchor),
            toolbarSubMenu.centerYAnchor.constraint(equalTo: self.centerYAnchor), // Centered with stackView
            toolbarSubMenu.widthAnchor.constraint(equalToConstant: 224), // Fixed width
            toolbarSubMenu.heightAnchor.constraint(equalTo: self.heightAnchor) // Same height as stackView
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //
    //
    //
    func createSubBar() {
        print("createSubBar()")
        self.setSubMenu(self.selectedSubmenuType)
        // self.toolbarSubMenu.frame = CGRect(x: self.frame.size.width, y: 0, width: 64, height: self.frame.size.height)
        self.addSubview(self.toolbarSubMenu)
    }
    
    
    //
    //
    //
    func setButtons(_ buttons: [AstralStageEditorToolbarButton]) {
        for button in buttons {
            // Add button to stackView
            self.stackView.addArrangedSubview(button)
            
            // Set button size constraints
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 64), // height for each button
                button.widthAnchor.constraint(equalTo: self.widthAnchor) // width same as toolbar
            ])
        }
    }
    
    
    
    //
    //
    //
    func setSubMenu(_ subViewType: AstralStageEditorToolbarSubViewType) {
        // Define an array to hold the submenu options
        let options: [AstralStageEditorToolbarButton]
        switch subViewType {
        case .file:
            options = [
                AstralStageEditorToolbarButton(icon: nil, action: {}, type: .secondLevel, submenuType: .file, submenuString: "File", submenuImage: UIImage(named: "file")),
                AstralStageEditorToolbarButton(icon: nil, action: {}, type: .secondLevel, submenuType: .file, submenuString: "New", submenuImage: UIImage(named: "new"))
            ]
        case .transition:
            options = [
                AstralStageEditorToolbarButton(icon: nil, action: {}, type: .secondLevel, submenuType: .transition, submenuString: "Idk lol", submenuImage: UIImage(named: "menu"))
            ]
        case .path:
            options = [
                AstralStageEditorToolbarButton(icon: nil, action: {}, type: .secondLevel, submenuType: .transition, submenuString: "Idk lol", submenuImage: UIImage(named: "menu"))
            ]
        case .enemy:
            options = [
                AstralStageEditorToolbarButton(icon: nil, action: {}, type: .secondLevel, submenuType: .transition, submenuString: "Idk lol", submenuImage: UIImage(named: "menu"))
            ]
             
        }
        
        // let subview = AstralStageEditorToolbarSubView(type: subViewType)
        // self.toolbarSubMenu = subview
    }
    
    
    
    //
    // Returns the closest UIButton on the toolbar
    //
    func getClosestButton(to point: CGPoint) -> AstralStageEditorToolbarButton {
        var closestButton: AstralStageEditorToolbarButton? = nil
        var smallestDistance: CGFloat = CGFloat.infinity
        for view in self.stackView.arrangedSubviews {
            if let button = view as? AstralStageEditorToolbarButton {
                let buttonY = self.stackView.convert(button.center, to: self).y
                let distance = abs(buttonY - point.y)
                if distance < smallestDistance {
                    smallestDistance = distance
                    closestButton = button
                }
            }
        }
        return closestButton!
    }
    
    
    //
    // Handles moving the cursor and defining what button is currently selected
    //
    func snapCursorToButton(at touchLocation: CGPoint) {
    
        let closestButton = self.getClosestButton(to: touchLocation)
        let newY = closestButton.center.y + (self.frame.size.height / 2) - (closestButton.frame.size.height * 2) - 2
        UIView.animate(withDuration: 0.3333, delay: 0.0, options: .curveEaseOut) {
            self.selectionCursor.center.y = newY
        }
        
        var type: AstralStageEditorToolbarSubViewType
        switch closestButton {
        case self.stackView.arrangedSubviews[0]:
            type = .file
        case self.stackView.arrangedSubviews[1]:
            type = .transition
        case self.stackView.arrangedSubviews[2]:
            type = .path
        case self.stackView.arrangedSubviews[3]:
            type = .enemy
        default:
            return
        }
        
        if type != lastSelectedSubmenuType {
            self.setSubMenu(type)
            self.toolbarSubMenu.type = type
            self.toolbarSubMenu.setTitle()            
            self.toolbarSubMenu.updateButtons()
        }
        
        self.selectedSubmenuType = type
        self.lastSelectedSubmenuType = type
    }
}
