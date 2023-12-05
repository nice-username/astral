//
//  AstralStageEditorToolbarSubView.swift
//  astral
//
//  Created by Joseph Haygood on 7/30/23.
//

import Foundation
import UIKit
import SpriteKit


struct AstralStageEditorToolbarAction {
    let title: String
    let imageName: String
}

enum AstralStageEditorToolbarSubViewType {
    case file, transition, path, enemy
    
    var actions: [AstralStageEditorToolbarAction] {
        switch self {
        case .file:
            return [
                AstralStageEditorToolbarAction(title: "Create new", imageName: "new"),
                AstralStageEditorToolbarAction(title: "Open", imageName: "open"),
                AstralStageEditorToolbarAction(title: "Save", imageName: "save"),
                AstralStageEditorToolbarAction(title: "Rename", imageName: "edit"),
                AstralStageEditorToolbarAction(title: "Stage length", imageName: "length"),
                AstralStageEditorToolbarAction(title: "Start", imageName: "play"),
                AstralStageEditorToolbarAction(title: "Main menu", imageName: "exit")
            ]
        case .transition:
            return [
                AstralStageEditorToolbarAction(title: "Initial art", imageName: "background"),
                AstralStageEditorToolbarAction(title: "Location", imageName: "point"),
                AstralStageEditorToolbarAction(title: "Animation", imageName: "transition_arrow"),
                // AstralStageEditorToolbarAction(title: "Duration", imageName: ""),
            ]
        case .path:
            return [
                AstralStageEditorToolbarAction(title: "Create", imageName: "path_add"),
                AstralStageEditorToolbarAction(title: "Add node", imageName: "node_add")
            ]
        case .enemy:
            return [
                AstralStageEditorToolbarAction(title: "Spritesheet", imageName: "ufo")
            ]
        }
    }
}


class AstralStageEditorToolbarSubView: UIView {
    var scene: SKScene
    var gameState: AstralGameStateManager?    
    var type: AstralStageEditorToolbarSubViewType
    var fileManager: AstralStageFileManager?
    var buttons: [UIButton] = []
    var stackView: UIStackView!
    var titleLabel: UILabel = UILabel()
    var titleSeparator: UIView = UIView()
    var titleIcon: UIImageView?
    var leftConstraint: NSLayoutConstraint!

    
    init(type: AstralStageEditorToolbarSubViewType, scene: SKScene) {
        self.scene = scene
        self.gameState = AstralGameStateManager.shared
        self.type = type
        
        super.init(frame: .zero)
        self.addSubview(self.titleLabel)
        self.addSubview(titleSeparator)
        
        titleSeparator.backgroundColor = .black
        
        self.stackView = UIStackView()
        self.addSubview(stackView)
        
        self.stackView.axis = .vertical
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 1
        self.stackView.alignment = .fill
        self.stackView.backgroundColor = .black
        self.backgroundColor = .darkGray
        
        self.setTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setAlpha(_ alpha: CGFloat) {
        stackView.arrangedSubviews.forEach { $0.alpha = alpha }
        titleLabel.alpha = alpha
        titleIcon?.alpha = alpha
    }

    
    
    func resizeStackView() {
        let buttonHeight: CGFloat = 54
        let stackHeight = (CGFloat(buttons.count) * buttonHeight) + CGFloat(buttons.count)
        
        stackView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: titleSeparator.topAnchor, constant: 1),
            stackView.heightAnchor.constraint(equalToConstant: stackHeight),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
    }
    
    
    
    //
    // Set title label and icon image
    //
    func setTitle() {
        if let icon = self.titleIcon {
            icon.removeFromSuperview()
        }
        
        self.titleLabel.font = UIFont(name: "Helvetica Neue", size: 32.0)
        self.titleLabel.textColor = .black
        
        switch self.type {
        case .file:
            self.titleLabel.text = "File"
            self.titleIcon = UIImageView(image: UIImage(named: "file_tool"))
        case .transition:
            self.titleLabel.text = "Transitions"
            self.titleIcon = UIImageView(image: UIImage(named: "transition"))
        case .path:
            self.titleLabel.text = "Paths"
            self.titleIcon = UIImageView(image: UIImage(named: "path_tool"))
        case .enemy:
            self.titleLabel.text = "Enemies"
            self.titleIcon = UIImageView(image: UIImage(named: "enemy"))
        }
        
        self.addSubview(titleIcon!)
    
        self.titleIcon?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleIcon!.topAnchor.constraint(equalTo: self.topAnchor, constant: 48),
            self.titleIcon!.heightAnchor.constraint(equalToConstant: 32),
            self.titleIcon!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.titleIcon!.widthAnchor.constraint(equalToConstant: 32)
        ])
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: titleIcon!.topAnchor, constant: -16),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 64),
            self.titleLabel.leadingAnchor.constraint(equalTo: titleIcon!.trailingAnchor, constant: 12),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 192)
        ])
        
        titleSeparator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleSeparator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleSeparator.heightAnchor.constraint(equalToConstant: 2),
            titleSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    
    func updateButtons() {
        self.buttons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let actions = type.actions
        var buttonIndex = 0
        for action in actions {
            let button = UIButton(type: .custom)
            button.setTitle(action.title, for: .normal)
            
            button.setImage(UIImage(named: action.imageName), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.clipsToBounds = true
            button.imageView?.layer.masksToBounds = true
            
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 18.0)
            button.contentHorizontalAlignment = .left
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.tag = buttonIndex
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            // Set the image view size
            button.imageView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.imageView!.topAnchor.constraint(equalTo: button.topAnchor, constant: 8),
                button.imageView!.leftAnchor.constraint(equalTo: button.leftAnchor, constant: 16),
                button.imageView!.widthAnchor.constraint(equalToConstant: 36),
                button.imageView!.heightAnchor.constraint(equalToConstant: 36)
            ])
            
            stackView.addArrangedSubview(button)
            buttons.append(button)
            buttonIndex += 1
        }
        if type == .file {
            
        }
        
        self.resizeStackView()
    }
    
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }
        switch type {
        case .file:
            self.handleFileAction(at: index)
        case .transition:
            self.handleTransitionAction(at: index)
        case .path:
            self.handlePathAction(at: index)
            break
        case .enemy:
            break
        }
    }
    
    private func handlePathAction(at index: Int) {
        switch index {
        case 0:
            self.gameState?.presentPathManager()
        case 1:
            self.gameState?.dismissPathManager()
        default:
            break
        }
    }
    
    private func handleFileAction(at index: Int) {
        self.fileManager = AstralStageFileManager()
        
        switch index {
        case 0:
            print("New")
        case 1:
            NotificationCenter.default.post(name: .loadFile, object: nil)
        case 2:
            NotificationCenter.default.post(name: .saveFile, object: nil)
        case 3:
            print("rename")
        case 4:
            print("set length")
        case 5:
            if self.gameState?.currentState == .editorPlay {
                self.buttons[5].setImage(UIImage(named: "play"), for: .normal)
                self.buttons[5].setTitle("Play", for: .normal)
                self.gameState?.transitionTo(.editorStop)
            } else {
                self.buttons[5].setImage(UIImage(named: "stop"), for: .normal)
                self.buttons[5].setTitle("Stop", for: .normal)
                self.gameState?.transitionTo(.editorPlay)
            }
        default:
            break
        }
    }
    
    
    private func handleTransitionAction(at index: Int) {
        switch index {
        case 0:
            self.gameState?.transitionTo(.editorParallaxBackgroundPicker)
        case 1:
            print("Location")
        case 2:
            print("Animation")
        default:
            break
        }
    }
}
