//
//  AppIcon.swift
//  Iconer
//
//  Created by lijun on 16/10/25.
//
//

import Cocoa


class BaseImage {
    public var idiom: String?
    public var scale: Int?
    public var filename: String?
}

class AppIcon: BaseImage {
    public var size: Int?
}

class LaunchImage: BaseImage {
    public var orientation: String?
    public var minimum_system_version: String?
    public var subtype: String?
}

class ImageSet: BaseImage {
    
}
