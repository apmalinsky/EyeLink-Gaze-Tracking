# EyeLink Gaze Tracking
This file is part of an eye tracking experimental study on visual attention. I developed this code in Dr. Katherine Moore's Attention, Memory & Cognition laboratory housed in the Psychology Department at Arcadia University. Written in MATLAB, it utilizes the Psychtoolbox library to interface with an SR Research EyeLink 1000 eye tracker. The EyelinkToolbox source code can be found [here](https://github.com/Psychtoolbox-3/Psychtoolbox-3/tree/master/Psychtoolbox/PsychHardware/EyelinkToolbox).

An adapted example program can be found [here](https://en.wikibooks.org/wiki/MATLAB_Programming/Psychtoolbox/eyelink_toolbox). For the purposes of the study we focused on tracking fixations. Outlined below are some steps I took for implementing and recording fixation results.

To simulate the experiment, run `EyeTrackingSearch.m`.

1. Keep a counter for draining the queue of samples and events from the link. This fixes an error that arose in which new samples had an event type of LOSTDATAEVENT.
    
    `if queueCounter >= 100` <br/>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`evtdata = Eyelink('GetQueuedData'); % remove items from queue to` `avoid LOSTDATAEVENT` <br/>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`queueCounter = 0; % reset counter` <br/>
    `end`

2. Check the next data type for fixations. For a complete list of event types you may reference [here](https://github.com/Psychtoolbox-3/Psychtoolbox-3/blob/master/Psychtoolbox/PsychHardware/EyelinkToolbox/EyelinkOneLiners/geteventtype.m).

    `evtype = Eyelink('GetNextDataType');` <br/>

    `if evtype == el.STARTFIX  % if the subject started a fixation` <br/>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`...` <br/>
    `if evtype == el.ENDFIX  % if the subject finished a fixation` <br/>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`...`                 

3. Fixations are saved to a table and stored in the tables/ folder.

4. Changed the default background color to black. This sets the background color during tracker setup, and mitigated some calibration issues we experienced. Black is the background color during the experiment, so it is possible that the difference in background color affected the tracking accuracy. This may not be an issue for you, but if it is, feel free to follow these instructions:

    * Find the location of the `EyelinkInitDefaults.m` file.<br/>
      Found within the Psychtoolbox folder, for instance:<br/>
      (C:\toolbox\Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkBasic)

    * Changed Line 60 to: <br/>
    `el.backgroundcolour = BlackIndex(el.window);`

    * Save the file.

Another experimental test can be found in the `BinocularTest.m` file. Also adapted from the example program, the following code snippet switches the eye being tracked. The user closes one eye to start tracking the other. This test relies on the use of EyeLink's Binocular configuration. For additional help, you can refer to the EyeLink 1000 [User Manual](http://sr-research.jp/support/EyeLink%201000%20User%20Manual%201.5.0.pdf) provided by SR Research.

    switch eye_used
        case el.LEFT_EYE 
            eye_used = el.RIGHT_EYE;
            rightEye; % call the rightEye function
        case el.RIGHT_EYE
            eye_used = el.LEFT_EYE;
            leftEye; % call the leftEye function
    end
