# EyeLink Gaze Tracking
This file is part of an eye tracking experimental study on visual attention. I developed this code in Dr. Katherine Moore's Attention, Memory & Cognition laboratory housed in the Psychology Department at Arcadia University. Written in MATLAB, it utilizes the Psychtoolbox library to interface with an SR Research EyeLink 1000 eye tracker. The EyelinkToolbox source code can be found [here](https://github.com/Psychtoolbox-3/Psychtoolbox-3/tree/master/Psychtoolbox/PsychHardware/EyelinkToolbox).

An adapted example program can be found [here](https://en.wikibooks.org/wiki/MATLAB_Programming/Psychtoolbox/eyelink_toolbox). For the purposes of the study we focused on tracking fixations. Outlined below are the additional steps I took for implementing and recording fixation results.

1. Create a file to write fixations to.

    `fixFileName = strcat('S',subjectNum,'fixations.txt');`
    `fixationFile = fopen(fixFileName{1},'w');`

2. Keep a counter for draining the queue of samples and events from the link. This fixes an error that arose in which new samples had an event type of LOSTDATAEVENT.
    
    `if queueCounter >= 100`
        `evtdata = Eyelink('GetQueuedData'); % remove items from queue to` `avoid LOSTDATAEVENT`
        `queueCounter = 0; % reset counter`
    `end`

3. Check the next data type for fixations. For a complete list of event types you may reference [here](https://github.com/Psychtoolbox-3/Psychtoolbox-3/blob/master/Psychtoolbox/PsychHardware/EyelinkToolbox/EyelinkOneLiners/geteventtype.m).

    `evtype = Eyelink('GetNextDataType');`

    `if evtype == el.STARTFIX  % if the subject started a fixation`
        `...`
    `if evtype == el.ENDFIX  % if the subject finished a fixation`
        `...`                 

4. Print new entry to fixation file. If printing to a text file using a Window's Notepad application, you must add the \r escape before every intended escape character.

    `entry = strcat(num2str(k),'\r\t',num2str(fixationNum),...,num2str(reactiontime),'\r\n');`
    `fprintf(fixationFile, entry);`

5. Close the fixation log file during cleanup.

    `fclose(fixationFile);`