//
//  TrailsFilterController.swift
//  MTB-BG Trails
//
//  Created by Ivan Dilchovski on 5/19/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import UIKit

protocol TrailsFilterDelegate
{
	func applyFilters(filters: [TrailFilter])
}

enum TrailFilter
{
	case lengthFilter(Float, Float)
	case ascentFilter(Float, Float)
	case effortFilter(Float, Float)
	case diffFilter(Float, Float)
}

class TrailsFilterController: UIViewController
{
	
	@IBOutlet weak var minLength: UISlider!
	@IBOutlet weak var maxLength: UISlider!
	@IBOutlet weak var minLengthLabel: UILabel!
	@IBOutlet weak var maxLengthLabel: UILabel!
	
	
	@IBOutlet weak var minAscent: UISlider!
	@IBOutlet weak var maxAscent: UISlider!
	@IBOutlet weak var minAscentLabel: UILabel!
	@IBOutlet weak var maxAscentLabel: UILabel!
	
	@IBOutlet weak var minEffort: UISlider!
	@IBOutlet weak var maxEffort: UISlider!
	@IBOutlet weak var minEffortLabel: UILabel!
	@IBOutlet weak var maxEffortLabel: UILabel!
	
	@IBOutlet weak var minDiff: UISlider!
	@IBOutlet weak var maxDiff: UISlider!
	@IBOutlet weak var minDiffLabel: UILabel!
	@IBOutlet weak var maxDiffLabel: UILabel!
	
	var statistics = Statistics()
	var delegate: TrailsFilterDelegate?
	
	private let lengthStep: Float = 0.5
	private let ascentStep: Float = 1.0
	private let effortStep: Float = 1.0
	private let diffStep:	Float = 1.0
    
    private var oldMinLength: Float = -1.23456789
	private var oldMaxLength: Float = -1.23456789

    private var oldMinAscent: Float = -1.23456789
    private var oldMaxAscent: Float = -1.23456789
    
    private var oldMinEffort: Float = -1.23456789
    private var oldMaxEffort: Float = -1.23456789
    
    private var oldMinDiff: Float = -1.23456789
    private var oldMaxDiff: Float = -1.23456789
    
	@IBAction func minLengthChanged(sender: UISlider)
	{
		let newStep = roundf((minLength.value) / lengthStep)
		minLength.value = newStep * lengthStep
		
        if minLength.value == oldMinLength
        {
            return
        } else
        {
            oldMinLength = minLength.value
        }
        
		minLengthLabel.text = "\(minLength.value)km"
		maxLength.minimumValue = minLength.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
						TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
						TrailFilter.effortFilter(minEffort.value, maxEffort.value),
						TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	@IBAction func maxLengthChanged(sender: UISlider)
	{
		let newStep = roundf((maxLength.value) / lengthStep)
		maxLength.value = newStep * lengthStep
        
        if maxLength.value == oldMaxLength
        {
            return
        } else
        {
            oldMaxLength = maxLength.value
        }
		
		maxLengthLabel.text = "\(maxLength.value)km"
		minLength.maximumValue = maxLength.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
			TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
			TrailFilter.effortFilter(minEffort.value, maxEffort.value),
			TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	@IBAction func minAscentChanged(sender: UISlider)
	{
		let newStep = roundf((minAscent.value) / ascentStep)
		minAscent.value = newStep * ascentStep
		
        if minAscent.value == oldMinAscent
        {
            return
        } else
        {
            oldMinAscent = minAscent.value
        }
        
		minAscentLabel.text = "\(minAscent.value)m"
		maxAscent.minimumValue = minAscent.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
			TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
			TrailFilter.effortFilter(minEffort.value, maxEffort.value),
			TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	@IBAction func maxAscentChanged(sender: UISlider)
	{
		let newStep = roundf((maxAscent.value) / ascentStep)
		maxAscent.value = newStep * ascentStep
		
        if maxAscent.value == oldMaxAscent
        {
            return
        } else
        {
            oldMaxAscent = maxAscent.value
        }
        
		maxAscentLabel.text = "\(maxAscent.value)m"
		minAscent.maximumValue = maxAscent.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
			TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
			TrailFilter.effortFilter(minEffort.value, maxEffort.value),
			TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	@IBAction func minEffortChanged(sender: UISlider)
	{
		let newStep = roundf((minEffort.value) / effortStep)
		minEffort.value = newStep * effortStep
		
        if minEffort.value == oldMinEffort
        {
            return
        } else
        {
            oldMinEffort = minEffort.value
        }
        
		minEffortLabel.text = "\(minEffort.value)"
		maxEffort.minimumValue = minEffort.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
			TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
			TrailFilter.effortFilter(minEffort.value, maxEffort.value),
			TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	@IBAction func maxEffortChanged(sender: UISlider)
	{
		let newStep = roundf((maxEffort.value) / effortStep)
		maxEffort.value = newStep * effortStep
		
        if maxEffort.value == oldMaxEffort
        {
            return
        } else
        {
            oldMaxEffort = maxEffort.value
        }
        
		maxEffortLabel.text = "\(maxEffort.value)"
		minEffort.maximumValue = maxEffort.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
			TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
			TrailFilter.effortFilter(minEffort.value, maxEffort.value),
			TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	@IBAction func minDiffChanged(sender: UISlider)
	{
		let newStep = roundf((minDiff.value) / diffStep)
		minDiff.value = newStep * diffStep
		
        if minDiff.value == oldMinDiff
        {
            return
        } else
        {
            oldMinDiff = minDiff.value
        }
        
		minDiffLabel.text = Constants.Values.vTrailDifficultyClasses[Int(minDiff.value)]
		maxDiff.minimumValue = minDiff.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
			TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
			TrailFilter.effortFilter(minEffort.value, maxEffort.value),
			TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	@IBAction func maxDiffChanged(sender: UISlider)
	{
		let newStep = roundf((maxDiff.value) / diffStep)
		maxDiff.value = newStep * diffStep
		
        if maxDiff.value == oldMaxDiff
        {
            return
        } else
        {
            oldMaxDiff = maxDiff.value
        }
        
		maxDiffLabel.text = Constants.Values.vTrailDifficultyClasses[Int(maxDiff.value)]
		minDiff.maximumValue = maxDiff.value
		
		let filters = [TrailFilter.lengthFilter(minLength.value, maxLength.value),
			TrailFilter.ascentFilter(minAscent.value, maxAscent.value),
			TrailFilter.effortFilter(minEffort.value, maxEffort.value),
			TrailFilter.diffFilter(minDiff.value, maxDiff.value)]
		
		delegate?.applyFilters(filters)
	}
	
	convenience init()
	{
		self.init(nibName: "TrailsFilterController", bundle: nil)
	}
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setupSliders()
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
	
	private func setupSliders()
	{
		minLength.minimumValue = Float(statistics.length.min)
		minLength.maximumValue = Float(statistics.length.max)
		minLength.value = minLength.minimumValue
		
		maxLength.minimumValue = Float(statistics.length.min)
		maxLength.maximumValue = Float(statistics.length.max)
		maxLength.value = maxLength.maximumValue
		
		minLengthLabel.text = "\(minLength.value)m"
		maxLengthLabel.text = "\(maxLength.value)m"
		
		
		minAscent.minimumValue = Float(statistics.ascent.min)
		minAscent.maximumValue = Float(statistics.ascent.max)
		minAscent.value = minAscent.minimumValue
		
		maxAscent.minimumValue = Float(statistics.ascent.min)
		maxAscent.maximumValue = Float(statistics.ascent.max)
		maxAscent.value = maxAscent.maximumValue
		
		minAscentLabel.text = "\(minAscent.value)m"
		maxAscentLabel.text = "\(maxAscent.value)m"
		
		
		minEffort.minimumValue = Float(statistics.strenuousness.min)
		minEffort.maximumValue = Float(statistics.strenuousness.max)
		minEffort.value = minEffort.minimumValue
		
		maxEffort.minimumValue = Float(statistics.strenuousness.min)
		maxEffort.maximumValue = Float(statistics.strenuousness.max)
		maxEffort.value = maxEffort.maximumValue
		
		minEffortLabel.text = "\(minEffort.value)"
		maxEffortLabel.text = "\(maxEffort.value)"
		
		
		minDiff.minimumValue = Float(statistics.difficulty.min - 1)
		minDiff.maximumValue = Float(statistics.difficulty.max)
		minDiff.value = minDiff.minimumValue
		
		maxDiff.minimumValue = Float(statistics.difficulty.min - 1)
		maxDiff.maximumValue = Float(statistics.difficulty.max)
		maxDiff.value = maxDiff.maximumValue
		
		minDiffLabel.text = Constants.Values.vTrailDifficultyClasses[Int(minDiff.value)]
		maxDiffLabel.text = Constants.Values.vTrailDifficultyClasses[Int(maxDiff.value)]
	}
}
