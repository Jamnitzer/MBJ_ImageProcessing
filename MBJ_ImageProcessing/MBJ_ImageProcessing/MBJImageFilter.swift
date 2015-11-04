//
//  MBEImageFilter.m
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//------------------------------------------------------------------------
//  converted to Swift by Jamnitzer (Jim Wrenholt)
//------------------------------------------------------------------------
import Foundation
import Metal

//------------------------------------------------------------------------------
class MBJImageFilter : MBJTextureProvider, MBJTextureConsumer
{
    var context:MBJContext! = nil
    var uniformBuffer:MTLBuffer! = nil
    var pipeline:MTLComputePipelineState! = nil
    var _texture:MTLTexture? = nil
    var dirty:Bool = true
    
    var kernelFunction:MTLFunction! = nil
    var _provider:MBJTextureProvider! = nil
    
    //------------------------------------------------------------------------
    var texture:MTLTexture  // required for MBJTextureProvider.
    {
        get {
            if (self.dirty)
            {
                self.applyFilter()
            }
            if (self._texture == nil)
            {
                print("self._texture == nil")
            }
            return self._texture!
        }
    }
    //------------------------------------------------------------------------
    var provider:MBJTextureProvider  // required for MBJTextureConsumer
        {
        get
        {
            return _provider
        }
    }
    //------------------------------------------------------------------------
    init(functionName:String, context:MBJContext)
    {
        self.context = context
        self.kernelFunction = self.context.library.newFunctionWithName(functionName)
        //-----------------------------------------------------------
        // setComputePipelineState:computeShader
        //-----------------------------------------------------------
        do {
            let compute_Shader = try self.context.device.newComputePipelineStateWithFunction(
                self.kernelFunction)
            self.pipeline = compute_Shader
        }
        catch let pipeline_error as NSError
        {
            print("Error occurred when building compute pipeline for function = \(pipeline_error)")
        }
        self.dirty = true
    }
    //------------------------------------------------------------------------
    func configureArgumentTableWithCommandEncoder(commandEncoder:MTLComputeCommandEncoder)
    {
        // empty in default base class.
    }
    //------------------------------------------------------------------------
    func applyFilter()
    {
        let inputTexture:MTLTexture = self.provider.texture
        
        if (self._texture == nil ||
            (self._texture!.width != inputTexture.width) ||
            (self._texture!.height != inputTexture.height) )
        {
            let textureDescriptor:MTLTextureDescriptor =
                MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(
                    inputTexture.pixelFormat,
                    width:inputTexture.width,
                    height:inputTexture.height,
                    mipmapped:false)
            
            if (self.context == nil)
            {
                print("self.context == nil")
            }
            if (self.context.device == nil)
            {
                print("self.context.device == nil")
            }
            
            self._texture =
                self.context.device.newTextureWithDescriptor(textureDescriptor)
        }
        
        let threadgroupCounts:MTLSize = MTLSizeMake(8, 8, 1)
        let threadgroups:MTLSize = MTLSizeMake(
                inputTexture.width / threadgroupCounts.width,
                inputTexture.height / threadgroupCounts.height, 1)
        
        let commandBuffer:MTLCommandBuffer = self.context.commandQueue.commandBuffer()
        let commandEncoder:MTLComputeCommandEncoder = commandBuffer.computeCommandEncoder()
        
        
        commandEncoder.setComputePipelineState(self.pipeline)
        commandEncoder.setTexture(inputTexture, atIndex:0)
        commandEncoder.setTexture(self._texture!, atIndex:1)
        configureArgumentTableWithCommandEncoder(commandEncoder)
        commandEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup:threadgroupCounts)
        commandEncoder.endEncoding()
       
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    //------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
