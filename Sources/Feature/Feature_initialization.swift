import XCERequirement

//===

public
struct Initialization<S: FeatureState>: Action
{
    public
    let name: String
    
    public
    let body: ActionBody
}

//===

public
extension Initialization
{
    init(
        action: String = #function,
        body: @escaping (Wrapped<StateGetter<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        )
    {
        self.name = action
        
        self.body = { model, mutate, submit in

            try REQ.isNil("\(S.ParentFeature.name) is NOT initialized yet") {
                
                model ==> S.ParentFeature.self
            }
            
            //===
            
            var newState: S!
            
            //===
            
            // http://alisoftware.github.io/swift/closures/2016/07/25/closure-capture-1/
            // capture 'var' value by reference here!
            
            try body({ newState = $0() }, submit)
            
            //===
            
            mutate { $0 <== newState }
        }
    }
}

//===

public
extension Initialization where S: SimpleState
{
    init(action: String = #function)
    {
        self.name = action
        
        self.body = { model, mutate, _ in
        
            try REQ.isNil("\(S.ParentFeature.name) is NOT initialized yet") {
                
                model ==> S.ParentFeature.self
            }
            
            //===
            
            mutate { $0 <== S.init() }
        }
    }
}
