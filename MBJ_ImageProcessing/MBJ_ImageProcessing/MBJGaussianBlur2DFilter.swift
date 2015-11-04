//
//  MBEGaussianBlur2DFilter.m
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//------------------------------------------------------------------------
//  converted to Swift by Jamnitzer (Jim Wrenholt)
//------------------------------------------------------------------------
import Foundation
import Metal
import UIKit
import simd
import Accelerate

//------------------------------------------------------------------------------
class MBJGaussianBlur2DFilter : MBJImageFilter
{
    var radius:Float = 1.0
    var sigma:Float = 1.0
    var blurWeightTexture:MTLTexture! = nil
    
    //------------------------------------------------------------------------
    class func filterWithRadius(radius:Float, context:MBJContext) -> MBJGaussianBlur2DFilter
    {
        let filter = MBJGaussianBlur2DFilter(radius:radius, context:context)
        return filter
    }
    //------------------------------------------------------------------------
    init(radius:Float, context:MBJContext)
    {
        super.init(functionName: "gaussian_blur_2d",context:context )
        self.radius = radius
    }
    //------------------------------------------------------------------------
    func setRadius(radius:Float)
    {
        self.dirty = true
        self.radius = radius
        self.sigma = radius / 2.0
        self.blurWeightTexture = nil
    }
    //------------------------------------------------------------------------
    func setSigma(sigma:Float)
    {
        self.dirty = true
        self.sigma = sigma
        self.blurWeightTexture = nil
    }
    //------------------------------------------------------------------------
    override func configureArgumentTableWithCommandEncoder(commandEncoder:MTLComputeCommandEncoder)
    {
        if (self.blurWeightTexture == nil)
        {
            generateBlurWeightTexture()
        }
        commandEncoder.setTexture(self.blurWeightTexture, atIndex:2)
    }
    //------------------------------------------------------------------------
    func generateBlurWeightTexture()
    {
        //---------------------------------------------------------
        //
        //---------------------------------------------------------
        //NSAssert(self.radius >= 0, @"Blur radius must be non-negative")
        //
        let kRadius:Float = self.radius
        let kSigma:Float = self.sigma
        let kSize:Int = Int(round(kRadius) * 2.0) + 1
        //print("kRadius = \(kRadius) ")      // 1..15
        //print("kSigma = \(kSigma) ")        // 1..15
        //print("kSize = \(kSize) ")          // 1..15
        //---------------------------------------------------------
        //
        //---------------------------------------------------------
        var delta:Float = 0.0
        var expScale:Float = 0.0
        if (kRadius > 0.0)
        {
            delta = (kRadius * 2.0) / (Float(kSize) - 1.0);
            expScale = -1.0 / (2.0 * kSigma * kSigma)
        }
        //print("delta = \(delta) ")          // 1..15
        //print("expScale \(expScale)")       // 1..15

        //---------------------------------------------------------
        // creat a float array for weights.
        //---------------------------------------------------------
        var weights = [Float](count:kSize*kSize, repeatedValue:0.0)
        
        //---------------------------------------------------------
        // fill array data & collect sum.
        //---------------------------------------------------------
        var weightSum:Float = 0.0
        var y:Float = -kRadius
       for (var j:Int = 0; j < kSize; ++j, y += delta)
        {
            var x:Float = -kRadius
            for (var i:Int = 0; i < kSize; ++i, x += delta)
            {
                let weight:Float = expf((x * x + y * y) * expScale)
                weights[j * kSize + i] = weight
                weightSum += weight
            }
        }
        //---------------------------------------------------------
        // divide each by weightSum
        //---------------------------------------------------------
        let weightScale:Float = 1.0 / weightSum
       for (var j:Int = 0; j < kSize; ++j)
        {
            for (var i:Int = 0; i < kSize; ++i)
            {
                weights[j * kSize + i] *= weightScale
                //print(" \(weights[j * kSize + i])", terminator:"")      // 1..15
            }
             //print("")      // 1..15
        }
         //---------------------------------------------------------
         // texture descriptor for weights. (it's 2d)
         //---------------------------------------------------------
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(
            MTLPixelFormat.R32Float,
            width:kSize,
            height:kSize,
            mipmapped:false)
        
         //---------------------------------------------------------
         // create texture
         //---------------------------------------------------------
         self.blurWeightTexture = self.context.device.newTextureWithDescriptor(textureDescriptor)
         //---------------------------------------------------------
         // 2d region
         //---------------------------------------------------------
        let region = MTLRegionMake2D(0, 0, kSize, kSize)
         //---------------------------------------------------------
         // replace region with data.
         //---------------------------------------------------------
        self.blurWeightTexture.replaceRegion(region,
            mipmapLevel:0,
            withBytes:weights,
            bytesPerRow:sizeof(Float) * kSize)
    }
    //------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
