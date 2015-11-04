//
//  MBEContext.m
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
class MBJContext
{
    var device:MTLDevice! = nil
    var library:MTLLibrary! = nil
    var commandQueue:MTLCommandQueue! = nil
    
   //------------------------------------------------------------------------
     init(device:MTLDevice?)
    {
        if (device != nil)
        {
            self.device = device
        }
        else
        {
            self.device = MTLCreateSystemDefaultDevice()
        }
        self.library = self.device!.newDefaultLibrary()
        self.commandQueue = self.device!.newCommandQueue()
    }
    //------------------------------------------------------------------------
    class func newContext() -> MBJContext
    {
        return MBJContext(device:nil)
    }
    //------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
