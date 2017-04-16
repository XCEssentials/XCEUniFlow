//
//  main.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/15/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

import XCEProjectGenerator

//===

let specData =
    Manager.prepareSpec(specFormat, for: project)
    .data(using: .utf8)

let targetPath = "\(CommandLine.arguments[1])/project.yml"

FileManager
    .default
    .createFile(
        atPath: targetPath,
        contents: specData,
        attributes: nil)
