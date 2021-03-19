function y = word_extract(x,Fs,THRESH_DB,WORD_LENGTH_MS,show_plots)
%word_extract Extract word segment out of a signal
%
% USAGE: y = word_extract(x,fs,thresh_db,word_length_ms,show_plots)
%
% INPUTS:
%   x - Input signal
%   fs - Input signal sample rate
%   thresh_db - Detection threshold in dB. Determines the power of the that
%       the input signal needs to go over for the word to be detected.
%   word_length_ms - The amount of time to extract for the word.
%   show_plots - Generated plots for debugging.
%
% OUTPUTS:
%   y - Output signal that contains the extracted word segment.

% params
STFT_WIN_LEN_MS    = 25;
STFT_WIN_OVRLAP_MS = 15;
STFT_FFT_LEN       = 1024;

% generate window
win_num_smpls = ceil(STFT_WIN_LEN_MS/1000*Fs);
win_ovrlp_smpls = ceil(STFT_WIN_OVRLAP_MS/1000*Fs);
w = hamming(win_num_smpls,'periodic');

% STFT
[s,s_freq,s_time] = spectrogram(x,w,win_ovrlp_smpls,STFT_FFT_LEN,Fs);

% PSD estimate of each frame
s_psd = (abs(s).^2)/STFT_FFT_LEN;

% calculate avg power and peak power in each frame
s_avg_pwr = var(s_psd);
s_peak_pwr = max(s_psd);

% determine which frames contain avg. power over the threshold
ovr_thresh_idx = find(db(s_avg_pwr,'power') > THRESH_DB);

% determine start and end of word envelope
word_start_idx = floor(s_time(ovr_thresh_idx(1))*Fs);
word_end_idx = word_start_idx + ceil(WORD_LENGTH_MS/1000*Fs)-1;

y = x(word_start_idx:word_end_idx);

if ~exist('show_plots','var')
    show_plots = 0;
end

if show_plots
%     figure('Name','Spectrogram')
%     imagesc(s_freq,s_time,db(s_psd,'power')')
%     axis xy
%     colorbar

    figure('Name','Word Extract Plots')
    subplot(3,1,1)
    plot(x)
    title('Input Signal')
    xlabel('sample')
    ylabel('amplitude')
    grid on
    subplot(3,1,2)
    plot(db(s_avg_pwr,'power'))
    title('Input Sig. Avg. Power')
    xlabel('frame')
    ylabel('dB')
    grid on
    subplot(3,1,3)
    plot(y)
    title('Output Signal')
    xlabel('sample')
    ylabel('amplitude')
    grid on
end 

end

