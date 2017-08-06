public
extension Dispatcher
{
    func enableDefaultReporting()
    {
        onDidProcessAction = {
            
            print("XCEUniFlow: [+] PROCESSED '\($0)' from '\($1)'")
        }
        
        onDidRejectAction = {
            
            print("XCEUniFlow: [-] REJECTED '\($0)' from '\($1)', reason: \($2)")
        }
    }
    
    func resetReporting()
    {
        onDidProcessAction = nil
        onDidRejectAction = nil
    }
}
