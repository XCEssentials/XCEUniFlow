import XCEUniFlow

//---

enum CRS: Feature {} // short name a.k.a. feature "code" or "id"
typealias CurrentSession = FeatureBase<CRS>

// MARK: - States

extension CurrentSession
{
    struct Anon: FeatureState
    {
        typealias ParentFeature = CRS
    }
    
    struct LoggingIn: FeatureState
    {
        typealias ParentFeature = CRS
        
        let username: String
    }
    
    struct LoginFailed: FeatureState
    {
        typealias ParentFeature = CRS
        
        let reason: Error
    }
    
    struct LoggedIn: FeatureState
    {
        typealias ParentFeature = CRS
        
        let sessionToken: String
    }
}

// MARK: - Actions

extension CurrentSession
{
    func prepare()
    {
        should {
            
            try $0.initialize(with: Anon())
        }
    }
    
    func login(username: String, password: String)
    {
        must {
            
            try $0.ensureCurrentState(is: Anon.self)
            let loggingIn = LoggingIn(username: username)
            
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
                from: LoggingIn.self,
                into: LoggedIn(sessionToken: sessionToken)
            )
        }
    }
    
    private
    func failed(with reason: Error)
    {
        must {
            
            try $0.transition(
                from: LoggingIn.self,
                into: LoginFailed(reason: reason)
            )
        }
    }
}
