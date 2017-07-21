import XCERequirement

//===

//public
//struct TriggerOn: Action
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
//extension TriggerOn
//{
//    init(
//        action: String = #function,
//        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
//        )
//    {
//        self.name = action
//        
//        self.body = { model, _, submit in
//            
//            try body(model, submit)
//        }
//    }
//    
//    init<S: FeatureState>(
//        action: String = #function,
//        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
//        )
//    {
//        self.name = action
//        
//        self.body = { model, _, submit in
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
//        }
//    }
//}
