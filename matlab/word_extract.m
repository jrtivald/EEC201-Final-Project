function y = word_extract(x,Fs,THRESH_DB,WORD_LENGTH_MS,show_plots)
%word_extract Extract word segment out of a signal
%   Detailed explanation goes here

% params
STFT_WIN_LEN_MS    = 20;
STFT_WIN_OVRLAP_MS = 15;
STFT_FFT_LEN       = 1024;

% normalize amplitude to [-0.5:0.5]
x_norm = (1/2) * x ./ norm(x,'Inf');

% generate window
win_num_smpls = STFT_WIN_LEN_MS/1000*Fs;
win_ovrlp_smpls = ceil(STFT_WIN_OVRLAP_MS/1000*Fs);
w = hamming(win_num_smpls,'periodic');

% STFT
[s,s_freq,s_time] = spectrogram(x_norm,w,win_ovrlp_smpls,STFT_FFT_LEN,Fs);

% PSD estimate of each frame; note that it is scales such that peak power 
% is 0 dB at peak signal amplitude
s_psd = (abs(s).^2)/sum(w);
%s_psd = (abs(s).^2)/(Fs*STFT_FFT_LEN);

% calculate avg power and peak power in each frame
s_avg_pwr = var(s_psd);
s_peak_pwr = max(s_psd);

% determine which frames contain peak power over the threshold
ovr_thresh_idx = find(db(s_avg_pwr,'power') > THRESH_DB);

% determine start and end of word envelope
word_start_idx = floor(s_time(ovr_thresh_idx(1))*Fs);
%word_end_idx = ceil(s_time(ovr_thresh_idx(end))*Fs);
word_end_idx = word_start_idx + WORD_LENGTH_MS/1000*Fs-1;

y = x(word_start_idx:word_end_idx);

if ~exist('show_plots','var')
    show_plots = 0;
end

if show_plots
    figure('Name','Spectrogram')
    imagesc(s_freq,s_time,db(s_psd,'power')')
    axis xy
    colorbar

    figure('Name','Word Extract Plots')
    subplot(4,1,1)
    plot(x)
    title('Input Signal')
    subplot(4,1,2)
    plot(db(s_avg_pwr,'power'))
    title('Input Sig. Avg. Power')
    subplot(4,1,3)
    plot(db(s_peak_pwr,'power'))
    title('Input Sig. Peak Power')
    subplot(4,1,4)
    plot(y)
    title('Output Signal')
end 

end

