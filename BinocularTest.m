% Author: Andy Malinsky

function BinocularTest

%Program using binocular tracking
%Allows switching tracked eye for gaze dependent position
%Left eye is default, close eye to switch

PsychDefaultSetup(1);
Screen('Preference', 'SkipSyncTests', 1);

% Open a graphics window on the main screen
screenNumber = max(Screen('Screens'));
window=Screen('OpenWindow', screenNumber);

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(window);

% Disable key output to Matlab window:
ListenChar(2);
dummymode=0; % set to 1 to initialize in dummymode

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end

% Just print some extra info
[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% Open file to record data to here if needed


% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);
EyelinkDoDriftCorrection(el);

% Start recording eye position
Eyelink('StartRecording');

% Record a few samples before we actually start displaying
WaitSecs(0.1); 

% Mark zero-plot time in data file
Eyelink('Message', 'SYNCTIME');

% Set some variables
stopkey = KbName('space');
eye_used = -1;
[width, height]=Screen('WindowSize', el.window);
message='';

% Set initial background to show on screen
Screen('FillRect', el.window, el.backgroundcolour);
Screen('Flip',  el.window, [], 1);

% Show gaze-dependent display
while 1 % loop till error or space bar is pressed
    % check recording status, stop display if error
    error=Eyelink('CheckRecording');
    if(error~=0)
        break;
    end
   
    [keyIsDown, secs, keyCode] = KbCheck;  % check for keyboard press
    if keyCode(stopkey) % if spacebar was pressed stop display
        break;
    end
    
    % check for presence of a new sample update
    if Eyelink( 'NewFloatSampleAvailable') > 0
        % get the sample in the form of an event structure
        evt = Eyelink( 'NewestFloatSample');

        if eye_used ~= -1 % do we know which eye to use yet?
            % if we do, get current gaze position from sample
            x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
            y = evt.gy(eye_used+1); 
            
            % do we have valid data and is the pupil visible?
            if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                % if data is valid, do something here
                % for example, checking the gaze position
                % and seeing if in a particular zone

            else
                % if data is invalid (e.g. during a blink), clear display
                Screen('FillRect', window, el.backgroundcolour);
                Screen('DrawText', window, message, 200, height-el.msgfontsize-20, el.msgfontcolour);
                Screen('Flip',  el.window, [], 1); % don't erase

                % here is where the tracked eye gets switched
                switch eye_used
                    case el.LEFT_EYE 
                        eye_used = el.RIGHT_EYE;
                        rightEye; % call the rightEye function
                    case el.RIGHT_EYE
                        eye_used = el.LEFT_EYE;
                        leftEye; % call the leftEye function
                end
            end
        else % if we don't, first find eye that's being tracked
            eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
            
            % default to left if both eyes are open 
            if eye_used == el.BINOCULAR
                eye_used = el.LEFT_EYE;
            end
        end            
    end % if sample available
end % main loop

WaitSecs(0.1); % wait a while to record a few more samples
cleanup; % call cleanup routine tp shut down program


% if tracking left eye do this
function leftEye
    % Now it just sets the brackground color and displays text
    % You can replace this with whatever you need
    
    Screen('FillRect', el.window, [100 100 100]);
    Screen('TextFont', el.window, el.msgfont);
    Screen('TextSize', el.window, el.msgfontsize);
    message='Tracking left eye';
    Screen('DrawText', el.window, message, 200, height-el.msgfontsize-20, el.msgfontcolour);
    Screen('Flip',  el.window, [], 1);
end

% if tracking right eye do this
function rightEye
    % Now it just sets the brackground color and displays text
    % You can replace this with whatever you need
    
    Screen('FillRect', el.window, el.backgroundcolour);
    Screen('TextFont', el.window, el.msgfont);
    Screen('TextSize', el.window, el.msgfontsize);
    message='Tracking right eye';
    Screen('DrawText', el.window, message, 200, height-el.msgfontsize-20, el.msgfontcolour);
    Screen('Flip',  el.window, [], 1);
end


% Cleanup routine:
function cleanup
    Eyelink('StopRecording'); % stop recording eye movements
    Eyelink('Shutdown'); % shutdown Eyelink:
    sca; % close window:
    % download data file here if needed

end

end
