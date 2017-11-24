//
//  PhysicsEngineLike.swift
//  PhysicsEngineLike
//
//  Created by LeeKiyang on 2016/03/26.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

public protocol Particle {
    var position: CGPoint { get set }
    var mass: CGFloat { get }
    var radius: CGFloat { get }
}

public enum GravityDirection {
    case Up
    case Down
    case Left
    case Right
}

private class Connection {
    fileprivate var particle: InternalParticle
    fileprivate var length: CGFloat
    fileprivate var offset: CGFloat = 0
    fileprivate var stiffness: CGFloat = 1
    init(particle: InternalParticle, length:CGFloat, stiffness: CGFloat = 1) {
        self.particle = particle
        self.length = length
        self.stiffness = stiffness
    }
}

private class InternalParticle {
    fileprivate var particle:Particle
    fileprivate var velocity: CGPoint = CGPoint.zero
    fileprivate var positionCache: CGPoint = CGPoint.zero
    fileprivate var connections: NSMutableArray = NSMutableArray()
    init(particle:Particle){
        self.particle = particle
    }
}

public class PhysicsEngineLike {
    private var particles:NSMutableArray = NSMutableArray()
    private var connections:NSMutableArray = NSMutableArray()
    private var timer: Timer?
    public var refreshTimeInterval: TimeInterval = 1.0/60.0
    public var elasticity: CGFloat = 0.9
    public var boundary: CGRect?
    public var gravityDirection = GravityDirection.Down
    public var gravityConstant:CGFloat = 400
    
    public func addVelocity(particle:Particle, velocity:CGPoint) {
        let iParticle = internalParticle(particle: particle)
        if let p = iParticle {
            p.velocity = CGPoint(x: p.velocity.x + velocity.x, y: p.velocity.y + velocity.y)
        }
    }
    public func removeParticles() {
        particles.removeAllObjects()
    }
    
    public func addParticle(_ particle: Particle) {
        particles.add(InternalParticle(particle: particle))
    }
    
    public func addConnection(particle1: Particle, particle2: Particle, length:CGFloat, stiffness:CGFloat) {
        let p1:InternalParticle? = internalParticle(particle: particle1)
        let p2:InternalParticle? = internalParticle(particle: particle2)
        if let p1_ = p1 {
            if let p2_ = p2 {
                p1_.connections.add(Connection(particle: p2_, length: length, stiffness: stiffness))
                p2_.connections.add(Connection(particle: p1_, length: length, stiffness: stiffness))
            }
        }
    }
    
    
    public func start() {
        self.timer = Timer.scheduledTimer(timeInterval: self.refreshTimeInterval, target: self, selector: #selector(PhysicsEngineLike.refresh), userInfo: nil, repeats: true)
    }
    
    public func stop() {
        self.timer?.invalidate()
    }
    
    @objc private func refresh(timer: Timer) {
        for particle in particles {
            if let p = particle as? InternalParticle {
                p.positionCache = p.particle.position
            }
        }
        
        if particles.count > 1 {
            for i in 0...particles.count-2 {
                if var p1 = particles[i] as? InternalParticle {
                    for j in i+1...particles.count-1 {
                        if var p2 = particles[j] as? InternalParticle {
                            isColliding(particle1: &p1, particle2: &p2)
                        }
                    }
                }
            }
        }

        for particle in particles {
            if var p = particle as? InternalParticle {
                isCollidingWithBoundary(particle: &p)
                calculateConnectionForce(particle: &p)
                addGravity(particle: &p)
                p.particle.position = CGPoint(x: p.positionCache.x + p.velocity.x * CGFloat(self.refreshTimeInterval) , y: p.positionCache.y + p.velocity.y * CGFloat(self.refreshTimeInterval))
            }
        }
    }
    
    private func internalParticle(particle: Particle) -> InternalParticle? {
        for iParticle in particles {
            if let ip = iParticle as? InternalParticle {
                if (ip.particle as AnyObject).isEqual(particle as AnyObject) {
                    return ip
                }
            }
        }
        return nil
    }
    
    private func lengthOfVector(vector: CGPoint) -> CGFloat {
        return CGFloat(sqrt(pow(Double(vector.x), 2.0) + pow(Double(vector.y), 2.0)))
    }
    
    private func rotate(vector:CGPoint, angle:CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(cos(angle))*vector.x - CGFloat(sin(angle))*vector.y, y: CGFloat(sin(angle))*vector.x + CGFloat(cos(angle))*vector.y)
    }
    
    private func angleOfVector(vector:CGPoint) -> CGFloat {
        var radian = atan(vector.y/vector.x)
        if vector.x < 0 {
            radian += CGFloat.pi
        }
        return radian
    }
    
    private func vectorDifference(particle1: CGPoint, particle2: CGPoint) -> CGPoint {
        return CGPoint(x: particle1.x - particle2.x, y: particle1.y - particle2.y)
    }
    
    private func vectorScaled(vector: CGPoint, scale:CGFloat) -> CGPoint {
        return CGPoint(x: vector.x * scale, y: vector.y * scale)
    }
    
    private func calculateCollisionForce(particle1: inout InternalParticle, particle2: inout InternalParticle) {
        let p1to2 = CGPoint(x: particle2.positionCache.x - particle1.positionCache.x, y: particle2.positionCache.y - particle1.positionCache.y)
        let angle1to2 = angleOfVector(vector: p1to2)
        let v1Rotated = rotate(vector: particle1.velocity, angle: -angle1to2)
        let v2Rotated = rotate(vector: particle2.velocity, angle: -angle1to2)
        let v1xPost = ((particle1.particle.mass - elasticity*particle2.particle.mass)*v1Rotated.x + (particle2.particle.mass+elasticity*particle2.particle.mass)*v2Rotated.x)/(particle1.particle.mass+particle2.particle.mass)
        let v2xPost = v1xPost + elasticity*(v1Rotated.x - v2Rotated.x)
        particle1.velocity = rotate(vector: CGPoint(x: v1xPost, y: v1Rotated.y), angle: angle1to2)
        particle2.velocity = rotate(vector: CGPoint(x: v2xPost, y: v2Rotated.y), angle: angle1to2)
    }
    
    private func isColliding(particle1: inout InternalParticle, particle2: inout InternalParticle, traditionally:Bool = true) {
        let collidingDistance = particle1.particle.radius + particle2.particle.radius
        let collisionNormal = vectorDifference(particle1: particle2.positionCache, particle2: particle1.positionCache)
        let lengthOfCollisionNormal = lengthOfVector(vector: collisionNormal)
        if lengthOfCollisionNormal <= collidingDistance {
            if lengthOfCollisionNormal < collidingDistance {
                let lengthToMove = collidingDistance - lengthOfCollisionNormal
                let lengthToMoveForPoint1 = -lengthToMove/2.0
                let lengthToMoveForPoint2 = lengthToMove/2.0
                let movingVectorForPoint1 = vectorScaled(vector: collisionNormal, scale: lengthToMoveForPoint1/lengthOfVector(vector: collisionNormal))
                let movingVectorForPoint2 = vectorScaled(vector: collisionNormal, scale: lengthToMoveForPoint2/lengthOfVector(vector: collisionNormal))
                particle1.positionCache = CGPoint(x: particle1.positionCache.x + movingVectorForPoint1.x, y: particle1.positionCache.y + movingVectorForPoint1.y)
                particle2.positionCache = CGPoint(x: particle2.positionCache.x + movingVectorForPoint2.x, y: particle2.positionCache.y + movingVectorForPoint2.y)
            }
            calculateCollisionForce(particle1: &particle1, particle2: &particle2)
        }
    }
    
    @discardableResult
    private func isCollidingWithBoundary( particle: inout InternalParticle) -> Bool {
        var collides = false
        if let b = boundary {
            if b.origin.x > particle.positionCache.x {
                collides = true
                particle.positionCache = CGPoint(x: b.origin.x, y: particle.positionCache.y)
                particle.velocity = CGPoint(x: -elasticity * particle.velocity.x, y: particle.velocity.y)
            }
            if b.origin.y > particle.positionCache.y {
                collides = true
                particle.positionCache = CGPoint(x: particle.positionCache.x, y: b.origin.y)
                particle.velocity = CGPoint(x: particle.velocity.x, y: -elasticity * particle.velocity.y)
            }
            if b.origin.x + b.size.width < particle.positionCache.x {
                collides = true
                particle.positionCache = CGPoint(x: b.origin.x + b.size.width, y: particle.positionCache.y)
                particle.velocity = CGPoint(x: -elasticity * particle.velocity.x, y: particle.velocity.y)
            }
            if b.origin.y + b.size.height < particle.positionCache.y {
                collides = true
                particle.positionCache = CGPoint(x: particle.positionCache.x, y: b.origin.y + b.size.height)
                particle.velocity = CGPoint(x: particle.velocity.x, y: -elasticity * particle.velocity.y)
            }
        }
        return collides
    }
    
    private func calculateConnectionForce( particle:inout InternalParticle) {
        for connection in particle.connections {
            if let c = connection as? Connection {
                let positionDifference = vectorDifference(particle1: c.particle.positionCache, particle2: particle.positionCache)
                let difference = c.length - lengthOfVector(vector: positionDifference)
                let angle = angleOfVector(vector: positionDifference)
                let velocityDX = -difference * cos(angle) * pow(c.stiffness, 1) * CGFloat(refreshTimeInterval)
                let velocityDY = -difference * sin(angle) * pow(c.stiffness, 1) * CGFloat(refreshTimeInterval)
                particle.velocity = CGPoint(x: particle.velocity.x + velocityDX, y: particle.velocity.y + velocityDY)
            }
        }
    }
    
    private func addGravity( particle:inout InternalParticle) {
        let margin = gravityConstant * CGFloat(refreshTimeInterval)
        switch gravityDirection {
        case .Up:
            particle.velocity = CGPoint(x: particle.velocity.x, y: particle.velocity.y - margin)
        case .Left:
            particle.velocity = CGPoint(x: particle.velocity.x - margin, y: particle.velocity.y)
        case .Right:
            particle.velocity = CGPoint(x: particle.velocity.x + margin, y: particle.velocity.y)
        case .Down:
            particle.velocity = CGPoint(x: particle.velocity.x, y: particle.velocity.y + margin)
        }
    }
}

