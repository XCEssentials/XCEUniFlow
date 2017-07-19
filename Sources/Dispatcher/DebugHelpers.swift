public
extension Dispatcher
{
    func enableDefaultReporting()
    {
        onReject = { print("MKHUniFlow: [-] \($0) REJECTED, error: \($1)") }
    }
}
