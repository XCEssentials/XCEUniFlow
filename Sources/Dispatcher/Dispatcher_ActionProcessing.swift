import Foundation

//===

public
extension Dispatcher.Proxy
{
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
            // another Action safely
            
            self.dispatcher.process(act)
        }
    }
    
    public
    func submit(_ actionGetter: @autoclosure () -> Action)
    {
        submit(actionGetter)
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
                let (mutations, annotation) = result
            {
                mutations(&model)
                subscriptions.forEach{
                    
                    $0.value.execute(with: model, recentChanges: annotation)
                }
            }
            
            //===
            
            onDidProcessAction?(act.name, act.feature.name)
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onDidRejectAction?(act.name, act.feature.name, error)
        }
    }
}
