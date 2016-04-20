//
//  PhysicsLike.swift
//  PhysicsEngineLike
//
//  Created by LeeKiyang on 2016/03/26.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import Foundation
import UIKit

public protocol Point {
    var position: CGPoint { get set }
    var velocity: CGPoint { get set }
    var mass: CGFloat { get }
    var connections: [Connection] { get }
    var radius: CGFloat { get }
}

public class Connection {
    var point1: Point
    var point2: Point
    var stiffness: UInt = 1
    init(point1: Point, point2: Point, stiffness: UInt = 1) {
        self.point1 = point1
        self.point2 = point2
    }
}

public class PhysicsLike {
    private var points: NSMutableArray = NSMutableArray()
    
    private var timer: NSTimer?
    
    public var timeInterval: NSTimeInterval = 1.0/60.0
    
    public var elasticity: CGFloat = 0.9
    
    public var boundary: CGRect?
    
    public func addPoint(point: Point) {
        points.addObject(point as! AnyObject)
    }
    
    public func start() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(PhysicsLike.refresh(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func refresh(timer: NSTimer) {
        if points.count > 1 {
            for i in 0...points.count-2 {
                var point1 = points[i] as! Point
                for j in i+1...points.count-1 {
                    var point2 = points[j] as! Point
                    isColliding(&point1, point2: &point2)
                }
            }
        }
        for point in points {
            var p = point as! Point
            isCollidingWithBoundary(&p)
            p.position = CGPoint(x: p.position.x + p.velocity.x * CGFloat(timeInterval) , y: p.position.y + p.velocity.y * CGFloat(timeInterval))
        }
    }
    
    private func distance(point1: Point, point2: Point) -> CGFloat {
        return CGFloat(sqrt(pow(Double(point1.position.x - point2.position.x), 2.0) + pow(Double(point1.position.y - point2.position.y), 2.0)))
    }
    
    private func lengthOfVector(vector: CGPoint) -> CGFloat {
        return CGFloat(sqrt(pow(Double(vector.x), 2.0) + pow(Double(vector.y), 2.0)))
    }
    
    private func innerProduct(v1: CGPoint, v2: CGPoint) -> CGFloat {
        return v1.x * v2.x + v1.y * v2.y
    }
    
    private func angleBetweenVectors(v1:CGPoint, v2:CGPoint) -> CGFloat {
        let cosineValueOfAngle = innerProduct(v1, v2: v2)/(lengthOfVector(v1) * lengthOfVector(v2))
        return acos(cosineValueOfAngle)
    }
    
    func rotate(vector:CGPoint, angle:CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(cos(angle))*vector.x - CGFloat(sin(angle))*vector.y, y: CGFloat(sin(angle))*vector.x + CGFloat(cos(angle))*vector.y)
    }
    
    func angleOfVector(vector:CGPoint) -> CGFloat {
        var thetaRadian = atan(vector.y/vector.x)
        if vector.x < 0 {
            thetaRadian += CGFloat(M_PI)
        }
        return thetaRadian
    }

    private func isColliding(inout point1: Point, inout point2: Point) {
        if distance(point1, point2: point2) <= (point1.radius + point2.radius) {
            let p1to2 = CGPoint(x: point2.position.x - point1.position.x, y: point2.position.y - point1.position.y)
            let angle1to2 = angleOfVector(p1to2)
            let v1Rotated = rotate(point1.velocity, angle: -angle1to2)
//            let verticalVelocity1to2 = v1Rotated.x
//            let horizontalVelocity1to2 = v1Rotated.y
//            let angle2to1 = angle1to2 + CGFloat(M_PI)
            let v2Rotated = rotate(point2.velocity, angle: -angle1to2)
//            let verticalVelocity2to1 = v2Rotated.x
//            let horizontalVelocity2to1 = v2Rotated.y
            
//            if v1Rotated.x * v2Rotated.x < 0 {
                let v1xPost = ((point1.mass - elasticity*point2.mass)*v1Rotated.x + (point2.mass+elasticity*point2.mass)*v2Rotated.x)/(point1.mass+point2.mass)
                let v2xPost = v1xPost + elasticity*(v1Rotated.x - v2Rotated.x)
                //            let v1yPost = ((point1.mass - elasticity*point2.mass)*point1.velocity.y + (point2.mass+elasticity*point2.mass)*point2.velocity.y)/(point1.mass+point2.mass)
                //            let v2yPost = v1xPost + elasticity*(point1.velocity.y - point2.velocity.y)
                point1.velocity = rotate(CGPoint(x: v1xPost, y: v1Rotated.y), angle: angle1to2)
                point2.velocity = rotate(CGPoint(x: v2xPost, y: v2Rotated.y), angle: angle1to2)
//            }
        }
    }
    private func isCollidingWithBoundary(inout point: Point) -> Bool {
        var collides = false
        if let b = boundary {
            if b.origin.x > point.position.x {
                collides = true
                point.position = CGPoint(x: b.origin.x, y: point.position.y)
                point.velocity = CGPoint(x: -elasticity * point.velocity.x, y: point.velocity.y)
            }
            if b.origin.y > point.position.y {
                collides = true
                point.position = CGPoint(x: point.position.x, y: b.origin.y)
                point.velocity = CGPoint(x: point.velocity.x, y: -elasticity * point.velocity.y)
            }
            if b.origin.x + b.size.width < point.position.x {
                collides = true
                point.position = CGPoint(x: b.origin.x + b.size.width, y: point.position.y)
                point.velocity = CGPoint(x: -elasticity * point.velocity.x, y: point.velocity.y)
            }
            if b.origin.y + b.size.height < point.position.y {
                collides = true
                point.position = CGPoint(x: point.position.x, y: b.origin.y + b.size.height)
                point.velocity = CGPoint(x: point.velocity.x, y: -elasticity * point.velocity.y)
            }
        }
        return collides
    }
}

