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
            var tmpModel = self.model
            
            try act.body(
                model,
                { $0(&tmpModel) },
                { self.proxy.submit($0) }
            )
            
            // if body will throw (even after call 'mutate',
            // then mutations will not be applied to global model
            self.model = tmpModel
            
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
