%
%EEC-201, Winter Quarter 2021, Final Project
%
%Title: Speaker Recognition
%
%Description: This is main function of the final project for EEC-201.
%             This program will store features in the recorded audio of 
%             different speakers in order to recognize which speaker is
%             talking on further recordings.
%
%Authors: Igor Sheremet and Jonathan Tivald
%
%Date: 2/7/2021

clear all;
close all;
clc;

%Parameters
train_rec_cnt = 11;
test_rec_cnt = 8;
max_len = 20000;
channel = 1; %Some audio files have stereo

%Read in a training file
train_file = zeros([max_len,train_rec_cnt]);

for i = 1:train_rec_cnt
    file = strcat('./data/Training_Data/s',num2str(i),'.wav');
    tmp = audioread(file);
    
    %check if stereo
    if size(tmp,2) > 1
        train_file(1:length(tmp),i) = tmp(:,channel);
    else
        train_file(1:length(tmp),i) = tmp;
    end
    
    disp(strcat(file,' length: ',num2str(length(tmp))))
end

%Read in a testing file
test_file = zeros([max_len,test_rec_cnt]);

for i = 1:test_rec_cnt
    file = strcat('./data/Test_Data/s',num2str(i),'.wav');
    tmp = audioread(file);
    
    %check if stereo
    if size(tmp,2) > 1
        test_file(1:length(tmp),i) = tmp(:,channel);
    else
        test_file(1:length(tmp),i) = tmp;
    end
    
    disp(strcat(file,' length: ',num2str(length(tmp))))
end

%Plot the difference
figure('name','Train Vs. Test Audio')
plot(train_file(:,1))
hold on;
plot(test_file(:,1),'r')
legend('Train','Test')