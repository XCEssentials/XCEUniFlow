public
typealias FeatureKey = String

//===

public
struct GlobalModel
{
    var data: [FeatureKey: Any] = [:]
    
    //===
    
    static
    func key<F: Feature>(from _: F.Type) -> FeatureKey
    {
        return String(reflecting: F.self)
    }
    
    //===
    
    init() {}
}
