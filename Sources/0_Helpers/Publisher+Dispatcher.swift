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
extension Publisher
{
    func executeNow()
    {
        _ = sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}

// MARK: - Access log - Processed vs. Rejected

public
extension Publisher where Output == Dispatcher.AccessReport, Failure == Never
{
    var onProcessed: AnyPublisher<Dispatcher.ProcessedActionReport, Failure>
    {
        return self
            .compactMap {
                
                switch $0.outcome
                {
                    case .success(let mutations):
                        
                        return .init(
                            timestamp: $0.timestamp,
                            mutations: mutations,
                            storage: $0.storage,
                            origin: $0.origin
                        )
                        
                    default:
                        
                        return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var onRejected: AnyPublisher<Dispatcher.RejectedActionReport, Failure>
    {
        return self
            .compactMap {
                
                switch $0.outcome
                {
                    case .failure(let reason):
                        
                        return .init(
                            timestamp: $0.timestamp,
                            reason: reason,
                            storage: $0.storage,
                            origin: $0.origin
                        )
                        
                    default:
                        
                        return nil
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Access log - Processed - get individual mutations

public
extension Publisher where Output == Dispatcher.ProcessedActionReport, Failure == Never
{
    var perEachMutation: AnyPublisher<Storage.HistoryElement, Failure>
    {
        flatMap(\.mutations.publisher).eraseToAnyPublisher()
    }
}

public
extension Publisher where Output == Storage.HistoryElement, Failure == Never
{
    func `as`<T: MutationDecriptor>(
        _: T.Type
    ) -> AnyPublisher<T, Failure> {
        
        compactMap(T.init(from:)).eraseToAnyPublisher()
    }
}

// MARK: - Access log - Processed - get features statuses (dashboard)

public
extension Publisher where Output == Dispatcher.ProcessedActionReport, Failure == Never
{
    var statusReport: AnyPublisher<[FeatureStatus], Failure>
    {
        self
            .filter {
                !$0.mutations.isEmpty
            }
            .map {
                $0.storage
                    .allStates
                    .map(
                        FeatureStatus.init
                    )
            }
            .eraseToAnyPublisher()
    }
}

public
extension Publisher where Output == [FeatureStatus], Failure == Never
{
    func matched(
        with features: [Feature.Type]
    ) -> AnyPublisher<Output, Failure> {

        self
            .map { existingStatuses in
                
                features
                    .map { feature in
                        
                        existingStatuses
                            .first(where: {
                                
                                if
                                    let state = $0.state
                                {
                                    return type(of: state).feature.name == feature.name
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
