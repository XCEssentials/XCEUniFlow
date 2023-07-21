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
extension Dispatcher
{   
    func hasState<S: FeatureState>(
        ofType _: S.Type
    ) -> Bool {
        
        do
        {
            _ = try fetchState(
                ofType: S.self
            )
            
            return true
        }
        catch
        {
            return false
        }
    }
    
    func ensureHasAnyState(fromTheList whitelist: [SomeStateBase.Type]) throws
    {
        let allStatesTypes = allStates.map { type(of: $0) }
        
        guard
            let _ = whitelist
                .first(where: {
                    
                    targetStateType in
                    
                    //---
                    
                    allStatesTypes.contains(where: { $0 == targetStateType })
                })
        else
        {
            throw CurrentStateCheckError.currentStateIsNotInTheList(whitelist)
        }
    }
}

//---

public
extension FeatureState
{
    static
    func fetch(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from dispatcher: Dispatcher
    ) throws -> Self {
        
        try dispatcher.fetchState(
            ofType: self
        )
    }
    
    //---
    
    static
    func isPresent(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        in dispatcher: Dispatcher
    ) -> Bool {
        
        dispatcher.hasState(
            ofType: self
        )
    }
}
