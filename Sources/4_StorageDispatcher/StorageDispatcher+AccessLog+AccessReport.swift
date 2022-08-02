/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation /// to access `Date` type

//---

public
extension StorageDispatcher
{
    struct AccessReport
    {
        public
        let timestamp = Date()
        
        public
        let outcome: Outcome
        
        public
        let storage: Storage
        
        public
        let env: EnvironmentInfo
    }
}

// MARK: - Nested types

public
extension StorageDispatcher.AccessReport
{
    enum Outcome
    {
        /// Access request has been succesfully processed.
        ///
        /// Any occurred mutations (see payload) have already been applied to the `storage`.
        case processed(
            mutations: Storage.History
        )
        
        /// Access request has been rejected due to an error thrown from access handler.
        ///
        /// NO changes have been applied to the `storage`.
        case rejected(
            reason: Error
        )
    }
    
    struct EnvironmentInfo
    {
        public
        let scope: String
        
        public
        let context: String
            
        public
        let location: Int
    }
}

// MARK: - Processed vs. Rejected

public
extension StorageDispatcher
{
    struct ProcessedAccessEventReport
    {
        public
        let timestamp: Date
        
        public
        let mutations: Storage.History
        
        public
        let storage: Storage
        
        public
        let env: AccessReport.EnvironmentInfo
    }
    
    struct RejectedAccessEventReport
    {
        public
        let timestamp: Date
        
        public
        let reason: Error
        
        public
        let storage: Storage
        
        public
        let env: AccessReport.EnvironmentInfo
    }
}
