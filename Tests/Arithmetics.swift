/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import XCTest

import Foundation

import XCEUniFlow
import XCERequirement

//---

class Arithmetics: FeatureBase, SomeObservingFeature, SomeExternalObserver
{
    struct Main: SomeState {
        
        typealias Feature = Arithmetics

        var val: Int
    }
    
    static
    var onInitialization: (() -> Void)!
    
    static
    var onActualization: (() -> Void)!
    
    static
    var initCount = 0
    
    static
    var deinitCount = 0
    
    static
    func resetCounters()
    {
        initCount = 0
        deinitCount = 0
    }
    
    override
    init(with storageDispatcher: StorageDispatcher? = nil)
    {
        super.init(with: storageDispatcher)
        
        //---
        
        Self.initCount += 1
    }
    
    deinit
    {
        Self.deinitCount += 1
    }
}

//---

extension Arithmetics
{
    static
    var bindings: [InternalBinding] {[
        
        scenario()
            .when(
                InitializationInto<Main>.completed
            )
            .then { _ in
                onInitialization?()
            },
        
        scenario()
            .when(
                ActualizationOf<Main>.completed
            )
            .then { _ in
                onActualization?()
            }
    ]}
    
    var bindings: [ExternalBinding] {[
        
        scenario()
            .when(
                InitializationInto<Main>.completed
            )
            .then { _, _ in }
    ]}
}

//---

extension Arithmetics
{
    func begin(with value: Int = 0)
    {
        dispatcher.should {
            
            let main = Main(val: value)
            
            //---
            
            try initialize(with: main)
        }
    }

    func setExplicit(value: Int)
    {
        dispatcher.should {
            
            var main: Main = try fetch()
            
            //---
            
            try Check.that("Current value is != to desired new value", main.val != value)
            
            //---
            
            main.val = value
            
            //---
            
            try actualize(with: main)
        }
    }

    func incFive()
    {
        dispatcher.should {
            
            var main: Main = try fetch()
            
            //---
            
            main.val += 5
            
            //---
            
            try actualize(with: main)
        }
    }
}
