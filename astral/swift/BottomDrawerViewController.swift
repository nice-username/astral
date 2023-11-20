//
//  BottomDrawerViewController.swift
//  astral
//
//  Created by Joseph Haygood on 11/19/23.
//
import Foundation
import UIKit

class BottomDrawerViewController: UIViewController {
    var isMenuRevealed = false
    var controlScrollView: UIScrollView!
    var panGesture: UIPanGestureRecognizer!
    var bottomBlurView: UIVisualEffectView!
    var minimizedHeight: CGFloat
    var maximizedHeight: CGFloat
    
    init(minHeight: CGFloat, maxHeight: CGFloat) {
        self.minimizedHeight = minHeight
        self.maximizedHeight = maxHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlurEffect()
        setupControlScrollView()
        setupPanGesture()
    }

    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        bottomBlurView = UIVisualEffectView(effect: blurEffect)
        bottomBlurView.frame = CGRect(x: 0, y: view.bounds.height - minimizedHeight, width: view.bounds.width, height: maximizedHeight)
        view.addSubview(bottomBlurView)
    }

    private func setupControlScrollView() {
        controlScrollView = UIScrollView()
        controlScrollView.frame = bottomBlurView.bounds
        bottomBlurView.contentView.addSubview(controlScrollView)
        controlScrollView.alpha = 0.0
    }

    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bottomBlurView.addGestureRecognizer(panGesture)
        panGesture.cancelsTouchesInView = false
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: bottomBlurView)
        let velocity = gesture.velocity(in: bottomBlurView)

        switch gesture.state {
        case .began, .changed:
            updateBottomView(translation: translation)
        case .ended, .cancelled:
            if isMenuRevealed {
                if shouldHideMenu(translation: translation, velocity: velocity) {
                    hideMenu()
                } else {
                    revealMenu()
                }
            } else {
                if shouldRevealMenu(translation: translation, velocity: velocity) {
                    revealMenu()
                } else {
                    hideMenu()
                }
            }
        default:
            break
        }
    }

    private func shouldRevealMenu(translation: CGPoint, velocity: CGPoint) -> Bool {
        return velocity.y < -500 || translation.y <= -64
    }

    private func shouldHideMenu(translation: CGPoint, velocity: CGPoint) -> Bool {
        return velocity.y > 500 || translation.y > 64
    }

    func revealMenu() {
        isMenuRevealed = true
        UIView.animate(withDuration: 0.166667) {
            self.bottomBlurView.frame.origin.y = (self.view.frame.height - self.bottomBlurView.frame.height)
            self.controlScrollView.alpha = 1.0
        }
    }

    func hideMenu() {
        isMenuRevealed = false
        UIView.animate(withDuration: 0.166667) {
            self.bottomBlurView.frame.origin.y = self.view.frame.height - self.minimizedHeight
            self.controlScrollView.alpha = 0.0
        }
    }

    private func updateBottomView(translation: CGPoint) {
        var targetY: CGFloat = 0.0

        if isMenuRevealed {
            targetY = self.view.frame.height - maximizedHeight + translation.y / 2
            targetY = max(self.view.frame.height - maximizedHeight, targetY)
        } else {
            targetY = self.view.frame.height - minimizedHeight + translation.y / 2
            targetY = min(self.view.frame.height - minimizedHeight, targetY)
        }
        
        // Clamp the targetY to ensure it does not exceed maximizedHeight
        targetY = min(self.view.frame.height - minimizedHeight, max(self.view.frame.height - maximizedHeight, targetY))

        // Update the bottomBlurView's position
        self.bottomBlurView.frame.origin.y = targetY
    }}
