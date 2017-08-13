import Foundation

//===

public
final
class Subscription
{
    // MARK: - Private members
    
    private
    weak
    var observer: AnyObject?
    
    // MARK: - Initializers
    
    init(with observer: PassiveObserver)
    {
        self.observer = observer
    }
    
    init(with observer: ActiveObserver)
    {
        self.observer = observer
    }
    
    // MARK: - Internal types
    
    typealias Identifier = ObjectIdentifier
    
    // MARK: - Internal members
    
    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    @discardableResult
    func notifyAndKeep(with mutation: Mutation,
                       model: GlobalModel,
                       submit: @escaping Wrapped<ActionGetter>) -> Bool
    {
        switch observer
        {
            case let observer as PassiveObserver:
                observer.update(with: mutation, model: model)
                return true
            
            case let observer as ActiveObserver:
                observer.update(with: mutation, model: model, submit: submit)
                return true
            
            default:
                return false // either 'nil' or not of any of expected protocols
        }
    }
    
    // MARK: - Public methods
    
    public
    func cancel()
    {
        observer = nil
    }
}

//===

public
protocol InitializableObserver: AnyObject
{
    func setup(with model: GlobalModel)
}

public
protocol PassiveObserver: AnyObject
{
    func update(with mutation: Mutation, model: GlobalModel)
}

public
protocol InitializablePassiveObserver: InitializableObserver, PassiveObserver { }

public
protocol ActiveObserver: AnyObject
{
    func update(with mutation: Mutation,
                model: GlobalModel,
                submit: @escaping Wrapped<ActionGetter>)
}

public
protocol InitializableActiveObserver: InitializableObserver, ActiveObserver { }

// MARK: Proxy extensions

public
extension Dispatcher.Proxy
{
    @discardableResult
    public
    func subscribe(_ observer: PassiveObserver,
                   updateNow: Bool = true) -> Subscription
    {
        let result = Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
        if
            updateNow
        {
            DispatchQueue.main.async {
                
                result.notifyAndKeep(with: NoMutation(),
                                           model: self.dispatcher.model,
                                           submit: self.submit)
            }
        }
        
        //===
        
        return result
    }
    
    @discardableResult
    public
    func subscribe(_ observer: InitializablePassiveObserver) -> Subscription
    {
        let result = Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
        DispatchQueue.main.async {
            
            observer.setup(with: self.dispatcher.model)
        }
        
        //===
        
        return result
    }
    
    @discardableResult
    public
    func subscribe(_ observer: ActiveObserver,
                   updateNow: Bool = true) -> Subscription
    {
        let result = Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
        if
            updateNow
        {
            DispatchQueue.main.async {
                
                result.notifyAndKeep(with: NoMutation(),
                                           model: self.dispatcher.model,
                                           submit: self.submit)
            }
        }
        
        //===
        
        return result
    }
    
    @discardableResult
    public
    func subscribe(_ observer: InitializableActiveObserver) -> Subscription
    {
        let result = Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //===
        
        DispatchQueue.main.async {
            
            observer.setup(with: self.dispatcher.model)
        }
        
        //===
        
        return result
    }
    
    public
    func setup(_ observer: InitializableObserver)
    {
        DispatchQueue.main.async {
            
            observer.setup(with: self.dispatcher.model)
        }
    }
    
    public
    func updateNow(_ observer: PassiveObserver)
    {
        DispatchQueue.main.async {
            
            observer.update(with: NoMutation(),
                            model: self.dispatcher.model)
        }
    }
    
    public
    func updateNow(_ observer: ActiveObserver)
    {
        DispatchQueue.main.async {
            
            observer.update(with: NoMutation(),
                            model: self.dispatcher.model,
                            submit: self.submit)
        }
    }
}
