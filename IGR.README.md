# IGR Features of the N64 RGB Firmware
## Modifying the Button Combinations

### Preface
With the In-Game Routines feature of the N64 RGB firmware you are able to trigger several events using the controller, e.g. perform a soft-reset.  
However, everybody prefer some different combinations according to some subjective criterias. This documents describes how to build your own firmware or how to request a firmware build.

### Required Software

- _build your own_: [Quartus Prime Lite edition](http://dl.altera.com/17.0/?edition=lite) with MaxII / MaxV support files. Please see release notes for additional hard- and software requirements.
- _request a fw-build_: simple text editor

### Adding your button combination

#### First steps
The firmware source is located in either _output\_files_.

If you use Quartus Prime to build your own firmware open the _Quartus Project File_ (\*.qpf) with Quartus Prime. Once the project has been loaded, change the revision accodingly to _n64rgb2\_viletim\_igr_.

#### Modifying the button combination
You find in the Verilog source files a file named **vh/igr\_params.vh**. open this file with either Quartus Prime or with a text editor of your choice.

**Please do not edit** the first few lines. Your editing starts at line 70. Each line starting with the keyword _parameter_ is now in your point of interest. After the keyword you have a name and an assigned value. Do not edit the name, just the assignment.

You have the following values for your assignment available: **\`A, \`B, \`Z, \`St, \`Du, \`Dd, \`Dl, \`Dr, \`L, \`R, \`Cu, \`Cd, \`Cl and \`Cr**. It's important that you **use the backtick** infront of each button code. You can **connect multiple buttons** with a simple **+** sign! A line closes with a semicolon. You can assign the following codes:

- _igr\_reset_: button combination to trigger a reset
- _igr\_deblur\_off_: button combination to switch deblur off
- _igr\_deblur\_on_: button combination to switch deblur on
- _igr\_15bitmode\_off_: button combination to switch 15bit color mode off
- _igr\_15bitmode\_on_: button combination to switch 15bit color mode on

Once you have edited your button combinations, you have the option to either build the firmware on your own or to request a firmware build.

#### Building the firmware 
In Quartus Prime then go to _Processing_ on the top bar and _Start Compilation_. Or simply double click on _Assembler (Generate programming file)_ in the _Tasks_-subwindow. Your programming file (\*.pof) will be located in the project-subfolder _output\_files/_.

#### Request the firmware
As I can understand that not everybody wants to install a 15GB program for just building the firmware, I offer you to generate your firmware. Just send me your edited **igr\_params.vh** to [borti4938@gmail.com](mailto:borti4938@gmail.com).

A few days later I return to you via email.
