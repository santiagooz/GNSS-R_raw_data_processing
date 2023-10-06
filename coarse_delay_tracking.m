%% Coarse delay tracking
% Run this script after main.m to estimate the residual delay difference in
% DDM time series
clear delay_central0
for batch = 1 : num_ddm
    [a, b] = find(ddm(:,:,batch)==max(max(ddm(:,:,batch))));

    delay1 = delay0 + delay_initial + delay_central((batch-1)*K+1);
    delay_central0(batch) = delay1(a) - 340;
end

t0 = K*Ti*(0:length(delay_central0)-1);

figure;plot(delay_central0)

% % exclude outliers
% excluded_datapoints = [37:45 50:61 71:86];
% t0(excluded_datapoints) = [];
% delay_central0(excluded_datapoints) = [];

figure;plot(t0, delay_central0)

%% Save in files directory

save(delay_filename,'t0','delay_central0')