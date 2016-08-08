//
//  ThumbSliderView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

@IBDesignable
class ThumbSliderView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var powerOffLabel: UIView!
    @IBOutlet weak var backgroundLeadingConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        let view = addOwnedViewFrom(nibNamed: String(ThumbSliderView.self))
        view.backgroundColor = .clearColor()
        
        backgroundView.backgroundColor = .purpleColor()
        thumbView.backgroundColor = .greenColor() // TODO: remove this
        
        setupThumbView()
    }
    
    func setupThumbView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(thumbViewWasPanned))
        thumbView.addGestureRecognizer(panGesture)
        panGesture.enabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: rounded corners don't look quite right
        backgroundView.layer.cornerRadius = backgroundView.bounds.size.height / 2.0
        thumbView.roundCornersToFormCircle()
    }
    
    // MARK: - Gesture Handling
    
    func thumbViewWasPanned(recognizer: UIPanGestureRecognizer) {
        // Note that slider is prevented from sliding past its end by making the
        // backgroundLeadingConstraint priority lower in the xib 

        let updatePowerOffLabel: () -> () = {
            // Hide the power off label when the slider is panned
            let desiredPowerOffLabelAlpha: CGFloat = (self.backgroundLeadingConstraint.constant == 0) ? 1.0 : 0.0
            if self.powerOffLabel.alpha != desiredPowerOffLabelAlpha {
                UIView.animateWithDuration(0.10, animations: {
                    self.powerOffLabel.alpha = desiredPowerOffLabelAlpha
                })
            }
        }
        
        switch recognizer.state {
        case .Possible, .Began:
            break
            
        case .Changed:
            let translation = recognizer.translationInView(self)
            backgroundLeadingConstraint.constant = max(translation.x, 0)
            updatePowerOffLabel()
            
        case .Ended, .Cancelled, .Failed:
            layoutIfNeeded()
            
            // Animate the slider back after the user lifts up and
            // it didn't pass the threshold
            UIView.animateWithDuration(0.10, animations: { 
                self.backgroundLeadingConstraint.constant = 0
                self.layoutIfNeeded()
            }, completion: { (finished) in
                if finished {
                    updatePowerOffLabel()
                }
            })
        }
        
    }
}
