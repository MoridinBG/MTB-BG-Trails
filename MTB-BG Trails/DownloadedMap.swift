//
//  DownloadedMap.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 6/5/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

/*
*   Model class with properties for downloaded sets of tiles
*/
class DownloadedMap: NSObject, NSCoding
{
    var name: String
    var directory: String
    
    //Conveninet dictionary with NW, NE & SW coordinates (x,y as in tile urls) of the downloaded region for each Z level
    lazy var coordinatesPerZ: [Int : ((Int, Int), (Int, Int), (Int, Int))] = {
        [unowned self] in
        
        var zDict = [Int : ((Int, Int), (Int, Int), (Int, Int))]()
        for (index, z) in enumerate(self.zLevels)
        {
            zDict[z] = ((self.nwX[z], self.nwY[z]), (self.neX[z], self.neY[z]), (self.swX[z], self.swY[z]))
        }
        
        return zDict
        
    }()
    
    var zLevels: [Int] = [Int]()
    
    private var nwX: [Int] = [Int]()
    private var nwY: [Int] = [Int]()
    
    private var neX: [Int] = [Int]()
    private var neY: [Int] = [Int]()
    
    private var swX: [Int] = [Int]()
    private var swY: [Int] = [Int]()
 
    
    
    private let nameKey      = "key.name"
    private let directoryKey = "key.directory"

    private let nwXKey       = "key.nw.x"
    private let nwYKey       = "key.nw.y"
    private let neXKey       = "key.ne.x"
    private let neYKey       = "key.ne.y"
    private let swXKey       = "key.sw.x"
    private let swYKey       = "key.sw.y"
    private let zLevelsKey   = "key.zLevels"
    
    
    init(name: String, directory: String, coordinatesPerZ: [Int : ((Int, Int), (Int, Int), (Int, Int))])
    {
        self.name = name
        self.directory = directory
        
        for z in coordinatesPerZ.keys
        {
            self.zLevels.append(z)
            let ((nwx, nwy), (nex, ney), (swx, swy)) = coordinatesPerZ[z]!
            
            self.nwX.append(nwx)
            self.nwY.append(nwy)
            
            self.neX.append(nex)
            self.neY.append(ney)
            
            self.swX.append(swx)
            self.swY.append(swy)
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        self.name = aDecoder.decodeObjectForKey(nameKey) as! String
        self.directory = aDecoder.decodeObjectForKey(directoryKey) as! String
        
        self.nwX = aDecoder.decodeObjectForKey(nwXKey) as! Array
        self.nwY = aDecoder.decodeObjectForKey(nwYKey) as! Array
        
        self.neX = aDecoder.decodeObjectForKey(neXKey) as! Array
        self.neY = aDecoder.decodeObjectForKey(neYKey) as! Array
        
        self.swX = aDecoder.decodeObjectForKey(swXKey) as! Array
        self.swY = aDecoder.decodeObjectForKey(swYKey) as! Array
        
        self.zLevels = aDecoder.decodeObjectForKey(zLevelsKey) as! Array
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(self.nameKey, forKey: nameKey)
        aCoder.encodeObject(self.directory, forKey: directoryKey)
        
        aCoder.encodeObject(self.nwX, forKey: nwXKey)
        aCoder.encodeObject(self.nwY, forKey: nwYKey)
        
        aCoder.encodeObject(self.neX, forKey: neXKey)
        aCoder.encodeObject(self.neY, forKey: neYKey)
        
        aCoder.encodeObject(self.swX, forKey: swXKey)
        aCoder.encodeObject(self.swY, forKey: swYKey)
        
        aCoder.encodeObject(self.zLevels, forKey: zLevelsKey)
    }
}