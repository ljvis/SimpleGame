//
//  GameScene.swift
//  SimpleGame
//
//  Created by ljvis42 on 14-02-15.
//  Copyright (c) 2015 GoudVis. All rights reserved.
//

import SpriteKit
import AVFoundation
import UIKit

/*extension SKAction {
    class func scaleBy(scale: CGFloat, duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return scaleXBy(scale, y: scale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    class func scaleTo(scale: CGFloat, duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return scaleXTo(scale, y: scale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
}
*/

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Player    : UInt32 = 0b100
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

let stepSound: SKAction = SKAction.playSoundFileNamed(
    "pistol.wav", waitForCompletion: false)
let gunSound: SKAction = SKAction.playSoundFileNamed(
    "gun.wav", waitForCompletion: false)










class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let player = SKSpriteNode(imageNamed: "olaf")
    var olafDead = false
    var duration = CGFloat(0)
    var deal = CGFloat(0)
    
    var replayView: SKView?
    
    
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.4)
        // player.position = CGPointZero
        player.xScale = 0.33
        player.yScale = 0.33
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size) // 1
        player.physicsBody?.dynamic = true // 2
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player // 3
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster // 4
        player.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        addChild(player)
      //  player.physicsBody?.applyImpulse(CGVectorMake(40, 10))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        self.replayView = SKView(
            frame: CGRectMake(
                self.frame.size.width/4, self.frame.size.height/4,
                self.frame.size.width/2, self.frame.size.height/2))
      //  let replayScene =
      // ReplayScene.sceneWithSize(CGSizeMake(self.frame.size.width/2, self.frame.size.height/2))
        
      //  self.replayView!.presentScene(replayScene)
        
       
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
                    }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        
        if olafDead == false {
            runAction(stepSound)
        
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        projectile.xScale = 0.4
        projectile.yScale = 0.4
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 0.7)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
            
        }
        
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        println("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func playerDidCollideWithMonster(monster:SKSpriteNode, player: SKSpriteNode) {
        runAction(gunSound)
        println("Damn")
        olafDead = true
        
     //   let remove = player.removeFromParent()
        
        let scale = SKAction.scaleXTo(0.0, y: 0.0 ,duration: 1)
        let actionRemove = SKAction.removeFromParent()
        
        
       let  sequence = SKAction.sequence([scale, actionRemove])
        player.runAction(sequence)
        
       /* if let scene = ReplayScene.unarchiveFromFile("ReplayScene") as? ReplayScene {
            let skView = self.view as SKView!
            skView.ignoresSiblingOrder = true
            scene.size = skView.bounds.size
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }

        */
       
        
           }

    
   
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as SKSpriteNode, monster: secondBody.node as SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
           (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
               playerDidCollideWithMonster(firstBody.node as SKSpriteNode, player: secondBody.node as SKSpriteNode)
        }
        
        
        
        
    }
    
    
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "bono")
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        monster.xScale = 0.30
        monster.yScale = 0.30
        
        // Add the monster to the scene
        addChild(monster)
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
}
