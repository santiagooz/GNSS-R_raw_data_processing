function [ y ] = coh_corr( S, fs, PRN, fD, tau, Ti, delay_initial)
% coh_corr calculates the correlation between the signal S
% and a local GPS C/A replica for every delay and Doppler
% value defined in tau and fD. It is expected that the coherent integration
% time is an integer multiple of 1 ms.

% If S is a matrix, their columns are treated as separate segments of the
% signal. The output y is a three-dimensional matrix representing a
% coherent correlation plane for each signal segment.

K = size(S,2);      % number of signal segments
fc = 1.023e6;       % C/A code chip frequency [Hz]

c = cacode(PRN);    % C/A code generation

Lf = size(fD,1);    % number of Doppler bins
Lt = length(tau);   % number of delay bins
y = zeros(Lt,K,Lf); % coherent correlation results

N = floor((floor((Ti-1e-5)/1e-3)+1)*1e-3*fs);
x0 = S;
n = 0 : N-1;
t = n'/fs;
os = 0;

% The coherent correlations are calculated as the IFFT of the product of
% their FFTs. Only the FFT of the Doppler shifted signal is calculated for
% every bin. The FFT of local replica with the corrseponding delay shift
% for every signal segment can be calculated outside of the loop that 
% iterates through the Doppler bins.
Cf = zeros(N,K);
for kk = 1:K
    C = c((mod(floor((n/fs+os)*fc-delay_initial(kk)),1023)+1));
    Cf(:,kk) = fft(C);
end
for indD = 1:Lf
    p = exp(-1i*2*pi*fD(indD,:).*t);
    xp = x0.*p;
    Xf = fft(xp);
    y_aux = ifft(conj(Cf).*Xf);
    y(:,:,indD) = 1/sqrt(N)*y_aux(1:Lt,:);
end


end
