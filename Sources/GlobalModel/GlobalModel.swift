public
struct GlobalModel
{
    public
    typealias Key = String
    
    static
    func key(for feature: Feature.Type) -> Key
    {
        return Key(reflecting: self)
    }
    
    //===
    
    var data: [Key: Any] = [:]
    
    //===
    
    init() {}
}
