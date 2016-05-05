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
    private var delegate: OrientationDetectorDelegate?
    public func setDelegate(delegate:OrientationDetectorDelegate) {
        self.delegate = delegate
        activate()
    }
    
    public func activate() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrientationDetector.didChangeOrientation), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    private func gravityDirection() -> GravityDirection {
        let orientation = UIDevice.currentDevice().orientation
        switch orientation {
        case .PortraitUpsideDown:
            return .Up
        case .LandscapeLeft:
            return .Left
        case .LandscapeRight:
            return .Right
        default:
            return .Down
        }
    }
    
    @objc func didChangeOrientation() {
        if let d = delegate {
            d.didChangeOrientation(gravityDirection())
        }
    }
}
