//
//  Spec.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/17/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

typealias SpecLine = (idention: Int, line: String)
typealias RawSpec = [SpecLine]

//===

func <<< (list: inout RawSpec, element: SpecLine)
{
    list.append(element)
}

func <<< (list: inout RawSpec, elements: RawSpec)
{
    list.append(contentsOf: elements)
}

//===

public
enum Spec
{
    public
    enum Format: String
    {
        case
            v1_2_1 = "1.2.1",
            v1_3_0 = "1.3.0"
    }
}

//===

extension Spec
{
    static
    func ident(_ idention: Int) -> String
    {
        return Array(repeating: "  ", count: idention).joined()
    }
    
    static
    func key(_ v: Any) -> String
    {
        return "\(v):"
    }
    
    static
    func value(_ v: Any) -> String
    {
        return " \"\(v)\""
    }
}
