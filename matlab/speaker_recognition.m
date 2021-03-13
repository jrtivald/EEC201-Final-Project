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

% Word Detection Parameters
WORD_DETECT_THRESH_DB = -62;
WORD_LENGTH_MS        = 550;

% MFCC parameters
FRAME_SIZE_MS    = 20;
FRAME_OVERLAP_MS = 10;
FFT_NUM_POINTS   = 1024;
MEL_NUM_BANKS    = 40;
CEPS_START_BANK  = 2;
CEPS_NUM_BANKS   = 15;

% LBG VQ Parameters
LBG_VQ_EPSILON = 0.01;
LBG_VQ_M = repmat(4,1,TRAIN_REC_CNT);
FEATURE_SPACE_RANGE = [-1 1];
SPKR_CENTROIDS = 5;
SPKR_PLT = [1 5];
CODEBOOK_MFCC = [1 3 7 8 9 11];
% NOTE: MFCCs to plot in FIGS MUST be in CODEBOOK_MFCC
CODEBOOK_FIGS = [[1 9 7];
                 [11 3 1]];

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

% % Trim down training data
% % TODO: make the word envelope detection automatic
% train_signal(:,1:TRIM_LEN) = train_signal(:,TRAIN_TRIM_OFFSET:...
%     (TRAIN_TRIM_OFFSET+TRIM_LEN-1));
% train_signal(:,TRIM_LEN+1:end) = [];

% plot spectrograms of training data to visualize
figure('Name','Training Data Spectrograms')
for i = 1:TRAIN_REC_CNT
    subplot(2,ceil(TRAIN_REC_CNT/2),i)
    spectrogram(train_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
        FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
    title(strcat('s',num2str(i),'.wav'))
end

%% Read in a testing file

% test_signal = zeros([TEST_REC_CNT,MAX_LEN]);
% test_fs = zeros([TEST_REC_CNT,1]);
% 
% for i = 1:TEST_REC_CNT
%     file = strcat('../data/Test_Data/s',num2str(i),'.wav');
%     [tmp_wav, test_fs(i)] = audioread(file);
%     
%     % check if stereo
%     if size(tmp_wav,2) > 1
%         test_signal(i,1:length(tmp_wav)) = tmp_wav(:,CHANNEL);
%     else
%         test_signal(i,1:length(tmp_wav)) = tmp_wav;
%     end
%     
%     disp(strcat(file,' length: ',num2str(length(tmp_wav))))
% end
% 
% % Trim down test data
% % TODO: make the word envelope detection automatic
% test_signal(:,1:TRIM_LEN) = test_signal(:,TEST_TRIM_OFFSET:...
%     (TEST_TRIM_OFFSET+TRIM_LEN-1));
% test_signal(:,TRIM_LEN+1:end) = [];
% 
% % plot spectrograms of test data to visualize
% figure('Name','Test Data Spectrograms')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     spectrogram(test_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
%         FRAME_OVERLAP_MS/1000*test_fs(i),FFT_NUM_POINTS,test_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% run signals through pre-emphasis filter

train_signal_preemph = zeros(TRAIN_REC_CNT,MAX_LEN);
for i = 1:TRAIN_REC_CNT
   train_signal_preemph(i,:) = pre_emph(train_signal(i,:)); 
end

% % plot filtered signals
% figure('Name','Pre-Emphasis Filtered Training Data Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(train_signal_preemph(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
%         FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% normalize signal amplitudes to [-1:1] range (ie auto. gain to full scale)

train_signal_normalized = zeros(TRAIN_REC_CNT,MAX_LEN);
for i = 1:TRAIN_REC_CNT
    train_signal_normalized(i,:) = train_signal_preemph(i,:) ./ norm(...
        train_signal_preemph(i,:),'Inf');
end

% % plot normalized signals
% figure('Name','Normalized Training Data')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     plot(train_signal_normalized(i,:));
%     title(strcat('s',num2str(i),'.wav'))
% end
% 
% figure('Name','Normalized Training Data Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(train_signal_normalized(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
%         FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% extract word envelopes from signals

word_signal = zeros(TRAIN_REC_CNT,ceil(WORD_LENGTH_MS/1000*12500));
for i = 1:TRAIN_REC_CNT
    word_signal(i,:) = word_extract(train_signal_normalized(i,:),...
        train_fs(i),WORD_DETECT_THRESH_DB,WORD_LENGTH_MS);
end

% plot extracted words
figure('Name','Extracted Word Signals')
for i = 1:TRAIN_REC_CNT
    subplot(2,ceil(TRAIN_REC_CNT/2),i)
    plot(word_signal(i,:));
    title(strcat('s',num2str(i),'.wav'))
end

figure('Name','Extracted Word Signals Spectrograms')
for i = 1:TRAIN_REC_CNT
    subplot(2,ceil(TRAIN_REC_CNT/2),i)
    spectrogram(word_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
        FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
    title(strcat('s',num2str(i),'.wav'))
end

%% Calculate the Mel-Frequency Cepstrum Coefficients

% calculate MFCC coefficients
mfcc_coeffs = cell(1,TRAIN_REC_CNT);
for i = 1:TRAIN_REC_CNT
    mfcc_coeffs{i} = mfcc(word_signal(i,:), train_fs(1), ... 
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

%% Vector Quantize the training data for matching the test data
LBG_VQ(mfcc_coeffs, CODEBOOK_MFCC, LBG_VQ_EPSILON, LBG_VQ_M, FEATURE_SPACE_RANGE, 1);

% Plot the VQ data
plot_spkr_centroids(mfcc_coeffs, CODEBOOK_MFCC, CODEBOOK_FIGS, SPKR_CENTROIDS);
plot_diff_spkrs(mfcc_coeffs, CODEBOOK_MFCC, CODEBOOK_FIGS, SPKR_PLT);

% Test to see if VQ will resolve on the correct training signal.
[test_distortion, speaker_number] = LBG_VQ(mfcc_coeffs{1,7}(:,:), CODEBOOK_MFCC, LBG_VQ_EPSILON, LBG_VQ_M, FEATURE_SPACE_RANGE, 0);

disp(strcat('Predicted Speaker is: ',num2str(speaker_number)))
