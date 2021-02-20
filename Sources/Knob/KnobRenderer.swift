//
//  KnobRenderer.swift
//  Knob
//
//  Created by Mr.Dong on 2021/2/19.
//

import UIKit

class KnobRenderer {
    
    var trackColor: UIColor = .black {
        didSet {
            updateTrackLayerPath()
        }
    }
    
    var lineWidth: CGFloat = 2 {
        didSet {
            updateTrackLayerPath()
            updateGraduationLayerPath()
            updateLargeGraduationLayerPath()
            updateIndicatorLayerPath()
        }
    }
    
    var startAngle: CGFloat = 0 {
        didSet {
            updateTrackLayerPath()
            updateGraduationLayerPath()
            updateLargeGraduationLayerPath()
            indicatorLayer.transform = CATransform3DMakeRotation(startAngle, 0, 0, 1)
        }
    }
    
    var endAngle: CGFloat = CGFloat.pi * 2 {
        didSet {
            updateTrackLayerPath()
            updateGraduationLayerPath()
            updateLargeGraduationLayerPath()
        }
    }
    
    // MARK: 指针
    
    var indicatorType: IndicatorType = .circle(color: .red, radius: 12) {
        didSet {
            updateIndicatorLayerPath()
        }
    }
    
    // MARK: 刻度
    
    var graduations: Int = 50 {
        didSet {
            graduations = min(360, max(0, graduations))
            updateGraduationLayerPath()
        }
    }
    
    var graduationWidth: CGFloat = 1 {
        didSet {
            updateGraduationLayerPath()
        }
    }
    
    var graduationLength: CGFloat = 3 {
        didSet {
            updateGraduationLayerPath()
        }
    }
    
    var graduationColor: UIColor = .gray {
        didSet {
            updateGraduationLayerPath()
        }
    }
    
    var largeGraduations: Int = 10 {
        didSet {
            largeGraduations = min(360, max(0, largeGraduations))
            updateLargeGraduationLayerPath()
        }
    }
    
    var largeGraduationWidth: CGFloat = 2 {
        didSet {
            updateLargeGraduationLayerPath()
        }
    }
    
    var largeGraduationLength: CGFloat = 6 {
        didSet {
            updateLargeGraduationLayerPath()
        }
    }
    
    var largeGraduationColor: UIColor = .black {
        didSet {
            updateLargeGraduationLayerPath()
        }
    }
    
    let trackLayer = CAShapeLayer()
    let graduationLayer = CAShapeLayer()
    let largeGraduationLayer = CAShapeLayer()
    let indicatorLayer = CAShapeLayer()
    
    private(set) var indicatorAngle: CGFloat = 0
    
    func setIndicatorAngle(_ newIndicatorAngle: CGFloat, animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        indicatorLayer.transform = CATransform3DMakeRotation(newIndicatorAngle, 0, 0, 1)
        if animated {
            let minAngle = min(newIndicatorAngle, indicatorAngle)
            let maxAngle = max(newIndicatorAngle, indicatorAngle)
            let midAngle = (maxAngle - minAngle) / 2 + minAngle
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values = [indicatorAngle, midAngle, newIndicatorAngle]
            animation.keyTimes = [0, 0.5, 1]
            animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
            indicatorLayer.add(animation, forKey: nil)
        }
        CATransaction.commit()
        indicatorAngle = newIndicatorAngle
    }
    
    init() {
        trackLayer.fillColor = UIColor.clear.cgColor
        graduationLayer.fillColor = UIColor.clear.cgColor
        largeGraduationLayer.fillColor = UIColor.clear.cgColor
        indicatorLayer.lineCap = .round
    }
    
    func updateBounds(_ bounds: CGRect) {
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        updateTrackLayerPath()
        
        graduationLayer.bounds = trackLayer.bounds
        graduationLayer.position = trackLayer.position
        updateGraduationLayerPath()
        
        largeGraduationLayer.bounds = trackLayer.bounds
        largeGraduationLayer.position = trackLayer.position
        updateLargeGraduationLayerPath()
        
        indicatorLayer.bounds = trackLayer.bounds
        indicatorLayer.position = trackLayer.position
        updateIndicatorLayerPath()
    }
    
    // MARK: Private
    
    private func updateTrackLayerPath() {
        let bounds = trackLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        
        let ring = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.path = ring.cgPath
    }
    
    private func updateGraduationLayerPath() {
        graduationLayer.isHidden = graduations == 0
        if graduations == 0 { return }
        let bounds = graduationLayer.bounds
        let radius = min(bounds.width, bounds.height - lineWidth) / 2
        
        let graduation = UIBezierPath()
        let graduationsAngle = (endAngle - startAngle) / CGFloat(graduations)
        var renderAngle = startAngle
        let count = endAngle - startAngle == CGFloat.pi * 2 ? (graduations - 1) : graduations
        for _ in 0...count {
            graduation.move(to: CGPoint(x: radius * cos(renderAngle) + bounds.midX,
                                   y: radius * sin(renderAngle) + bounds.midY))
            graduation.addLine(to: CGPoint(x: (radius - graduationLength) * cos(renderAngle) + bounds.midX,
                                      y: (radius - graduationLength) * sin(renderAngle) + bounds.midY))
            renderAngle += graduationsAngle
        }
        graduationLayer.strokeColor = graduationColor.cgColor
        graduationLayer.lineWidth = graduationWidth
        graduationLayer.path = graduation.cgPath
    }
    
    private func updateLargeGraduationLayerPath() {
        largeGraduationLayer.isHidden = largeGraduations == 0
        if largeGraduations == 0 { return }
        let bounds = largeGraduationLayer.bounds
        let radius = min(bounds.width, bounds.height - lineWidth) / 2
        
        let graduation = UIBezierPath()
        let graduationsAngle = (endAngle - startAngle) / CGFloat(largeGraduations)
        var renderAngle = startAngle
        let count = endAngle - startAngle == CGFloat.pi * 2 ? (largeGraduations - 1) : largeGraduations
        for _ in 0...count {
            graduation.move(to: CGPoint(x: radius * cos(renderAngle) + bounds.midX,
                                   y: radius * sin(renderAngle) + bounds.midY))
            graduation.addLine(to: CGPoint(x: (radius - largeGraduationLength) * cos(renderAngle) + bounds.midX,
                                      y: (radius - largeGraduationLength) * sin(renderAngle) + bounds.midY))
            renderAngle += graduationsAngle
        }
        largeGraduationLayer.strokeColor = largeGraduationColor.cgColor
        largeGraduationLayer.lineWidth = largeGraduationWidth
        largeGraduationLayer.path = graduation.cgPath
    }
    
    private func updateIndicatorLayerPath() {
        let bounds = indicatorLayer.bounds
        
        let indicator = UIBezierPath()
        switch indicatorType {
        case let .pointer(color, length, width):
            indicator.move(to: CGPoint(x: bounds.midX, y: bounds.midY))
            indicator.addLine(to: CGPoint(x: bounds.midX + length, y: bounds.midY))
            indicatorLayer.strokeColor = color.cgColor
            indicatorLayer.fillColor = UIColor.clear.cgColor
            indicatorLayer.lineWidth = width
        case let .graduation(color, length, width):
            indicator.move(to: CGPoint(x: bounds.width - length - lineWidth / 2, y: bounds.midY))
            indicator.addLine(to: CGPoint(x: bounds.width - lineWidth / 2, y: bounds.midY))
            indicatorLayer.strokeColor = color.cgColor
            indicatorLayer.fillColor = UIColor.clear.cgColor
            indicatorLayer.lineWidth = width
        case let .circle(color, radius):
            let center = CGPoint(x: bounds.width - radius * 2 - graduationLength - lineWidth / 2, y: bounds.midY)
            indicator.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            indicatorLayer.strokeColor = UIColor.clear.cgColor
            indicatorLayer.fillColor = color.cgColor
            indicatorLayer.lineWidth = 0
        }
        
        indicatorLayer.path = indicator.cgPath
    }
}
