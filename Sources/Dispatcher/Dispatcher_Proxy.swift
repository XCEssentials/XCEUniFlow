public
extension Dispatcher
{
    var proxy: DispatcherProxy {
        
        return (
            subscribe: { self.subscribe($0) },
            subscribeLater: { self.subscribe($0, updateNow: false) },
            unsubscribe: self.unsubscribe,
            submit: self.submit
        )
    }
}
