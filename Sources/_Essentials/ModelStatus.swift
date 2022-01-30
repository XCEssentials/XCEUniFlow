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
struct ModelStatus
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
    let state: SomeStateBase?
    
    public
    let indicator: StatusIndicator
    
    public
    init(missing model: SomeStateful.Type)
    {
        self.title = model.displayName
        self.subtitle = "<missing>"
        self.state = nil
        self.indicator = .missing
    }
    
    public
    init(with state: SomeStateBase)
    {
        self.title = type(of: state).model.displayName
        self.subtitle = .init(describing: type(of: state).self)
        self.state = state
        
        switch state
        {
            case is FailureIndicator:
                self.indicator = .failure
                
            case is BusyIndicator:
                self.indicator = .busy
                
            default:
                self.indicator = .ok
        }
    }
}

// MARK: - Access log - Processed - get model status (dashboard)

public
extension Publisher where Output == StorageDispatcher.ProcessedAccessEventReport, Failure == Never
{
    var statusReport: AnyPublisher<[ModelStatus], Failure>
    {
        self
            .filter {
                !$0.mutations.isEmpty
            }
            .map {
                $0.storage
                    .allValues
                    .map(
                        ModelStatus.init
                    )
            }
            .eraseToAnyPublisher()
    }
}

public
extension Publisher where Output == [ModelStatus], Failure == Never
{
    func matched(
        with models: [SomeStateful.Type]
    ) -> AnyPublisher<Output, Failure> {

        self
            .map { existingStatuses in
                
                models
                    .map { feature in
                        
                        existingStatuses
                            .first(where: {
                                
                                if
                                    let state = $0.state
                                {
                                    return type(of: state).model.name == feature.name
                                }
                                else
                                {
                                    return false
                                }
                            })
                            ?? .init(missing: feature)
                    }
            }
            .eraseToAnyPublisher()
    }
}
