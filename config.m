%% project: GNSS-R_raw_data_procssing
%
% Configuration script.

%% Input parameteres

time_to_process = 60;   % total time to process
caseID = 0;     % case ID number listed in case_selector.m

% Processing and delay-Doppler plane parameters
Ti = 1e-3;      % coherent integration time [secs]
Tnc = 0.5;        % non-coherent integration time [secs]
dec_ratio = 4;  % decimation ratio
Doppler_resolution = 500;   % DDM Doppler bin resolution [Hz]
Doppler_spread = 2e3;       % DDM Maximum Doppler deviation[Hz]
Doppler_offset = 0;         % Optional Doppler offset [Hz]

folder_path = ".\files\"; % files directory path

plot_tracks = 1; % flag to plot reflection tracks over the surface

%% Loading and defining required values for processing

case_selector % defines input file names corresponding to the selected case

% Useful constants
fc = 1.023e6;       % C/A code chip frequency [Hz]
fL1 = 1575.42e6;    % L1 C/A nominal carrier frequency [Hz]
fIF = fL1 - fOL;    % Front-end intermediate frequency [Hz]

% Delay bins
delay_resolution = dec_ratio/fs*fc;  % delay resolution, given by the dec_ratio [chips]
delay_initial = 0;                   % initial delay value [chips]
delay0 = (0 : delay_resolution : Ti*fc-delay_resolution); % delay axis starting in 0 chips
Lt = length(delay0);

% Doppler bins
Doppler0 = -Doppler_spread : Doppler_resolution : Doppler_spread; % Doppler axis centered in 0 Hz
Lf = length(Doppler0);

K = floor(Tnc/Ti);                     % non-coherent integration time in samples (Tnc = K*Ti)
num_ddm = floor(time_to_process/Ti/K); % Number of DDMs calculated during the processing time

N = floor(Ti*fs);   % Integration time in samples
bytes_to_read = ceil(K*Ti*fs/4);   % Number of bytes to read for a single DDM
deltaN_sampling = Ti*fs-N;  % Error in samples due to rounding in a coherent integration time interval

% offset variables used while reading the binary file for each DDM
bytes_offset = 0;
samples_offset = 0;
offset = 0;

% expected excess of bytes needed to read due to Doppler effect in the code
% signal phase (worst case)
bytes_guard = ceil(abs(min(Doppler_central))*Ti/1540*fs/fc*K/4)+1;

% Necessary matrices initialization
Doppler = zeros(Lf, K);
ddm = squeeze(zeros(Lt, Lf, num_ddm));

