//
//  Renderer.swift
//  Pipeline_XIB
//
//  Created by Peter Huber on 2020-12-10.
//

import Cocoa
import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!

    var timer: Float = 0

    
    init(metalView: MTKView) {
        
        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else
        {
            fatalError("GPU not available")
        }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        // let mdlMesh = Primitive.makeCube(device: device, size: 1)
        let mdlMesh = Primitive.makeTrain(device: device)
        
        do {
            self.mesh = try MTKMesh(mesh: mdlMesh, device: device)
        }
        catch
        {
            print(error.localizedDescription)
        }

        self.vertexBuffer = self.mesh.vertexBuffers[0].buffer

        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch
        {
            fatalError(error.localizedDescription)
        }

        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self

    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let descriptor = view.currentRenderPassDescriptor, let commandBuffer = Renderer.commandQueue.makeCommandBuffer(), let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else
        {
            return
        }

        timer += 0.05
        var currentTime = sin(timer)
        
        renderEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 1)

        renderEncoder.setRenderPipelineState(self.pipelineState)
        renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        
        for submesh in self.mesh.submeshes
        {
          renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }


        renderEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else
        {
          return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()

    }
    

}
