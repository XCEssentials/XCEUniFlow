import XCEUniFlow

//---

public
enum CurrentSession: Feature
{
    struct Anon: FeatureState
    {
        typealias ParentFeature = CurrentSession
    }
    
    struct LoggingIn: FeatureState
    {
        typealias ParentFeature = CurrentSession
        
        let username: String
    }
    
    struct LoginFailed: FeatureState
    {
        typealias ParentFeature = CurrentSession
        
        let reason: Error
    }
    
    struct LoggedIn: FeatureState
    {
        typealias ParentFeature = CurrentSession
        
        let sessionToken: String
    }
}

extension ActionContext where F == CurrentSession
{
    func prepare()
    {
        should {
            
            try $0.initialize(with: F.Anon())
        }
    }
    
    func login(username: String, password: String)
    {
        must {
            
            try $0.ensureCurrentState(is: F.Anon.self)
            let loggingIn = F.LoggingIn(username: username)
            
            //---
            
            try $0.transition(into: loggingIn)
            
            //---
            
            Task {
                
                do
                {
                    let sessionToken = "123" // execute throwing login request...
                    success(sessionToken: sessionToken)
                }
                catch
                {
                    failed(with: error)
                }
            }
        }
    }
    
    private
    func success(sessionToken: String)
    {
        must {
            
            try $0.transition(
                from: F.LoggingIn.self,
                into: F.LoggedIn(sessionToken: sessionToken)
            )
        }
    }
    
    private
    func failed(with reason: Error)
    {
        must {
            
            try $0.transition(
                from: F.LoggingIn.self,
                into: F.LoginFailed(reason: reason)
            )
        }
    }
}
