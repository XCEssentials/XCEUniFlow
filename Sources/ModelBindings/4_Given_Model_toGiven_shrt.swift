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

// MARK: - After VOID, WITH output

public
extension Given.ModelConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func givn<Output>(
        _ specification: String,
        mapState handler: @escaping (GlobalModel) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        return and(specification, mapState: handler)
    }
}

// MARK: - After VOID, NO output

public
extension Given.ModelConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func givn(
        _ specification: String,
        withState handler: @escaping (GlobalModel) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        return and(specification, withState: handler)
    }
}

// MARK: - WITH output

public
extension Given.ModelConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func givn<Output>(
        _ specification: String,
        mapInput handler: @escaping (GivenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        return and(specification, mapInput: handler)
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func givn<Output>(
        _ specification: String,
        map handler: @escaping (GlobalModel, GivenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        return and(specification, map: handler)
    }
}

// MARK: - NO output

public
extension Given.ModelConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func givn(
        _ specification: String,
        withInput handler: @escaping (GivenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        return and(specification, withInput: handler)
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func givn(
        _ specification: String,
        with handler: @escaping (GlobalModel, GivenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        return and(specification, with: handler)
    }
}
