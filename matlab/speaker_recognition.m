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

% Signals parameters
TRAIN_REC_CNT = 10;
TEST_REC_CNT  = 13;
CHANNEL       = 1;            % Some audio files have stereo
SAMPLE_RATE   = 12500;

% Word Detection Parameters
WORD_DETECT_THRESH_DB = -62;
WORD_LENGTH_MS        = 500;

% MFCC parameters
FRAME_SIZE_MS    = 20;
FRAME_OVERLAP_MS = 10;
FFT_NUM_POINTS   = 1024;
MEL_NUM_BANKS    = 40;
CEPS_START_BANK  = 2;
CEPS_NUM_BANKS   = 12;

% LBG VQ Parameters
LBG_VQ_EPSILON      = 0.01;
LBG_VQ_M            = repmat(8,1,TRAIN_REC_CNT);
FEATURE_SPACE_RANGE = [-1 1];
SPKR_CENTROIDS      = 5;
SPKR_PLT            = [7 6];
CODEBOOK_MFCC       = 1:12;

% NOTE: MFCCs to plot in FIGS MUST be in CODEBOOK_MFCC
CODEBOOK_FIGS = [[1 2];
                 [3 4];
                 [5 6]
                 [7 8]
                 [9 10]
                 [11 12]];

% Speaker Prediction
CONFIDENCE_THRESHOLD = 0.5;

%% Read in training data

train_signals = cell(1,TRAIN_REC_CNT);

for i = 1:TRAIN_REC_CNT
    file = strcat('../data/Training_Data/s',num2str(i),'.wav');
    train_signals{i} = read_signal(file,SAMPLE_RATE,CHANNEL);
end

% % plot training data
% figure('Name','Training Data Signals')
% for i = 1:TRAIN_REC_CNT
%    subplot(2,ceil(TRAIN_REC_CNT/2),i)
%    plot(train_signals{i})
%    title(strcat('s',num2str(i),'.wav'))
% end
% 
% % plot spectrograms of training data to visualize
% figure('Name','Training Data Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(train_signals{i},hamming(ceil(FRAME_SIZE_MS/1000*SAMPLE_RATE)),...
%         ceil(FRAME_OVERLAP_MS/1000*SAMPLE_RATE),FFT_NUM_POINTS,SAMPLE_RATE);
%     title(strcat('s',num2str(i),'.wav'))
% end

%% run signals through pre-emphasis filter

train_signals_preemph = cell(1,TRAIN_REC_CNT);

for i = 1:TRAIN_REC_CNT
   train_signals_preemph{i} = pre_emph(train_signals{i}); 
end

% % plot filtered signals
% figure('Name','Pre-Emphasis Filtered Training Data Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(train_signals_preemph{i},hamming(ceil(FRAME_SIZE_MS/1000*SAMPLE_RATE)),...
%         ceil(FRAME_OVERLAP_MS/1000*SAMPLE_RATE),FFT_NUM_POINTS,SAMPLE_RATE);
%     title(strcat('s',num2str(i),'.wav'))
% end

%% normalize signal amplitudes to [-1:1] range (ie auto. gain to full scale)

train_signals_normalized = cell(1,TRAIN_REC_CNT);

for i = 1:TRAIN_REC_CNT
    train_signals_normalized{i} = train_signals_preemph{i} ./ norm(...
        train_signals_preemph{i},'Inf');
end

% % plot normalized signals
% figure('Name','Normalized Training Data')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     plot(train_signals_normalized{i});
%     title(strcat('s',num2str(i),'.wav'))
% end
% 
% figure('Name','Normalized Training Data Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(train_signals_normalized{i},hamming(ceil(FRAME_SIZE_MS/1000*SAMPLE_RATE)),...
%         ceil(FRAME_OVERLAP_MS/1000*SAMPLE_RATE),FFT_NUM_POINTS,SAMPLE_RATE);
%     title(strcat('s',num2str(i),'.wav'))
% end

%% extract word envelopes from signals

train_word_signals = cell(1,TRAIN_REC_CNT);

for i = 1:TRAIN_REC_CNT
    train_word_signals{i} = word_extract(train_signals_normalized{i},...
        SAMPLE_RATE,WORD_DETECT_THRESH_DB,WORD_LENGTH_MS);
end

% % plot extracted words
% figure('Name','Extracted Word Signals')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     plot(train_word_signals{i});
%     title(strcat('s',num2str(i),'.wav'))
% end
% 
% figure('Name','Extracted Training Word Signals Spectrograms')
% for i = 1:TRAIN_REC_CNT
%     subplot(2,ceil(TRAIN_REC_CNT/2),i)
%     spectrogram(train_word_signals{i},hamming(ceil(FRAME_SIZE_MS/1000*SAMPLE_RATE)),...
%         ceil(FRAME_OVERLAP_MS/1000*SAMPLE_RATE),FFT_NUM_POINTS,SAMPLE_RATE);
%     title(strcat('s',num2str(i),'.wav'))
% end

%% Calculate the Mel-Frequency Cepstrum Coefficients

training_mfcc_coeffs = cell(1,TRAIN_REC_CNT);

for i = 1:TRAIN_REC_CNT
    training_mfcc_coeffs{i} = mfcc(train_word_signals{i}, SAMPLE_RATE, ... 
        FRAME_SIZE_MS,FRAME_OVERLAP_MS, FFT_NUM_POINTS, MEL_NUM_BANKS, ...
        CEPS_START_BANK, CEPS_NUM_BANKS);
end

% plot MFCC coefficients
figure('Name','Training MFCCs')
for i = 1:TRAIN_REC_CNT
   subplot(2,ceil(TRAIN_REC_CNT/2),i)
   imagesc(training_mfcc_coeffs{i}')
   colorbar
   axis xy
   title(strcat('MFCC s',num2str(i),'.wav'))
   xlabel('Coeff. #')
   ylabel('Frame #')
end

%% Vector Quantize the training data for matching the test data

% run training signals through
LBG_VQ(training_mfcc_coeffs, CODEBOOK_MFCC, LBG_VQ_EPSILON, LBG_VQ_M, ...
    FEATURE_SPACE_RANGE, 1);

% Plot the VQ data
plot_spkr_centroids(training_mfcc_coeffs, CODEBOOK_MFCC, CODEBOOK_FIGS, SPKR_CENTROIDS);
%plot_diff_spkrs(training_mfcc_coeffs, CODEBOOK_MFCC, CODEBOOK_FIGS, SPKR_PLT, 0);
%plot_diff_spkrs(training_mfcc_coeffs, CODEBOOK_MFCC, CODEBOOK_FIGS, SPKR_PLT, 1);

% Test to see if VQ will resolve on the correct training signal.
train_distortion = LBG_VQ(training_mfcc_coeffs,CODEBOOK_MFCC, LBG_VQ_EPSILON,...
                            LBG_VQ_M, FEATURE_SPACE_RANGE, 0);

decide_spkr(train_distortion,CONFIDENCE_THRESHOLD,'Training Signals');

%% Read in testing data

test_signals = cell(1,TEST_REC_CNT);

for i = 1:TEST_REC_CNT
    file = strcat('../data/Test_Data/s',num2str(i),'.wav'); 
    test_signals{i} = read_signal(file,SAMPLE_RATE,CHANNEL);
end

% % plot spectrograms of test data to visualize
% figure('Name','Test Data Spectrograms')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     spectrogram(test_signals{i},hamming(ceil(FRAME_SIZE_MS/1000*SAMPLE_RATE)),...
%         ceil(FRAME_OVERLAP_MS/1000*SAMPLE_RATE),FFT_NUM_POINTS,SAMPLE_RATE);
%     title(strcat('s',num2str(i),'.wav'))
% end

%% Run signals through pre-emphasis

test_signals_preemph = cell(1,TEST_REC_CNT);

for i = 1:TEST_REC_CNT
   test_signals_preemph{i} = pre_emph(test_signals{i}); 
end

%% Normalize signals to [-1:1] range (ie auto-gain)

test_signals_normalized = cell(1,TEST_REC_CNT);

for i = 1:TEST_REC_CNT
    test_signals_normalized{i} = test_signals_preemph{i} ./ norm(...
        test_signals_preemph{i},'Inf');
end

%% Extract word setctions from signals

test_word_signals = cell(1,TEST_REC_CNT);

for i = 1:TEST_REC_CNT
    test_word_signals{i} = word_extract(test_signals_normalized{i},...
        SAMPLE_RATE,WORD_DETECT_THRESH_DB,WORD_LENGTH_MS);
end

% % plot extracted words
% figure('Name','Extracted Test Word Signals')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     plot(test_word_signals{i});
%     title(strcat('s',num2str(i),'.wav'))
% end

% figure('Name','Extracted Test Word Signals Spectrograms')
% for i = 1:TEST_REC_CNT
%     subplot(2,ceil(TEST_REC_CNT/2),i)
%     spectrogram(test_word_signals{i},hamming(ceil(FRAME_SIZE_MS/1000*SAMPLE_RATE)),...
%         ceil(FRAME_OVERLAP_MS/1000*SAMPLE_RATE),FFT_NUM_POINTS,SAMPLE_RATE);
%     title(strcat('s',num2str(i),'.wav'))
% end

%% Calculate MFCC

test_mfcc_coeffs = cell(1,TEST_REC_CNT);

for i = 1:TEST_REC_CNT
    test_mfcc_coeffs{i} = mfcc(test_word_signals{i}, SAMPLE_RATE, ... 
        FRAME_SIZE_MS,FRAME_OVERLAP_MS, FFT_NUM_POINTS, MEL_NUM_BANKS, ...
        CEPS_START_BANK, CEPS_NUM_BANKS);
end

% plot MFCC coefficients
figure('Name','Test MFCCs')
for i = 1:TEST_REC_CNT
   subplot(2,ceil(TEST_REC_CNT/2),i)
   imagesc(test_mfcc_coeffs{i}')
   colorbar
   axis xy
   title(strcat('MFCC s',num2str(i),'.wav'))
   xlabel('Coeff. #')
   ylabel('Frame #')
end

%% Vector Quantize the test data

test_distortion = LBG_VQ(test_mfcc_coeffs, CODEBOOK_MFCC, LBG_VQ_EPSILON,...
                  LBG_VQ_M, FEATURE_SPACE_RANGE, 0);

decide_spkr(test_distortion,CONFIDENCE_THRESHOLD,'Testing Signals');
