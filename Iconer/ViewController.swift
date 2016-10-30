//
//  ViewController.swift
//  Iconer
//
//  Created by lijun on 16/10/24.
//
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupView()
    }
    
    enum IconType {
        case appIcon
        case launchImage
        case imageSet
        case customContentsJson
    }
    
    
    @IBOutlet weak var imageView: DragAndDropImageView!
    @IBOutlet weak var appIconButton: NSButton!
    @IBOutlet weak var launchImageButton: NSButton!
    @IBOutlet weak var imageSetButton: NSButton!
    @IBOutlet weak var contentJsonButton: NSButton!
    @IBOutlet weak var textfield: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
    var iconType: IconType?
    var dirPath: String?
    
    
    
    
    // 初始化view
    func setupView() {
        
        self.view.window?.title = "Iconer"
        self.view.window!.styleMask.remove(.resizable)
        
        self.imageView.wantsLayer = true
        self.imageView.layer?.backgroundColor = NSColor.lightGray.cgColor
        
        
        // button
        textfield.isEditable = false
        textfield.isSelectable = false
    }
    
    private var now: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH-mm-ss "
        let now = dateFormatter.string(from: Date())
        return now
    }
    
    // 在指定目录下创建图片的父文件夹
    // @return 返回创建好的文件夹路径
    fileprivate func createDirAtPath(path: String) -> String? {
        
        var dirName: String?
        
        if let it = iconType {
            switch it {
            case .appIcon:
                dirName = "AppIcon.appiconset"
            case .launchImage:
                dirName = "LaunchImage.launchimage"
            case .imageSet:
                dirName = "Image.imageset"
            default:
                dirName = nil
            }
            
            guard dirName != nil else {
                return nil
            }

            let dirPath = path+"/" + now + dirName!
            let fileManager = FileManager.default
            
            
            if !fileManager.fileExists(atPath: dirPath) {
                let url = URL(fileURLWithPath: dirPath)
                do {
                    try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    log.debug("创建文件夹\(dirPath)失败")
                    return nil
                }
                log.debug("创建文件夹\(dirPath)成功")
                self.dirPath = dirPath
                return dirPath
            } else {
                log.debug("文件夹\(dirPath)已存在")
            }
        }
        
        return nil
    }
    
    // 在指定目录创建json文件
    // @return 返回是否创建成功
    fileprivate func createJsonFileAtPath(path: String) -> Bool {
        var result = true
        var originJsonName: String?
        
        if let it = iconType {
            switch it {
            case .appIcon:
                originJsonName = "appicon"
            case .imageSet:
                originJsonName = "imageset"
            case .launchImage:
                originJsonName = "launchimage"
            default:
                originJsonName = nil
            }
            
            guard originJsonName != nil else {
                return false
            }
            
            var originJsonPath: String? = textfield.stringValue
            
            if originJsonPath == "" {
                originJsonPath = Bundle.main.path(forResource: originJsonName, ofType: "json")
            }

            do {
                
                let jsonData = try NSData(contentsOfFile: originJsonPath!) as Data
                
                if let oldJsonDic = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? NSDictionary {
                    
                    if let oldIconItemList = oldJsonDic["images"] as? NSArray {
                        
                        let newDic = NSMutableDictionary(dictionary: oldJsonDic)
                        let newIconItemList = NSMutableArray()
                        
                        for iconItem in oldIconItemList {
                            newIconItemList.add(parseImage(dictionary: iconItem as! NSDictionary))
                        }
                        
                        newDic["images"] = newIconItemList
                        
                        let filePath = path + "/" + "Contents.json"
                        if saveDictionary(dictionary: newDic, toPath: filePath) {
                            log.debug("jsonFileAtPath:\(path), 创建成功")
                        } else {
                            log.debug("jsonFileAtPath:\(path), 创建失败")
                        }
                    }
                }
            } catch {
                result = false
                log.debug("json解析失败")
            }
        }
        
        return result
    }
   
    // 解析图片
    func parseImage(dictionary: NSDictionary) -> NSDictionary {
        
        let newDic = NSMutableDictionary(dictionary: dictionary)

        var width: Int?
        var height: Int?
        var iconName: String?
        
        if (iconType == .appIcon) {
            // 解析appIcon
            let scaleString = dictionary["scale"] as! String
            let sizeString = dictionary["size"] as! String
            
            let scaleRange = scaleString.range(of: "x")
            let scale = Int((scaleString.substring(to: (scaleRange?.lowerBound)!)))
            
            let sizeRange = sizeString.range(of: "x")
            let size = Float((sizeString.substring(to: (sizeRange?.lowerBound)!)))
            
            // 图片时间尺寸

            width = Int(size! * Float(scale!))
            height = width
            
            
            // 图片名字
            iconName = "appicon-"+sizeString.substring(to: (sizeRange?.lowerBound)!)+(scaleString != "1x" ? ("@"+scaleString) : "")+".png"
            newDic["filename"] = iconName
            
//            log.debug("iconName:\(iconName), size:\(size), scale:\(scale), iconPixel:\(iconPixel)")


            
        } else if (iconType == .launchImage) {
            // 解析launchImage
            
            let subtypeString: String? = dictionary["subtype"] as? String
            let scaleString: String = dictionary["scale"] as! String
            let scaleRange = scaleString.range(of: "x")
            let scale = Int((scaleString.substring(to: (scaleRange?.lowerBound)!)))
            width = 320
            height = 480
            
            if (subtypeString == "retina4") {
                width = 640
                height = 1136
            } else if (subtypeString == "667h") {
                width = 750
                height = 1334
            } else if (subtypeString == "736h") {
                width = 1242
                height = 2208
            } else if (subtypeString == nil) {
                // 320*480 640*960
                if (scale == 2) {
                    width = 640
                    height = 960
                }
            }
            
            iconName = "launchImage-"+String(height!)+(scaleString != "1x" ? ("@"+scaleString) : "")+".png"
            newDic["filename"] = iconName

            
        } else if (iconType == .imageSet) {
            // 解析普通图片，默认把导入的图片当做3x图处理
            
            let scaleString = dictionary["scale"] as! String
            let scaleRange = scaleString.range(of: "x")
            let scale = Int((scaleString.substring(to: (scaleRange?.lowerBound)!)))

            var ratio: Float = 1.0
            if (scale == 2) {
                ratio = 1.5
            } else if (scale == 1) {
                ratio = 3
            }
            
            let size = imageView.image?.size
            width = Int((Float((size?.width)!) / ratio))
            height = Int((Float((size?.height)!) / ratio))
            
            
            iconName = String(width!)+"*"+String(height!)+".png"
            
            newDic["filename"] = iconName

        }
        
        
        // 图片处理，判断指定位置的图片是否存在，如果存在，则不处理；如果不存在，则压缩并保存
        if let iname = iconName {
            let fileManger = FileManager.default
            let imagePath = dirPath! + "/" + iname
            if !fileManger.fileExists(atPath: imagePath) {
                if saveImage(image: scaleImageToSize(width: width!, height: height!), toPath: imagePath) {
                    log.debug("图片保存成功")
                } else {
                    log.debug("图片保存失败")
                }
            }
        }
        

        
        return newDic
    }
    
    
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        textfield.stringValue = ""
    }
    
    
    @IBAction func buttonPressed(_ sender: NSButton) {
        
        if (sender == contentJsonButton) {
            iconType = .customContentsJson
            browseFile(sender: sender)
        } else {
            
            if let oriImagePath = imageView.imagePath(), let lastSlash = oriImagePath.range(of: "/", options: .backwards) {
                
                // 创建文件夹
                let parentDirPath = oriImagePath.substring(to: lastSlash.lowerBound)
                if (sender == appIconButton) {
                    iconType = .appIcon
                } else if (sender == launchImageButton) {
                    iconType = .launchImage
                } else if (sender == imageSetButton) {
                    iconType = .imageSet
                }
                
                if let dirPath = createDirAtPath(path: parentDirPath) {
                    if createJsonFileAtPath(path: dirPath) {
                        
                    }
                }
                
            } else {
                log.debug("未获取到图片地址")
            }
        }
    }

    func browseFile(sender: AnyObject) {
        let dialog = NSOpenPanel()
        dialog.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
        dialog.title = "选择contents.json文件"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["json"]
    
        if (dialog.runModal() == NSModalResponseOK) {
            if let result = dialog.url {
                textfield.stringValue = result.path
            }
        }
    }
    
    
    // 根据原始图片、图片尺寸列表创建一组图片
    func scaleImageToSize(width: Int, height: Int) -> NSImage? {
        return imageView.image?.resizeImage(width: width, height: height)
    }
    
    func saveImage(image: NSImage?, toPath: String) -> Bool {
        guard image != nil else {
            return false
        }
        
        let imageData = image!.tiffRepresentation!
        let filePath = NSURL(fileURLWithPath: toPath) as URL
        var result = true
        do {
            try NSBitmapImageRep(data: imageData)?.representation(using: NSPNGFileType, properties: [:])?.write(to: filePath, options: .atomic)
            
        } catch  {
            result = false
        }
        
        return result
    }
    
    // 将NSDictionary 作为json保存到指定目录下
    func saveDictionary(dictionary: NSDictionary, toPath: String) -> Bool {
        var result = true
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            let filePath = NSURL(fileURLWithPath: toPath) as URL
            try jsonData.write(to: filePath, options: .atomic)
            
        } catch  {
            result = false
        }
        
        return result
    }
    
    
    func screenSize() ->(width: Int, height: Int) {
        if let screens = NSScreen.screens() {
            var rect: NSRect?
            for screen in screens {
                rect = screen.visibleFrame
            }
            let width = Int((rect?.width)!)
            let height = Int((rect?.height)!)
            return (width, height)
        }
        
        return (200, 200)
    }
}


extension NSImage {
    func resizeImage(width: Int, height: Int) -> NSImage? {
        
        guard self.isValid else {
            return nil
        }
        
        if let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0) {
            
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: rep))
            self.draw(in: NSMakeRect(0, 0, CGFloat(width), CGFloat(height)), from: NSMakeRect(0, 0, size.width, size.height), operation: NSCompositeCopy, fraction: 1)
            NSGraphicsContext.restoreGraphicsState()
            
            let img = NSImage(size: CGSize(width: width, height: height))
            img.addRepresentation(rep)
            return img
        }
        
        return nil
    }
}


