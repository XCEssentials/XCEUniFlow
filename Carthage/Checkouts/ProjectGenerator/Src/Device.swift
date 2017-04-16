//
//  Device.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/18/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
enum DeviceFamily
{
    public
    enum iOS
    {
        public
        static
        let universal = "1,2"
        
        public
        static
        let phone = "1" // iPhone and iPod Touch
        
        public
        static
        let pad   = "2"  // iPad
    }
}
