public
protocol ActionContext { }

//===

public
extension ActionContext
{
    static
    func action(
        name: String = #function,
        body: @escaping (GlobalModel, Wrapped<Mutations<GlobalModel>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: name, context: Self.self) { model, submit in
            
            var updatedModel = model
            
            //===
            
            try body(model, { $0(&updatedModel) }, submit)
            
            //===
            
            return ({ $0 = updatedModel }, UnspecifiedMutation.self)
        }
    }
    
    //===
    
    static
    func trigger(
        action: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: Self.self) { model, submit in
            
            try body(model, submit)
            
            //===
            
            return nil
        }
    }
}
