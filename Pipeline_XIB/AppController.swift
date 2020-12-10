//
//  AppController.swift
//  Pipeline_XIB
//
//  Created by Peter Huber on 2020-12-10.
//

import Cocoa
import Metal
import MetalKit

class AppController: NSObject {

    @IBOutlet weak var metalView: MTKView!
    var renderer:Renderer?
    
    override func awakeFromNib() {
        
        self.renderer = Renderer(metalView: self.metalView)
    }
}
