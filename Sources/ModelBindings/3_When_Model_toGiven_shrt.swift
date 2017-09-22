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
extension When.ModelConnector
{
    /**
     Defines first 'GIVEN' clause in a Scenario.
     */
    func givn<Output>(
        _ specification: String,
        mapState handler: @escaping (GlobalModel) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        return self.given(specification, mapState: handler)
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario.
     */
    func givn<Output>(
        _ specification: String,
        mapMutation handler: @escaping (WhenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        return given(specification, mapMutation: handler)
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario.
     */
    func givn<Output>(
        _ specification: String,
        map handler: @escaping (GlobalModel, WhenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        return given(specification, map: handler)
    }
}

// MARK: - NO output

public
extension When.ModelConnector
{
    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func givn(
        _ specification: String,
        withState handler: @escaping (GlobalModel) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        return given(specification, withState: handler)
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func givn(
        _ specification: String,
        withMutation handler: @escaping (WhenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        return given(specification, withMutation: handler)
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func givn(
        _ specification: String,
        with handler: @escaping (GlobalModel, WhenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        return given(specification, with: handler)
    }
}
