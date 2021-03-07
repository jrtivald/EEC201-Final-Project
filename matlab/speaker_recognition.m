% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Speaker Recognition
%
% Description: This is main function of the final project for EEC-201.
%              This program will store features in the recorded audio of 
%              different speakers in order to recognize which speaker is
%              talking on further recordings.
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 2/7/2021

clear;
close all;
clc;

% Parameters
TRAIN_REC_CNT    = 11;
TEST_REC_CNT     = 8;
MAX_LEN          = 30000;
CHANNEL          = 1;            % Some audio files have stereo

% MFCC parameters
FRAME_SIZE_MS    = 20;
FRAME_OVERLAP_MS = 8;
FFT_NUM_POINTS   = 512;
MEL_NUM_BANKS    = 40;
CEPS_START_BANK  = 2;
CEPS_NUM_BANKS   = 15;

% Trim down the files for the "important part"
% TODO: make the word envelope detection automatic
TRIM_LEN          = 13000;
TRAIN_TRIM_OFFSET = 2500;
TEST_TRIM_OFFSET  = 2500;

%% Read in a training file

train_signal = zeros([TRAIN_REC_CNT,MAX_LEN]);
train_fs = zeros([TRAIN_REC_CNT,1]);

for i = 1:TRAIN_REC_CNT
    file = strcat('../data/Training_Data/s',num2str(i),'.wav');
    [tmp_wav, tmp_fs] = audioread(file);
    
    %check if stereo
    if size(tmp_wav,2) > 1
        train_signal(i,1:length(tmp_wav)) = tmp_wav(:,CHANNEL);
    else
        train_signal(i,1:length(tmp_wav)) = tmp_wav;
    end
    
    %Save Fs
    train_fs(i) = tmp_fs;
    
    disp(strcat(file,' length: ',num2str(length(tmp_wav))))
end

% Trim down training data
% TODO: make the word envelope detection automatic
train_signal(:,1:TRIM_LEN) = train_signal(:,TRAIN_TRIM_OFFSET:...
    (TRAIN_TRIM_OFFSET+TRIM_LEN-1));
train_signal(:,TRIM_LEN+1:end) = [];

% plot spectrograms of training data to visualize
figure('Name','Training Data Spectrograms')
for i = 1:TRAIN_REC_CNT
    subplot(2,ceil(TRAIN_REC_CNT/2),i)
    spectrogram(train_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
        FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
    title(strcat('s',num2str(i),'.wav'))
end

%% Read in a testing file

test_signal = zeros([TEST_REC_CNT,MAX_LEN]);
test_fs = zeros([TEST_REC_CNT,1]);

for i = 1:TEST_REC_CNT
    file = strcat('../data/Test_Data/s',num2str(i),'.wav');
    [tmp_wav, test_fs(i)] = audioread(file);
    
    % check if stereo
    if size(tmp_wav,2) > 1
        test_signal(i,1:length(tmp_wav)) = tmp_wav(:,CHANNEL);
    else
        test_signal(i,1:length(tmp_wav)) = tmp_wav;
    end
    
    disp(strcat(file,' length: ',num2str(length(tmp_wav))))
end

% Trim down test data
% TODO: make the word envelope detection automatic
test_signal(:,1:TRIM_LEN) = test_signal(:,TEST_TRIM_OFFSET:...
    (TEST_TRIM_OFFSET+TRIM_LEN-1));
test_signal(:,TRIM_LEN+1:end) = [];

% % plot spectrograms of test data to visualize
% figure('Name','Test Data Spectrograms')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     spectrogram(test_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
%         FRAME_OVERLAP_MS/1000*train_fs(i),N_FFT,train_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% run signals through pre-emphasis filter

train_signal_preemph = zeros(TRAIN_REC_CNT,TRIM_LEN);
for i = 1:TRAIN_REC_CNT
   train_signal_preemph(i,:) = pre_emph(train_signal(i,:)); 
end

% plot filtered signals
figure('Name','Filtered Training Data Spectrograms')
for i = 1:TRAIN_REC_CNT
    subplot(2,ceil(TRAIN_REC_CNT/2),i)
    spectrogram(train_signal_preemph(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
        FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
    title(strcat('s',num2str(i),'.wav'))
end

%% Calculate the Mel-Frequency Cepstrum Coefficients

% calculate MFCC coefficients
mfcc_coeffs = cell(1,TRAIN_REC_CNT);
for i = 1:TRAIN_REC_CNT
    mfcc_coeffs{i} = mfcc(train_signal_preemph(i,:), train_fs(1), ... 
        FRAME_SIZE_MS,FRAME_OVERLAP_MS, FFT_NUM_POINTS, MEL_NUM_BANKS, ...
        CEPS_START_BANK, CEPS_NUM_BANKS);
end

% plot MFCC coefficients
figure('Name','MFCCs')
for i = 1:TRAIN_REC_CNT
   subplot(2,ceil(TRAIN_REC_CNT/2),i)
   imagesc(mfcc_coeffs{i}')
   colorbar
   axis xy
   title(strcat('MFCC s',num2str(i),'.wav'))
   xlabel('Coeff. #')
   ylabel('Frame #')
end
