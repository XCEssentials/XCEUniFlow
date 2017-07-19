import Foundation

//===

public
protocol ActionContext {}

//===

public
extension ActionContext
{
    static
    var name: String { return String(reflecting: Self.self) }
    
    static
    func action(_ name: String = #function, body: @escaping ActionBody) -> Action
    {
        return Action("\(self.name).\(name)", body)
    }
}
