public
struct SemanticMutationError: Error
{
    public
    let expectedMutation: ExpectedMutation
    
    public
    let proposedOutcome: MutationAttemptOutcome
}

public
enum MutationAttemptOutcome
{
    case initialization(key: SomeFeatureBase.Type, newValue: SomeStateBase)
    case actualization(key: SomeFeatureBase.Type, oldValue: SomeStateBase, newValue: SomeStateBase)
    case transition(key: SomeFeatureBase.Type, oldValue: SomeStateBase, newValue: SomeStateBase)
    case deinitialization(key: SomeFeatureBase.Type, oldValue: SomeStateBase)
    
    /// No removal operation has been performed, because no such key has been found.
    case nothingToRemove(key: SomeFeatureBase.Type)
}

public
enum ExpectedMutation
{
    case auto
    case initialization
    case actualization
    case transition(fromValueType: SomeStateBase.Type?)
    case deinitialization(fromValueType: SomeStateBase.Type?, strict: Bool)
    
    func validateProposedOutcome(_ outcome: MutationAttemptOutcome) throws -> Void
    {
        switch (self, outcome)
        {
            case (.auto, _):
                
                break // OK
                
            case (.initialization, .initialization):
                
                break // OK
                
            case (.actualization, .actualization):
                
                break  // OK
                
            case (.transition(.some(let givenOldValueType)), .transition(_, let oldValue, _))
                where givenOldValueType == type(of: oldValue):
                
                break // OK
                
            case (.transition(.none), .transition):
                
                break // OK
                
            case (.deinitialization(.some(let givenOldValueType), _), .deinitialization(let oldValue, _))
                where givenOldValueType == type(of: oldValue):
                
                break // OK
                
            case (.deinitialization(.none, _), .deinitialization):
                
                break // OK
                
            case (.deinitialization(.none, strict: false), .nothingToRemove):
                
                break // OK
                
            default:
                throw SemanticMutationError(
                    expectedMutation: self,
                    proposedOutcome: outcome
                )
        }
    }
}
