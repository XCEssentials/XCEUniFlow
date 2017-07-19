//  https://en.wikipedia.org/wiki/Proxy_pattern

import Foundation

//===

public
typealias DispatcherProxy =
(
    subscribe: (AnyObject) -> SubscriptionBlank,
    subscribeLater: (AnyObject) -> SubscriptionBlank,
    unsubscribe: (AnyObject) -> Void,
    submit: ActionGetterWrapped
)

//===

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

//===

public
protocol DispatcherBindable: class
{
    func bind(with proxy: DispatcherProxy) -> Self
}

//===

public
protocol DispatcherInitializable: class
{
    init(with proxy: DispatcherProxy)
}
