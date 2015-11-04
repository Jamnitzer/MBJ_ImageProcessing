//
//  MBEViewController.mm
//  ImageProcessing
//
//  Created by Warren Moore on 9/30/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//------------------------------------------------------------------------
//  converted to Swift by Jamnitzer (Jim Wrenholt)
//------------------------------------------------------------------------
import Foundation
import Metal
import UIKit

//------------------------------------------------------------------------------
class MBJViewController : UIViewController
{
    var context:MBJContext! = nil
    var imageProvider:MBJTextureProvider! = nil
    
    var desaturateFilter:MBJSaturationAdjustmentFilter! = nil
    var blurFilter:MBJGaussianBlur2DFilter! = nil
    
    var renderingQueue:dispatch_queue_t! = nil
    var jobIndex:UInt64 = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurRadiusSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    
    //------------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.renderingQueue = dispatch_queue_create("Rendering", DISPATCH_QUEUE_SERIAL)
        
        buildFilterGraph()
        updateImage()
    }
    //------------------------------------------------------------------------
    func buildFilterGraph()
    {
        self.context = MBJContext.newContext()
        self.imageProvider =
            MBJMainBundleTextureProvider.textureProviderWithImageNamed(
                "mandrill", context:self.context)
        
       // self.imageView.image = UIImage(contentsOfFile: "mandrill")
        self.imageView.image = UIImage(named:"mandrill")

        self.desaturateFilter =
            MBJSaturationAdjustmentFilter.filterWithSaturationFactor(
                self.saturationSlider.value, context:self.context)
        self.desaturateFilter._provider = self.imageProvider
        
        self.blurFilter = MBJGaussianBlur2DFilter.filterWithRadius(
            self.blurRadiusSlider.value, context:self.context)
        self.blurFilter._provider = self.desaturateFilter
    }
    //------------------------------------------------------------------------
    func updateImage()
    {
        self.jobIndex += 1
        let currentJobIndex:UInt64 = self.jobIndex
        
        //----------------------------------------------------------------------
        // Grab these values while we're still on the main thread, since we could
        // conceivably get incomplete values by reading them in the background.
        //----------------------------------------------------------------------
        let blurRadius:Float = self.blurRadiusSlider.value
        let saturation:Float = self.saturationSlider.value
        
//        print("blurRadius == \(blurRadius)")
//        print("saturation == \(saturation)")
       
        dispatch_async(self.renderingQueue) {
            if (currentJobIndex != self.jobIndex)
            {
                return
            }
            self.blurFilter.setRadius(blurRadius)
            self.desaturateFilter.setSaturationFactor(saturation)
            //print("blurRadius == \(blurRadius)")
            //print("saturation == \(saturation)")
            
            let texture:MTLTexture = self.blurFilter.texture
            let image:UIImage = MBJTextureUtilities.imageWithMTLTexture(texture)!
            
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = image
            }
        }
    }
    //------------------------------------------------------------------------
    @IBAction func saturationDidChange(sender: AnyObject)
    {
        updateImage()
    }
    //------------------------------------------------------------------------
    @IBAction func blurRadiusDidChange(sender: AnyObject)
    {
        updateImage()
    }
    //------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
