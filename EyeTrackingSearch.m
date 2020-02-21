% Author: Andy Malinsky

function EyeTrackingSearch

% To edit toolbox find files in:
% C:\toolbox\Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkBasic
% Edited EyelinkInitDefaults. Line 60, changed to: 
% el.backgroundcolour = BlackIndex(el.window);
% This makes the background black during tracker setup,
% as this mitigated some calibration issues we experienced.

% Some default setups
PsychDefaultSetup(1);
Screen('Preference', 'SkipSyncTests', 1);
clear all;
fclose('all');

% User inputs the subject number
prompt1 = ('Subject Number:');
subjectNum = inputdlg(prompt1);

% Output to table file
tableFile = strcat('tables/', 'S', subjectNum, 'table.mat'); % Create file name
headers = {'TrialNum' 'FixationNum' 'Position' 'ZoneNum' 'DistractorNum' 'ReactionTime'};   % Specifiy headers for table
data = cell(100, 6);    % Create a matrix with 100 rows and 6 columns
T = cell2table(data);   % Create table
T.Properties.VariableNames = headers;   % Assign the headers as the columns

% Create extra data file (optional)
inputfilename = strcat('S',subjectNum,'varfile');
edfFile = strcat('S',subjectNum,'.edf'); % name of remote data file to create
edfFile_1 = edfFile{1};

% some parameters
bgcolor = [0 0 0];  % background color is black
textcolor = [255 255 255];  % text color is white
target1 = [239 90 0];   % orange
target2 = [0 159 247];  % blue
fillercolors = {[214 214 0] [48 166 0] [135 98 255] [250 59 184]};  % these are rgb values for the filler colors
length = 60;    % length of the bars on the L/T
width = 15;     % thickness of the bars
Loffset = 10;   % where the vertical bar intersects
radius = 400;   % the radius of the octagon
diagonal_val = radius*.7067;
arraysize = 8;
detectionRadius = length + (1.25 * length); % radius of circle around each shape for fixation detection

% Default eye tracking setups
createFile = 1; % record eyetracking data on the remote (eyetracking) computer and suck over the file when done
dummymode=0;    % set to 1 to initialize in dummymode

% Open a graphics window on the main screen
% using the PsychToolbox's Screen function.
screenNumber = max(Screen('Screens'));
window = Screen('OpenWindow', screenNumber);

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el = EyelinkInitDefaults(window);

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
    cleanup;    % cleanup function
    return;
end

% Print tracker version just for some info
[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% Make sure that we get gaze data from the Eyelink
Eyelink('Command','link_sample_data = LEFT,RIGHT,GAZE,AREA');

% Open file to record data to (just an example, not required)
Eyelink('Openfile',edfFile_1);

EyelinkDoTrackerSetup(el);      % Calibrate the eye tracker
EyelinkDoDriftCorrection(el);   % Do a final check of calibration using driftcorrection

% Hide the mouse cursor;
Screen('HideCursorHelper', window);

% Set screen variables
res = Screen('Resolution',window);
Screen('TextSize',window,40);
centerx = res.width/2;
centery = res.height/2;

% Locations of shapes 
loc1 = [centery-radius centerx];
loc2 = [centery-diagonal_val centerx+diagonal_val];
loc3 = [centery centerx+radius];
loc4 = [centery+diagonal_val centerx+diagonal_val];
loc5 = [centery+radius centerx];
loc6 = [centery+diagonal_val centerx-diagonal_val];
loc7 = [centery centerx-radius];
loc8 = [centery-diagonal_val centerx-diagonal_val];
locations = {loc1 loc2 loc3 loc4 loc5 loc6 loc7 loc8};

Screen('FillRect',window, bgcolor); % fill the background

% EyeTrackingInstructions;
% EyeTrackingSearch_practice;

% Display some instructions
Screen('FillRect',window,bgcolor);
Screen('TextSize',window, 40);
Screen('DrawText',window,'Now the real experiment will start.', 10, 10,[255 255 255]);
Screen('DrawText',window,'Press space when you are ready to continue',10,75,[255 255 255]);
Screen('DrawText',window,'A reminder of your target colors:',10, 150,[255 255 255]);
% left
Screen('FillRect',window, target1, [250 300 250+length 300+width]);
Screen('FillRect',window, target1, [250 300-length/2+width/2 250+width 300+length/2+width/2]);
% right
Screen('FillRect',window, target1, [400 300 400+length 300+width]);
Screen('FillRect',window, target1, [400+length-width 300-length/2+width/2 400+length+width-width 300+length/2+width/2]);
% left
Screen('FillRect',window, target2, [250 400 250+length 400+width]);
Screen('FillRect',window, target2, [250 400-length/2+width/2 250+width 400+length/2+width/2]);
% right
Screen('FillRect',window, target2, [400 400 400+length 400+width]);
Screen('FillRect',window, target2, [400+length-width 400-length/2+width/2 400+length+width-width 400+length/2+width/2]);

% Refresh the screen
Screen('Flip',window);
FlushEvents('keydown');
WaitSecs(.5);
KbStrokeWait;

numtrials = 10; % set the number of trials
matrix_setup; % run the matrix_setup file

stopKey=KbName('q'); % this key quits the program
nextKey=KbName('space'); % this key goes to next trial
queueCounter = 0; % initialize counter for queue maintenance

% Start recording eye position
status=Eyelink('StartRecording');
if status~=0 % throw error if encountered
    error('startrecording error, status: ',status)
end

eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end

% Record a few samples before we actually start displaying
WaitSecs(0.1);

% Mark zero-plot time in data file
status=Eyelink('message','SYNCTIME');
if status~=0 % throw error if encountered
    error('message error, status: ',status)
end

entryCounter = 1; %initialize counter for table entries
n = 1; % initialize counter
for k=1:numtrials % loop for the amount of trials
    if k==n*22 % for breaks
        n=n+1; % set for next break
        
        % Display reminder instructions
        Screen('FillRect',window,bgcolor);
        Screen('TextSize',window, 40);
        Screen('DrawText',window,'Please take a short break.', 10, 10,[255 255 255]);
        Screen('DrawText',window,'Press space when you are ready to continue',10,75,[255 255 255]);
        Screen('DrawText',window,'A reminder of your target colors:',10, 150,[255 255 255]);
        % left
        Screen('FillRect',window, target1, [250 300 250+length 300+width]);
        Screen('FillRect',window, target1, [250 300-length/2+width/2 250+width 300+length/2+width/2]);
        % right
        Screen('FillRect',window, target1, [400 300 400+length 300+width]);
        Screen('FillRect',window, target1, [400+length-width 300-length/2+width/2 400+length+width-width 300+length/2+width/2]);
        % left
        Screen('FillRect',window, target2, [250 400 250+length 400+width]);
        Screen('FillRect',window, target2, [250 400-length/2+width/2 250+width 400+length/2+width/2]);
        % right
        Screen('FillRect',window, target2, [400 400 400+length 400+width]);
        Screen('FillRect',window, target2, [400+length-width 400-length/2+width/2 400+length+width-width 400+length/2+width/2]);

        % Refresh the screen
        Screen('Flip',window);
        FlushEvents('keydown');
        WaitSecs(.5);
        KbStrokeWait;
        Screen('FillRect',window,bgcolor);
        Screen('Flip',window);
        WaitSecs(1);
    end

    trial_setup; % run the trial_setup file

    % Initialize variables
    starttime=GetSecs; % start time for checking on this trial
    currenttime = starttime+2; % this is just for initializing purposes -- make this number higher than the starttime
    FlushEvents('keydown'); % get rid of extraneous keypresses that happened during filler or pre-target trial (e.g. responding to distractor)
    secs = 0;
    reactiontime = 99;  % this is the value that is inputted if the person never responds 
    fixationNum = 0;    % fixation counter per trial
    targetZone = 0;     % zone number containing the target
    breakFlag = 0;      % switches to 1 when the subject presses the stopKey
    nextTrial = false;  % switches to true when moving on to nextTrial
    fixationZone = 0;   % zone number subject fixates on
    fixationPeriod = 0.1; % amount of time in seconds to count as a fixation

    while ~nextTrial % loop until error or until nextTrial update
        updateTrial = false; % initialize condition for moving to next trial

        % Check recording status, stop display if error
        err=Eyelink('CheckRecording');
        if(err~=0) % throw error if encountered
            error('checkrecording problem, status: ',err)
            break;
        end

        % Check for presence of a new sample update
        status = Eyelink('NewfloatSampleAvailable');
        eyeFound = false; % initialize eyeFound variable
        if  status > 0
            % get the sample in the form of an event structure
            evt = Eyelink('NewestFloatSample');       

            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample
                x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                y = evt.gy(eye_used+1);

                % do we have valid data and is the pupil visible?
                if (x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0) 
                    eyeFound = true; % eye is found if no missing data
                else
                    Screen('FillRect', window, bgcolor); % make screen black if eye closed
                end

                if eyeFound % if an eye was found      
                    queueCounter = queueCounter + 1; % update the queue counter

                    if mastertrials{k,8} ~= 0   % if there is a target location
                        if queueCounter >= 100  % for every 100 eye tracking events
                            evtdata = Eyelink('GetQueuedData'); % remove items from queue to avoid a LOSTDATAEVENT
                            queueCounter = 0;   % reset counter
                        end

                        evtype = Eyelink('GetNextDataType'); % get the type of eye tracking event

                        if evtype == el.STARTFIX    % if the subject starts a fixation
                            currenttime = secs;     % record the current time
                            reactiontime = currenttime - starttime; % calculate reactiontime;

                            for z=1:zones.size() % for each zone location, compare the distance from the zone to gaze position
                                currentZone = zones.get(z); % save the current zone in the loop to variable
                                xZ = currentZone(2);    % get x coordinate of current zone
                                yZ = currentZone(1);    % get y coordinate of current zone
                                xPos = int16(x);        % convert into calculatable integer
                                yPos = int16(y);        % convert into calculatable integer
                                dSquared = (xPos-xZ)^2 + (yPos-yZ)^2;   % calculate distance squared, (distance formula)

                                if dSquared <= (detectionRadius^2)  % if distance value is within the detection radius                                    
                                    fixationZone = z;   % record the zone number subject is starting fixatation on
                                    WaitSecs(fixationPeriod); % wait for a period of time that is necessary to count as a fixation
                                end
                            end
                        end

                        if evtype == el.ENDFIX  % if the subject finished a fixation
                            targetZone = zones.get(mastertrials{k,8});  % get target zone location x and y
                            distractorZone1 = mastertrials{k,9};        % get distractor 1 location
                            distractorZone2 = mastertrials{k,10};       % get distractor 2 location
                            distractorZone3 = mastertrials{k,11};       % get distractor 3 location
                            distractorNum = 0;
                            % Distactor Num Values:
                            % 0: Not Distractor Fixation
                            % 1: Same Color as target in trial
                            % 2: Different Color as target in trial

                            xPos = int16(x);    % convert into calculatable integer
                            yPos = int16(y);    % convert into calculatable integer

                            for z=1:zones.size()    % for each zone location, compare the distance from the zone to gaze position
                                currentZone = zones.get(z);
                                xZ = currentZone(2);
                                yZ = currentZone(1);      
                                dSquared = (xPos-xZ)^2 + (yPos-yZ)^2;   % calculate distance squared, (distance formula)

                                if dSquared <= (detectionRadius^2) && z == fixationZone  % if distance value is within the detection radius                                    
                                    if currentZone == targetZone  % if fixation on target, update trial
                                        updateTrial = true; 
                                        mastertrials{k,15} = reactiontime;
                                    end    

                                    targetColor = mastertrials{k,3}; % get color of target
                                    distractorColor = 0; % initialize variable
                                    
                                    % if distractor exists, set the color value to the distractorColor variable
                                    if distractorZone1 ~= 0 && z == distractorZone1  % if fixation on distractor 1
                                        distractorColor = mastertrials{k,4};
                                    elseif distractorZone2 ~= 0 && z == distractorZone2  % if fixation on distractor 2
                                        distractorColor = mastertrials{k,5};
                                    elseif distractorZone3 ~= 0 && z == distractorZone3  % if fixation on distractor 3
                                        distractorColor = mastertrials{k,6};
                                    end

                                    if distractorColor ~= 0 % if there is a distractor
                                        targetR = mod(targetColor, 10); % get second digit
                                        targetColorTag = (targetColor - targetR)/10; % equals 1 or 2, (gets first digit)

                                        distractorR = mod(distractorColor, 10); % get second digit
                                        distractorColorTag = (distractorColor - distractorR)/10; % equals 1 or 2, (gets first digit)

                                        if targetColorTag == distractorColorTag % if fixated on target
                                            distractorNum = 1;
                                        else % if fixated on distractor
                                            distractorNum = 2;
                                        end    
                                    end    

                                    fixationNum = fixationNum + 1;  % update fixation counter

                                    % create and add a new entry to our subject's table
                                    tableEntry = {k, fixationNum, strcat('(',num2str(xPos),',',num2str(yPos),')'), z, distractorNum, reactiontime};
                                    for c = 1:6
                                       T{entryCounter,c} = tableEntry(c);
                                    end

                                    entryCounter = entryCounter + 1;  % update entry counter
                                end
                            end    

                            if updateTrial % move to next trial if ready to update
                                nextTrial = true;
                            end
                        end
                    else
                        targetZone = 0; % no target shape to fixate on
                    end    
                end
            else % if we don't know, find eye that's being tracked
                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                switch eye_used
                    case el.BINOCULAR % if tracking both eyes, track the left eye
                        disp('tracker indicates binocular, we''ll use left')
                        eye_used = el.LEFT_EYE;
                    case el.LEFT_EYE
                        disp('tracker indicates left eye')
                    case el.RIGHT_EYE
                        disp('tracker indicates right eye')
                    case -1
                        error('eyeavailable returned -1')
                    otherwise
                        error('uninterpretable result from eyeavailable: ',eye_used)
                end
            end
        end % if sample available

        % check for keyboard press
        [keyIsDown,secs,keyCode] = KbCheck;
        
        if keyIsDown == 1 % if a key was pressed
            if keyCode(stopKey) % if stopKey was pressed stop display
                % finish up: stop recording eye-movements,
                % close graphics window, close data file and shut down tracker
                cleanup(createFile, edfFile_1, tableFile, T); % call the cleanup function
                breakFlag = 1; % let us know to break out of the trial loop
                break;
            elseif keyCode(nextKey) % if space bar is pressed
                if targetZone == 0 % if there was no target, subject was correct
                    mastertrials{k,14} = 1;
                else
                    mastertrials{k,14} = 0;
                end

                currenttime = secs;
                reactiontime = currenttime - starttime; % calculate reactiontime;
                mastertrials{k,15} = reactiontime;
                save(inputfilename{1}, 'subjectNum', 'mastertrials');
                nextTrial = true;
            end
        end
    end

    if breakFlag == 1   % if q is pressed break out of main loop
        break;
    end        
end % main for loop

% Call cleanup function and display end of experiment notifications
cleanup(createFile, edfFile_1, tableFile, T);   
Screen('DrawText',window,'The experiment has finished.',50,100,textcolor);
Screen('DrawText',window,'Please get the researcher to be debriefed.',50,150,textcolor);
Screen('TextFont',window,'Batang');
Screen('Flip',window);
WaitSecs(1);
KbStrokeWait;
fclose('all');
Screen('CloseAll');

end

% Ends and closes all processes
function cleanup(createFile, edfFile_1, tableFile, T)
    Eyelink('StopRecording');
    ShowCursor;

    if createFile
        status=Eyelink('CloseFile');
        if status ~=0
            fprintf('closefile error, status: %d\n',status)
        end
        status=Eyelink('ReceiveFile',edfFile_1,pwd,1);
        if status~=0
            fprintf('problem: ReceiveFile status: %d\n', status);
        end
        if 2==exist(edfFile_1, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile_1, pwd );
        else
            disp('unknown where data file went')
        end
        % print out location of tableFile
        fprintf('Fixation file ''%s'' can be found in ''%s''\n', tableFile{1}, pwd );
        save([tableFile{:}], 'T');  % save the tableFile
    end
    
    Eyelink('Shutdown');        % shutdown Eyelink
end
