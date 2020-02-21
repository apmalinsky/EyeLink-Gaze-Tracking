% Author: Dr. Katherine Moore, Andy Malinsky

Screen('FillRect',window, bgcolor);
Screen('DrawText',window,'+',centerx,centery,[255 255 255]);
Screen('Flip',window);
WaitSecs(1);


%%% location will be determined randomly with the restriction that the
%%% target is not next to another distractor; two distractors can be next
%%% to each other
%%% also make sure no two filler colors are adjacent?

loclist = randperm(arraysize); % all possible locations
no8list = [2 3 4 5 6]; % all possible locations if target is in #8
no8list = Shuffle(no8list);
no1list = [3 4 5 6 7]; % all possible locations if target is in #1
no1list = Shuffle(no1list);
orient_list = [1 1 1 1 2 2 2 2];
orient_list = Shuffle(orient_list);

% initialize zones for each shape, zones 1 through 8
zones = java.util.HashMap;
for i=1:8
    zones.put(i, locations{i});
end

for i=1:zones.size()
    currentZone = zones.get(i);
    xPos = currentZone(2);
    yPos = currentZone(1);
    
%     baseRect = [0 0 detectionRadius detectionRadius];
%     centeredRect = CenterRectOnPointd(baseRect, xPos, yPos);
%     maxDiameter = max(baseRect) * 1.01;
%     rectColor = [255 255 255];
%     Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
end

% reset the locations at the start of each trial
targloc = 0;
dist1loc = 0;
dist2loc = 0;
dist3loc = 0;

% assign the target color and orientation
if mastertrials{k,3} == 11
    targcolor = target1;
    targleftright = 1;
    corresp = 'j';
elseif mastertrials{k,3} == 12
    targcolor = target1;
    targleftright = 2;
    corresp = 'k';
elseif mastertrials{k,3} == 21
    targcolor = target2;
    targleftright = 1;
    corresp = 'j';
elseif mastertrials{k,3} == 22
    targcolor = target2;
    targleftright = 2;
    corresp = 'k';
else % no target on this trial
    corresp = 'f';
end

% assign the dist1 color and orientation
if mastertrials{k,4} == 11
    dist1color = target1;
    dist1leftright = 1;
elseif mastertrials{k,4} == 12
    dist1color = target1;
    dist1leftright = 2;
elseif mastertrials{k,4} == 21
    dist1color = target2;
    dist1leftright = 1;
elseif mastertrials{k,4} == 22
    dist1color = target2;
    dist1leftright = 2;
end

% assign the dist2 color and orientation
if mastertrials{k,5} == 11
    dist2color = target1;
    dist2leftright = 1;
elseif mastertrials{k,5} == 12
    dist2color = target1;
    dist2leftright = 2;
elseif mastertrials{k,5} == 21
    dist2color = target2;
    dist2leftright = 1;
elseif mastertrials{k,5} == 22
    dist2color = target2;
    dist2leftright = 2;
end

% assign the dist3 color and orientation
if mastertrials{k,6} == 11
    dist3color = target1;
    dist3leftright = 1;
elseif mastertrials{k,6} == 12
    dist3color = target1;
    dist3leftright = 2;
elseif mastertrials{k,6} == 21
    dist3color = target2;
    dist3leftright = 1;
elseif mastertrials{k,6} == 22
    dist3color = target2;
    dist3leftright = 2;
end

if mastertrials{k,3} > 0 % if there is a target on this trial
    targloc = loclist(1);
    Shuffle(loclist); % give it a location
    mastertrials{k,8} = targloc;
end

if mastertrials{k,4} > 0 % if there is a first distractor on this trial
    if targloc == 1
        no1list = Shuffle(no1list);
        dist1loc = no1list(1);
    elseif targloc == 8
        no8list = Shuffle(no8list);
        dist1loc = no8list(1);
    else
        dist1loc = targloc;
        while (((targloc - 1) <= dist1loc) && ((targloc+1) >= dist1loc))
            loclist = Shuffle(loclist);
            dist1loc = loclist(1);
        end
    end
    mastertrials{k,9} = dist1loc;
end

if mastertrials{k,5} > 0 % if there is a second distractor on this trial
    if targloc == 1
        no1list = Shuffle(no1list);
        dist2loc = no1list(1);
        while dist2loc == dist1loc % as long as you accidentally chose the same location for dists1 and 2, keep looking for dist2
        no1list = Shuffle(no1list);
        dist2loc = no1list(1);
        end
        
    elseif targloc == 8
        no8list = Shuffle(no8list);
        dist1loc = no8list(1);
        while dist2loc == dist1loc % as long as you accidentally chose the same location for dists1 and 2, keep looking for dist2
        no8list = Shuffle(no8list);
        dist2loc = no8list(1);
        end
        
    else
        dist2loc = targloc;
        while (((targloc - 1) <= dist2loc) && ((targloc+1) >= dist2loc))
            loclist = Shuffle(loclist);
            dist2loc = loclist(1);
            while dist1loc == dist2loc
            loclist = Shuffle(loclist);
            dist2loc = loclist(1);
            end
        end
    end
    mastertrials{k,10} = dist2loc;
end


if mastertrials{k,6} > 0 % if there is a third distractor on this trial
    if targloc == 1
        no1list = Shuffle(no1list);
        dist3loc = no1list(1);
        while dist3loc == dist1loc % as long as you accidentally chose the same location for dists1 and 2, keep looking for dist2
            no1list = Shuffle(no1list);
            dist3loc = no1list(1);
            while dist3loc == dist2loc % as long as you accidentally chose the same location for dists1 and 2, keep looking for dist2
                no1list = Shuffle(no1list);
                dist3loc = no1list(1);
            end
        end
        
    elseif targloc == 8
        no8list = Shuffle(no8list);
        dist1loc = no8list(1);
        while dist2loc == dist1loc % as long as you accidentally chose the same location for dists1 and 2, keep looking for dist2
            no8list = Shuffle(no81list);
            dist2loc = no8list(1);
            while dist3loc == dist2loc % as long as you accidentally chose the same location for dists1 and 2, keep looking for dist2
                no8list = Shuffle(no8list);
                dist3loc = no8list(1);
            end
        end
        
    else
        dist3loc = targloc;
        while (((targloc - 1) <= dist3loc) && ((targloc+1) >= dist3loc))
            loclist = Shuffle(loclist);
            dist3loc = loclist(1);
            while dist3loc == dist2loc
                loclist = Shuffle(loclist);
                dist3loc = loclist(1);
                while dist3loc == dist1loc
                    loclist = Shuffle(loclist);
                    dist3loc = loclist(1);
                end
            end
        end
    end
    mastertrials{k,11} = dist3loc;
end

fillercolors = mastertrials{k,7};

mastertrials{k,8} = targloc;
mastertrials{k,9} = dist1loc;
mastertrials{k,10} = dist2loc;
mastertrials{k,11} = dist3loc;

% first, draw the whole thing with fillers
for i=1:8
    if i == targloc
        leftright = targleftright;
    elseif i == dist1loc
        leftright = dist1leftright;
    elseif i == dist2loc
        leftright = dist2leftright;
    elseif i == dist3loc
        leftright = dist3leftright;
    else
        leftright = ceil(rand*2);
    end
   
    offsetshift = ceil(rand*2); % randomly choose number 1 or 2

    if leftright == 1 % if the T/L is facing to the left
        if i==targloc
            littlerect_horiz = [locations{i}(2)-(length/2) locations{i}(1)-(width/2) locations{i}(2)+(length/2) locations{i}(1)+(width/2)];
        else
            if offsetshift == 1 % if we're shifting down
                littlerect_horiz = [locations{i}(2)-(length/2) locations{i}(1)-width/2+Loffset locations{i}(2)+length/2 locations{i}(1)+(width/2+Loffset)];
            else % if we're shifting up
                littlerect_horiz = [locations{i}(2)-(length/2) locations{i}(1)-width/2-Loffset locations{i}(2)+length/2 locations{i}(1)+(width/2-Loffset)];
            end
        end
        % no matter what, we're drawing a verticle line that is all of
        % the way on the L
        littlerect_vert = [locations{i}(2)-(length/2) locations{i}(1)-length/2 locations{i}(2)-length/2+width locations{i}(1)+(length/2)];
        
    else % the T/L is facing to the right now
        if i==targloc
            littlerect_horiz = [locations{i}(2)-(length/2) locations{i}(1)-(width/2) locations{i}(2)+(length/2) locations{i}(1)+(width/2)];
        else
            if offsetshift == 1 % if we're shifting down
                littlerect_horiz = [locations{i}(2)-(length/2) locations{i}(1)-width/2+Loffset locations{i}(2)+length/2 locations{i}(1)+(width/2+Loffset)];
            else % if we're shifting up
                littlerect_horiz = [locations{i}(2)-(length/2) locations{i}(1)-width/2-Loffset locations{i}(2)+length/2 locations{i}(1)+(width/2-Loffset)];
            end
        end
        % no matter what, we're drawing a verticle line that is all of
        % the way on the R
        littlerect_vert = [locations{i}(2)+((length/2)-width) locations{i}(1)-length/2 locations{i}(2)+length/2 locations{i}(1)+(length/2)];
    end

    if i == targloc % if we're at the location for the target in the circle
        fillcolor = targcolor; % choose a target color
        mastertrials{k,7}{i} = targcolor;
    elseif i == dist1loc % distractor location
        fillcolor = dist1color;
        mastertrials{k,7}{i} = dist1color;
    elseif i == dist2loc
        fillcolor = dist2color;
        mastertrials{k,7}{i} = dist2color;
    elseif i == dist3loc
        fillcolor = dist3color;
        mastertrials{k,7}{i} = dist3color;
    else
        fillcolor = mastertrials{k,7}{i};
    end
    
    % now draw the two segments of the T/L in the selected color
    
    Screen('DrawText',window,'+',centerx,centery,[255 255 255]);
    Screen('FillRect',window, fillcolor, littlerect_horiz);
    Screen('FillRect',window, fillcolor, littlerect_vert);
end





Screen('TextFont',window,'Batang');

Screen('Flip',window);


