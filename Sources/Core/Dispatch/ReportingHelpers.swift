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
enum DefaultReporting
{
    case none, short, verbose
}

//===

public
extension Dispatcher
{
    func enableVerboseDefaultReporting()
    {
        onDidProcessAction = {
            
            print("XCEUniFlow: [+] PROCESSED '\($0.name)' >> '\($0.kindDescription)'")
        }
        
        onDidRejectAction = {
            
            print("XCEUniFlow: [-] REJECTED '\($0.name)' >> '\($0.kindDescription)', reason: \($1)")
        }

        onDidProcessBinding = {

            print("XCEUniFlow: [+] processed BINDING: '\($0)'")
        }

        onDidRejectBinding = {

            print("XCEUniFlow: [-] rejected BINDING: '\($0)', reason: \($1)")
        }
    }
    
    //===

    func enableShortDefaultReporting()
    {
        onDidProcessAction = {
            
            print("XCEUniFlow: [+] PROCESSED '\($0.context)' >> '\($0.kindDescription)'")
        }
        
        onDidRejectAction = {
            
            print("XCEUniFlow: [-] REJECTED '\($0.context)' >>  '\($0.kindDescription)', reason: \($1)")
        }

        onDidProcessBinding = {

            print("XCEUniFlow: [+] processed BINDING: '\($0)'")
        }
    }
    
    //===

    func resetReporting()
    {
        onDidProcessAction = nil
        onDidRejectAction = nil
    }
}
