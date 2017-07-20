import XCERequirement

//===

public
extension Feature
{
    static
    func initialization<S: FeatureState>(
        action name: String = #function,
        body: @escaping (Wrapped<StateGetter<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
        where Self == S.ParentFeature
    {
        return action(name) { model, mutate, next in
                
            try REQ.isNil("\(S.ParentFeature.name) is NOT initialized yet") {
                
                model ==> S.ParentFeature.self
            }
            
            //===
            
            var newState: S!
            
            //===
            
            // http://alisoftware.github.io/swift/closures/2016/07/25/closure-capture-1/
            // capture 'var' value by reference here!
            
            try body({ newState = $0() }, next)
            
            //===
            
            mutate { $0 <== newState }
        }
    }
    
    //===
    
    static
    func initialization<S: SimpleState>(
        action name: String = #function,
        into _: S.Type
        ) -> Action
        where Self == S.ParentFeature
    {
        return action(name) { model, mutate, _ in
            
            try REQ.isNil("\(S.ParentFeature.name) is NOT initialized yet") {
                
                model ==> S.ParentFeature.self
            }
            
            //===
            
            mutate { $0 <== S.init() }
        }
    }
}
