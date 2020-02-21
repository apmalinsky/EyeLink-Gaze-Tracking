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

3. Fixations are saved to a table and stored in the `tables/` folder.
