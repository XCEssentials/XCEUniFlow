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
