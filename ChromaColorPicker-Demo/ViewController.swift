//
//  ViewController.swift
//  ChromaColorPicker-Demo
//
//  Created by Cardasis, Jonathan (J.) on 8/11/16.
//  Copyright © 2016 Jonathan Cardasis. All rights reserved.
//

import UIKit
import ChromaColorPicker
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var colorDisplayView: UIView!
    @IBOutlet weak var ImageView: UIImageView!
    
    var colorPicker: ChromaColorPicker!
    var chromacolourpicker = ChromaColorPicker()
    var ratio1 : Float = 0
    var ratio2 : Float = 0
    var filter : CIFilter? = nil
    
    @IBOutlet weak var CheckView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TapGesture()
        ImageView.image = #imageLiteral(resourceName: "3")
        /* Calculate relative size and origin in bounds */
        let pickerSize = CGSize(width: view.bounds.width*0.6, height: view.bounds.width*0.6)
        let pickerOrigin = CGPoint(x: view.bounds.midX - pickerSize.width/2, y: view.bounds.midY - pickerSize.height/2)
        
        /* Create Color Picker */
        colorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
        colorPicker.delegate = self
        
        /* Customize the view (optional) */
        colorPicker.padding = 10
        colorPicker.stroke = 3 //stroke of the rainbow circle
        colorPicker.currentAngle = Float.pi
        
        /* Customize for grayscale (optional) */
        colorPicker.supportsShadesOfGray = true // false by default
        //colorPicker.colorToggleButton.grayColorGradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.gray.cgColor] // You can also override gradient colors
    
        colorPicker.hexLabel.textColor = UIColor.white
        
        /* Don't want an element like the shade slider? Just hide it: */
        //colorPicker.shadeSlider.hidden = true
        
        self.view.addSubview(colorPicker)
    }
    
    func GetRGB (Colourview:UIView)
    {
        /*print("Red:",Colourview.backgroundColor!.redValue as Any)
        print("Green:",Colourview.backgroundColor!.greenValue as Any)
        print("Blue:",Colourview.backgroundColor!.blueValue as Any)
        print("Alpha:",Colourview.backgroundColor!.alphaValue as Any)*/
        
        CheckView.backgroundColor = UIColor(red: (Colourview.backgroundColor?.redValue)!, green: (Colourview.backgroundColor?.greenValue)!, blue: (Colourview.backgroundColor?.blueValue)!, alpha: (Colourview.backgroundColor?.alphaValue)!)
    }
    
    func TapGesture()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.TouchUpImage))
        tap.numberOfTapsRequired = 1
        ImageView.isUserInteractionEnabled = true
        self.ImageView.addGestureRecognizer(tap)
    }
    
    @objc func TouchUpImage(sender:UITapGestureRecognizer)
    {
        
        //let context = CIContext()
        print("Touch Up Inside")
        ImageView.image = #imageLiteral(resourceName: "3")
        filter = chromaKeyFilter(fromHue: CGFloat(ratio1), toHue: CGFloat(ratio2))
        let image = ImageView.image
        let cgimage = image?.cgImage

        /*let bgurl = Bundle.main.url(forResource: "2", withExtension: "png")
        let bimage = CIImage(contentsOf: bgurl!)!*/
        let coreImage = CIImage(cgImage: cgimage!)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        let sourceCIImageWithoutBackground = filter?.outputImage
        
        /*let aspectRatio1 = Double(ImageView.frame.size.height) / Double(ImageView.frame.size.width)
        let scalfilter1 = scaleFilter(sourceCIImageWithoutBackground!, aspectRatio: aspectRatio1, scale:0.45)*/
        
        /*let compositor = CIFilter(name:"CISourceOverCompositing")
        compositor?.setValue(sourceCIImageWithoutBackground, forKey: kCIInputImageKey)
        compositor?.setValue(bimage, forKey: kCIInputBackgroundImageKey)
        let compositedCIImage = compositor?.outputImage*/
        
        /*let cgimage1 = context.createCGImage(compositedCIImage!, from: (compositedCIImage?.extent)!)*/
        ImageView.layer.borderWidth = 1
        ImageView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        ImageView.image = UIImage(ciImage: sourceCIImageWithoutBackground!)
        print("done")
        //ImageView.frame = CGRect(x: ImageView.frame.origin.x, y: ImageView.frame.origin.y, width: ImageView.frame.size.width, height: ImageView.frame.size.height)
        //ImageView.backgroundColor = UIColor.clear
    }
    
    func scaleFilter(_ input:CIImage, aspectRatio : Double, scale : Double) -> CIImage
    {
        let scaleFilter = CIFilter(name:"CILanczosScaleTransform")!
        scaleFilter.setValue(input, forKey: kCIInputImageKey)
        scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
        scaleFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return scaleFilter.outputImage!
    }

}

extension ViewController: ChromaColorPickerDelegate{

    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color:UIColor) {
        //Set color for the display view
        colorDisplayView.backgroundColor = color
        GetRGB(Colourview: colorDisplayView)
        //Perform zesty animation
        UIView.animate(withDuration: 0.2,
                animations: {
                    self.colorDisplayView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }, completion: { (done) in
                UIView.animate(withDuration: 0.2, animations: { 
                    self.colorDisplayView.transform = CGAffineTransform.identity
                })
        }) 
    }
    
    func AngleIndegree(angle: Float) {
        let DegreeAngle = angle * 57.324847643
        let ratio = DegreeAngle/360
        ratio1 = ratio - 0.05
        ratio2 = ratio + 0.05
        print("ratio1:",ratio1,"and ratio2:",ratio2)
    }
    
    func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter?
    {
        // 1
        let size = 64
        var cubeRGB = [Float]()
        
        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)
                    
                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue && hue <= toHue) ? 0: 1
                    
                    // 4
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }
        
        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))
        
        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat
    {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }

}

extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}



