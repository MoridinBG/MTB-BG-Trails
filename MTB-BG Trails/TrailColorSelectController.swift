//
//  TrailColorSelectController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/27/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit

protocol TrailColorSelectDelegate
{
    func selectedColor(selection: ColorSelection)
}

enum ColorSelection
{
    case Random
    case Length
    case Ascent
    case Effort
    case Technicality
}
class TrailColorSelectController: UIViewController
{

    @IBOutlet weak var randomSwitch: UISwitch!
    
    var delegate: TrailColorSelectDelegate?
    
    private var activeSwitch: UISwitch?
    
    @IBAction func switchedRandom(sender: UISwitch)
    {
        if sender.on
        {
            activeSwitch?.on = false
            activeSwitch = sender
            
            delegate?.selectedColor(.Random)
        } else if activeSwitch == sender
        {
            sender.on = true
        }
    }
    
    @IBAction func switchedLength(sender: UISwitch)
    {
        if sender.on
        {
            activeSwitch?.on = false
            activeSwitch = sender
            
            delegate?.selectedColor(.Length)
        } else if activeSwitch == sender
        {
            sender.on = true
        }
    }
    
    @IBAction func switchedAscent(sender: UISwitch)
    {
        if sender.on
        {
            activeSwitch?.on = false
            activeSwitch = sender
            
            delegate?.selectedColor(.Ascent)
        } else if activeSwitch == sender
        {
            sender.on = true
        }
    }
    
    @IBAction func switchedEffort(sender: UISwitch)
    {
        if sender.on
        {
            activeSwitch?.on = false
            activeSwitch = sender
            
            delegate?.selectedColor(.Effort)
        } else if activeSwitch == sender
        {
            sender.on = true
        }
    }
    
    @IBAction func switchedTechnicality(sender: UISwitch)
    {
        if sender.on
        {
            activeSwitch?.on = false
            activeSwitch = sender
            
            delegate?.selectedColor(.Technicality)
        } else if activeSwitch == sender
        {
            sender.on = true
        }
    }
    
    convenience init()
    {
        self.init(nibName: "TrailColorSelect", bundle: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        activeSwitch = randomSwitch
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
