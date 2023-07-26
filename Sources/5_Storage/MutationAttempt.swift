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

//---

public
struct MutationAttempt
{
    public
    let timestamp: Date = .init()

    public
    let operation: MutationAttemptOutcome
}

//---

public
extension MutationAttempt
{
    var feature: Feature.Type
    {
        switch self.operation
        {
            case
                .initialization(let state),
                .actualization(let state, _),
                .transition(let state, _),
                .deinitialization(let state):
                
                return type(of: state).feature
                
            case .nothingToRemove(let feature):
                return feature
        }
    }
    
    var isAnyMutation: Bool
    {
        AnyMutation(from: self) != nil
    }

    var isAnySetting: Bool
    {
        AnySetting(from: self) != nil
    }

    var isInitialization: Bool
    {
        Initialization(from: self) != nil
    }

    var isUpdate: Bool
    {
        AnyUpdate(from: self) != nil
    }

    var isActualization: Bool
    {
        Actualization(from: self) != nil
    }

    var isTransition: Bool
    {
        Transition(from: self) != nil
    }

    var isDeinitialization: Bool
    {
        Deinitialization(from: self) != nil
    }
}
