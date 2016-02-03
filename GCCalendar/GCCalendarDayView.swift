//
//  GCCalendarDayView.swift
//  GCCalendar
//
//  Created by Gray Campbell on 1/29/16.
//  Copyright © 2016 Gray Campbell. All rights reserved.
//

import UIKit

public final class GCCalendarDayView: UIView
{
    // MARK: - Properties
    
    var date: NSDate?
    let button = UIButton()
    let buttonWidth: CGFloat = 35
    
    var isSelectedDay: Bool = false {
        
        didSet { self.isSelectedDay ? self.daySelected() : self.dayDeselected() }
    }
    
    var isToday: Bool = false {
        
        didSet {
            
            self.button.titleLabel!.font = self.defaultFont
            self.button.setTitleColor(self.defaultTextColor, forState: .Normal)
        }
    }
}

// MARK: Font & Text Color

extension GCCalendarDayView
{
    var defaultFont: UIFont {
        
        return self.isToday ? Calendar.CurrentDayView.font : Calendar.DayView.font
    }
    
    var selectedFont: UIFont {
        
        return self.isToday ? Calendar.CurrentDayView.selectedFont : Calendar.DayView.selectedFont
    }
    
    var defaultTextColor: UIColor {
        
        return self.isToday ? Calendar.CurrentDayView.textColor : Calendar.DayView.textColor
    }
    
    var selectedTextColor: UIColor {
        
        return self.isToday ? Calendar.CurrentDayView.selectedTextColor : Calendar.DayView.selectedTextColor
    }
}

// MARK: - Initializers

extension GCCalendarDayView
{
    public convenience init(date: NSDate?)
    {
        self.init(frame: CGRectZero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addDate(date)
    }
}

// MARK: - Button

extension GCCalendarDayView
{
    func addButton()
    {
        self.button.layer.cornerRadius = self.buttonWidth / 2
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.button)
        self.addButtonConstraints()
    }
    
    private func addButtonConstraints()
    {
        let width = NSLayoutConstraint(i: self.button, a: .Width, c: self.buttonWidth)
        let height = NSLayoutConstraint(i: self.button, a: .Height, c: self.buttonWidth)
        let centerX = NSLayoutConstraint(i: self.button, a: .CenterX, i: self)
        let centerY = NSLayoutConstraint(i: self.button, a: .CenterY, i: self)
        
        self.superview!.addConstraints([width, height, centerX, centerY])
    }
}

// MARK: - Date

extension GCCalendarDayView
{
    private func addDate(date: NSDate?)
    {
        self.date = date
        
        if self.date != nil
        {
            let dateFormatter = self.dateFormatter
            
            let title = dateFormatter.stringFromDate(self.date!)
            
            self.button.setTitle(title, forState: .Normal)
            
            self.button.addTarget(self, action: "dayPressed", forControlEvents: .TouchUpInside)
            
            self.isToday = Calendar.currentCalendar.isDateInToday(self.date!)
            self.isSelectedDay = self.isToday
        }
    }
    
    private var dateFormatter: NSDateFormatter {
        
        var dateFormatter: NSDateFormatter!
        var onceToken: dispatch_once_t = 0
        
        dispatch_once(&onceToken) {
         
            dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "d"
            
            if dateFormatter.calendar != Calendar.currentCalendar
            {
                dateFormatter.calendar = Calendar.currentCalendar
            }
        }
        
        return dateFormatter
    }
}

// MARK: - Selection

extension GCCalendarDayView
{
    func dayPressed()
    {
        self.isSelectedDay = true
    }
    
    private func daySelected()
    {
        self.button.enabled = false
        
        Calendar.selectedDayView?.dayDeselected()
        
        Calendar.selectedDayView = self
        
        self.button.backgroundColor = Calendar.CurrentDayView.selectedBackgroundColor
        
        self.button.titleLabel!.font = Calendar.CurrentDayView.selectedFont
        
        self.button.setTitleColor(Calendar.CurrentDayView.selectedTextColor, forState: .Normal)
        
        self.animateSelection()
    }
    
    private func dayDeselected()
    {
        self.backgroundColor = nil
        
        let font = self.isToday ? Calendar.CurrentDayView.font : Calendar.DayView.font
        let titleColor = self.isToday ? Calendar.CurrentDayView.textColor : Calendar.DayView.textColor
        
        self.button.titleLabel!.font = font
        
        self.button.setTitleColor(titleColor, forState: .Normal)
        
        self.button.enabled = true
    }
}

// MARK: Animations

extension GCCalendarDayView
{
    private func animateSelection()
    {
        self.animateToScale(0.9) { finished in
            
            if finished
            {
                self.animateToScale(1.1) { finished in
                    
                    if finished
                    {
                        self.animateToScale(1.0, completion: nil)
                    }
                }
            }
        }
    }
    
    private func animateToScale(scale: CGFloat, completion: ((Bool) -> Void)?)
    {
        UIView.animateWithDuration(0.1, animations: {
            
            self.button.transform = CGAffineTransformMakeScale(scale, scale)
            
            }, completion: completion)
    }
}
