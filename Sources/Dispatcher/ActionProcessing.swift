import Foundation

//===

public
extension Dispatcher.Proxy
{
    public
    func submit(_ action: Action)
    {
        OperationQueue.main.addOperation {
            
            // we add this action to queue async-ly,
            // to make sure it will be processed AFTER
            // current execution is complete,
            // that allows to submit an Action from
            // another Action safely
            
            self.dispatcher.process(action)
        }
    }

    public
    func submit(_ actionGetter: () -> Action)
    {
        submit(actionGetter())
    }
}

//===

extension Dispatcher
{
    func process(_ act: Action)
    {
        do
        {
            let result = try act.body(model) { self.proxy.submit($0) }
            
            //===
            
            // NOTE: if body will throw,
            // then mutations will not be applied to global model
            
            //===
            
            if
                let (mutation, annotation) = result
            {
                mutation(&model)
                subscriptions.forEach{ $0.value.notify(annotation, model) }
            }
            
            //===
            
            onDidProcessAction?(act.name, act.contextDescription)
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onDidRejectAction?(act.name, act.contextDescription, error)
        }
    }
}
