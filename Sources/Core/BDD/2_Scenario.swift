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
protocol BDDScenarioClause: CustomStringConvertible
{
    var prefix: String { get }
    var specification: String { get }
}

//===

public
extension BDDScenarioClause
{
    var prefix: String
    {
        return "\(type(of: self))"
    }
    
    var description: String
    {
        return "\(prefix.uppercased()) \(specification)"
    }
}

// MARK: - Scenario

public
protocol BDDScenario: CustomStringConvertible
{
    associatedtype ThenClause: BDDScenarioClause

    // MARK: - Public members

    var context: Any.Type { get }
    var explicitSummary: String? { get }

    // MARK: - Internal members

    var onDidSatisfyWhenHandler: ((Self) -> Void)? { get set }
    var onWillPerformThenHandler: ((Self) -> Void)? { get set }

    var when: When { get }
    var given: [Given] { get }
    var then: ThenClause { get }
}

//===

public
extension BDDScenario
{
    var implicitSummary: String
    {
        return type(of: self).constructSummary(when, given, then)
    }

    var summary: String
    {
        return explicitSummary ?? implicitSummary
    }

    var description: String
    {
        return "[\(String(reflecting: context))] \(summary)"
    }

    //===

    func onDidSatisfyWhen(_ handler: @escaping (Self) -> Void) -> Self
    {
        var result = self
        result.onDidSatisfyWhenHandler = handler

        //---

        return result
    }

    func onDidSatisfyWhenDefault() -> Self
    {
        var result = self
        result.onDidSatisfyWhenHandler = { print($0.description) }

        //---

        return result
    }

    func onWillPerformThen(_ handler: @escaping (Self) -> Void) -> Self
    {
        var result = self
        result.onWillPerformThenHandler = handler

        //---

        return result
    }

    func onWillPerformThenDefault() -> Self
    {
        var result = self
        result.onWillPerformThenHandler = { print($0.description) }

        //---

        return result
    }

    // MARK: - Summary auto-constructor

    private
    static
    func constructSummary(
        _ when: BDDScenarioClause,
        _ given: [BDDScenarioClause],
        _ then: BDDScenarioClause
        ) -> String
    {
        return ([when] + given + [then])
            .map{ $0.description }
            .joined(separator: ", ") + "."
    }
}
