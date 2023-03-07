%    __________  _______  _  __  _________   ______ __
%   / __/  _/  |/  / __ \/ |/ / /_  __/ _ | / __/ //_/
%  _\ \_/ // /|_/ / /_/ /    /   / / / __ |_\ \/ ,<   
% /___/___/_/  /_/\____/_/|_/   /_/ /_/ |_/___/_/|_|  
%
%% ======================== ANALYSIS PLAN ===============================

% Descriptive Stats: 
% - RT: Mean, STD, Bootstrapped CI's, Max & Min
% - Accuracy: Mean and Error mean

% end terminal print out - von den descriptive stats 

% Inferential Stats: 
% - RT - Congruent vs Incongruent = repeated measures paired ttest
% - RT - Incongruent Left vs Incongruent Right = repeated measures paired ttest
% - RT - Acc vs Error = repeated measures paired ttest
% - Acc - Congruent vs Incongruent = repeated measures paired ttest
% - Acc - Incongruent Left vs Incongruent Right = repeated measures paired ttest

%% ======================== LOADING DATA ===============================
clear all

% if PRINT is true then it will print the output for descriptive stats
PRINT = true;

% create an array with the right subject numbers
subj = [11:13,32:34,41:43,51:53,63];

for i = 1:13 % loop through the participants
    FullFileName = ['/Users/lp1/Nextcloud/FU/ProgrammingTask/data/SimonTask_P', num2str(subj(i)) ,'.txt']; % Here enter your pathway to the data
    ImpData = readtable(FullFileName, 'Delimiter', '\t'); % read in data
    ImpData.Subj = zeros(size(ImpData,1),1) + subj(i); % add another column in the Data with the subject numbers
    

    % Store data in seperate variables
    RT = ImpData.Var1;        % Reaction Time
    Acc = ImpData.Var2;       % Accuracy [0 = inccorect, 1 = correct]
    Congru = ImpData.Var3;    % simple Congruency - were stimuli and response key congruent or incongruent
    Congru_LR = ImpData.Var4; % finer Congruency - were stimuli and response key congruent or incongruent on the left or the right side

    % Concatenate and store data for inferential analysis
    if i < 2
        Data = ImpData;
    else
        Data = vertcat(Data, ImpData);
    end
     
    
%% ======================== DESCRIPTIVE STATISTICS ===============================

%% participant-wise descriptive statistics

    % general info
    Stats.subj(i) = subj(i);

    % RT based
    Stats.mean_RT(i) = mean(RT,1)';
    Stats.median_RT(i) = median(RT,1);
    Stats.std_RT(i) = std(RT);
    Stats.min_RT(i) = min(RT);
    Stats.max_RT(i) = max(RT);

    % calculate and store bootstrapped CI (5% & 95%)
    [bci95, ~] = bootci(2000, @mean, RT);
    Stats.lowCI(i) = bci95(1);
    Stats.highCI(i) = bci95(2);

    % Accuracy and Error
    Stats.accuracy(i) = sum(Acc,1)/numel(Acc)*100; % in percent
    Stats.error(i) = 100 - (sum(Acc,1)/numel(Acc)*100); % in percent


end

% Save Stats Struct in a table
Stats = structfun(@transpose, Stats, 'UniformOutput', false);
Stats_Table = struct2table(Stats);

%% over-all perticipants descriptive statistics

Stats.mean_RT_all = mean(Stats.mean_RT,1);
Stats.mean_accuracy = mean(Stats.accuracy,1);
Stats.mean_error = mean(Stats.error,1);
Stats.mean_lowCI = mean(Stats.lowCI,1);
Stats.mean_highCI = mean(Stats.highCI,1);
Stats.mean_std_RT = mean(Stats.std_RT,1);
Stats.mean_median_RT = mean(Stats.median_RT,1);

%% ======================== INFERENTIAL STATISTICS ===============================

%% Genereal variables SetUp 

% create a vector of correct congruent and incongruent and the
% corresponding RT times

% Accuracy
correct = find(Data.Var2 == 1);
incorrect = find(Data.Var2 == 0);
RT_Acc = Data.Var1(correct,1);
RT_Error = Data.Var1(incorrect,1);

% create logical arrays for the correct strings
congruent = strcmp(Data.Var3, 'congruent');
congruent_Left = strcmp(Data.Var4, 'congruent_Left');
congruent_Right = strcmp(Data.Var4, 'congruent_Right');
incongruent = strcmp(Data.Var3, 'incongruent');
incongruent_Left = strcmp(Data.Var4, 'incongruent_Left');
incongruent_Right = strcmp(Data.Var4, 'incongruent_Right');

% extract the RTs from the logical arrays
RT_congruent = Data.Var1(congruent,1);
RT_congruent_Left = Data.Var1(congruent_Left,1);
RT_congruent_Right = Data.Var1(congruent_Right,1);
RT_incongruent = Data.Var1(incongruent,1);
RT_incongruent_Left = Data.Var1(incongruent_Left,1);
RT_incongruent_Right = Data.Var1(incongruent_Right,1);


%% ======================== OUTPUT ===============================


if PRINT 
    fprintf('\n <strong> Despriptive Statistics </strong> \n Mean RT overall is %4.3f\n Mean RT of Congurent and correct trials is %4.3f\n Mean RT of Incongurent and correct trials is %4.3f\n Mean median RT is %4.3f\n Mean Standard Deviation is %4.3f\n Mean Accuracy is %3.1f percent \n Mean Error is %3.1f percent \n Mean high Conficence Interval is %4.3f\n Mean low Conficence Interval is %4.3f\n\n',...
        Stats.mean_RT_all, mean(RT_congruent,1), mean(RT_incongruent,1), Stats.mean_median_RT, Stats.mean_std_RT, Stats.mean_accuracy, Stats.mean_error, Stats.mean_highCI, Stats.mean_lowCI);
end
