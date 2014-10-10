Faurecia BioFit Demo iOS
========================

Sample iOS iPhone application demonstrating use of the Faurecia BioFit SDK


Getting Started
===============

* clone this repo to your Mac
* open the *project* in Xcode: `open FaureciaBioFitDemo.xcodeproj`
* run! The app needs to deploy to a device (such as an iPhone), not a simulator because the simulator does not have Bluetooth capability.


Running the iOS App
====================
Once you have [the BioFit simulator](https://github.com/FaureciaDev/Faurecia-BioFit-Simulator) running as well, you can connect to it and run the iOS demo app.  Make sure you press the "sit down" button on the simulator to begin bluetooth advertising.

Press the "Start" button in the upper right of the iOS app (The button text will change to "Stop" once its clicked).  Then select the name of the peripheral you want to connect to.  It will either say "BioFit", or the name of your computer.

The app will connect to the simulator.  The pre-set data modification "A" on the simulator will increase stress over time. Click on the "A" button and watch the stress level change.  When it gets to be over 60, you should see the message update.
