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

public
enum MutationAttemptOutcome: CustomStringConvertible
{
    case initialization(newState: FeatureStateBase)
    case actualization(oldState: FeatureStateBase, newState: FeatureStateBase)
    case transition(oldState: FeatureStateBase, newState: FeatureStateBase)
    case deinitialization(oldState: FeatureStateBase)
    
    /// No removal operation has been performed, because no such key has been found.
    case nothingToRemove(feature: Feature.Type)
    
    public
    var description: String
    {
        switch self
        {
            case .initialization(let newState):
                return ".initialization(newState: \(type(of: newState))"
                
            case .actualization(let oldState, let newState):
                return ".actualization(oldState: \(type(of: oldState)), newState: \(type(of: newState))"
                
            case .transition(let oldState, let newState):
                return ".transition(oldState: \(type(of: oldState)), newState: \(type(of: newState))"
                
            case .deinitialization(let oldState):
                return ".deinitialization(oldState: \(type(of: oldState))"
                
            case .nothingToRemove(let feature):
                return ".nothingToRemove(feature: \(feature.name)"
        }
    }
}
