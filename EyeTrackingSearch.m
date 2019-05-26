% EyelinkToolbox Implementation Author: Andy Malinsky

clear all;
fclose('all');

prompt1=('Subject Number:');
subjectNum = inputdlg(prompt1);
inputfilename=strcat('S',subjectNum,'varfile');
edfFile=strcat('S',subjectNum,'.edf'); %name of remote data file to create
edfFile_1 = edfFile{1};
fixFileName = strcat('S',subjectNum,'fixations.txt'); % name of remote fixation file to create
fixationFile = fopen(fixFileName{1},'w'); % create fixation file for writing

% some parameters
bgcolor = [0 0 0]; % background color is black
textcolor = [255 255 255];
target1 = [239 90 0];
target2 = [0 159 247];
fillercolors = {[214 214 0] [48 166 0] [135 98 255] [250 59 184]}; % these are rgb values for the filler colors
length = 60; % length of the bars on the L/T
width = 15; % thickness of the bars
Loffset = 10; % where the vertical bar intersects
radius = 400; % the radius of the octagon
diagonal_val = radius*.7067;
arraysize = 8;
detectionRadius = length + (0.9 * length);   % radius of circle around each shape for fixation detection

target1 = [239 90 0];
target2 = [0 159 247];
fillercolors = {[214 214 0] [48 166 0] [135 98 255] [250 59 184]}; % these are rgb values for the filler colors

% prompt1=('Subject Number');
% subjectNum = inputdlg(prompt1);
rect = [500];
Screen('Preference', 'SkipSyncTests', 1);
window = Screen(0,'OpenWindow', rect); %% error here, I don't know how to debug it
res = Screen('Resolution',window);
Screen('TextSize',window,40);

% Hide the mouse cursor;
Screen('HideCursorHelper', window);

centerx = res.width/2;
centery = res.height/2;

% locations 
loc1 = [centery-radius centerx];
loc2 = [centery-diagonal_val centerx+diagonal_val];
loc3 = [centery centerx+radius];
loc4 = [centery+diagonal_val centerx+diagonal_val];
loc5 = [centery+radius centerx];
loc6 = [centery+diagonal_val centerx-diagonal_val];
loc7 = [centery centerx-radius];
loc8 = [centery-diagonal_val centerx-diagonal_val];
locations = {loc1 loc2 loc3 loc4 loc5 loc6 loc7 loc8};

loclist = randperm(8);
targloc = loclist(1);
distloc = loclist(2);
orient_list = [1 1 1 1 2 2 2 2];
orient_list = Shuffle(orient_list);

Screen('FillRect',window, bgcolor);

EyeTrackingInstructions;
% EyeTrackingSearch_practice;

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

Screen('Flip',window);
FlushEvents('keydown');
WaitSecs(.5);
KbStrokeWait;

numtrials = 10;
matrix_setup;

doDisplay=1; %use ptb
createFile=1; %record eyetracking data on the remote (eyetracking) computer and suck over the file when done
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
if doDisplay
    el=EyelinkInitDefaults(window);
else
    el=EyelinkInitDefaults();
end

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if (Eyelink('initialize') ~= 0)
    error('could not init connection to Eyelink')
    return;
end;  

% make sure that we get gaze data from the Eyelink
status=Eyelink('command','link_sample_data = LEFT,RIGHT,FIXATION,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT');
if status~=0
    error('link_sample_data error, status: ',status)
end

% open file to record data to (just an example, not required)
if createFile
    status=Eyelink('openfile',edfFile_1);
    if status~=0
        error('openfile error, status: ',status)
    end
end

% KbName('UnifyKeyNames') %enables cross-platform key id's
% 
% EyelinkDoTrackerSetup(el); % Calibrate the eye tracker
% EyelinkDoDriftCorrection(el); % Do a final check of calibration using driftcorrection

WaitSecs(0.1);

% start recording eye position
status=Eyelink('StartRecording');
if status~=0
    error('startrecording error, status: ',status)
end
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR % if both eyes are tracked
    eye_used = el.RIGHT_EYE; % use left eye
end

% record a few samples before we actually start displaying
WaitSecs(0.1);

% mark zero-plot time in data file
status=Eyelink('message','SYNCTIME');
if status~=0
    error('message error, status: ',status)
end

stopKey=KbName('q');
nextKey=KbName('space');
eye_used = -1; %just an initializer to remind us to ask tracker which eye is tracked
queueCounter = 0; % initialize counter for queue maintenance

n = 1;
for k=1:numtrials
    if k==n*22 %for breaks
        n=n+1; %set for next break
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
        
        Screen('Flip',window);
        FlushEvents('keydown');
        WaitSecs(.5);
        KbStrokeWait;
        
        Screen('FillRect',window,bgcolor);
        Screen('Flip',window);
        WaitSecs(1);
    end
    
    trial_setup;
    
    starttime=GetSecs; % start time for checking on this trial
    timeTracker=GetSecs; %used to space out the frames while still checking for a response
    currenttime = starttime+2; % this is just for initializing purposes -- make this number higher than the starttime
    FlushEvents('keydown'); % get rid of extraneous keypresses that happened during filler or pre-target trial (e.g. responding to distractor)
    keepchecking = 1; % start this variable off as yes, we want to check for a response
    secs = 0; % just for initializing purposes
    reactiontime = 99; % this is the value that is inputted if the person never responds 
    fixationNum = 0; % initialize fixation counter per trial
    
    % initialize variables
    targetZone = 0; 
    breakFlag = 0;
    nextTrial = false;
    fixationZone = 0;
    
    while ~nextTrial % loop until error or until nextTrial update
        updateTrial = false; % initialize condition for moving to next trial
        
        % Check recording status, stop display if error
        err=Eyelink('CheckRecording');
        if(err~=0)
            error('checkrecording problem, status: ',err)
            break;
        end

        % check for presence of a new sample update
        status = Eyelink('NewfloatSampleAvailable');
        eyeFound = false;
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
                    % if data is invalid (e.g. during a blink), clear display
                    if doDisplay
                        Screen('FillRect', window, [0 0 0]);
                    end
                    % disp('blink! (x or y is missing or pupil size<=0)')
                end
                
                if eyeFound
                    queueCounter = queueCounter + 1;
                    
                    if mastertrials{k,8} ~= 0   % if there is a target location
                        if queueCounter >= 100
                            evtdata = Eyelink('GetQueuedData'); % remove items from queue to avoid LOSTDATAEVENT
                            queueCounter = 0; % reset counter
                        end
                        
                        evtype = Eyelink('GetNextDataType');
                        
                        if evtype == el.STARTFIX  % if the subject starts a fixation
                            currenttime=secs;
                            reactiontime=currenttime-starttime; % calculate reactiontime;

                            for z=1:zones.size()    % for each zone location, compare the distance from the zone to gaze position
                                currentZone = zones.get(z);
                                xZ = currentZone(2);
                                yZ = currentZone(1);      
                                dSquared = (xPos-xZ)^2 + (yPos-yZ)^2;   % calculate distance squared, (distance formula)

                                if dSquared <= (detectionRadius^2)  % if distance value is within the detection radius                                    
                                    fixationZone = z;
                                end
                            end
                        end
                        
                        if evtype == el.ENDFIX  % if the subject finished a fixation
                            targetZone = zones.get(mastertrials{k,8});  % get target zone location x and y
                            distractorZone1 = mastertrials{k,9}; % get distractor 1 location
                            distractorZone2 = mastertrials{k,10}; % get distractor 2 location
                            distractorZone3 = mastertrials{k,11}; % get distractor 3 location
                            distractorNum = 0;
                            % Distactor Num Values:
                            % 0: Not Distractor Fixation
                            % 1: Same Color as target in trial
                            % 2: Different Color as target in trial
                            
                            xPos = int16(x);    % convert into calculatable integers
                            yPos = int16(y);

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
                                    
                                    targetColor = mastertrials{k,3};
                                    distractorColor = 0;
                                    
                                    if distractorZone1 ~= 0 && z == distractorZone1  % if fixation on distractor 1
                                        distractorColor = mastertrials{k,4};
                                    elseif distractorZone2 ~= 0 && z == distractorZone2  % if fixation on distractor 2
                                        distractorColor = mastertrials{k,5};
                                    elseif distractorZone3 ~= 0 && z == distractorZone3  % if fixation on distractor 3
                                        distractorColor = mastertrials{k,6};
                                    end
                                    
                                    if distractorColor ~= 0
                                        targetR = mod(targetColor, 10); % get remainder (second digit)
                                        targetColorTag = (targetColor - targetR)/10; % equals 1 or 2, (gets first digit)
                                        
                                        distractorR = mod(distractorColor, 10); % get remainder (second digit)
                                        distractorColorTag = (distractorColor - distractorR)/10; % equals 1 or 2, (gets first digit)
                                        
                                        if targetColorTag == distractorColorTag
                                            distractorNum = 1;
                                        else
                                            distractorNum = 2;
                                        end    
                                    end    
        
                                    fixationNum = fixationNum + 1;  % update fixation counter
                                    
                                    % print new entry to fixation file
                                    entry = strcat(num2str(k),'\r\t',num2str(fixationNum),'\r\t','(',num2str(xPos),',',num2str(yPos),')','\r\t',num2str(z),'\r\t',num2str(distractorNum),'\r\t',num2str(reactiontime),'\r\n');
                                    fprintf(fixationFile, entry);    
                                end
                            end    
                       
                            if updateTrial
                                nextTrial = true;
                            end
                        end
                    else
                        targetZone = 0; % no target shape to fixate on
                    end    
                end
            else % if we don't, first find eye that's being tracked
                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                switch eye_used
                    case el.BINOCULAR
                        disp('tracker indicates binocular, we''ll use right')
                        eye_used = el.RIGHT_EYE;
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
%          else
%              fprintf('no sample available, status: %d\n',status)
         end % if sample available
        
        % check for keyboard press
        [keyIsDown,secs,keyCode] = KbCheck;
        % if stopKey was pressed stop display
        if keyIsDown == 1
            if keyCode(stopKey)
                % finish up: stop recording eye-movements,
                % close graphics window, close data file and shut down tracker
                cleanup(createFile, edfFile_1, fixationFile);
                breakFlag = 1;
                break;
            elseif keyCode(nextKey) % if space bar is pressed
                if targetZone == 0
                    mastertrials{k,14} = 1;
                else
                    mastertrials{k,14} = 0;
                end
                
                currenttime=secs;
                reactiontime=currenttime-starttime; % calculate reactiontime;
                mastertrials{k,15} = reactiontime;
                save(inputfilename{1}, 'subjectNum', 'mastertrials');
                nextTrial = true;
            end
        end
    end
        if breakFlag == 1   % if q is pressed break out of main loop
            break;
        end
end % main loop

cleanup(createFile, edfFile_1, fixationFile);   % call cleanup function
Screen('DrawText',window,'The experiment has finished.',50,100,textcolor);
Screen('DrawText',window,'Please get the researcher to be debriefed.',50,150,textcolor);
Screen('TextFont',window,'Batang');

Screen('Flip',window);
WaitSecs(1);
KbStrokeWait;

fclose('all');
Screen('CloseAll');

% ends and closes all  processes
function cleanup(createFile, edfFile_1, fixationFile)
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
%         if 2==exist(fixationFile, 'file') % error: The first input to exist must be a character vector.
%             fprintf('Fixation file ''%s'' can be found in ''%s''\n', fixationFile, pwd );
%         else
%             disp('unknown where fixation file went')
%         end
    end
    
    fclose(fixationFile);
    Eyelink('Shutdown');
end
