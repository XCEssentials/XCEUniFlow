public
protocol ActionContext { }

//===

public
extension ActionContext
{
    static
    func action(
        scope: String = #file,
        context: String = #function,
        body: @escaping (NewModel, SubmitMutations, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            var mutations: [GlobalDiff] = []
            
            //---
            
            try body(model, { mutations.append(contentsOf: $0) }, submit)
            
            //---
            
            return mutations
        }
    }
    
    //===
    
    static
    func trigger(
        scope: String = #file,
        context: String = #function,
        body: @escaping (NewModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try body(model, submit)
            
            //---
            
            return nil
        }
    }
}
