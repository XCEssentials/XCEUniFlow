public
protocol ActionContext { }

//===

public
extension ActionContext
{
    
//    // This kind of general action is NOT allowed, because it does not guarantee
//    // that requested mutations are eligible on the global model. It's required that user
//    // uses one of provided convenient mutation helpers - they do necessary chacks
//    // before proceed to user provided custom code and isolate user from
//    // accessing global model directly.
//    
//    static
//    func action(
//        scope: String = #file,
//        context: String = #function,
//        body: @escaping (GlobalModel, SubmitMutations, @escaping SubmitAction) throws -> Void
//        ) -> Action
//    {
//        return Action(scope, context, self) { model, submit in
//
//            var mutations: [GlobalMutation] = []
//
//            //---
//
//            try body(model, { mutations.append(contentsOf: $0) }, submit)
//
//            //---
//
//            return mutations.isEmpty ? nil : mutations
//        }
//    }
    
    //===
    
    static
    func trigger(
        scope: String = #file,
        context: String = #function,
        body: @escaping (GlobalModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try body(model, submit)
            
            //---
            
            return nil
        }
    }
}
