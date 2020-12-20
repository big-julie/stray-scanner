//
//  CameraRenderer.swift
//  StrayScanner
//
//  Created by Kenneth Blomqvist on 12/20/20.
//  Copyright © 2020 Stray Robots. All rights reserved.
//

import Foundation
import Metal
import ARKit

class CameraRenderer {
    private var device: MTLDevice!
    private var metalLayer: CAMetalLayer!
    private var vertexBuffer: MTLBuffer!
    private var pipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    private var textureY: MTLTexture!
    private var textureCbCr: MTLTexture!
    private lazy var textureCache: CVMetalTextureCache = makeTextureCache()

    init(parentView: UIView) {
        initMetal(view: parentView)
    }

    func render(frame: ARFrame) {
        updateTexture(frame: frame)

        guard let drawable = metalLayer.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.1,
            green: 0.1,
            blue: 0.1,
            alpha: 1.0)

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setCullMode(.none)
        renderEncoder.label = "CustomCameraViewEncoder"
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(textureY, index: 0)
        renderEncoder.setFragmentTexture(textureCbCr, index: 1)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func initMetal(view: UIView) {
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.width * 1920.0/1440.0)
        view.layer.addSublayer(metalLayer)

        print("screen width: \(view.bounds.width) height: \(view.bounds.height)")

        let dataSize = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        let imagePlaneVertexDescriptor = MTLVertexDescriptor()
        // Vertices.
        imagePlaneVertexDescriptor.attributes[0].format = .float2
        imagePlaneVertexDescriptor.attributes[0].offset = 0
        imagePlaneVertexDescriptor.attributes[0].bufferIndex = 0

        // Texture coordinates.
        imagePlaneVertexDescriptor.attributes[1].format = .float2
        imagePlaneVertexDescriptor.attributes[1].offset = 8
        imagePlaneVertexDescriptor.attributes[1].bufferIndex = 0

        // Buffer layout.
        imagePlaneVertexDescriptor.layouts[0].stride = 16
        imagePlaneVertexDescriptor.layouts[0].stepRate = 1
        imagePlaneVertexDescriptor.layouts[0].stepFunction = .perVertex

        let defaultLibary = device.makeDefaultLibrary()!

        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.label = "CustomCameraView"
        pipeline.vertexFunction = defaultLibary.makeFunction(name: "drawRectangle")
        pipeline.fragmentFunction = defaultLibary.makeFunction(name: "displayTexture")
        pipeline.vertexDescriptor = imagePlaneVertexDescriptor
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline.sampleCount = 1

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipeline)

        commandQueue = device.makeCommandQueue()
    }

    private func updateTexture(frame: ARFrame) {
        let colorImage = frame.capturedImage
        textureY = createTexture(fromPixelBuffer: colorImage, pixelFormat: .r8Unorm, planeIndex: 0)!
        textureCbCr = createTexture(fromPixelBuffer: colorImage, pixelFormat: .rg8Unorm, planeIndex: 1)!
    }

    private func createTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> MTLTexture? {
        var mtlTexture: MTLTexture? = nil
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)

        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
        if status == kCVReturnSuccess {
            mtlTexture = CVMetalTextureGetTexture(texture!)
        }

        return mtlTexture
    }

    private func makeTextureCache() -> CVMetalTextureCache {
        var cache: CVMetalTextureCache!
        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        return cache
    }

}