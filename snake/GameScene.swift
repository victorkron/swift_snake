//
//  GameScene.swift
//  snake
//
//  Created by Карим Руабхи on 27.11.2021.
//

import SpriteKit
import GameplayKit

struct CollisionCategory {
    static let Snake: UInt32 = 0x1 << 0 // 0001 2
    static let SnakeHead: UInt32 = 0x1 << 1 // 0010 4
    static let Apple: UInt32 = 0x1 << 2 // 0100 8
    static let EdgeBody: UInt32 = 0x1 << 3 // 1000 16
}

class GameScene: SKScene {
    
    var snake: Snake?
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsBody?.allowsRotation = false
        self.physicsWorld.contactDelegate = self
        
        view.showsPhysics = true
        
        let leftClockwiseButton = SKShapeNode()
        leftClockwiseButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).cgPath
        
        leftClockwiseButton.position = CGPoint(x: view.scene!.frame.minX + 30, y: view.scene!.frame.minY + 30)
        
        leftClockwiseButton.fillColor = UIColor.magenta
        leftClockwiseButton.strokeColor = UIColor.cyan
        leftClockwiseButton.lineWidth = 4
        leftClockwiseButton.name = "leftClockwiseButton"
        
        self.addChild(leftClockwiseButton)
        
        
        let rightClockwiseButton = SKShapeNode()
        rightClockwiseButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).cgPath
        
        rightClockwiseButton.position = CGPoint(x: view.scene!.frame.maxX - 80, y: view.scene!.frame.minY + 30)
        
        rightClockwiseButton.fillColor = UIColor.magenta
        rightClockwiseButton.strokeColor = UIColor.cyan
        rightClockwiseButton.lineWidth = 4
        rightClockwiseButton.name = "rightClockwiseButton"
        
        self.addChild(rightClockwiseButton)
        self.createApple()
        
        self.snake = Snake(atPoint: CGPoint(x: view.scene!.frame.midX, y: view.scene!.frame.midY))
        addChild(snake!)
        
        self.physicsBody?.categoryBitMask = CollisionCategory.EdgeBody
        self.physicsBody?.collisionBitMask = CollisionCategory.Snake | CollisionCategory.SnakeHead
        
        
    }
        
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            guard let touchNode = self.atPoint(touchLocation) as? SKShapeNode, touchNode.name == "rightClockwiseButton" || touchNode.name == "leftClockwiseButton" else {
                return
            }
            
            touchNode.fillColor = .systemOrange
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            guard let touchNode = self.atPoint(touchLocation) as? SKShapeNode, touchNode.name == "rightClockwiseButton" || touchNode.name == "leftClockwiseButton" else {
                return
            }
            
            touchNode.fillColor = .magenta
            
            if touchNode.name == "rightClockwiseButton" {
                snake!.moveClockwise()
            } else if touchNode.name == "leftClockwiseButton" {
                snake!.moveCounterclockwise()
            }
                
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
     
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        snake!.move()
        // Called before each frame is rendered
    }
    
    func createApple() {
        let randX = CGFloat(arc4random_uniform(UInt32(view!.scene!.frame.maxX - 10)))
        let randY = CGFloat(arc4random_uniform(UInt32(view!.scene!.frame.maxY - 55)))
        
        let apple = Apple(position: CGPoint(x: randX, y: randY))
        
        self.addChild(apple)
    }
}



extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyes = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        let collisionObject = bodyes - CollisionCategory.SnakeHead
        
        switch collisionObject {
        case CollisionCategory.Apple:
            let apple = contact.bodyA.node is Apple ? contact.bodyA.node : contact.bodyB.node
            snake?.addBodyPart()
            apple?.removeFromParent()
            createApple()
        
        case CollisionCategory.EdgeBody:
            self.snake?.removeFromParent()
            self.snake = nil
            self.snake = Snake(atPoint: CGPoint(x: view!.scene!.frame.midX, y: view!.scene!.frame.midY))
            addChild(self.snake!)
            
            
        default:
            break
        }
    }
}
