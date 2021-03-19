% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Degrade Test Signals
%
% Description: Generate folders of degraded test signals for
%               Testing the LBG-VQ algorithm
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 3/5/2021

% Parameters
TEST_DIR_PATH    = '../data/Test_Data';
TEST_REC_CNT     = 11;
MAX_LEN          = 30000;
CHANNEL          = 1;            % Some audio files have stereo

% Notech filtering Parameters
MEL_NUM_BANKS    = 40;
NOTCH_FILES      = [2];    % Mel filter index to notch out

% Noise Paramters
NOISE_FILES      = [30];    % SNR in DB of output signal

%% Read in a testing file

test_dir = dir(strcat(TEST_DIR_PATH,'/*.wav'));

test_signal = zeros([TEST_REC_CNT,MAX_LEN]);
test_fs = zeros([TEST_REC_CNT,1]);
test_length = zeros([TEST_REC_CNT,1]);

for i = 1:TEST_REC_CNT
    file = strcat(test_dir(i).folder,'/',test_dir(i).name);
    [tmp_wav, test_fs(i)] = audioread(file);
    test_length(i) = length(tmp_wav);
    
    % check if stereo
    if size(tmp_wav,2) > 1
        test_signal(i,1:length(tmp_wav)) = tmp_wav(:,CHANNEL);
    else
        test_signal(i,1:length(tmp_wav)) = tmp_wav;
    end
    
    disp(strcat(file,' length: ',num2str(test_length(i))))
end

%% Run signals through Notch Filter data
for i = 1:TEST_REC_CNT

    % generate mel-freq filter bank matrix
    mel_banks = melfb_gen(MEL_NUM_BANKS,MAX_LEN,test_fs(i));

    for j = 1:length(NOTCH_FILES)

        % normalize and invert the mel fiter bank
        notch = [mel_banks(NOTCH_FILES(j),1:round(MAX_LEN/2)) fliplr(mel_banks(NOTCH_FILES(j),1:round(MAX_LEN/2)))];
        notch = notch/max(notch);
        notch = -1.*(notch-1);

        % Generate FFT of sound file
        test_fft = fft(test_signal(i,:));

        % Filter the signal
        notch_fft = test_fft.*notch;

        % Generate new audio file
        notch_sound = ifft(notch_fft);

        % Save new sound file
        location = strcat(test_dir(i).folder,'_',num2str(MEL_NUM_BANKS),...
                '_mel_',num2str(NOTCH_FILES(j)),'_notch');
        
        if ~exist(location, 'dir')
            mkdir(location);
        end
        
        filename = strcat(location,'/',test_dir(i).name);
        
        disp(strcat('Saving: ',filename));
        
        audiowrite(filename,real(notch_sound(1:test_length(i))),test_fs(i));
    end
end

%% Add noise to signal
for i = 1:TEST_REC_CNT

    for j = 1:length(NOISE_FILES)
        
        % Add WGN to signal
        out = awgn(test_signal(i,:),NOISE_FILES(j),'measured');

        % Save new sound file
        location = strcat(test_dir(i).folder,'_',...
                        num2str(NOISE_FILES(j)),'_dB_snr');
        
        if ~exist(location, 'dir')
            mkdir(location);
        end
        
        filename = strcat(location,'/',test_dir(i).name);
        
        disp(strcat('Saving: ',filename));
        
        audiowrite(filename,out(1:test_length(i)),test_fs(i));
    end
end
