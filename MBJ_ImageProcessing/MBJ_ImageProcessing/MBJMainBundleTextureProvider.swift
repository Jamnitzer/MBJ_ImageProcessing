//
//  MBEMainBundleTextureProvider.m
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//------------------------------------------------------------------------
//  converted to Swift by Jamnitzer (Jim Wrenholt)
//------------------------------------------------------------------------
import Foundation
import UIKit
import Metal

//------------------------------------------------------------------------------
class MBJMainBundleTextureProvider : MBJTextureProvider
{
     var _texture:MTLTexture! = nil  // in super.

    //------------------------------------------------------------------------
     class func textureProviderWithImageNamed(imageName:String,
                context:MBJContext) -> MBJMainBundleTextureProvider
    {
        return MBJMainBundleTextureProvider(imageName:imageName, context:context)
    }
   //------------------------------------------------------------------------
     init(imageName:String, context:MBJContext)
    {
        let image = UIImage(named:imageName)
        _texture = self.textureForImage(image!, context:context)
    }
    //------------------------------------------------------------------------
    func textureForImage(image:UIImage, context:MBJContext) -> MTLTexture?
    {
        let imageRef = image.CGImage
        
        //------------------------------------------------------------------------
        // Create a suitable bitmap context for extracting the bits of the image
        //------------------------------------------------------------------------
        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = calloc(height * width * 4, Int(sizeof(UInt8)))
        
        let bytesPerPixel: Int = 4
        let bytesPerRow: Int = bytesPerPixel * width
        let bitsPerComponent: Int = 8
        
        let options = CGImageAlphaInfo.PremultipliedLast.rawValue |
            CGBitmapInfo.ByteOrder32Big.rawValue
        
        let bitmapContext = CGBitmapContextCreate(rawData, width, height,
            bitsPerComponent, bytesPerRow, colorSpace, options)
        // CGColorSpaceRelease(colorSpace)
        
        //------------------------------------------------------------------------
        // Flip the context so the positive Y axis points down
        //------------------------------------------------------------------------
        CGContextTranslateCTM(bitmapContext, 0.0, CGFloat(height));
        CGContextScaleCTM(bitmapContext, 1.0, -1.0);
        
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0,
            CGFloat(width), CGFloat(height)), imageRef)
        // CGContextRelease(bitmapContext)
        
        let textureDescriptor =
        MTLTextureDescriptor.texture2DDescriptorWithPixelFormat( .RGBA8Unorm,
            width: Int(width), height: Int(height),
            mipmapped: false)
        
        let texture = context.device.newTextureWithDescriptor(textureDescriptor)
        texture.label = "textureForImage"
        
        let region = MTLRegionMake2D(0, 0, Int(width), Int(height))
        texture.replaceRegion(region, mipmapLevel: 0,
            withBytes: rawData, bytesPerRow: Int(bytesPerRow))
        
        free(rawData)
        return texture
    }
    //------------------------------------------------------------------------
    var texture:MTLTexture  // required for MBJTextureProvider.
        {
        get {
            return self._texture
        }
    }
    //------------------------------------------------------------------------
    // - (void)provideTexture:(void (^)(id<MTLTexture>))textureBlock
    // //func provideTexture(textureBlock:MTLTexture)
   //  {
        //if (textureBlock)
        //{
        //    textureBlock(self._texture);
        //}
    //}
    //------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
