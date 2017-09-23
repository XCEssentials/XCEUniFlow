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
struct ObserverBinding: BDDScenario
{
    // MARK: - Public members

    public
    let context: Any.Type

    public
    let explicitSummary: String?

    // MARK: - Internal members

    public
    var onDidSatisfyWhenHandler: ((ObserverBinding) -> Void)?

    public
    var onWillPerformThenHandler: ((ObserverBinding) -> Void)?

    public
    let when: When

    public
    let given: [Given]

    public
    let then: Then

    // MARK: - Initializers

    init(context: StateObserver.Type,
         summary: String?,
         when: When,
         given: [Given],
         then: Then)
    {
        self.context = context
        self.explicitSummary = summary
        self.when = when
        self.given = given
        self.then = then
    }
}

//===

public
extension ObserverBinding
{
    func execute(
        with globalModel: GlobalModel,
        mutation: GlobalMutation?,
        observer: StateObserver
        ) throws
    {
        do
        {
            var input: Any = try self.when.implementation(mutation)

            //---

            self.onDidSatisfyWhenHandler?(self)

            //---

            for item in self.given
            {
                input = try item.implementation(globalModel, input)
            }

            //---

            self.onWillPerformThenHandler?(self)

            //--

            try self.then.implementation(observer, input)
        }
        catch
        {
            throw BDDScenarioFailure(context: self.context,
                                     summary: self.summary,
                                     reason: error)
        }
    }
}
