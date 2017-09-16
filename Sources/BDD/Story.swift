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

/**
 
 Example:
 
 AS the app owner
 IN ORDER TO retain users
 I WANT TO provide smooth and pleasant FTUE.
 
 */
public
typealias StorySummary = (as: String, inOrderTo: String, wantTo: String)

//===

public
protocol Story
{
    static
    var name: String { get }

    static
    var summary: StorySummary { get }
    
    static
    var scenarios: [Scenario] { get }
}

//===

public
extension Story
{
    static
    var name: String
    {
        return String(reflecting: self)
    }
    
    static
    var summary: StorySummary
    {
        return ("", "", "")
    }
    
    static
    var scenarios: [Scenario]
    {
        return []
    }
}
