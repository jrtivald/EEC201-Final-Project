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
LBG_VQ_EPSILON      = 0.01;
LBG_VQ_M            = repmat(4,1,TRAIN_REC_CNT);
FEATURE_SPACE_RANGE = [-1 1];
SPKR_CENTROIDS      = 5;
SPKR_PLT            = [1 5];
CODEBOOK_MFCC       = [1 3 7 8 9 11];

% NOTE: MFCCs to plot in FIGS MUST be in CODEBOOK_MFCC
CODEBOOK_FIGS = [[1 9 7];
                 [11 3 1]];

%% Read in training data

train_signals = zeros([TRAIN_REC_CNT,MAX_LEN]);
train_fs = zeros([TRAIN_REC_CNT,1]);

for i = 1:TRAIN_REC_CNT
    file = strcat('../data/Training_Data/s',num2str(i),'.wav');
    [tmp_wav, tmp_fs] = audioread(file);
    
    % check if stereo
    if size(tmp_wav,2) > 1
        train_signals(i,1:length(tmp_wav)) = tmp_wav(:,CHANNEL);
    else
        train_signals(i,1:length(tmp_wav)) = tmp_wav;
    end
    
    % Save Fs
    train_fs(i) = tmp_fs;
    
    disp(strcat(file,' length: ',num2str(length(tmp_wav))))
end

% % plot spectrograms of training data to visualize
% figure('Name','Training Data Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(train_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
%         FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% run signals through pre-emphasis filter

train_signals_preemph = zeros(TRAIN_REC_CNT,MAX_LEN);
for i = 1:TRAIN_REC_CNT
   train_signals_preemph(i,:) = pre_emph(train_signals(i,:)); 
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

train_signals_normalized = zeros(TRAIN_REC_CNT,MAX_LEN);
for i = 1:TRAIN_REC_CNT
    train_signals_normalized(i,:) = train_signals_preemph(i,:) ./ norm(...
        train_signals_preemph(i,:),'Inf');
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

training_word_signals = zeros(TRAIN_REC_CNT,ceil(WORD_LENGTH_MS/1000*12500));
for i = 1:TRAIN_REC_CNT
    training_word_signals(i,:) = word_extract(train_signals_normalized(i,:),...
        train_fs(i),WORD_DETECT_THRESH_DB,WORD_LENGTH_MS);
end

% % plot extracted words
% figure('Name','Extracted Word Signals')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     plot(word_signal(i,:));
%     title(strcat('s',num2str(i),'.wav'))
% end
% 
% figure('Name','Extracted Word Signals Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(word_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
%         FRAME_OVERLAP_MS/1000*train_fs(i),FFT_NUM_POINTS,train_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% Calculate the Mel-Frequency Cepstrum Coefficients

training_mfcc_coeffs = cell(1,TRAIN_REC_CNT);
for i = 1:TRAIN_REC_CNT
    training_mfcc_coeffs{i} = mfcc(training_word_signals(i,:), train_fs(1), ... 
        FRAME_SIZE_MS,FRAME_OVERLAP_MS, FFT_NUM_POINTS, MEL_NUM_BANKS, ...
        CEPS_START_BANK, CEPS_NUM_BANKS);
end

% % plot MFCC coefficients
% figure('Name','MFCCs')
% for i = 1:TRAIN_REC_CNT
%    subplot(2,ceil(TRAIN_REC_CNT/2),i)
%    imagesc(training_mfcc_coeffs{i}')
%    colorbar
%    axis xy
%    title(strcat('MFCC s',num2str(i),'.wav'))
%    xlabel('Coeff. #')
%    ylabel('Frame #')
% end

%% Vector Quantize the training data for matching the test data

% run training signals through
LBG_VQ(training_mfcc_coeffs, CODEBOOK_MFCC, LBG_VQ_EPSILON, LBG_VQ_M, ...
    FEATURE_SPACE_RANGE, 1);

% % Plot the VQ data
% plot_spkr_centroids(mfcc_coeffs, CODEBOOK_MFCC, CODEBOOK_FIGS, SPKR_CENTROIDS);
% plot_diff_spkrs(mfcc_coeffs, CODEBOOK_MFCC, CODEBOOK_FIGS, SPKR_PLT);

% % Test to see if VQ will resolve on the correct training signal.
% for i = 1:TRAIN_REC_CNT
%     [test_distortion, speaker_number] = LBG_VQ(training_mfcc_coeffs{i}(:,:), ...
%         CODEBOOK_MFCC, LBG_VQ_EPSILON, LBG_VQ_M, FEATURE_SPACE_RANGE, 0);
%     assert(speaker_number == i,'detected the training data incorectly')
% end

%% Read in testing data

test_signals = zeros([TEST_REC_CNT,MAX_LEN]);
test_fs = zeros([TEST_REC_CNT,1]);

for i = 1:TEST_REC_CNT
    file = strcat('../data/Test_Data/s',num2str(i),'.wav');
    [tmp_wav, test_fs(i)] = audioread(file);
    
    % check if stereo
    if size(tmp_wav,2) > 1
        test_signals(i,1:length(tmp_wav)) = tmp_wav(:,CHANNEL);
    else
        test_signals(i,1:length(tmp_wav)) = tmp_wav;
    end
    
    disp(strcat(file,' length: ',num2str(length(tmp_wav))))
end

% % plot spectrograms of test data to visualize
% figure('Name','Test Data Spectrograms')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     spectrogram(test_signal(i,:),hamming(FRAME_SIZE_MS/1000*train_fs(i)),...
%         FRAME_OVERLAP_MS/1000*test_fs(i),FFT_NUM_POINTS,test_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% Run signals through pre-emphasis

test_signals_preemph = zeros(TEST_REC_CNT,MAX_LEN);
for i = 1:TEST_REC_CNT
   test_signals_preemph(i,:) = pre_emph(test_signals(i,:)); 
end

%% Normalize signals to [-1:1] range (ie auto-gain)

test_signals_normalized = zeros(TEST_REC_CNT,MAX_LEN);
for i = 1:TEST_REC_CNT
    test_signals_normalized(i,:) = test_signals_preemph(i,:) ./ norm(...
        test_signals_preemph(i,:),'Inf');
end

%% Extract word setctions from signals

test_word_signals = zeros(TEST_REC_CNT,ceil(WORD_LENGTH_MS/1000*12500));
for i = 1:TEST_REC_CNT
    test_word_signals(i,:) = word_extract(test_signals_normalized(i,:),...
        test_fs(i),WORD_DETECT_THRESH_DB,WORD_LENGTH_MS);
end

% % plot extracted words
% figure('Name','Extracted Test Word Signals')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     plot(test_word_signals(i,:));
%     title(strcat('s',num2str(i),'.wav'))
% end
% 
% figure('Name','Extracted Test Word Signals Spectrograms')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     spectrogram(test_word_signals(i,:),hamming(FRAME_SIZE_MS/1000*test_fs(i)),...
%         FRAME_OVERLAP_MS/1000*test_fs(i),FFT_NUM_POINTS,test_fs(i));
%     title(strcat('s',num2str(i),'.wav'))
% end

%% Calculate MFCC

test_mfcc_coeffs = cell(1,TEST_REC_CNT);
for i = 1:TEST_REC_CNT
    test_mfcc_coeffs{i} = mfcc(test_word_signals(i,:), test_fs(1), ... 
        FRAME_SIZE_MS,FRAME_OVERLAP_MS, FFT_NUM_POINTS, MEL_NUM_BANKS, ...
        CEPS_START_BANK, CEPS_NUM_BANKS);
end

% % plot MFCC coefficients
% figure('Name','Test MFCCs')
% for i = 1:TEST_REC_CNT
%    subplot(2,ceil(TEST_REC_CNT/2),i)
%    imagesc(test_mfcc_coeffs{i}')
%    colorbar
%    axis xy
%    title(strcat('MFCC s',num2str(i),'.wav'))
%    xlabel('Coeff. #')
%    ylabel('Frame #')
% end

%% Vector Quantize the test data

for i = 1:TEST_REC_CNT
    [test_distortion, speaker_number] = LBG_VQ(test_mfcc_coeffs{i}(:,:), ...
        CODEBOOK_MFCC, LBG_VQ_EPSILON, LBG_VQ_M, FEATURE_SPACE_RANGE, 0);
    fprintf('Test speaker %i is train speaker %i\n',i,speaker_number);
end