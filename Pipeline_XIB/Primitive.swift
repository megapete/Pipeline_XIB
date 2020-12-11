//
//  Primitive.swift
//  Pipeline_XIB
//
//  Created by Peter Huber on 2020-12-10.
//

import MetalKit

class Primitive {
    
    static func makeCube(device: MTLDevice, size: Float) -> MDLMesh {
        
        let allocator = MTKMeshBufferAllocator(device: device)
        
        let mesh = MDLMesh(boxWithExtent: [size, size, size], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)

        return mesh
    }
    
    static func makeTrain(device: MTLDevice) -> MDLMesh {
        
        let allocator = MTKMeshBufferAllocator(device: device)
        
        guard let assetURL = Bundle.main.url(forResource: "train", withExtension: "obj") else
        {
          fatalError()
        }

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride

        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)

        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition

        let asset = MDLAsset(url: assetURL, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)

        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        
        return mdlMesh
    }
    
}
