% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Mel-Frequency Cepstrum Coefficients
%
% Description: This functions will find the MFCCs of a signal
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 2/26/2021

function mfcc_coeffs = mfcc(xn, fs, frm_sz_ms, frm_ovr_ms, fft_N, ...
    mel_num_banks, ceps_start_bank, ceps_num_banks, gen_plots)

    % convert frame specs from mS to samples
    frm_sz_smpls = ceil(frm_sz_ms/1000*fs);
    frm_ovr_smpls = ceil(frm_ovr_ms/1000*fs);
    
    % generate signal spectrogram (STFT)
    [spec,spec_freq,spec_time] = spectrogram(xn,hamming(frm_sz_smpls),...
        (frm_ovr_smpls),fft_N,fs);

    % magnitude squared of the spectrogram frames
    spec_mag_2 = spec .* conj(spec);
    
    % generate mel-freq filter bank matrix
    mel_banks = melfb_gen(mel_num_banks,fft_N,fs);
    
    % filter spectrum frames through mel-spaced filter bank
    mel = mel_banks * spec_mag_2;

    % calculate cepstrum
    mel_log = log(mel);
    ceps = dct(mel_log);
    
    % select desired cepstrum banks
    ceps_sel = ceps(ceps_start_bank:ceps_start_bank+ceps_num_banks,:);
    
    % normalize range to [-1:1] (inf. norm)
    ceps_frame_norm = zeros(1,numel(spec_time));
    for i = 1:numel(spec_time)
        ceps_frame_norm(i) = norm(ceps_sel(:,i),'Inf');
    end
    ceps_normalized = ceps_sel ./ ceps_frame_norm;
    
    % Output the MFCC coefficients
    mfcc_coeffs = ceps_normalized;
    
    % enable plots for debug
    if ~exist('gen_plots','var')
        gen_plots = false;
    end
    
    if gen_plots 
        % Plot input
        figure('name','Input Signals')
        plot(xn)
        title('Inpus Signal')
        xlabel('sample')
        ylabel('amplitude')

        % display signal spectrogram
        figure('Name','Signal Spectrogram')
        imagesc(spec_freq,spec_time,db(spec_mag_2)')
        colorbar
        axis xy
        title('Signal Spectrogram')
        xlabel('Freq. (Hz)')
        ylabel('Time (s)')
    
        % plot filterbanks
        figure('Name','Mel-Spaced Filter Banks')
        plot(spec_freq,mel_banks)
        title('Mel-Spaced Filter Banks')
        xlabel('freq. (Hz)')
        ylabel('Magnitude')
        grid on

        % display filter bank spectrogram
        figure('Name','Filter Bank Spectrogram')
        imagesc(0:mel_num_banks-1,spec_time,db(mel)')
        colorbar
        axis xy
        title('Mel-Spaced Filter Bank Spectrogram')
        xlabel('Bank Index')
        ylabel('Time (s)')

        % plot cepstrum
        figure('Name','Cepstrum')
        imagesc(0:mel_num_banks-1,spec_time,ceps')
        colorbar
        axis xy
        title('Cepstrum')
        xlabel('index')
        ylabel('Time (s)')
        
        % plot MFCC coefficients
        figure('Name','MFCC Coefficients')
        imagesc(0:ceps_num_banks-1,spec_time,mfcc_coeffs')
        colorbar
        axis xy
        title('MFCC Coefficients')
        xlabel('index')
        ylabel('Time (s)')

    end 
    
end