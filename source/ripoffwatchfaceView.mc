using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Application;

var font;
var symbols;

var primary;
var secondary;
var background;

class ripoffwatchfaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        font = WatchUi.loadResource(Rez.Fonts.id_futura);
        symbols = WatchUi.loadResource(Rez.Fonts.id_symbols);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        primary = Application.getApp().getProperty("PrimaryColor");
        secondary = Application.getApp().getProperty("SecondaryColor");
        background = Application.getApp().getProperty("BackgroundColor");

        setDate();
        setSteps();
        setBattery();
        setHR();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // all dc calls must happen after layout redraw
        setClock(dc);
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
        dc.setColor(primary, Graphics.COLOR_TRANSPARENT);


//      debugging
//      dc.setPenWidth(1);
//      dc.drawLine(0, 120, 240, 120);
//      dc.drawLine(120, 0, 120, 240);

        dc.setPenWidth(3);
        dc.drawLine(0, 43, 240, 43);
        dc.drawLine(0, 203, 240, 203);

        dc.setPenWidth(4);

        // 180 +- 30
        // left arc
//      dc.drawArc(120, 120, 116, Graphics.ARC_CLOCKWISE, 210, 150);

        // 0 +- 30
        // right arc
        var arcBackgroundColor = background == Graphics.COLOR_DK_GRAY ? Graphics.COLOR_BLACK : Graphics.COLOR_DK_GRAY;
        dc.setColor(arcBackgroundColor, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(120, 120, 116, Graphics.ARC_COUNTER_CLOCKWISE, 330, 30);

        var battery = System.getSystemStats().battery;
        var top = (360 + (battery / 100 * 60) - 30).toLong() % 360;

        dc.setColor(primary, Graphics.COLOR_BLACK);
        dc.drawArc(120, 120, 116, Graphics.ARC_COUNTER_CLOCKWISE, 330, top);
    }

    hidden function charOffset(char) {
        switch (char) {
            case "0": return 50;
            case "1": return 40;
            case "2": return 51;
            case "3": return 51;
            case "4": return 51;
            case "5": return 50;
            case "6": return 53;
            case "7": return 57;
            case "8": return 55;
            case "9": return 56;
            default: return -1;
        }

    }

    hidden function drawClockSegment(dc, color, segment, x, y) {
        var c1 = segment.substring(0, 1);
        var c2 = segment.substring(1, 2);

        // center align
//      var width = charOffset(c1) + charOffset(c2);
//
//      var c1x = x - (width / 2);
//      var c2x = x;

        // left align
        var c1x = x;
        var c2x = x + charOffset(c1);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(c2x, y, font, c2, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(c1x, y, font, c1, Graphics.TEXT_JUSTIFY_LEFT);
    }

    hidden function setClock(dc) {
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
        drawClockSegment(dc, secondary, hourString, 50, 28);
        drawClockSegment(dc, primary, minuteString, 80, 102);
    }

    hidden function setDate() {
        var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateString = Lang.format("$1$ $2$", [date.day_of_week.toUpper(), date.day]);

        var dateDisplay = View.findDrawableById("DateLabel");
        dateDisplay.setColor(secondary);
        dateDisplay.setText(dateString);
    }

    hidden function setSteps() {
        var stepCount = ActivityMonitor.getInfo().steps.toString();
        var stepCountDisplay = View.findDrawableById("StepLabel");
        stepCountDisplay.setColor(secondary);

        stepCountDisplay.setText(stepCount);

        View.findDrawableById("StepIcon").setColor(secondary);
    }

    hidden function setBattery() {
        var battery = System.getSystemStats().battery;
        var batteryDisplay = View.findDrawableById("BatteryLabel");
        batteryDisplay.setColor(secondary);
        batteryDisplay.setText(battery.format("%d"));

        var batteryIcon = View.findDrawableById("BatteryIcon");
        batteryIcon.setColor(secondary);
        if (System.getSystemStats().charging) {
            batteryIcon.setText("c");
        }
        else if (battery > 90) {
            batteryIcon.setText("0");
        } else if (battery > 75) {
            batteryIcon.setText("1");
        } else if (battery > 40) {
            batteryIcon.setText("2");
        } else if (battery > 20) {
            batteryIcon.setText("3");
        } else {
            batteryIcon.setText("4");
        }
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
        heartrateDisplay.setColor(secondary);
        heartrateDisplay.setText(hr);

        View.findDrawableById("HRIcon").setColor(secondary);
    }

}
