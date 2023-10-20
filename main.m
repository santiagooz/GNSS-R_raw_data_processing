%% project: GNSS-R_raw_data_processing
% Santiago Ozafrain, Oct 2018. Updated: Oct 2023.
% UIDET-SENyT, Facultad de Ingenieria, UNLP.

% Main script.

clear;
close all;
clc


config % runs configuration script


%% DDM processing
% num_ddm consecutive DDMs are calculated. For every DDM a batch of bytes
% in the binary file is read and processed.

tic

wb = waitbar(0, 'Processing data: 0% completed');
for batch = 1 : num_ddm

    signal = zeros(ceil(N/dec_ratio),K); % signal matrix initialization, each column corresponds to a coherent integration interval

    % move to the starting position for this batch to read (skipping DRT0 packet)
    fseek(fileID, 35 + channel + bytes_offset*num_channels, -1);

    % reads a batch from the binary file and saves it in the array signal_IF
    [signal_IF, success] = bin2int(fileID, format, bytes_to_read + bytes_guard, samples_offset, num_channels);

    sum_offset = 0;  % accumulated sample difference due to sample rounding and Doppler deviation in the code signal

    if success ==  true
        pointer = 1; % pointer to the start of the signal segment used in each integration

        for kk = 1:K
            Doppler(:, kk) = Doppler0 + Doppler_central((batch-1)*K+kk) + Doppler_offset;       % Doppler bins for this coherent integration
            deltaN_Doppler = -Ti*(Doppler_central((batch-1)*K+kk) + Doppler_offset)/1540*fs/fc; % Code phase error in samples due to Doppler deviation

            % Selects the corresponding signal segment, downconverts to
            % baseband and stores it in the matrix signal after decimation
            signal_aux = signal_IF((pointer : pointer+N-1)+floor(sum_offset));
            signal(:,kk) = decimate(signal_aux.*exp(-1i*2*pi*fIF/fs*(0:N-1)), dec_ratio, 'fir');

            % accumulate sample difference and update pointer
            sum_offset = deltaN_sampling + deltaN_Doppler + sum_offset;
            pointer = pointer + N;
        end

        % coherent correlation calculation
        y = coh_corr( signal, fs/dec_ratio, meta.PRN, Doppler, delay0, Ti, delay_initial + delay_central((batch-1)*K+1:batch*K));

        % non-coherent averaging
        if Lf > 1  % more than one frequency bin (DDM)
            if K == 1
                ddm(:,:,batch) = squeeze(abs(y).^2);
            else
                ddm(:,:,batch) = squeeze(mean(abs(y).^2,2));
            end
        else       % only one frequency bin (WF)
            ddm(:,batch) = mean(abs(y).^2,2);
        end
    end

    % update offsets to move starting position for next batch
    offset = offset + pointer + sum_offset;
    bytes_offset = floor(offset/4);
    samples_offset = floor(mod(offset,4));

    % progression bar
    time_past = toc;
    time_per_batch = time_past/batch;
    time_left = (num_ddm-batch)*time_per_batch;
    time_left_h = floor(time_left/3600);
    time_left_m = floor((time_left - time_left_h*3600)/60);
    time_left_s = floor(time_left - time_left_h*3600 - time_left_m*60);
    msg = sprintf('Processing data: %i%% completed - %i:%i:%i remaining', floor(batch/num_ddm*100), time_left_h, time_left_m, time_left_s);
    waitbar(batch/num_ddm, wb, msg)
end
close(wb)

% If the data register is shorter than time_to_process, the last DDMs are
% all zero. This loop fixes it.
if Lf >1
    while ~any(ddm(:,:,num_ddm),'all')
        num_ddm = num_ddm-1;
    end
else
    while ~any(ddm(:,num_ddm))
        num_ddm = num_ddm-1;
    end
end

fclose(fileID); clear y signal signal_aux;
%%  Plot DDM (or WF) time series

% linear interpolation of the SP ground track in the metadata
a = linspace(0,1,num_ddm); dt1 = mode(diff(t1));
sp_lat_int = meta.sp_lat(1) + (meta.sp_lat(floor(num_ddm*K*Ti/dt1))-meta.sp_lat(1))*a;
sp_lon_int = meta.sp_lon(1) + (meta.sp_lon(floor(num_ddm*K*Ti/dt1))-meta.sp_lon(1))*a;

SNRdB = zeros(1, num_ddm);
SNRdBmax = 21; % max value in y axis for SNRdB plot

fh = figure(123);
fh.WindowState = 'maximized';
for batch = 1 : num_ddm
    delay = delay0 + delay_initial + delay_central((batch-1)*K+1);
    if Lf > 1 % plots DDM and WF
        Doppler = Doppler0 + Doppler_central((batch-1)*K+1) + Doppler_offset;


        ddm_mean = mean(ddm,3);
        [delay_max, doppler_max] = find(ddm_mean == max(ddm_mean(:)));
        NL = mean(ddm(1 : delay_max-30, :, batch), 'all');  % noise level
        ddm_max = max(ddm(:,:,batch), [], 'all');
        SNRdB(batch) = 10*log10(ddm_max/NL-1);

        subplot(2,2,1)
        colormap(subplot(2,2,1),parula)
        surf(Doppler*1e-3, delay, ddm(:,:,batch));shading interp
        view([90 90])
        axis([Doppler(1)*1e-3 Doppler(end)*1e-3 delay(delay_max)-20 delay(delay_max)+20 min(ddm(:)) max(ddm(:,:,batch),[],'all')*1.1])
        ylabel('delay [chips]');xlabel('Doppler [kHz]');
        tit = sprintf('DDM num %i - SNR = %.2g dB', batch, SNRdB(batch));
        title(tit)

        subplot(2,2,3)
        hold off
        plot(delay, ddm(:,doppler_max,batch),'Linewidth',2);
        hold on
        plot(delay, NL*ones(size(delay)),'--r');
        plot(delay, ddm_max*ones(size(delay)),'--g');
        axis([delay(delay_max)-20 delay(delay_max)+20 min(ddm(:)) max(ddm(:,:,batch),[],'all')*1.1])
        xlabel('delay [chips]'); grid on
        tit = sprintf('WF num %i - SNR = %.2g dB', batch, SNRdB(batch));
        title(tit)

    else % plots only WF
        ddm_mean = mean(ddm,2);
        delay_max = find(ddm_mean == max(ddm_mean(:)));
        NL = mean(ddm(1 : delay_max-30, batch));  % noise level
        [ddm_max, max_idx] = max(ddm(:,batch));
        SNRdB(batch) = 10*log10(ddm_max/NL-1);

        subplot(2,2,1)
        plot(delay, ddm(:,batch),'Linewidth',2);
        axis([delay(delay_max)-20 delay(delay_max)+20 min(ddm(:)) max(ddm(:,batch))*1.1])
        grid on
        hold on;
        stem(delay(max_idx),ddm(max_idx,batch));
        plot(delay, NL*ones(size(delay)),'--r');
        plot(delay, ddm_max*ones(size(delay)),'--g');
        hold off


        xlabel('delay [chips]');
        tit = sprintf('WF num %i - SNR = %.2g dB', batch, SNRdB(batch));
        title(tit)


    end

    % Plots interpolated SP ground tracks. Their color represents the
    % estimated SNR of the corresponding DDM.
    subplot(2,2,2);
    title('Reflection ground track')
    geoscatter(sp_lat_int(batch),sp_lon_int(batch),36,SNRdB(batch),'Filled');
    colormap(subplot(2,2,2), autumn)
    a = colorbar;a.Label.String = 'SNR [dB]';
    geolimits([min(sp_lat_int)-.1 max(sp_lat_int)+.1], [min(sp_lon_int)-.1 max(sp_lon_int)+.1])
    hold on
    geobasemap topographic

    % Plots estimated SNR.
    subplot(2,2,4);
    plot((0:batch-2)*K*Ti, SNRdB(1:batch-1),'*','Color',[0, 0, 155]/256); grid on;hold on
    plot((batch-1)*K*Ti, SNRdB(batch),'*','Color',[200, 50, 0]/256); grid on;hold on
    xlabel('t [s]');ylabel('SNR [dB]');title('Estimated signal to noise ratio')
    axis([0 (num_ddm-1)*K*Ti -10 SNRdBmax])

    pause(.005)
end

