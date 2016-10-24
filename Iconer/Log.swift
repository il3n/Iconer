//
//  Log.swift
//  Iconer
//
//  Created by lijun on 16/10/24.
//
//

import XCGLogger

public let log: XCGLogger = {
    
    let result = XCGLogger.default
    result.setup(level: logLevel, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: false, fileLevel: logLevel)
    return result
}()

fileprivate var logLevel: XCGLogger.Level {

    #if DEBUG
        return .verbose
    #else
        return .none
    #endif
}


