//
//  Helpers.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 12/22/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

enum Helpers
{
    static
    func actionName(from fullName: String) -> String
    {
        return fullName.components(separatedBy: "(").first ?? ""
    }
}
