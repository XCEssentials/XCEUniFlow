import Foundation

//===

public
extension Dispatcher.Proxy
{
    public
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
    
    public
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

//===

extension Dispatcher
{
    func process(_ act: Action)
    {
        do
        {
            try act.body(
                model,
                { $0(&self.model) },
                { self.proxy.submit($0) }
            )
            
            //===
            
            onDidProcessAction?(act.name)
            notifySubscriptions()
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onDidRejectAction?(act.name, error)
        }
    }
}
