public
extension Dispatcher
{
    func enableDefaultReporting()
    {
        onDidProcessAction = {
            
            print("XCEUniFlow: [+] \($0) PROCESSED")
        }
        
        onDidRejectAction = {
            
            print("XCEUniFlow: [-] \($0) REJECTED, error: \($1)")
        }
    }
}
