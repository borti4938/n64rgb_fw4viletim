# N64 RGB Firmware
An alternative firmware for viletims commercial N64 RGB mod. The actual project is for **version 2 of viletims N64RGB**, not for version 1.x. However, latest version of the firmware for boards 1.x is provided in _output\_files/viletim\_v1_.

If you need the history for the firmware, please take a look at the [_n64rgb_ repository](https://github.com/borti4938/n64rgb) which was the initial place for the alternative firmware.

I do not offer 1:1 support for this project. Please respect that! If you have any problems, please reach out to any forum seeking for help with your issue. Nevertheless, you may contact me if you found a major issue or problem with the project implementation.



## Description of the Firmware Version

I uploaded two different firmware versions. These are the common features:
- Detection of 240p/288p
- Detection of PAL and NTSC mode (no output of that information at the moment as it is only internally used)
- Heuristic for de-blur function
- De-Blur in 240p/288p (horizontal resolution decreased from 640 to 320 pixels)
- 15bit color mode
- Slow Slew Rate

The two versions of the firmware now differs in the way how de-blur and 15bit color mode is accessed:
- With mechanical switches
- with in-game routine (IGR)

The following shortly describes the main features of the firmware and how to use / control them.


### In-Game Routines (IGR)

Three functionalities are implemented: toggle vi-deblur feature, toggle the 15bit mode and resetting the console.

To use this firmware (and therefore the IGRs) pin 21 of the CPLD (pad *A*) has to be connected to the communication wire of controller 1. On the controller port this is the middle pin, which is connected to pin 16 of the PIF-NUS (PIFP-NUS) on most consoles. Check this before soldering a wire to the PIF-NUS.

To use the reset functionality please connect pin 1 OR pin 18 of the CPLD (pad *M*) to the PIF-NUS pin 27. This is optional and can be left out if not needed.

The button combination are as follows:

- reset the console: Z + Start + R + A + B
- (de)activate vi-deblur:
  - activate: Z + Start + R + C-ri
  - deactivate: Z + Start + R + C-le
- (de)activate 15bit mode:
  - activate: Z + Start + R + C-dw
  - deactivate: Z + Start + R + C-up
- In order to deactivate the IGR module, ...
  - v2.x: short pin 78 to GND (e.g. pin 79)
  - v1.x: short pin 91 to GND (e.g. pin 90)

_Modifiying the IGR Button Combinations_:  
It's difficult to make everybody happy with it. Third party controllers, which differ from the original ones by design, make it even more difficult. So it is possible to generate your own firmware with **your own** preferred **button combinations** implemented. Please refer to the document **IGR.README.md** located in the top folder of this repository for further information.

_Final remark on IGR_:  
However, as the communication between N64 and the controller goes over a single wire, sniffing the input is not an easy task (and probably my solution is not the best one). This together with the lack of an exhaustive testing (many many games out there as well my limited time), I'm looking forward to any incoming issue report to further improve this feature :)

_Remark on older PCB versions_

- v1.2:
  - Pad A is connected to pin 100
  - Pad M is connected to pin 99
- v1.1 and v1.0
  - Pad A and M are not present
  - use pin 100 (function of pad A) and pin 99 or pin 1(function of pad M)


### VI-DeBlur

VI-Deblur of the picture information is only be done in 240p/288p. This is be done by simply blanking every second pixel. Normally, the blanked pixels are used to introduce blur by the N64 in 240p/288p mode. However, some games like Mario Tennis, 007 Goldeneye, and some others use these pixel for additional information rather than for blurring effects. In other words this means that these games uses full horizontal resolution even in 240p/288p output mode. Hence, the picture looks more blurry in this case if de-blur feature is activated.

How to control the feature:
- firmware with switches
  * By setting pin 21 of the MaxII CPLD (pad *A*) to GND, vi-deblur becomes active.
  * By lefting pin 21 of the MaxII CPLD (pad *A*) open, vi-deblur becomes inactive.
  * remark on older versions:
    - version 1.2: pad *A* is connected to pin 100
	- version 1.1 and 1.0: pad *A* is not present, use pin 100
- 'firmware with IGR':
  * By shorting pin 61 of the MaxII CPLD to GND (pin 60 e.g.), vi-deblur becomes active.
  * By lefting pin 61 of the MaxII CPLD open, vi-deblur becomes inactive.
  * Pin 61 state determines the default state of vi-deblur
  * IGR can override this. However the pad setting becomes active again if you toggle the state.


### 15bit Color Mode

The 15bit color mode reduces the color depth from 21bit (7bit for each color) down to 15bits (5bit for each color). Some very few games just use the five MSBs of the color information and the two LSBs for some kind of gamma dither. The 15bit color mode simply sets the two LSBs to '0'.

How to control the feature:
- firmware with switches
  * By setting pin 18 of the MaxII CPLD (pad *M*) to GND, vi-deblur becomes active.
  * By lefting pin 18 of the MaxII CPLD (pad *M*) open, vi-deblur becomes inactive.
  * remark on older versions:
    - version 1.2: pad *M* is connected to pin 99
	- version 1.1 and 1.0: pad *M* is not present, use either pin 99 or pin 1
- 'firmware with IGR':
  * By shorting pin 33 of the MaxII CPLD to GND (pin 32 e.g.), 15bit mode becomes active.
  * By lefting pin 33 of the MaxII CPLD open, vi-deblur becomes inactive.
  * Pin 33 state determines the default state of 15bit mode
  * IGR can override this. However the pad setting becomes active again if you toggle the state.

_Remark on older PCB versions_
- v1.x: IGR firmware
  * use pin 36 to toggle 15bit mode (GND is pin 37)


## Final Remarks

Lastly, the information how to update can be grabbed incl. some more technical information here: [URL to viletims official website](http://etim.net.au/n64rgb/tech/). The use of the presented firmware is up on everybodies own risk. However, a fallback to the initial firmware is provided on viletims webpage.
