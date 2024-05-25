//
//  AstralSceneKeyframeViewController.swift
//  astral
//
//  Created by Joseph Haygood on 5/23/24.
//

import Foundation
import UIKit


class AstralSceneKeyframeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var keyframeManager: AstralSceneKeyframeManager!
    var selectedFrameIndex: Int?
    var keyframePropertiesVC: AstralSceneKeyframePropertiesViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(AstralSceneKeyframeViewCell.self, forCellWithReuseIdentifier: "AstralSceneKeyframeViewCell")
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Keyframes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addKeyframe))
    }
    
    @objc private func addKeyframe() {
        print("add new keyframe")
        // Navigate to the keyframe editing view
        // Example:
        // let editVC = KeyframeEditViewController()
        // navigationController?.pushViewController(editVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keyframeManager.getAllKeyframes().count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AstralSceneKeyframeViewCell", for: indexPath) as! AstralSceneKeyframeViewCell
        let keyframe = keyframeManager.getKeyframe(at: indexPath.item)!
        cell.nameLabel.text = keyframe.name
        // TODO: Update progress bar
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60) // Adjust as needed
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFrameIndex = indexPath[1]
        
        // Navigate to the keyframe editing view
        let keyframe = keyframeManager.getKeyframe(at: indexPath[1])
        let values = [
            keyframe?.eulerAngles.x,
            keyframe?.eulerAngles.y,
            keyframe?.eulerAngles.z,
            keyframe?.position.x,
            keyframe?.position.y,
            keyframe?.position.z,
        ]
        
        keyframePropertiesVC = AstralSceneKeyframePropertiesViewController()
        keyframePropertiesVC.sceneKitManager = (parent?.parent as? GameViewController)?.sceneKitManager
        keyframePropertiesVC.keyframeManager = keyframeManager
        keyframePropertiesVC.selectedFrameIndex = selectedFrameIndex!
        keyframePropertiesVC.sliderValues = values
        
        navigationController?.pushViewController(keyframePropertiesVC, animated: true)
    }
}
