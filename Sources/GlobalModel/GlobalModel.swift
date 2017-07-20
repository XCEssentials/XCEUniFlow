public
typealias FeatureKey = String

//===

public
extension Feature
{
    static
    var key: FeatureKey
    {
        return FeatureKey(reflecting: self)
    }
}

//===

public
struct GlobalModel
{
    var data: [FeatureKey: Any] = [:]
    
    //===
    
    init() {}
}
