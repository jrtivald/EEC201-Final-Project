function output_signal = read_signal(signal_path,fs,channel)
%read_signal read in signal from a file.
%
%   USAGE: output_signal = read_signal(signal_path,fs,channel)
%
%   INPUTS:
%       signal_path - path of the signal to read in
%       fs - desired output sample rate
%       channel - which channel to use if input signal is stereo
%
%   OUTPUTS:
%       output_signal - vector of the signal that was read in

% read in signal
[tmp_wav, tmp_fs] = audioread(signal_path);

% check if stereo
if size(tmp_wav,2) > 1
    tmp_wav = tmp_wav(:,channel);
end

% resample to desired rate
if tmp_fs ~= fs
    output_signal = resample(tmp_wav,fs,tmp_fs)';
else
    output_signal = tmp_wav';
end

end

