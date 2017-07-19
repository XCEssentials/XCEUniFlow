import Foundation

//===

public
extension Dispatcher
{
    func enableDefaultReporting()
    {
        onReject = {
            
            print("===\\\\\\\\\\\\\\\\\\")
            
            print("MKHUniFlow: [-] \($0) REJECTED, error: \($1)")
            
            print("===/////////")
        }
    }
}
