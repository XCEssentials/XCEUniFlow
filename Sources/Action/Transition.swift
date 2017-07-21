import XCERequirement

//===

//public
//struct TransitionBetween<From, Into>: Action where
//    From: FeatureState,
//    Into: FeatureState,
//    From.ParentFeature == Into.ParentFeature
//{
//    public
//    let name: String
//    
//    public
//    let body: ActionBody
//}
//
////===
//
//public
//extension TransitionBetween
//{
//    init(
//        action: String = #function,
//        body: @escaping (From, Wrapped<StateGetter<Into>>, @escaping Wrapped<ActionGetter>) throws -> Void
//        )
//    {
//        self.name = action
//        
//        self.body = { model, mutate, submit in
//            
//            let currentState =
//                
//            try REQ.value("\(From.ParentFeature.name) is in \(From.self) state") {
//                
//                model ==> From.self
//            }
//            
//            //===
//            
//            var newState: Into?
//            
//            try body(currentState, { newState = $0() }, submit)
//            
//            //===
//            
//            try REQ.isNotNil("New state for \(Into.ParentFeature.name) is set") {
//                
//                newState
//            }
//            
//            //===
//            
//            mutate { $0 <== newState }
//        }
//    }
//}
//
////===
//
//public
//extension TransitionBetween where Into: SimpleState
//{
//    init(action: String = #function)
//    {
//        self.name = action
//        
//        self.body = { model, mutate, _ in
//            
//            try REQ.isNotNil("\(From.ParentFeature.name) is in \(From.self) state") {
//                
//                model ==> From.self
//            }
//            
//            //===
//            
//            mutate { $0 <== Into.init() }
//        }
//    }
//    
//    //===
//    
//    init(
//        action: String = #function,
//        body: @escaping (@escaping Wrapped<ActionGetter>) throws -> Void
//        )
//    {
//        self.name = action
//        
//        self.body = { model, mutate, submit in
//            
//            try REQ.isNotNil("\(From.ParentFeature.name) is in \(From.self) state") {
//                
//                model ==> From.self
//            }
//            
//            //===
//            
//            mutate { $0 <== Into.init() }
//            
//            //===
//            
//            try body(submit)
//        }
//    }
//}
