import Combine

// MARK: - Access log - Processed vs. Rejected

public
extension Publisher where Output == StorageDispatcher.AccessReport, Failure == Never
{
    var onProcessed: AnyPublisher<StorageDispatcher.ProcessedAccessEventReport, Failure>
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
                            env: $0.env
                        )
                        
                    default:
                        
                        return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var onRejected: AnyPublisher<StorageDispatcher.RejectedAccessEventReport, Failure>
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
                            env: $0.env
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
extension Publisher where Output == StorageDispatcher.ProcessedAccessEventReport, Failure == Never
{
    var mutation: AnyPublisher<Storage.HistoryElement, Failure>
    {
        self
            .flatMap(
                \.mutations.publisher
            )
            .eraseToAnyPublisher()
    }
    
    func mutation<T: SomeMutationDecriptor>(
        _: T.Type
    ) -> AnyPublisher<T, Failure> {
        
        mutation
            .compactMap(
                T.init(from:)
            )
            .eraseToAnyPublisher()
    }
}
