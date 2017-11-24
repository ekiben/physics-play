//
//  ParticleView.swift
//  physicsenginelike
//
//  Created by 李 起揚 on 2016/05/07.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

public class ParticleView: UIView, Particle {
    public var position: CGPoint {
        get {
            return center
        }
        set(value) {
            center = value
        }
    }
    public var mass: CGFloat  {
        get {
            return pow(layer.cornerRadius, 2.0)
        }
    }
    public var radius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set(value) {
            layer.cornerRadius = value
        }
    }
    
    init(radius:CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        self.radius = radius
        backgroundColor = UIColor.blue
        layer.masksToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
