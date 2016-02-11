//
//  MyHandlers.swift
//  MKHUniFlowDemo
//
//  Created by Maxim Khatskevich on 2/11/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

import MKHUniFlow

//===

struct MyAppModel: UFLState
{
    var hasEverShared = false
    var shareCount = 0
    var lastSharedMsg: String?
    
    var collectedItems: [String] = []
    
    var lastShownProductId: String?
}

//===

enum MyAction: UFLAction
{
    case Share(msg: String)
    case Collect(objId: String)
    case UnCollect(objId: String)
    case ShowProduct(prodId: String)
}

//===

struct MyAct
{
    struct Share: UFLHandler
    {
        //
    }
}

//===

extension MyDispatcher
{
    func addHandlers()
    {
        // Share
        
        ufl_register { (action, currentState) -> (MyAppModel) in
            
            var result = currentState
            
            //===
            
            switch (action)
            {
                case .Share(let msg):
                    result.hasEverShared = true
                    result.shareCount++
                    result.lastSharedMsg = msg
                    
                default:
                    break
            }
            
            //===
            
            return result
        }
        
        //===
        
        // Collect/Uncollect
        
        ufl_register { (action, currentState) -> (MyAppModel) in
            
            var result = currentState
            
            //===
            
            switch (action)
            {
                case .Collect(let objId):
                    result.collectedItems.append(objId)
                
                case .UnCollect(let objId):
                    if let i = result.collectedItems.indexOf(objId)
                    {
                        result.collectedItems.removeAtIndex(i)
                    }
                    
                default:
                    break
            }
            
            //===
            
            return result
        }
        
        //===
        
        // ShowProduct
        
        ufl_register { (action, currentState) -> (MyAppModel) in
            
            var result = currentState
            
            //===
            
            switch (action)
            {
                case .ShowProduct(let prodId):
                    result.lastShownProductId = prodId
                
                default:
                    break
            }
            
            //===
            
            return result
        }
        
    }
}
