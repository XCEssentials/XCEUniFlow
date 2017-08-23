import Foundation

//===

public
extension Dispatcher
{
    final
    class Subscription
    {
        fileprivate(set)
        weak
        var observer: AnyObject?
        
        init(with observer: PassiveObserver)
        {
            self.observer = observer
        }
        
        init(with observer: ActiveObserver)
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
    func notifyAndKeep(with diff: GlobalDiff,
                       model: GlobalModel,
                       submit: @escaping Wrapped<ActionGetter>) -> Bool
    {
        switch observer
        {
            case let observer as PassiveObserver:
                observer.update(with: diff, model: model)
                return true
            
            case let observer as ActiveObserver:
                observer.update(with: diff, model: model, submit: submit)
                return true
            
            default:
                return false // either 'nil' or not of any of expected protocols
        }
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

// MARK: - Observer protocols

public
protocol InitializableObserver: AnyObject
{
    func setup(with model: GlobalModel)
}

public
protocol PassiveObserver: AnyObject
{
    func update(with diff: GlobalDiff, model: GlobalModel)
}

public
protocol InitializablePassiveObserver: InitializableObserver, PassiveObserver { }

public
protocol ActiveObserver: AnyObject
{
    func update(with diff: GlobalDiff,
                model: GlobalModel,
                submit: @escaping Wrapped<ActionGetter>)
}

public
protocol InitializableActiveObserver: InitializableObserver, ActiveObserver { }

// MARK: Proxy extensions for subscriptions

public
extension Dispatcher.Proxy
{
    @discardableResult
    public
    func subscribe(_ observer: PassiveObserver,
                   updateNow: Bool = false) -> Dispatcher.Subscription
    {
        let result = Dispatcher.Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
        if
            updateNow
        {
//            DispatchQueue.main.async {
            
                result.notifyAndKeep(with: NoMutation(),
                                     model: self.dispatcher.model,
                                     submit: self.submit)
//            }
        }
        
        //===
        
        return result
    }
    
    @discardableResult
    public
    func subscribe(_ observer: InitializablePassiveObserver) -> Dispatcher.Subscription
    {
        let result = Dispatcher.Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
//        DispatchQueue.main.async {
        
            observer.setup(with: self.dispatcher.model)
//        }
        
        //===
        
        return result
    }
    
    @discardableResult
    public
    func subscribe(_ observer: ActiveObserver,
                   updateNow: Bool = false) -> Dispatcher.Subscription
    {
        let result = Dispatcher.Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
        if
            updateNow
        {
//            DispatchQueue.main.async {
            
                result.notifyAndKeep(with: NoMutation(),
                                     model: self.dispatcher.model,
                                     submit: self.submit)
//            }
        }
        
        //===
        
        return result
    }
    
    @discardableResult
    public
    func subscribe(_ observer: InitializableActiveObserver) -> Dispatcher.Subscription
    {
        let result = Dispatcher.Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
//        DispatchQueue.main.async {
        
            observer.setup(with: self.dispatcher.model)
//        }
        
        //===
        
        return result
    }
    
    public
    func setup(_ observer: InitializableObserver)
    {
//        DispatchQueue.main.async {
        
            observer.setup(with: self.dispatcher.model)
//        }
    }
    
    public
    func updateNow(_ observer: PassiveObserver)
    {
//        DispatchQueue.main.async {
        
            observer.update(with: NoMutation(),
                            model: self.dispatcher.model)
//        }
    }
    
    public
    func updateNow(_ observer: ActiveObserver)
    {
//        DispatchQueue.main.async {
        
            observer.update(with: NoMutation(),
                            model: self.dispatcher.model,
                            submit: self.submit)
//        }
    }
}
