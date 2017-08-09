public
enum DefaultReporting
{
    case none, short, verbose
}

//===

public
extension Dispatcher
{
    func enableVerboseDefaultReporting()
    {
        onDidProcessAction = {
            
            print("XCEUniFlow: [+] PROCESSED '\($0.name)' / '\($0.typeDescription)'")
        }
        
        onDidRejectAction = {
            
            print("XCEUniFlow: [-] REJECTED '\($0.name)' / '\($0.typeDescription)', reason: \($1)")
        }
    }
    
    func enableShortDefaultReporting()
    {
        onDidProcessAction = {
            
            print("XCEUniFlow: [+] PROCESSED '\($0.typeDescription)'")
        }
        
        onDidRejectAction = {
            
            print("XCEUniFlow: [-] REJECTED '\($0.typeDescription)', reason: \($1)")
        }
    }
    
    func resetReporting()
    {
        onDidProcessAction = nil
        onDidRejectAction = nil
    }
}
