//
//  ViewController.swift
//  Example
//
//  Created by Mr.Dong on 2021/2/19.
//

import UIKit
import Knob

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let knob = Knob(frame: CGRect(x: (view.bounds.width - 240) / 2,
                                      y: (view.bounds.height - 240) / 2,
                                      width: 240,
                                      height: 240))
        view.addSubview(knob)
        
        knob.minimumValue = 0
        knob.maximumValue = 260
        
        knob.startAngle = -CGFloat.pi * 5 / 4
        knob.endAngle = CGFloat.pi / 4
        
        knob.graduations = 26
        knob.largeGraduations = 13
        
        knob.valueDisplay = .forLargeGraduation
        knob.valueAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 16) ]
        knob.valueFormatter = { "\(Int($0))" }
        
        knob.isEnableFeedback = true
        knob.isGraduationsAligned = true
        knob.isContinuous = false
        
        knob.indicatorType = .pointer(color: .red, length: 100, width: 4)
        
        knob.addTarget(self, action: #selector(ViewController.handleValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func handleValueChanged(_ sender: Knob) {
        print("value: \(sender.value)")
    }
}

