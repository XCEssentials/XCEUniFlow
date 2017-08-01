public
struct GlobalModel
{
    var data: [Key: Any] = [:]
    
    //===
    
    init() {}
}

//===

extension GlobalModel
{
    typealias Key = String
    
    static
    func key(for feature: Feature.Type) -> Key
    {
        return Key(reflecting: self)
    }
}

//===

extension GlobalModel
{
    //
}
