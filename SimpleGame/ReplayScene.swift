//
//  ReplayScene.swift
//  SimpleGame
//
//  Created by Youri on 14-02-15.
//  Copyright (c) 2015 GoudVis. All rights reserved.
//

import SpriteKit

class ReplayScene: SKScene {
    
    
    
    override func didMoveToView(view: SKView) {
        let leftMargin = view.bounds.width/4
        let topMargin = view.bounds.height/4
        
        let question = SKLabelNode(fontNamed:"Arial")
        question.text = "Play Again?"
        question.fontSize = 30
        question.position =
            CGPoint(x:leftMargin, y:view.bounds.height - topMargin)
        self.addChild(question)
        
               
        let playAgainButton =
        UIButton(frame: CGRectMake(leftMargin, topMargin + 30,100,50))
        playAgainButton.backgroundColor = UIColor.clearColor()
        playAgainButton.setTitle("Yes", forState: UIControlState.Normal)
        playAgainButton.setTitleColor(
            UIColor.greenColor(), forState: UIControlState.Normal)
        playAgainButton.addTarget(self, action: "buttonAction:",
                forControlEvents: UIControlEvents.TouchDown)
        self.view?.addSubview(playAgainButton)
        
    }
    
    func buttonAction(sender:UIButton!) {
        if sender!.currentTitle=="Yes"
        {
            // close ReplayScene and start the game again
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
