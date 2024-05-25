//
//  AstralSceneKeyframeViewCell.swift
//  astral
//
//  Created by Joseph Haygood on 5/23/24.
//

import Foundation
import UIKit

// Custom UICollectionViewCell
class AstralSceneKeyframeViewCell: UICollectionViewCell {
    let nameLabel = UILabel()
    let progressBar = UIProgressView(progressViewStyle: .default)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            progressBar.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            progressBar.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
}
