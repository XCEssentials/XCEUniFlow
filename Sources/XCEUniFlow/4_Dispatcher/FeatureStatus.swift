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

import Combine

//---

public
struct FeatureStatus
{
    public
    enum StatusIndicator: String, Equatable, Codable
    {
        case ok = "🟢"
        case busy = "🟠"
        case failure = "🔴"
        case missing = "⚠️"
    }

    //---
    
    public
    let title: String
    
    public
    let subtitle: String
    
    public
    let state: (any FeatureState)?
    
    public
    let indicator: StatusIndicator
    
    public
    init(missing feature: Feature.Type)
    {
        self.title = feature.displayName
        self.subtitle = "<missing>"
        self.state = nil
        self.indicator = .missing
    }
    
    public
    init(with state: any FeatureState)
    {
        self.title = type(of: state).feature.displayName
        self.subtitle = .init(describing: type(of: state).self)
        self.state = state
        
        switch state
        {
            case is any FailureIndicator:
                self.indicator = .failure
                
            case is any BusyIndicator:
                self.indicator = .busy
                
            default:
                self.indicator = .ok
        }
    }
}
