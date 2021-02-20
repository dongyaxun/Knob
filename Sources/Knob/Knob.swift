//
//  Knob.swift
//  Knob
//
//  Created by Mr.Dong on 2021/2/8.
//

import UIKit

public enum IndicatorType {
    case pointer(color: UIColor, length: CGFloat, width: CGFloat)
    case graduation(color: UIColor, length: CGFloat, width: CGFloat)
    case circle(color: UIColor, radius: CGFloat)
}

public enum ValueDisplayOptions {
    case none
    case forLargeGraduation
    case forGraduation
}

open class Knob: UIControl {
    
    public var trackColor: UIColor {
        get { return renderer.trackColor }
        set { renderer.trackColor = newValue }
    }
    
    public var lineWidth: CGFloat {
        get { return renderer.lineWidth }
        set { renderer.lineWidth = newValue }
    }
    
    public var startAngle: CGFloat {
        get { return renderer.startAngle }
        set { renderer.startAngle = newValue }
    }

    public var endAngle: CGFloat {
        get { return renderer.endAngle }
        set { renderer.endAngle = newValue }
    }
    
    // 震动反馈
    public var isEnableFeedback: Bool = true
    // 刻度对齐
    public var isGraduationsAligned: Bool = true
    // 持续响应
    public var isContinuous: Bool = false
    
    // MARK: 指针
    
    public var indicatorType: IndicatorType {
        get { return renderer.indicatorType }
        set { renderer.indicatorType = newValue }
    }
    
    // MARK: 刻度
    
    public var graduations: Int {
        get { return renderer.graduations }
        set { renderer.graduations = newValue }
    }
    
    public var graduationLength: CGFloat {
        get { return renderer.graduationLength }
        set { renderer.graduationLength = newValue }
    }
    
    public var graduationWidth: CGFloat {
        get { return renderer.graduationWidth }
        set { renderer.graduationWidth = newValue }
    }
    
    public var graduationColor: UIColor {
        get { return renderer.graduationColor }
        set { renderer.graduationColor = newValue }
    }
    
    public var largeGraduations: Int {
        get { return renderer.largeGraduations }
        set { renderer.largeGraduations = newValue }
    }
    
    public var largeGraduationLength: CGFloat {
        get { return renderer.largeGraduationLength }
        set { renderer.largeGraduationLength = newValue }
    }
    
    public var largeGraduationWidth: CGFloat {
        get { return renderer.largeGraduationWidth }
        set { renderer.largeGraduationWidth = newValue }
    }
    
    public var largeGraduationColor: UIColor {
        get { return renderer.largeGraduationColor }
        set { renderer.largeGraduationColor = newValue }
    }
    
    // MARK: Value
    
    public var valueDisplay: ValueDisplayOptions = .forLargeGraduation
    
    public var valueFormatter: ((Float) -> String)?
    public var valueAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.black,
        .font: UIFont.systemFont(ofSize: 14)
    ]
    public var valueMargin: CGFloat = 15
    
    public var minimumValue: Float = 0
    public var maximumValue: Float = 1
    
    public private(set) var value: Float = 0
    
    public func setValue(_ newValue: Float, animated: Bool = false) {
        value = min(maximumValue, max(minimumValue, newValue))
        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue
        let angleValue = CGFloat((value - minimumValue) / valueRange) * angleRange + startAngle
        renderer.setIndicatorAngle(angleValue, animated: animated)
    }
    
    // MARK: Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Private
    
    private let renderer = KnobRenderer()
    
    @available(iOS 13.0, *)
    private lazy var feedbackGenertor = UIImpactFeedbackGenerator(style: .rigid)
    
    private func commonInit() {
        backgroundColor = .white
        
        renderer.updateBounds(bounds)
        renderer.setIndicatorAngle(renderer.startAngle)
        
        layer.addSublayer(renderer.graduationLayer)
        layer.addSublayer(renderer.largeGraduationLayer)
        layer.addSublayer(renderer.trackLayer)
        layer.addSublayer(renderer.indicatorLayer)
        
        let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func handleGesture(_ gesture: RotationGestureRecognizer) {
        let valueRange = maximumValue - minimumValue
        var newValue = Float(gesture.deltaAngle / (endAngle - startAngle)) * valueRange + value
        newValue = min(maximumValue, max(minimumValue, newValue))
        if newValue == value && gesture.state == .changed { return }
        if #available(iOS 13.0, *), isEnableFeedback {
            let count = max(graduations, largeGraduations)
            let graduationValue = (maximumValue - minimumValue) / Float(count)
            if Int(newValue / graduationValue) != Int(value / graduationValue) {
                feedbackGenertor.impactOccurred()
            }
        }
        if gesture.state == .ended || gesture.state == .cancelled {
            let count = max(graduations, largeGraduations)
            if isGraduationsAligned && count > 0 {
                let graduationValue = (maximumValue - minimumValue) / Float(count)
                let targetValue = (value / graduationValue).rounded(.toNearestOrAwayFromZero) * graduationValue
                setValue(targetValue, animated: true)
            }
            sendActions(for: .valueChanged)
        } else {
            setValue(newValue)
            if isContinuous { sendActions(for: .valueChanged) }
        }
    }
    
    // draw values
    open override func draw(_ rect: CGRect) {
        var count = 0
        switch valueDisplay {
        case .forGraduation: count = graduations
        case .forLargeGraduation: count = largeGraduations
        case .none: count = 0
        }
        if count == 0 { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let defaultFormatter: (Float) -> String = { String(format: "%.1f", $0) }
        let radius = min(rect.width, rect.height - lineWidth) / 2 - largeGraduationLength - valueMargin
        let graduationValue = (maximumValue - minimumValue) / Float(count)
        let graduationsAngle = (endAngle - startAngle) / CGFloat(count)
        var renderAngle = startAngle
        if endAngle - startAngle == CGFloat.pi * 2 { count -= 1 }
        UIGraphicsPushContext(context)
        for i in 0...count {
            let value = minimumValue + graduationValue * Float(i)
            let formatter = valueFormatter ?? defaultFormatter
            let text = formatter(value) as NSString
            let size = text.size(withAttributes: valueAttributes)
            var point = CGPoint(x: radius * cos(renderAngle) + rect.midX,
                                y: radius * sin(renderAngle) + rect.midY)
            point.x -= size.width / 2
            point.y -= size.height / 2
            text.draw(at: point, withAttributes: valueAttributes)
            renderAngle += graduationsAngle
        }
        UIGraphicsPopContext()
    }
}
