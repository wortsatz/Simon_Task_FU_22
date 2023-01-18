function results = SimonTask_Experiment(participantID)
% __________  _______  _  __  _________   ______ __
%   / __/  _/  |/  / __ \/ |/ / /_  __/ _ | / __/ //_/
%  _\ \_/ // /|_/ / /_/ /    /   / / / __ |_\ \/ ,<   
% /___/___/_/  /_/\____/_/|_/   /_/ /_/ |_/___/_/|_|  
%
        
%
%% ======================== GETTING STARTED ===============================

% Clear the workspace
close all;
%clear all;
sca;

% Prevent Screen Issues with PTB
Screen('Preference', 'SkipSyncTests', 1);

%% ================= BASIC EXPERIMENTAL PARAMETERS ========================
% Participant ID - change it for everyone and use 0 for tests
%participantID = 1;

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
hello = 'Hello, welcome to the experiment!';
next = 'Please press any key on the keyboard to continue.';

% Explanation Screen Text
expl_1 = 'In the following experiment, you will be shown a fixation cross followed by either the letter L or the letter R.';
expl_2 = 'The letter will be shown either on the left or the right side of the screen.';
expl_3 = 'When you see the letter L, please press the Q key on the keyboard, regardless of its position on the screen.';
expl_4 = 'When you see the letter R, please press the P key on the keyboard, regardless of its position on the screen.';
expl_5 = 'Please be as fast as possible while trying to be accurate. Get ready! With the next click the experiment starts. ';      

instruct = [{hello}, {expl_1}, {expl_2}, {expl_3}, {expl_4}, {expl_5}];

%% ================= EXPERIMENTAL LOOP ========================

% Open screen for the demo
[window,windowRect]=Screen('OpenWindow',screenNumber,0);

%dummy calls

WaitSecs(.1);
GetSecs;

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
        [respt, keyCode]=KbWait([], 2, StimulusOnsetTime + 3); 
        congruency_1 = ('congruent');
        congruency_2 = ('congruent_Left');

        cc=KbName(keyCode); %get the name of the key pressed
        if strcmp(cc,'q') % check if q was pressed
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            if sum(keyCode) == 1    
                DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
                accuracy = 0;
            else
                DrawFormattedText(window, 'Timeout!', 'center', 'center', 255);
                accuracy = 3;
            end
        end
        
        Screen('Flip', window); %flip the screen to show feedback
        WaitSecs(0.5); %wait

    elseif condition_table(i)==11
        DrawFormattedText(window, 'R', mx+300,'center',255); %places the R
        [StimulusOnsetTime] = Screen('Flip', window);
        [respt, keyCode, deltaSecs]=KbWait([], 2, StimulusOnsetTime + 3); %wait for the key press to continue
        congruency_1 = ('congruent');
        congruency_2 = ('congruent_Right'); 

        cc=KbName(keyCode);

        if strcmp(cc, 'p')
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            if sum(keyCode) == 1
                DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
                accuracy = 0;
            else
                DrawFormattedText(window, 'Timeout!', 'center', 'center', 255);
                accuracy = 3;
            end
        end

        Screen('Flip', window); %flip the screen to show feedback
        WaitSecs(0.5); %wait

    elseif condition_table(i) == 20 %Letter L on Right
        DrawFormattedText(window, 'L', mx+300,'center',255); %places the R
        [StimulusOnsetTime] = Screen('Flip', window);
        [respt, keyCode]=KbWait([], 2, StimulusOnsetTime + 3); %wait for the key press to continue
        congruency_1 = ('incongruent');
        congruency_2 = ('incongruent_Right');

        cc=KbName(keyCode);

        if strcmp(cc, 'q') %check if q was pressed
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            if sum(keyCode) == 1
                DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
                accuracy = 0;
            else
                DrawFormattedText(window, 'Timeout!', 'center', 'center', 255);
                accuracy = 3;
            end
        end

        Screen('Flip', window); %flip the screen to show feedback
        WaitSecs(0.5); %wait

    elseif condition_table(i) == 21 %Letter R on Left
        DrawFormattedText(window, 'R', mx-400,'center',255); %places the R
        [StimulusOnsetTime] = Screen('Flip', window);
        [respt, keyCode]=KbWait([], 2, StimulusOnsetTime + 3); %wait for the key press to continue
        congruency_1 = ('incongruent');
        congruency_2 = ('incongruent_Left');

        cc=KbName(keyCode);

        if strcmp(cc, 'p')
            Screen('TextSize', window, 50);
            DrawFormattedText(window, 'Correct!', 'center', 'center', 255);
            accuracy = 1;
        else
            Screen('TextSize', window, 50);
            if sum(keyCode) == 1
                DrawFormattedText(window, 'Incorrect!', 'center', 'center', 255);
                accuracy = 0;
            else
                DrawFormattedText(window, 'Timeout!', 'center', 'center', 255);
                accuracy = 3;
            end
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
DrawFormattedText(window, thanks, 'center', 'center', 255);

Screen('Flip', window); % the problem was, the screen was being flipped before the message was written,
% the screen flip has to happen after we have the scree readdy

WaitSecs(5); %lets wait 5s to close the goodbye screen, maybe change it to wait for the keypress?


%% ================= CLEAN UP ========================

% Close the data log
fclose(fileID);
sca;



    
                                                    