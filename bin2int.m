function [ Data_int, success ] = bin2int( fileID, format, bytes_to_read, samples_offset, num_channels )
% Reads the samples of the signal registered in the binary file fileID and
% stores them as integers in the array Data_int.
% Using 2-bit representation, the number of samples read is
% bytes_to_read*4-samples_offset

bits_to_read = bytes_to_read*8;
ii = 1:2:bits_to_read-1;
success = false;
Data_int = [];

Data = fread(fileID, bytes_to_read, format, num_channels-1);
if length(Data) == bytes_to_read
    Data_b1 = de2bi(Data,'left-msb');
    Data_b2 = reshape(Data_b1',1,[]);
    Data_int = (2*Data_b2(ii+1)+1).*(-1).^(Data_b2(ii)+1);
    Data_int = Data_int(1+samples_offset:end );
    success = true;
end