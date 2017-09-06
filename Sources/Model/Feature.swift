public
protocol Feature {}

//===

public
extension Feature
{
    static
    var name: String { return String(reflecting: self) }
}
