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
    func process(_ action: Action)
    {
        do
        {
            let result = try action.body(state.itself, proxy.submit)
            
            //===
            
            // NOTE: if body will throw,
            // then mutations will not be applied to global model
            
            //===
            
            if
                let request = result
            {
//                mutation(&model)
//                
//                middleware
//                    .forEach { $0(diff, model, proxy.submit) }
//                
//                subscriptions
//                    .filter {
//                        
//                        !$0.value.notifyAndKeep(with: diff,
//                                                model: model,
//                                                submit: proxy.submit)
//                    }
//                    .map { $0.key }
//                    .forEach { subscriptions[$0] = nil }
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
