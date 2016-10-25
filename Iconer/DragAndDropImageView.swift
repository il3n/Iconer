//
//  DragAndDropImageView.swift
//  Iconer
//
//  Created by lijun on 16/10/24.
//
//

import Cocoa

class DragAndDropImageView: NSImageView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(forDraggedTypes: [NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF])
        
        
    }
    
    let fileTypes = ["jpg", "jpeg", "png", "gif", "bmp"]
    var fileTypeIsOK = false
    var droppedFilePath: String?
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(drag: sender) {
            fileTypeIsOK = true
            return .copy
        } else {
            fileTypeIsOK = false
            return []
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if fileTypeIsOK {
            return .copy
        } else {
            return []
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
       
        if let board = sender.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray, let imagePath = board[0] as? String {
            
            droppedFilePath = imagePath
            log.debug("droppedFilePath:"+imagePath)
            return true
        }
        
        return false
    }
    
    func checkExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray, let path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let fileExtension = url.pathExtension?.lowercased() {
                return fileTypes.contains(fileExtension)
            }
        }
        return false
    }
    
    public func imagePath() -> String? {
        return droppedFilePath
    }
    
    
    
}
