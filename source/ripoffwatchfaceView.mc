using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Application;

var font;

class ripoffwatchfaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
        font = WatchUi.loadResource(Rez.Fonts.id_futura);
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	setClock();
    	setDate();
    	setSteps();
    	setBattery();
    	setHR();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        // all dc calls must happen after layout redraw
        
    	drawLines(dc);
        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    hidden function drawLines(dc) {
    	dc.setColor(0xffffff, 0x000000);
    	dc.setPenWidth(2);
    	
    	dc.drawLine(0, 43, 240, 43);
    	dc.drawLine(0, 203, 240, 203);
    	
    	// 180 +- 35
    	dc.setPenWidth(4);
    	dc.drawArc(120, 120, 116, Graphics.ARC_CLOCKWISE, 215, 145);
    	
    	// 0 +- 35
    	dc.drawArc(120, 120, 116, Graphics.ARC_COUNTER_CLOCKWISE, 325, 35);
//    	
////    	dc.drawLine(55, 40, 55, 200);
////    	dc.drawLine(190, 40, 190, 200);
//    	
//    	dc.setColor(0x999999, 0x000000);
//    	dc.drawLine(120, 0, 120, 240);
//    	dc.drawLine(0, 120, 240, 120);
    }
    
    // -------------------------------------------
    
    
    // height: 69px
    // total height: 240px
    // padding: 10px
    // top: ((240 - (69*2))/2) - 5
    // bottom: ((240 - (69*2))/2) + 69 + 5
    
    hidden function setClock() {
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (Application.getApp().getProperty("UseMilitaryFormat")) {
                hours = hours.format("%02d");
            }
        }
        var hourString = hours.format("%02d");
        var minuteString = clockTime.min.format("%02d");

        // Update the view
        var hourView = View.findDrawableById("HourLabel");
        hourView.setFont(font);
        hourView.setText(hourString);
		
        
        var minuteView = View.findDrawableById("MinuteLabel");
        minuteView.setFont(font);
        minuteView.setColor(Application.getApp().getProperty("ForegroundColor"));
        minuteView.setText(minuteString);
    }
    
    hidden function setDate() {
    	var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    	var dateString = Lang.format("$1$ $2$", [date.day_of_week.toUpper(), date.day]);
    	
    	var dateDisplay = View.findDrawableById("DateLabel");      
		dateDisplay.setText(dateString);	
    }
    
    hidden function setSteps() {
//    	var stepCount = ActivityMonitor.getInfo().steps.toString();
		var stepCount = "1234";
		var stepCountDisplay = View.findDrawableById("StepLabel");      
		stepCountDisplay.setText(stepCount);
    }
    
    hidden function setBattery() {
	    var battery = System.getSystemStats().battery;				
		var batteryDisplay = View.findDrawableById("BatteryLabel");      
		batteryDisplay.setText(battery.format("%d")+"%");
    }
    
    hidden function setHR() {
    	var hr = "";
    	if(ActivityMonitor has :INVALID_HR_SAMPLE) {
	    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
			var currentHeartrate = heartrateIterator.next().heartRate;
		
			if(currentHeartrate == ActivityMonitor.INVALID_HR_SAMPLE) {
				return "--";
			} else {
				hr = currentHeartrate.format("%d");
			}	
    	}
    	else {
    		hr = "--";
    	}
    	
		var heartrateDisplay = View.findDrawableById("HRLabel");
		
		// todo heart glyph
		hr = "HR " + hr;  
		heartrateDisplay.setText(hr);
    }

}
