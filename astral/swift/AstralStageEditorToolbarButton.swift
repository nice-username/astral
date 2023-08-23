//
//  AstralStageEditorToolbarButton.swift
//  astral
//
//  Created by Joseph Haygood on 7/30/23.
//

import Foundation
import UIKit

enum AstralStageEditorToolbarButtonType {
    case topLevel
    case secondLevel
}

class AstralStageEditorToolbarButton: UIButton {
    let type: AstralStageEditorToolbarButtonType
    let action: () -> Void
    let submenuType: AstralStageEditorToolbarSubViewType
    let submenuString: String
    let submenuImage: UIImage
    private var submenuLabel: UILabel?
    weak var delegate: AstralStageEditorToolbarButtonDelegate?

    
    override var intrinsicContentSize: CGSize {
        switch self.type {
        case .topLevel:
            return CGSize(width: 64, height: 64) // 64 x 64 for top-level buttons
        case .secondLevel:
            return CGSize(width: 128, height: 64) // Longer rectangles for submenu buttons
        }
    }
    
    
    init(icon: UIImage?,
         action: @escaping () -> Void,
         type: AstralStageEditorToolbarButtonType,
         submenuType: AstralStageEditorToolbarSubViewType,
         submenuString: String? = nil,
         submenuImage: UIImage? = nil) {
        self.action        = action
        self.type          = type
        self.submenuType   = submenuType
        self.submenuString = submenuString ?? ""
        self.submenuImage  = submenuImage ?? UIImage()
        super.init(frame: .zero)
        
        if let submenuString = submenuString, !submenuString.isEmpty {
            submenuLabel = UILabel()
            submenuLabel?.text = submenuString
            submenuLabel?.textAlignment = .left
            addSubview(submenuLabel!)
        } else {
            submenuLabel = nil
        }
        
        self.layer.zPosition = 3
        
        let padding = 10.0
        self.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

        if let iconImage = icon {
            self.setImage(iconImage, for: .normal)
        }
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        switch self.type {
        case .topLevel:
            self.backgroundColor = .white
        case .secondLevel:
            self.backgroundColor = .lightGray
            if let submenuImg = submenuImage {
               self.setImage(submenuImg, for: .normal)
            }
        }
    }
    
    
    
    // Override the layoutSubviews method to set the frames of the image and label
        override func layoutSubviews() {
            super.layoutSubviews()

            // Layout the image
            // self.imageView?.frame = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height)
        
            if !submenuString.isEmpty {
                let labelX = self.bounds.height + 5 // 5 is the spacing between the image and label
                submenuLabel?.frame = CGRect(x: labelX, y: 0, width: self.bounds.width - labelX, height: self.bounds.height)
                
            }
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTapped() {
        delegate?.didTapButton(self)
    }
}
