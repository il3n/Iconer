//
//  ViewController.swift
//  Iconer
//
//  Created by lijun on 16/10/24.
//
//

import Cocoa




class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the viXCGLogger.frameworkew.
  
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupView()
    }
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var appIconButton: NSButton!
    @IBOutlet weak var launchImageButton: NSButton!
    @IBOutlet weak var imageSetButton: NSButton!
    
    
    
    // 初始化view
    func setupView() {
        self.imageView.wantsLayer = true
        self.imageView.layer?.backgroundColor = NSColor.lightGray.cgColor
        
        // button
        
    }
    
    @IBAction func buttonPressed(_ sender: NSButton) {
        
        if (sender == appIconButton) {
            print("appIconButton")
        } else if (sender == launchImageButton) {
            print("launchImageButton")
        } else if (sender == imageSetButton) {
            print("imageSetButton")
        }
    }
}

