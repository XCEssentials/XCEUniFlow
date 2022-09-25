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
struct SemanticError: Error
{
    public
    let expectedMutation: ExpectedMutation
    
    public
    let proposedOutcome: MutationAttemptOutcome
    
    static
    func validateProposedOutcome(
        expected: ExpectedMutation,
        proposed: MutationAttemptOutcome
    ) throws -> Void {
        
        switch (expected, proposed)
        {
            case (.auto, _):
                
                break // OK
                
            case (.initialization, .initialization):
                
                break // OK
                
            case (.actualization, .actualization):
                
                break  // OK
                
            case (.transition(.some(let givenStateType)), .transition(let oldState, _))
                where givenStateType == type(of: oldState):
                
                break // OK
                
            case (.transition(.none), .transition):
                
                break // OK
                
            case (.deinitialization(.some(let givenOldStateType), _), .deinitialization(let oldState))
                where givenOldStateType == type(of: oldState):
                
                break // OK
                
            case (.deinitialization(.none, _), .deinitialization):
                
                break // OK
                
            case (.deinitialization(.none, strict: false), .nothingToRemove):
                
                break // OK
                
            default:
                
                throw Self(
                    expectedMutation: expected,
                    proposedOutcome: proposed
                )
        }
    }
}
