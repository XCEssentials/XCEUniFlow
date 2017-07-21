import XCERequirement

//===

//public
//struct DeinitializationFrom<S: FeatureState>: Action
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
//extension DeinitializationFrom
//{
//    init(action: String = #function)
//    {
//        self.name = action
//        
//        self.body = { model, mutate, _ in
//            
//            try REQ.isNotNil("\(S.ParentFeature.name) is in \(S.self) state") {
//                
//                model ==> S.self
//            }
//            
//            //===
//            
//            mutate{ $0 /== S.ParentFeature.self }
//        }
//    }
//    
//    //===
//    
//    init(
//        action: String = #function,
//        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
//        )
//    {
//        self.name = action
//        
//        self.body = { model, mutate, submit in
//            
//            let currentState =
//                
//            try REQ.value("\(S.ParentFeature.name) is in \(S.self) state") {
//                
//                model ==> S.self
//            }
//            
//            //===
//            
//            try body(currentState, submit)
//            
//            //===
//            
//            mutate{ $0 /== S.ParentFeature.self }
//        }
//    }
//}
//            
