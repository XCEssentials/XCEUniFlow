import Combine

// MARK: - Access log - Processed vs. Rejected

public
extension Publisher where Output == Dispatcher.AccessReport, Failure == Never
{
    var onProcessed: AnyPublisher<Dispatcher.ProcessedAccessEventReport, Failure>
    {
        return self
            .compactMap {
                
                switch $0.outcome
                {
                    case .processed(let mutations):
                        
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
    
    var onRejected: AnyPublisher<Dispatcher.RejectedAccessEventReport, Failure>
    {
        return self
            .compactMap {
                
                switch $0.outcome
                {
                    case .rejected(let reason):
                        
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
extension Publisher where Output == Dispatcher.ProcessedAccessEventReport, Failure == Never
{
    var perEachMutation: AnyPublisher<Storage.HistoryElement, Failure>
    {
        flatMap(\.mutations.publisher).eraseToAnyPublisher()
    }
}

public
extension Publisher where Output == Storage.HistoryElement, Failure == Never
{
    func `as`<T: SomeMutationDecriptor>(
        _: T.Type
    ) -> AnyPublisher<T, Failure> {
        
        compactMap(T.init(from:)).eraseToAnyPublisher()
    }
}

// MARK: - Access log - Processed - get features statuses (dashboard)

public
extension Publisher where Output == Dispatcher.ProcessedAccessEventReport, Failure == Never
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
        with features: [SomeFeature.Type]
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
