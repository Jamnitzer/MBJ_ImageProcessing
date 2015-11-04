//
//  MBESaturationAdjustmentFilter.m
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
class MBJSaturationAdjustmentFilter : MBJImageFilter
{
    var saturationFactor:Float = 0.0
    
    //------------------------------------------------------------------------
    class func filterWithSaturationFactor(
        saturationFactor:Float, context:MBJContext) -> MBJSaturationAdjustmentFilter
    {
        let filter = MBJSaturationAdjustmentFilter(saturationFactor:saturationFactor, context:context)
        return filter
    }
    //------------------------------------------------------------------------
    init(saturationFactor:Float, context:MBJContext)
    {
         super.init(functionName:"adjust_saturation", context:context )
         self.saturationFactor = saturationFactor
    }
    //------------------------------------------------------------------------
    func setSaturationFactor(saturationFactor:Float)
    {
        self.dirty = true
        self.saturationFactor = saturationFactor
    }
    //------------------------------------------------------------------------
    override func configureArgumentTableWithCommandEncoder(commandEncoder:MTLComputeCommandEncoder)
    {
        var uniform_saturation:Float = self.saturationFactor

        if (self.uniformBuffer == nil)
        {
            self.uniformBuffer = self.context.device!.newBufferWithLength(sizeof(Float),
                options:.CPUCacheModeDefaultCache)
        }
        let bufferPointer:UnsafeMutablePointer<Void>?
        bufferPointer = self.uniformBuffer.contents()
        
        memcpy(bufferPointer!, &uniform_saturation, sizeof(Float))
        commandEncoder.setBuffer(self.uniformBuffer, offset:0, atIndex:0)
    }
}
//------------------------------------------------------------------------------
