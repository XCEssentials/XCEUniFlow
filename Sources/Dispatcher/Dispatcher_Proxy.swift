import Foundation

//===

public
extension Dispatcher
{
    public
    final
    class Proxy
    {
        //  https://en.wikipedia.org/wiki/Proxy_pattern
        
        let dispatcher: Dispatcher
        
        //===
        
        init(_ dispatcher: Dispatcher)
        {
            self.dispatcher = dispatcher
        }
        
        //===
        
        func subscribe(
            _ observer: AnyObject,
            updateNow: Bool = true
            ) -> SubscriptionBlank
        {
            return SubscriptionBlank(
                observer: observer,
                dispatcher: dispatcher,
                initialUpdate: updateNow
            )
        }
        
        func unsubscribe(_ observer: AnyObject)
        {
            dispatcher.subscriptions.removeObject(forKey: observer)
        }
        
        func submit(_ actionGetter: @autoclosure () -> Action)
        {
            let act = actionGetter()
            
            //===
            
            OperationQueue.main.addOperation {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is complete,
                // that allows to submit an Action from
                // another Action
                
                self.dispatcher.process(act)
            }
        }
        
        func submit(_ actionGetter: () -> Action)
        {
            let act = actionGetter()
            
            //===
            
            OperationQueue.main.addOperation {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is complete,
                // that allows to submit an Action from
                // another Action
                
                self.dispatcher.process(act)
            }
        }
    }
}
