//
//  ViewController.swift
//  PhysicsEngineLike
//
//  Created by LeeKiyang on 2016/03/25.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

public class Particle: UIView, Point {
    public var position: CGPoint {
        get {
            return center
        }
        set(value) {
            center = value
        }
    }
    private var _velocity: CGPoint = CGPointZero
    public var velocity: CGPoint {
        get {
            return _velocity
        }
        set(value) {
            _velocity = value
        }
    }
    public var mass: CGFloat  {
        get {
            return pow(layer.cornerRadius, 2.0)
        }
    }
    public var connections: [Connection] {
        get {
            return []
        }
    }
    public var radius: CGFloat {
        get {
            return layer.cornerRadius
        }
    }
}

class ViewController: UIViewController {
    var particles: [Particle] = []
    var draggingPoint: Particle?
    var originalCenterOfDraggingPoint: CGPoint?
    var originalColorOfDraggingPoint: UIColor?
    let physicsLike: PhysicsLike = PhysicsLike()
    let velocityFactor: CGFloat = 0.5
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        physicsLike.boundary = self.view.frame
        physicsLike.start()
    }
    func norm(point1:CGPoint, point2:CGPoint)->Double {
        return sqrt(pow(Double(point1.x - point2.x), 2.0) + pow(Double(point1.y - point2.y), 2.0))
    }
    
    @IBAction func drag(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            let location = sender.locationInView(self.view)
            for point in particles {
                if norm(location, point2: point.center) <= Double(point.layer.cornerRadius) {
                    draggingPoint = point
                    draggingPoint?.velocity = CGPointZero
                    originalColorOfDraggingPoint = point.backgroundColor
                    point.backgroundColor = UIColor.blueColor()
                    originalCenterOfDraggingPoint = point.center
                    return
                }
            }
        case .Changed:
            let translation = sender.translationInView(self.view)
            print("Dragging on \(translation)")
            if let point = draggingPoint {
                if let center = originalCenterOfDraggingPoint {
                    let newCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
                    point.center = newCenter
                }
                
            }
        case .Ended:
            let velocity = sender.velocityInView(view)
            draggingPoint?.velocity = CGPoint(x: velocity.x * velocityFactor, y: velocity.y * velocityFactor)
            draggingPoint?.backgroundColor = originalColorOfDraggingPoint
            draggingPoint = nil
            originalCenterOfDraggingPoint = nil
        default:
            print("nothing")
        }
    }

    @IBAction func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            print("Long press on \(sender.locationOfTouch(0, inView: self.view))")
            let radius: CGFloat = CGFloat(arc4random()%10+1)*8
            let point = Particle(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
            point.center = sender.locationInView(self.view)
            point.backgroundColor = UIColor.redColor()
            point.layer.cornerRadius = radius
            point.layer.masksToBounds = true
            view.addSubview(point)
            particles.append(point)
            physicsLike.addPoint(point)
        }
    }
}

