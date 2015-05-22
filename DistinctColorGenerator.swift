//
//  DistinctColorGen.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/21/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

class DistinctColourGenerator
{
    class func isValidLABColour(var l: Double, var a: Double, var b: Double) -> Bool
    {
        let (r, g, b) = LabtoRGB(l, a: a, b: b)
        
        return (r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255)
    }
    
    class func generateDistinctColours(count: Int, quality: Int, highPrecision: Bool) -> [(Double, Double, Double)]
    {
        var labColours = [(Double, Double, Double)]()
        var forceVectors = [(Double, Double, Double)]()
        for i in 1...count
        {
            var colour = randomRGB()
            colour = RGBtoLab(colour.0, g: colour.1, b: colour.2)
            labColours.append(colour)
            forceVectors.append((0, 0, 0))
        }
        
        let repulsion = 0.3
        let speed = 0.05
        let steps = quality * 20
        
        for i in 1...steps
        {
            for (index, _) in enumerate(forceVectors)
            {
                forceVectors[index] = (0, 0, 0)
            }
            
            for (indexOuter, (la, aa, ba)) in enumerate(labColours)
            {
                for (indexInner, (lb, ab, bb)) in enumerate(labColours[0..<indexOuter])
                {
                    let dl = la - lb
                    let da = aa - ab
                    let db = ba - bb
                    let d =  sqrt(pow(dl, 2) + pow(da, 2) + pow(db, 2));
                    
                    if d < 0
                    {
                        println("Loool")
                    }
                    
                    let repulsionForce = repulsion / pow(d, 2)
                    
                    let dlForce = dl * repulsionForce / d
                    let daForce = da * repulsionForce / d
                    let dbForce = db * repulsionForce / d
                    
                    var (outerDlForce, outerDaForce, outerDbForce) = forceVectors[indexOuter]
                    outerDlForce += dlForce
                    outerDaForce += daForce
                    outerDbForce += dbForce
                    forceVectors[indexOuter] = (outerDlForce, outerDaForce, outerDbForce)
                    
                    var (innerDlForce, innerDaForce, innerDbForce) = forceVectors[indexInner]
                    innerDlForce -= dlForce
                    innerDaForce -= daForce
                    innerDbForce -= dbForce
                    forceVectors[indexInner] = (innerDlForce, innerDaForce, innerDbForce)
                }
            }
            for (index, (l, a, b)) in enumerate(labColours)
            {
                var (dlForce, daForce, dbForce) = forceVectors[index]
                let displacement = speed * sqrt(pow(dlForce, 2) + pow(daForce, 2) + pow(dbForce, 2))
                if displacement < 0
                {
                    println("Loool2")
                }
                let ratio = speed * min(0.1, displacement) / displacement
                
                let cl = l + dlForce * ratio
                let ca = a + daForce * ratio
                let cb = b + dbForce * ratio
                if isValidLABColour(cl, a: ca, b: cb)
                {
                    labColours[index] = (cl, ca, cb)
                }
            }
        }
        
        var rgbColours = [(Double, Double, Double)]()
        for (index, (l, a, b)) in enumerate(labColours)
        {
            rgbColours.append(LabtoRGB(l, a: a, b: b))
        }
        
        return rgbColours
    }
    
    class func randomRGB() -> (Double, Double, Double)
    {
        let r = Double(arc4random_uniform(256))
        let g = Double(arc4random_uniform(256))
        let b = Double(arc4random_uniform(256))
        
        return (r, g, b)
    }
    
    class func RGBtoLab(var r: Double, var g: Double, var b: Double) -> (Double, Double, Double)
    {
        let (x, y, z) = RGBtoXYZ(r, g: g, b: b)
        
        return XYZtoLab(x, y: y, z: z)
    }
    
    class func LabtoRGB(var l: Double, var a: Double, var b: Double) -> (Double, Double, Double)
    {
        let (x, y, z) = LabtoXYZ(l, a: a, b: b)
        
        return XYZtoRGB(x, y: y, z: z)
    }
    
    class func RGBtoXYZ(var r: Double, var g: Double, var b: Double) -> (Double, Double, Double)
    {
        var (x, y, z) = (0.0, 0.0, 0.0)
        
        r /= 255.0
        g /= 255.0
        b /= 255.0
        
        if(r > 0.04045)
        {
            r = (r + 0.055) / 1.055
            r = pow(r, 2.4)
        } else
        {
            r /= 12.92
        }
        
        if(g > 0.04045)
        {
            g = (g + 0.055) / 1.055
            g = pow(g, 2.4)
        }
        else
        {
            g /= 12.92
        }
        
        if(b > 0.04045)
        {
            b = (b + 0.055) / 1.055
            b = pow(b, 2.4)
        }
        else
        {
            b /= 12.92
        }
        
        r *= 100
        g *= 100
        b *= 100
        
        x = r * 0.4124 + g * 0.3576 + b * 0.1805;
        y = r * 0.2126 + g * 0.7152 + b * 0.0722;
        z = r * 0.0193 + g * 0.1192 + b * 0.9505;
        
        return (x, y, z)
    }
    
    class func XYZtoRGB(var x: Double, var y: Double, var z: Double) -> (Double, Double, Double)
    {
        x = x / 100        //X from 0 to  95.047      (Observer = 2°, Illuminant = D65)
        y = y / 100        //Y from 0 to 100.000
        z = z / 100        //Z from 0 to 108.883
        
        var r = x *  3.2406 + y * -1.5372 + z * -0.4986
        var g = x * -0.9689 + y *  1.8758 + z *  0.0415
        var b = x *  0.0557 + y * -0.2040 + z *  1.0570
        
        if r > 0.0031308
        {
            r = 1.055 * (pow(r, 1 / 2.4 ) ) - 0.055
        }
        else
        {
            r = 12.92 * r
        }
        
        if g > 0.0031308
        {
            g = 1.055 * (pow(g, 1 / 2.4 ) ) - 0.055
        }
        else
        {
            g = 12.92 * g
        }
        
        if b > 0.0031308
        {
            b = 1.055 * (pow(b, 1 / 2.4 ) ) - 0.055
        }
        else
        {
            b = 12.92 * b
        }
        
        return (r * 255, g * 255, b * 255)
    }
    
    class func XYZtoLab(var x: Double, var y: Double, var z: Double) -> (Double, Double, Double)
    {
        var (l, b, a) = (0.0, 0.0, 0.0)
        x /= 95.047
        y /= 100
        z /= 108.883
        
        if(x > 0.008856)
        {
            x = pow(x, 1 / 3)
        }
        else
        {
            x = 7.787 * x + 16 / 116
        }
        
        if(y > 0.008856)
        {
            y = pow(y, 1 / 3)
        }
        else
        {
            y = (7.787 * y) + (16 / 116)
        }
        
        if(z > 0.008856)
        {
            z = pow(z, 1 / 3)
        }
        else
        {
            z = 7.787 * z + 16 / 116
        }
        
        l = 116 * y - 16;
        a = 500 * (x - y);
        b = 200 * (y - z);
        
        return (l, a, b)
    }
    
    class func LabtoXYZ(var l: Double, var a: Double, var b: Double) -> (Double, Double, Double)
    {
        var y = (l + 16) / 116
        var x = a / 500 + y
        var z = y - b / 200
        
        let tmpY = pow(y, 3)
        if tmpY > 0.008856
        {
            y = tmpY
        }
        else
        {
            y = (y - 16 / 116) / 7.787
        }
        
        let tmpX = pow(x, 3)
        if tmpX > 0.008856
        {
            x = tmpX
        }
        else
        {
            x = (x - 16 / 116) / 7.787
        }
        
        let tmpZ = pow(z, 3)
        if tmpZ > 0.008856
        {
            z = tmpZ
        }
        else
        {
            z = (z - 16 / 116) / 7.787
        }
        
        x = 95.047 * x
        y = 100 * y
        z = 108.883 * z
        
        return (x, y, z)
    }
}