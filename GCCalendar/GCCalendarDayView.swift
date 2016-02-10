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
    
    private var delegate: GCCalendarDelegate!
    
    private var date: NSDate?
    private let button = UIButton()
    private let buttonWidth: CGFloat = 35
    
    private var isSelectedDay: Bool = false {
        
        didSet { self.isSelectedDay ? self.daySelected() : self.dayDeselected() }
    }
    
    private var isToday: Bool = false {
        
        didSet {
            
            self.button.titleLabel!.font = self.defaultFont
            self.button.setTitleColor(self.defaultTextColor, forState: .Normal)
        }
    }
}

// MARK: - Font, Text Color, & Background Color

extension GCCalendarDayView
{
    private var defaultFont: UIFont {
        
        return self.isToday ? self.delegate.currentDayViewFont!() : self.delegate.dayViewFont!()
    }
    
    private var selectedFont: UIFont {
        
        return self.isToday ? self.delegate.currentDayViewSelectedFont!() : self.delegate.dayViewSelectedFont!()
    }
    
    private var defaultTextColor: UIColor {
        
        return self.isToday ? self.delegate.currentDayViewTextColor!() : self.delegate.dayViewTextColor!()
    }
    
    private var selectedTextColor: UIColor {
        
        return self.isToday ? self.delegate.currentDayViewSelectedTextColor!() : self.delegate.dayViewSelectedTextColor!()
    }
    
    private var selectedBackgroundColor: UIColor {
        
        return self.isToday ? self.delegate.currentDayViewSelectedBackgroundColor!() : self.delegate.dayViewSelectedBackgroundColor!()
    }
}

// MARK: - Initializers

extension GCCalendarDayView
{
    convenience init(delegate: GCCalendarDelegate, date: NSDate?)
    {
        self.init(frame: CGRectZero)
        
        self.delegate = delegate
        
        self.addButton()
        self.update(newDate: date)
    }
}

// MARK: - Button

extension GCCalendarDayView
{
    private func addButton()
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
        
        self.addConstraints([width, height, centerX, centerY])
    }
}

// MARK: - Date

extension GCCalendarDayView
{
    func update(newDate newDate: NSDate?)
    {
        self.date = newDate
        
        if self.date == nil
        {
            self.button.setTitle(nil, forState: .Normal)
            self.button.removeTarget(self, action: "dayPressed", forControlEvents: .TouchUpInside)
            
            self.isToday = false
            self.isSelectedDay = false
        }
        else
        {
            let title = self.dateFormatter.stringFromDate(self.date!)
            
            self.button.setTitle(title, forState: .Normal)
            self.button.addTarget(self, action: "dayPressed", forControlEvents: .TouchUpInside)
            
            self.isToday = Calendar.currentCalendar.isDateInToday(self.date!)
            self.isSelectedDay = Calendar.currentCalendar.isDate(self.date!, inSameDayAsDate: Calendar.selectedDate)
        }
    }
    
    private var dateFormatter: NSDateFormatter {
        
        var formatter: NSDateFormatter!
        var onceToken: dispatch_once_t = 0
        
        dispatch_once(&onceToken) {
         
            formatter = NSDateFormatter(dateFormat: "d")
            
            if formatter.calendar != Calendar.currentCalendar
            {
                formatter.calendar = Calendar.currentCalendar
            }
        }
        
        return formatter
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
        Calendar.selectedDate = self.date!
        
        self.button.backgroundColor = self.selectedBackgroundColor
        self.button.titleLabel!.font = self.selectedFont
        self.button.setTitleColor(self.selectedTextColor, forState: .Normal)
        
        self.delegate.didSelectDate(self.date!)
        
        self.animateSelection()
    }
    
    private func dayDeselected()
    {
        self.button.backgroundColor = nil
        
        let font = self.isToday ? self.delegate.currentDayViewFont!() : self.delegate.dayViewFont!()
        let titleColor = self.isToday ? self.delegate.currentDayViewTextColor!() : self.delegate.dayViewTextColor!()
        
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
        self.animateToScale(0.9) { finished in self.animateToScale(1.1) { finished in self.animateToScale(1.0) } }
    }
    
    private func animateToScale(scale: CGFloat, completion: ((Bool) -> Void)? = nil)
    {
        UIView.animateWithDuration(0.1, animations: {
            
            self.button.transform = CGAffineTransformMakeScale(scale, scale)
            
        }, completion: completion)
    }
}
