//
//  RotationGestureRecognizer.swift
//  Knob
//
//  Created by Mr.Dong on 2021/2/19.
//

import UIKit

class RotationGestureRecognizer: UIPanGestureRecognizer {

    private(set) var deltaAngle: CGFloat = 0
    
    private var prevAngle: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view = view else { return }
        let touchPoint = touch.location(in: view)
        prevAngle = angle(for: touchPoint, in: view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view = view else { return }
        let touchPoint = touch.location(in: view)
        let touchAngle = angle(for: touchPoint, in: view)
        let newDelta = touchAngle - prevAngle
        prevAngle = touchAngle
        if newDelta > CGFloat.pi || newDelta < -CGFloat.pi { return }
        deltaAngle = newDelta
    }
    
    private func angle(for point: CGPoint, in view: UIView) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - view.bounds.midX, y: point.y - view.bounds.midY)
        return atan2(centerOffset.y, centerOffset.x)
    }
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }
}
