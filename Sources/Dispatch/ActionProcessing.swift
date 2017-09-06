import Foundation

//===

public
extension Dispatcher.Proxy
{
    public
    func submit(_ action: Action)
    {
        DispatchQueue.main.async {
            
            // we add this action to queue async-ly,
            // to make sure it will be processed AFTER
            // current execution is complete,
            // that allows to submit an Action from
            // another Action safely
            
            self.dispatcher.process(action)
        }
    }
}

//===

extension Dispatcher
{
    func syncMiddleware(_ mutation: GlobalMutationExt)
    {
        let mutationType = type(of: mutation)
        let key = mutationType.feature.name
        
        switch mutationType.kind
        {
            case .addition:
                middleware[key] = mutationType.feature.middleware
            
            case .update:
                break
            
            case .removal:
                middleware[key] = nil
        }
    }
    
    func process(_ action: Action)
    {
        do
        {
            if
                let mutation = try action.body(state, proxy.submit)
            {
                // NOTE: if body will throw,
                // then mutations will not be applied to global model
                
                //---
                
                state = mutation.apply(state) // mutation(&model)
                
                //---
                
                syncMiddleware(mutation)
                
                //---
                
                middleware.values.joined().forEach{
                    
                    $0(state, mutation, proxy.submit)
                }

                //---
                
                // in one pass notify observers and release cancelled subscriptions
                subscriptions
                    .filter { !$0.value.notifyAndKeep(with: state, mutation: mutation) }
                    .map { $0.key }
                    .forEach { subscriptions[$0] = nil }
            }
            
            //===
            
            onDidProcessAction?(action)
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onDidRejectAction?(action, error)
        }
    }
}
