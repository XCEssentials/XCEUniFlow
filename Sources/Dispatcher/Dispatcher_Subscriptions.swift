final
class Subscription
{
    typealias Identifier = ObjectIdentifier
    
    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    let onConvert: ((GlobalModel, MutationAnnotation.Type) -> Any?)?
    let onUpdate: (Any, MutationAnnotation.Type) -> Void
    
    //===
    
    init<SubState>(
        _ onConvert: @escaping (GlobalModel, MutationAnnotation.Type) -> SubState?,
        _ onUpdate: @escaping (SubState, MutationAnnotation.Type) -> Void
        )
    {
        self.onConvert = onConvert
        self.onUpdate = {
            
            if
                let subState = $0 as? SubState
            {
                onUpdate(subState, $1)
            }
        }
    }
    
    init(
        _ onUpdate: @escaping (GlobalModel, MutationAnnotation.Type) -> Void
        )
    {
        self.onConvert = nil
        self.onUpdate = {
            
            if
                let globalModel = $0 as? GlobalModel
            {
                onUpdate(globalModel, $1)
            }
        }
    }
    
    //===
    
    func execute(with model: GlobalModel, recentChanges: MutationAnnotation.Type)
    {
        if
            let cvt = onConvert,
            let subModel = cvt(model, recentChanges)
        {
            onUpdate(subModel, recentChanges)
        }
        else
        {
            onUpdate(model, recentChanges)
        }
    }
}

// MARK: Proxy extensions

public
extension Dispatcher.Proxy
{
    public
    func subscribe(
        updateNow: Bool = true,
        onUpdate: @escaping (GlobalModel, MutationAnnotation.Type) -> Void
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(onUpdate)
        
        //===
        
        dispatcher.add(subscription, updateNow)
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
    
    public
    func subscribe<SubState>(
        updateNow: Bool = true,
        onConvert: @escaping (GlobalModel, MutationAnnotation.Type) -> SubState?,
        onUpdate: @escaping (SubState, MutationAnnotation.Type) -> Void
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(onConvert, onUpdate)
        
        //===
        
        dispatcher.add(subscription, updateNow)
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
}

// MARK: Dispatcher extensions

extension Dispatcher
{
    func add(
        _ subscription: Subscription,
        _ initialUpdate: Bool = true
        )
    {
        subscriptions[subscription.identifier] = subscription
        
        //===
        
        if
            initialUpdate
        {
            subscription.execute(
                with: model,
                recentChanges: NoMutation.self
            )
        }
    }
}
