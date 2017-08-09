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
        body: @escaping (GlobalModel, Wrapped<Mutations<GlobalModel>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            var updatedModel = model
            
            //===
            
            try body(model, { $0(&updatedModel) }, submit)
            
            //===
            
            return ({ $0 = updatedModel }, UnspecifiedMutation())
        }
    }
    
    //===
    
    static
    func trigger(
        scope: String = #file,
        context: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try body(model, submit)
            
            //===
            
            return nil
        }
    }
}
