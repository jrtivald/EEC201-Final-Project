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

clear all;
close all;
clc;

%Parameters
train_rec_cnt = 11;
test_rec_cnt = 8;
max_len = 30000;
channel = 1;            %Some audio files have stereo
pre_a = 0.95;           %Pre-Emphasis coefficient
frame_size = 20;
frame_overlap = 8;
N_fft = 512;

%Read in a training file
train_file = zeros([train_rec_cnt,max_len]);
train_fs = zeros([train_rec_cnt,1]);

for i = 1:train_rec_cnt
    file = strcat('./data/Training_Data/s',num2str(i),'.wav');
    [tmp_wav, tmp_fs] = audioread(file);
    
    %check if stereo
    if size(tmp_wav,2) > 1
        train_file(i,1:length(tmp_wav)) = tmp_wav(:,channel);
    else
        train_file(i,1:length(tmp_wav)) = tmp_wav;
    end
    
    %Save Fs
    train_fs(i) = tmp_fs;
    
    disp(strcat(file,' length: ',num2str(length(tmp_wav))))
end

%Read in a testing file
test_file = zeros([test_rec_cnt,max_len]);
test_fs = zeros([test_rec_cnt,1]);

for i = 1:test_rec_cnt
    file = strcat('./data/Test_Data/s',num2str(i),'.wav');
    [tmp_wav, tmp_fs] = audioread(file);
    
    %check if stereo
    if size(tmp_wav,2) > 1
        test_file(i,1:length(tmp_wav)) = tmp_wav(:,channel);
    else
        test_file(i,1:length(tmp_wav)) = tmp_wav;
    end

    %Save Fs
    test_fs(i) = tmp_fs;
    
    disp(strcat(file,' length: ',num2str(length(tmp_wav))))
end

%Calculate the Mel-Frequency Cepstrum Coefficients
tmp = mfcc(train_file(1,:), train_fs(1), pre_a, frame_size, frame_overlap, N_fft);
