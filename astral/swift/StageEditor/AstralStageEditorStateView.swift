//
//  AstralStageEditorStateView.swift
//  astral
//
//  Created by Joseph Haygood on 3/3/24.
//

import Foundation
import UIKit

class AstralStageEditorStateView: UIView {
    private let iconImageView = UIImageView()
    private let stateLabel = UILabel()

    var iconPadding: CGFloat = 8     // Padding between icon and label
    var viewPadding: CGFloat = 16    // Padding inside the view for the label and icon
    var edgeMargin: CGFloat = 20     // Margin from the screen edges
    
    private var iconWidthConstraint: NSLayoutConstraint?
    private var labelLeadingConstraint: NSLayoutConstraint?

    init(icon: UIImage? = nil, message: String, fontSize: CGFloat = 24, height: CGFloat = 76) {
        super.init(frame: .zero)
        setupView(height: height, fontSize: fontSize)
        configure(with: icon, message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(height: CGFloat, fontSize: CGFloat) {
        // View styling
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        // Icon setup
        iconImageView.contentMode = .scaleAspectFit
        self.addSubview(iconImageView)
        
        // Label setup
        stateLabel.font = UIFont.systemFont(ofSize: fontSize)
        stateLabel.textColor = UIColor.white
        self.addSubview(stateLabel)
        
        // Setup constraints
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconWidthConstraint = iconImageView.widthAnchor.constraint(equalToConstant: height - 2 * viewPadding)
        labelLeadingConstraint = stateLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: iconPadding)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height),
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: viewPadding),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            labelLeadingConstraint!,
            stateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -viewPadding),
            stateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    

    func configure(with icon: UIImage?, message: String) {
        iconImageView.image = icon
        
        if let _ = icon {
            iconWidthConstraint?.constant = self.frame.height - 2 * viewPadding
            labelLeadingConstraint?.constant = iconPadding
        } else {
            iconWidthConstraint?.constant = 0 // Remove the icon's width
            labelLeadingConstraint?.constant = 0 // Adjust label leading to align with view's leading
        }
        
        iconWidthConstraint?.isActive = true
        labelLeadingConstraint?.isActive = true
        
        stateLabel.text = message
    }
    
    func showInView(_ view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeMargin),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeMargin),
            self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -edgeMargin)
        ])
    }
}
