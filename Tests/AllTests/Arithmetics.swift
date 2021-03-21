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

import Foundation

import XCEUniFlow
import XCERequirement

//---

enum Arithmetics: Feature, NoBindings
{
    struct Main: State { typealias Parent = Arithmetics
        
        var val: Int
    }
}

//---

extension Arithmetics
{
    static
    func begin() -> Action
    {
        return initialize.Into<Main>.via
        {
            become, submit in

            //---
            
            become << Main(val: 0)
            
            //---
            
            submit << [ setExplicit(value: 10),
                        incFive() ]
        }
    }
    
    static
    func setExplicit(value: Int) -> Action
    {
        return actualize.In<Main>.via
        {
            _, current, _ in

            //---

            try Require("Current value is != to desired new value"){ value != $0 }
                .validate(current.val)
            
            //---
            
            current.val = value
        }
    }
    
    static
    func incFive() -> Action
    {
        return actualize.In<Main>.via
        {
            _, current, _ in

            //---
            
            current.val += 5
        }
    }
}
