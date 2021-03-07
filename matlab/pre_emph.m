function y = pre_emph(x)
% pre_emph: Runs input signal through pre-emphasis filter to remove DC
% componenet and emphesize higher frequency components.
%
% USAGE: y = pre_process(x)
%
% INPUTS: 
%   x - input signal vector
%
% OUTPUTS:
%   y - output signal after it is filtered

% pre-emphasis filter
y = [x(1),x(2:end) - x(1:end-1)];

end

