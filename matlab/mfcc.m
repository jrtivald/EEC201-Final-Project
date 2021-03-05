% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Mel-Frequency Cepstrum Coefficients
%
% Description: This functions will find the MFCCs of a signal
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 2/26/2021

function coeff = mfcc(xn, fs, premph, frm_sz, frm_ovr, N)

    %Apply Pre-Emphasis
    xn_emph = [xn(1), xn(2:end)-premph.*xn(1:end-1)];
    
    %Apply framing
    %Determine frame and overlap indecies
    sz_idx = round(frm_sz*fs*0.001);
    ovr_idx = round(frm_ovr*fs*0.001);
    frm_step = sz_idx-(ovr_idx/2);
    num_frm = ceil(abs(length(xn)-sz_idx)/frm_step);
    
    %Generate Frames
    emph_idx = repmat((1:sz_idx),num_frm,1) + repmat((1:frm_step:num_frm*frm_step),sz_idx,1)';
    x_frms = xn_emph(emph_idx);
    
    %Generate Hamming window and apply to all frames
    hw = hamming(sz_idx);
    x_frm_win = x_frms.*repmat(hw',num_frm,1);
    
    %Calculate the FFT and Periodogram of all the frames
    x_frm_fft = fft(x_frm_win, N, 2);
    x_frm_period = (abs(x_frm_fft).^2)/N;
    x_frm_period_freq = 0:fs/N:fs-(fs/N);
    
    %Cesptral Coefficients
    
    %Mean Normalization
    
    %Output the MFCCs
    coeff = x_frm_period;
    
    %Plot input and pre-emphasis
    figure('name','MFCC')    
    tiledlayout(2,1)

    % Plot input
    ax1 = nexttile;
    plot(xn)
    title('xn')

    % Pre-Emphasis plot
    ax2 = nexttile;
    plot(xn_emph)
    title('pre-emph(xn)')
    
    linkaxes([ax1 ax2],'xy')
    
    %Plot a random frame for spot check
    figure('name','Frame Analysis')
    
    %Choose random frame
    idx = round(rand(1)*num_frm);
    
    %plot the frame of data
    subplot(1,3,1)
    plot(0:sz_idx-1,x_frms(idx,:))
    title(strcat('Frame ',num2str(idx),' data'))
    
    %plot the windowed data
    subplot(1,3,2)
    plot(0:sz_idx-1,x_frm_win(idx,:))
    title(strcat('Frame ',num2str(idx),' Windowed'))
    
    %plot the data periodogram
    subplot(1,3,3)
    plot(x_frm_period_freq,x_frm_period(idx,:))
    title(strcat('Frame ',num2str(idx),' Periodogram'))

end