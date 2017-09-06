import Foundation

// MARK: - Observer

public
protocol StateObserver: class
{
    func update(with: GlobalModel, mutation: GlobalMutation?) // @escaping SubmitAction
}

//===

public
extension Dispatcher
{
    final
    class Subscription
    {
        fileprivate(set)
        weak
        var observer: StateObserver?
        
        init(with observer: StateObserver)
        {
            self.observer = observer
        }
        
        typealias Identifier = ObjectIdentifier
        
        lazy
        var identifier: Identifier = Identifier(self)
    }
}

// MARK: - Subscription - internal methods

extension Dispatcher.Subscription
{
    @discardableResult
    func notifyAndKeep(with state: GlobalModel, mutation: GlobalMutation) -> Bool
    {
        guard
            let observer = observer
        else
        {
            return false
        }
        
        //---
        
        observer.update(with: state, mutation: mutation)
        
        //---
        
        return true
    }
}

// MARK: - Subscription - public methods

public
extension Dispatcher.Subscription
{
    func cancel()
    {
        observer = nil
    }
}

// MARK: Proxy extensions for subscriptions

public
extension Dispatcher.Proxy
{
    @discardableResult
    public
    func subscribe(
        _ observer: StateObserver,
        forceUpdateNow: Bool = false
        ) -> Dispatcher.Subscription
    {
        let result = Dispatcher.Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //---
        
        if
            forceUpdateNow
        {
            updateNow(observer)
        }
        
        //---
        
        return result
    }
    
    //===

    public
    func updateNow(_ observer: StateObserver)
    {
        observer.update(with: self.dispatcher.state, mutation: nil)
    }
}
