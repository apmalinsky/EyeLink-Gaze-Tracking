% Author: Dr. Katherine Moore
% matrix_setup.m
%
% to be used with the eye tracking experiments

% cell matrix columns are: 
% subject(1), trial number (2), target type(3) targ1=11&12, targ2=21&22, target absent=0,
% distractor #1 (4) 0=target alone, 11&12=dist1, 21&22=dist2, distractor #2 (5)
% 0=target alone or single distractor, 11&12=dist1, 21&22=dist2, distractor #3 (6)
% 0=less than 3 dists, 11&12=dist1, 21&22=dist2, (7) filler list
% , target location (8), dist1 loc (9), dist2 loc (10), dist3 loc (11),
% hit (12), miss (13), CR (14), RT to target / end (15), condition (16)

% % %  - TA: 60 -- 1
% % %  - SC: 32 -- 2
% % %  - DC: 32 -- 3
% % %  - 2 distraction: 32 - div 4 A, B abA abB aaB bbA -- 4
% % %  - 3 distraction: 16 - aabB bbaA -- 5
% % %
% % %  - no targ: 16 -- 0
% % %  - DA: 16 -- 6
% % %  - two DA: -- 7

numberoftrials = 220;
mastertrials = cell(numberoftrials,16);

mastertrials(:,1) = {subjectNum};

random_trials = randperm(numberoftrials);

for i=1:numberoftrials
    mastertrials{i,2} = random_trials(i);
end

for i=1:60
    mastertrials{i,16} = 1;
end
for i=61:92
    mastertrials{i,16} = 2;
end
for i=93:124
    mastertrials{i,16} = 3;
end
for i=125:156
    mastertrials{i,16} = 4;
end
for i=157:172
    mastertrials{i,16} = 5;
end
for i=173:188
    mastertrials{i,16} = 0;
end
for i=189:204
    mastertrials{i,16} = 6;
end
for i=205:220
    mastertrials{i,16} = 7;
end


% build the matrix with the actual trial types desired
% column 3 -- target type
% target alone trials, 60
for i=1:15 % color 1
    mastertrials{i,3} = 11;
end
for i=16:30 % color 1
    mastertrials{i,3} = 12;
end
for i=31:45 % color 2
    mastertrials{i,3} = 21;
end
for i=46:60 % color 2
    mastertrials{i,3} = 22;
end

% SC trials, 32
for i=61:68 % STC
    mastertrials{i,3} = 11;
end
for i=69:76 
    mastertrials{i,3} = 12;
end
for i=76:84 
    mastertrials{i,3} = 21;
end
for i=85:92 
    mastertrials{i,3} = 22;
end

% DC trials, 32
for i=93:100 
    mastertrials{i,3} = 11;
end
for i=101:108 
    mastertrials{i,3} = 12;
end
for i=109:116 
    mastertrials{i,3} = 21;
end
for i=117:124 
    mastertrials{i,3} = 22;
end


% 2 distraction trials, 32
for i=125:132
    mastertrials{i,3} = 11;
end
for i=133:140
    mastertrials{i,3} = 12;
end
for i=141:148 
    mastertrials{i,3} = 21;
end
for i=149:156 
    mastertrials{i,3} = 22;
end

% 3 distraction trials, 32
for i=157:160
    mastertrials{i,3} = 11;
end
for i=161:164
    mastertrials{i,3} = 12;
end
for i=165:168 
    mastertrials{i,3} = 21;
end
for i=169:172 
    mastertrials{i,3} = 22;
end

% trials without targets
for i=173:numberoftrials
    mastertrials{i,3} = 0;
end


% column 4 -- first distractor
for i=1:60
    mastertrials{i,4} = 0; % null; no distractor
end

for i=61:92 %STC trials -- same distractor number as target number
    if (mastertrials{i,3} == 11) || (mastertrials{i,3} == 12)
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1);
    else
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1);
    end
end

for i=93:124 %DC trials 
    if (mastertrials{i,3} == 11) || (mastertrials{i,3} == 12)
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1);
    else
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1);
    end
end

for i=125:128 % 2 distractor trials abA
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end
for i=129:132 % 2 distractor trials bbA
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end   
for i=133:136 % 2 distractor trials abA
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end
for i=137:140 % 2 distractor trials bbA
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end 

for i=141:144 % 2 distractor trials abB
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end
for i=145:148 % 2 distractor trials aaB
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end   
for i=149:152 % 2 distractor trials abA
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end
for i=153:156 % 2 distractor trials bbA
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end  



% for i=157:164 % 3 distractor trials bbA
%         randlist = [11 12];
%         randlist = Shuffle(randlist);
%         mastertrials{i,4} = randlist(1); 
% end   
% for i=165:172 % 3 distractor trials bbA
%         randlist = [21 22];
%         randlist = Shuffle(randlist);
%         mastertrials{i,4} = randlist(1); 
% end  
for i=157:160
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end

for i=161:164
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end

for i=165:168
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end

for i=169:172
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,4} = randlist(1); 
end

for i=173:188
    mastertrials{i,4} = 0;
end

% distractor alone, 1 dist
for i=189:196
    randlist = [11 12];
    randlist = Shuffle(randlist);
    mastertrials{i,4} = randlist(1);
end
for i=197:204
    randlist = [21 22];
    randlist = Shuffle(randlist);
    mastertrials{i,4} = randlist(1);
end

% distractor alone, 2 dist
for i=205:212
    randlist = [11 12];
    randlist = Shuffle(randlist);
    mastertrials{i,4} = randlist(1);
end
for i=212:220
    randlist = [21 22];
    randlist = Shuffle(randlist);
    mastertrials{i,4} = randlist(1);
end


% second distractor
% column 5
for i=1:124
    mastertrials{i,5} = 0;
end

for i=125:140 % 2 distractor trials abA, aaB
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end

for i=141:156 % 2 distractor trials aaB
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end  



for i=157:160
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end

for i=161:164
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end

for i=165:168
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end

for i=169:172
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end


for i=173:204
    mastertrials{i,5} = 0;
end

for i=205:208
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end
for i=209:212
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end
for i=213:216
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end
for i=217:220
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,5} = randlist(1); 
end
   
% 3rd distractor
for i=1:156
    mastertrials{i,6} = 0;
end

for i=157:160
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,6} = randlist(1); 
end
for i=161:164
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,6} = randlist(1); 
end
for i=165:168
        randlist = [11 12];
        randlist = Shuffle(randlist);
        mastertrials{i,6} = randlist(1); 
end
for i=169:172
        randlist = [21 22];
        randlist = Shuffle(randlist);
        mastertrials{i,6} = randlist(1); 
end

for i=173:220
    mastertrials{i,6} = 0;
end

% column 7 -- filler list will be list of colors
for i=1:numberoftrials
    fillertrial = cell(1,arraysize);
    for j=1:arraysize
        if j == 1 % if this is the first item in the filler color array for this trial,
            fillercolors = Shuffle(fillercolors); % choose something and move on
            fillertrial{j} = fillercolors{1};
        elseif j < arraysize % if it's any other item than the last item
            % first try to choose something
            fillercolors = Shuffle(fillercolors);
            fillertrial{j} = fillercolors{1};
            % but then check to see if it's the same as what was chosen
            % previously
            if fillertrial{j} == fillertrial{j-1}
                fillertrial{j} = fillercolors{2}; % replace with a different one if needed
            end
        elseif j == arraysize
            % if it's the last item in the array, choose something
            fillercolors = Shuffle(fillercolors);
            fillertrial{j} = fillercolors{1};
            % but then check to see if it's the same as the first item in
            % the circle and the previous one
            if fillertrial{j} == fillertrial{j-1}
                fillertrial{j} = fillercolors{2}; % replace with a different one if needed
            end
            if fillertrial{j} == fillertrial{1}
                fillertrial{j} = fillercolors{3};
                if fillertrial{j} == fillertrial{1}
                    fillertrial{j} = fillercolors{4};
                end
            end
        end
    end
    mastertrials{i,7} = fillertrial;
end

% columns 9, 10, 11, 12 & 13
for i=1:numberoftrials
    mastertrials{i,8} = [];
    mastertrials{i,9} = []; % 
    mastertrials{i,10} = []; % 
    mastertrials{i,11} = []; % 
    mastertrials{i,12} = []; % 
    mastertrials{i,13} = []; % 
end

% now randomize the order of the trials in the matrix. 
% this sequence is repeatable with ss4 trials once that matrix is made.


temp_ss = mastertrials; % duplicate matrix
for i=1:numberoftrials % for all of the trials in the exp,
    thistrial = random_trials(i); % choose a random trial (without replacement)
    for j=1:16 % number of columns
        mastertrials{i,j} = temp_ss{thistrial,j}; % reassign the trial matrix with the random trial number
        mastertrials{i,2} = i; % but be sure to assign the trial number to the new number we are working on
    end
end
