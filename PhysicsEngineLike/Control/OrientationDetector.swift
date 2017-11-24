//
//  OrientationDetector.swift
//  physicsenginelike
//
//  Created by LeeKiyang on 2016/05/19.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

public protocol OrientationDetectorDelegate {
    func didChangeOrientation(orientation: GravityDirection)
}

public class OrientationDetector: NSObject {
    var delegate: OrientationDetectorDelegate? {
        didSet {
            activate()
        }
    }
    
    public func activate() {
        NotificationCenter.default.addObserver(self, selector: #selector(OrientationDetector.didChangeOrientation),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    private func gravityDirection() -> GravityDirection {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portraitUpsideDown:
            return .Up
        case .landscapeLeft:
            return .Left
        case .landscapeRight:
            return .Right
        default:
            return .Down
        }
    }
    
    @objc func didChangeOrientation() {
        if let d = delegate {
            d.didChangeOrientation(orientation: gravityDirection())
        }
    }
}
