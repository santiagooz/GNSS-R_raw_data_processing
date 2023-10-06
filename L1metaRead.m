function [ meta ] = L1metaRead( L1meta_filename, DRT0_vars, time_to_process, ddmID, plot_tracks )
% Reads netCDF file and saves relevant variables in the output struct "meta".

variables_to_read = {'ddm_timestamp_gps_sec', 'prn_code', 'sp_ddmi_dopp', 'ddm_snr', 'sp_lat', 'sp_lon', 'sc_lat', 'sc_lon', 'sp_rx_gain'};
outstrct=struct('filename', L1meta_filename);
for i=1:length(variables_to_read)         % loop over the number of variables in variables_to_read
    eval(['a=ncread(L1meta_filename,''' variables_to_read{i} ''');'])    % reads in variable data
    outstrct = setfield(outstrct, variables_to_read{i}, a);
    clear a
end

S = outstrct.ddm_timestamp_gps_sec;

time_resolution = mode(diff(outstrct.ddm_timestamp_gps_sec(1:20)));
num_samples = ceil(time_to_process/time_resolution);

% Using the timing reference in the netCDF file and the starting time of the binary file,
% the start_index is obtained to get the PRN, central Doppler and SNR of
% the on board processed DDM (ddmID) during the time interval selected (time_to_process).
[~, start_index] = min(abs(S-DRT0_vars.GPSSeconds_Start));
end_index = start_index + num_samples - 1;

PRN = outstrct.prn_code;
Doppler_central = outstrct.sp_ddmi_dopp;
SNR = outstrct.ddm_snr;
sp_lat = outstrct.sp_lat;
sp_lon = outstrct.sp_lon;
sc_lat = outstrct.sc_lat;
sc_lon = outstrct.sc_lon;
sp_rx_gain = outstrct.sp_rx_gain;

meta.PRN = PRN(ddmID+1, start_index);
meta.Doppler_central = Doppler_central(ddmID+1, start_index : end_index);
meta.SNR = SNR(ddmID+1, start_index : end_index);

meta.ddm_timestamp = outstrct.ddm_timestamp_gps_sec(start_index : end_index);
meta.sp_lat = sp_lat(ddmID+1, start_index : end_index);
meta.sp_lon = sp_lon(ddmID+1, start_index : end_index);
meta.sp_rx_gain = sp_rx_gain(ddmID+1, start_index : end_index);


% If plot_tracks flag is 1, it plots the tracks of the 4 DDMs processed on
% board, with the antenna receiver gain value for that reflection
% represented by their color as reported in the metadata.

if plot_tracks == 1
    % geobasemap 'satellite'
    geobasemap 'landcover'
    colormap winter
    for dd = 1:4
            geoscatter(sp_lat(dd, start_index : end_index-1), sp_lon(dd, start_index : end_index-1),36,sp_rx_gain(dd, start_index : end_index-1), 'Filled');
            a = colorbar;a.Label.String = 'Rx Gain [dB]';
            hold on
        if dd == ddmID +1
            geoplot(sp_lat(dd, end_index), sp_lon(dd, end_index),'*','Color','m','linewidth',2);
            text(sp_lat(dd,end_index),sp_lon(dd,end_index)+.1,sprintf('ddmID = %i',dd-1),'FontSize',15,'Color','m')
        else
            geoplot(sp_lat(dd, end_index), sp_lon(dd, end_index),'*','Color',[0, 0, 100]/256,'linewidth',2);
            text(sp_lat(dd,end_index),sp_lon(dd,end_index)+.1,sprintf('ddmID = %i',dd-1),'FontSize',15,'Color',[0, 0, 155]/256)
        end
    end
    geoplot(sc_lat(start_index : end_index-1), sc_lon(start_index : end_index-1),'*','Color',[255, 153, 51]/256,'linewidth',2);
    geoplot(sc_lat(end_index), sc_lon(end_index),'*','Color',[100, 20, 0]/256,'linewidth',2);
    text(sc_lat(end_index),sc_lon(end_index)+.1,"CYGNSS satellite",'FontSize',10,'Color',[155, 20, 0]/256)
    geolimits([min(min(sp_lat(:, start_index : end_index))) max(max(sp_lat(:, start_index : end_index)))], [min(min(sp_lon(:, start_index : end_index))) max(max(sp_lon(:, start_index : end_index)))])
end

end

