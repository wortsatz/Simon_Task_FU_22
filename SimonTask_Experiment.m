%    __________  _______  _  __  _________   ______ __
%   / __/  _/  |/  / __ \/ |/ / /_  __/ _ | / __/ //_/
%  _\ \_/ // /|_/ / /_/ /    /   / / / __ |_\ \/ ,<   
% /___/___/_/  /_/\____/_/|_/   /_/ /_/ |_/___/_/|_|  
%
        
%
%% ======================== GETTING STARTED ===============================

% Clear the workspace
close all;
clear all;
sca;

% Prevent Screen Issues with PTB
Screen('Preference', 'SkipSyncTests', 1)

%% ================= BASIC EXPERIMENTAL PARAMETERS ========================
% Participant ID - change it for everyone and use 0 for tests
participantID = 1;

%number of trials
no_trials = 10; % 135 trials 

%% ================= RANDOMIZATION AND TIMELINE ========================
% We said that it is 50/50 Congruent and Incongruent and then within Incongruency there is 50/50 of left and right
% we can also change it here by giving different percentages; the numbers
% of stimuli are rounded to integers, so all combinations of number of
% stimuli and percentages should work, but not all of them will be precise

percentage_congruent=50; %frequency of congruent stimuli
percentage_L=50; %frequency of letter L

% Stimulus order and Radnomization
%coding_congruent=[10 20]; %coding for congruent/incongruent stimuli; 10= congruent, 20= incongruent
%coding_letter=[0 1]; %coding for the letter that appears 0=L 1=R

%calculate how many stimuli of each type do we need

number_congruent= round(no_trials/(100/percentage_congruent));  %number of congruent stimuli
number_incongruent= no_trials-number_congruent; %number of congruent stimuli

number_L_congruent=round(number_congruent/(100/percentage_L)); %number of Ls congruent
number_R_congruent= number_congruent-number_L_congruent; % number of congruent Rs

number_L_incongruent= round(number_incongruent/(100/percentage_L)); %number of incongruent Ls
number_R_incongruent= number_incongruent-number_L_incongruent; %number of incongruent Rs

%create coded lists of stimuli
congruent_order= [repmat(10,number_congruent,1); repmat(20,number_incongruent,1)]; %list of congruent and incongruent stimuli

letters_order=[repmat(0,number_L_congruent,1); repmat(1,number_R_congruent,1); repmat(0, number_L_incongruent,1); repmat(1,number_R_incongruent,1)]; %order of the letters

condition_table_coded=congruent_order+letters_order; %list of balanced conditions

condition_table= condition_table_coded(randperm(no_trials)); %shuffles the balanced list to get random order of conditions

%% ================= DATA LOG ========================
% create a txt file 
% logdir = '<DIRECTORY NAME>';      % Declare the working directory where we will store data
% cd(logdir);										    % Move to working directory
fileID = fopen(['SimonTask_','P', num2str(participantID), '.txt'], 'w'); % Is now stored in the current open folder in MATLAB - path can be inserted

%% ================= PSYCHTOOLBOX SETUP ========================
% Make sure PTB runs 
AssertOpenGL();

% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one connected
screenNumber = max(Screen('Screens'));

%% ================= PREPARE WELCOME SCREEN AND INSTRUCTIONS ========================
% Welcome Screen Text
hello = 'Hello, welcome to the experiment!'
next = 'Please press any key on the keyboard to continue.'

% Explanation Screen Text
expl_1 = 'In the following experiment, you will be shown a fixation cross followed by either the letter L or the letter R.'
expl_2 = 'The letter will be shown either on the left or the right side of the screen.'
expl_3 = 'When you see the letter L, please press the Q key on the keyboard, regardless of its position on the screen.'
expl_4 = 'When you see the letter R, please press the P key on the keyboard, regardless of its position on the screen.'
expl_5 = 'Please be as fast as possible while trying to be accurate. Get ready! With the next click the experiment starts. '      

instruct = [{hello}, {expl_1}, {expl_2}, {expl_3}, {expl_4}, {expl_5}]

%% ================= EXPERIMENTAL LOOP ========================

% Open screen for the demo
[window,windowRect]=Screen('OpenWindow',screenNumber,0);
%  Flip to clear
Screen('Flip', window);
HideCursor;
%get  
[mx, my] = RectCenter(windowRect);

% Display welcome screen ----- Wait for key press to move through
% instructions- write this more efficiently

for i = 1:length(instruct)
    DrawFormattedText(window, [instruct{i} '\n' next], 'center','center', 255);
    Screen('Flip', window); %flip the screen
    KbWait([], 2);     
end

% % wait 500 ms
% pause(0.5);

%preparing fixation cross
FixCr=zeros(80,80);
FixCr(36:45,:)=255;
FixCr(:,36:45)=255;
fixcross = Screen('MakeTexture',window,FixCr);

for i=1:no_trials
    %Fixation Cross
    Screen('DrawTexture', window, fixcross,[],[mx-40,my-40,mx+40,my+40]); %show the fixation cross
    Screen('Flip', window); %flip the screen
    WaitSecs(.5); %cross is showing for .5 seconds      

    Screen('TextSize', window, 150); %sets the font size
   
    if condition_table(i) == 10 %Letter L on left
        DrawFormattedText(window, 'L', mx-400,'center',255); %places the L
        [StimulusOnsetTime] = Screen('Flip', window);
        [respt, keyCode]=KbWait([], 2); 
        congruency_1 = ('congruent');
        congruency_2 = ('congruent_Left');

        cc=KbName(keyCode); %get the name of the key pressed
        if strcmp(cc,'q') % check if q was pressed
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
            accuracy = 0;
        end
        
        Screen('Flip', window); %flip the screen to show feedback
        WaitSecs(0.5); %wait

       

    elseif condition_table(i)==11
        DrawFormattedText(window, 'R', mx+300,'center',255); %places the R
        [StimulusOnsetTime] = Screen('Flip', window);

        [respt, keyCode]=KbWait([], 2); %wait for the key press to continue
        congruency_1 = ('congruent');
        congruency_2 = ('congruent_Right');

        cc=KbName(keyCode);

        if strcmp(cc, 'p')
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
            accuracy = 0;
        end

        Screen('Flip', window); %flip the screen to show feedback
        WaitSecs(0.5); %wait

    elseif condition_table(i) == 20 %Letter L on Right
        DrawFormattedText(window, 'L', mx+300,'center',255); %places the R
        [StimulusOnsetTime] = Screen('Flip', window);
        [respt, keyCode]=KbWait([], 2); %wait for the key press to continue
        congruency_1 = ('incongruent');
        congruency_2 = ('incongruent_Right');

        cc=KbName(keyCode);

        if strcmp(cc, 'q') %check if q was pressed
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
            accuracy = 0;
        end

        Screen('Flip', window); %flip the screen to show feedback
        WaitSecs(0.5); %wait

    elseif condition_table(i) == 21 %Letter R on Left
        DrawFormattedText(window, 'R', mx-400,'center',255); %places the R
        [StimulusOnsetTime] = Screen('Flip', window);
        [respt, keyCode]=KbWait([], 2); %wait for the key press to continue
        congruency_1 = ('incongruent');
        congruency_2 = ('incongruent_Left');

        cc=KbName(keyCode);

        if strcmp(cc, 'p')
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
            accuracy = 0;
        end

        Screen('Flip', window); %flip the screen to show feedback
        WaitSecs(0.5); % wait before new trial starts
    end

    % calculate RT time 
    RT = respt-StimulusOnsetTime;

    % print and write into the log
    fprintf(fileID,'%f\t%d\t%s\t%s\n', RT, accuracy, congruency_1, congruency_2);
   
end

% Goodbye Screen

Screen('TextSize', window, 40); %had to put the  font size back down, so the message is visible
thanks = 'Thank you for completing the experiment!';
DrawFormattedText(window, thanks, 'center', 'center', 255)

Screen('Flip', window); % the problem was, the screen was being flipped before the message was written,
% the screen flip has to happen after we have the scree readdy

WaitSecs(5); %lets wait 5s to close the goodbye screen, maybe change it to wait for the keypress?

%end

% Save Congruence code(code), Status(status), and Response time(rt) to the datafile after every trial.
%   Congruence code: (10)L on left, (20)L on right, (11)R on right, (21)R on left
%   Status:  (1)correct, (2)incorrect, (3)timeout.      RT: response time(ms)
% fprintf(fileID, strcat([int2str(code), '\t', int2str(status), '\t', int2str(rt), '\n']));
     

%% ================= CLEAN UP ========================

% Close the data log
fclose(fileID);
sca;
% I moved sca; command to below the analysis section...move back if we don't need screen active to display analysis results?

% %% =================== ANALYSIS ==================================
% % Read the trial data file into a Matrix because can't do analysis directly on the txt file. Then create the following boolean filter vectors: 
% %   correct, congruent, incongruent, response times.  These are used to filter against eachother as necessary using & | operators to get only the
% %   needed elements for analysis functions sum() and mean().
% % Example Data analysis array for reference (single trial): [11 1 674]  where 11 is (congruence code) 1 is (Status) 674 is 
% %   (response time), the outputs from a single dummy trial
% % See above code within 'Experimental Loop' section for explanation of Congruence Codes, and Status codes.
% data = readmatrix(strcat('SimonTask_','P', num2str(participantID), '.txt'), 'w');    % read trial data from txt file into data array 
% correct = data(:,2)== 1;        % create boolean vector of correct trials (used for filtering array rows for analysis)
% n = size(data,1);			    % number of trials is number of rows, hence size of column 1
% congruent = data(:,1) <20;   % boolean vector of congruent trials (used for filtering array rows for analysis)
% incongruent = data(:,1) >=20; % boolean vector of incongruent trials
% response_times = data(:,3);     % extract response times column from matrix, as a vector.  Better to filter directly on matrix, but couldn't find method to do this in Matlab.
% 
% disp('Average response speed (Correct trials only):');
% % Apparently you can't just put a constructed string directly into Display expression like in Python, so here's a pointless array X to make it work, 
% % repeated for each display statement below.  ...Welcome to update if anyone knows how to put it directly into a display() expression :)
% % Calculate mean of ('congruent' and 'correct') trials, using boolean vectors created above
% X = ['  Congruent trials:   ',num2str(mean(response_times([congruent & correct]))),'(ms)'];
% disp(X);
% % Calculate mean of ('incongruent' and 'correct') trials, using boolean vectors created above
% X = ['  Incongruent trials: ',num2str(mean(response_times([incongruent & correct]))),'(ms)'];
% disp(X);
% disp(' ')   % Just inserts a blank line
% % Calculate error rate for congruent trial responses only
% X = ['Error Rate (congruent trials):   ', num2str(sum(congruent & ~correct)/n*100),'%'];
% disp(X);
% % Calculate error rate for incongruent trial responses only
% X = ['Error Rate (incongruent trials)  ', num2str(sum(incongruent & ~correct)/n*100),'%'];
% disp(X);
% disp(' ')
% % Calculate Simon Effect as (average response time for Incongruent trials) - (average response time for Congruent trials) 
% X = ['Simon Effect:  ',num2str(mean(response_times([incongruent & correct])) - mean(response_times([congruent & correct]))),'(ms)'];
% disp(X);
% disp(' ');
% disp('Press space bar to exit');
% 
%sca;

%catch me 


    
                                                    