# Clock Alarm Calendar

This project implements a digital clock with alarm and calendar functionality for Tiny Tapeout.

## What it does

The design keeps track of:
- hours and minutes
- day and month
- year
- alarm time

The current time and date are generated inside the logic core.  
A display scanner formats the data for an external 74HC595-based serial display interface.

## Inputs

- `ui_in[0]`: mode / pause button  
- `ui_in[1]`: decrement button (currently reserved)  
- `ui_in[2]`: increment button  

## Outputs

- `uo_out[0]`: serial clock (`sclk`)  
- `uo_out[1]`: register clock (`rclk`)  
- `uo_out[2]`: serial data output (`dio`)  
- `uo_out[3]`: buzzer output  

## How it works

The design uses several internal blocks:

- `clock_divider`: generates timing ticks
- `button_debounce`: cleans button inputs
- `time_calendar_core`: stores and updates time, date, year, and alarm values
- `display_scanner`: prepares the display data stream
- `hc595_driver`: shifts display data out to an external 74HC595-compatible interface

A Tiny Tapeout wrapper module maps the project into the standard Tiny Tapeout pin interface.

## External hardware

This project is intended to drive an external display system through a shift-register style serial interface.
A buzzer output is also provided for alarm indication.

## Notes

- Reset is driven from Tiny Tapeout `rst_n` and internally converted to active-high reset.
- The current version mainly uses increment and mode control.
- The decrement input is reserved for future expansion.
