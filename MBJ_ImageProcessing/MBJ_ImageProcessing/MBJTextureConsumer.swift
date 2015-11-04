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
import Metal

//------------------------------------------------------------------------------
protocol MBJTextureConsumer
{
    var provider:MBJTextureProvider {get}
}
//------------------------------------------------------------------------------
