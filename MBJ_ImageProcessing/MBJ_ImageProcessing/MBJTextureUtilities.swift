//
//  UIImage+MBETextureUtilities.m
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
class MBJTextureUtilities
{
    //------------------------------------------------------------------------
    class func imageWithMTLTexture(texture:MTLTexture) -> UIImage?
    {
        assert(texture.pixelFormat == MTLPixelFormat.RGBA8Unorm,
            "Pixel format of texture must be MTLPixelFormatBGRA8Unorm to create UIImage")
        
        let width = Int(texture.width)
        let height = Int(texture.height)
        let imageByteCount = width * height * 4
        let imageBytes = malloc(imageByteCount)
        
        let bytesPerRow = width * 4
        let region = MTLRegionMake2D(0, 0, width, height)
        
        texture.getBytes(imageBytes, bytesPerRow:bytesPerRow, fromRegion:region, mipmapLevel:0)
        
        let provider = CGDataProviderCreateWithData(nil,
                 imageBytes, imageByteCount, nil) // MBJReleaseDataCallback ?
        
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue:
            CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        
        let renderingIntent:CGColorRenderingIntent = .RenderingIntentDefault

        let imageRef = CGImageCreate(width, height,
                        bitsPerComponent, bitsPerPixel, bytesPerRow,
                        colorSpaceRef,
                        bitmapInfo,
                        provider,
                        nil,
                        false,
                        renderingIntent)
        
        let image = UIImage(CGImage:imageRef!, scale:0.0, orientation:UIImageOrientation.DownMirrored)
        return image;
    }
    //------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
