function [ data ] = DRT0packetRead( fileID, format )
% function that reads the DRT0 packet at the beginning of the binary data
% file: CYGNSS Level 1 Raw Intermediate Frequency Data Record

DRT0packet = fread(fileID, 35, format);
data.PacketType = [char(DRT0packet(1)) char(DRT0packet(2)) char(DRT0packet(3)) char(DRT0packet(4))];
data.GPSWeeks_Start = bi2de([de2bi(DRT0packet(5),8,'left-msb') de2bi(DRT0packet(6),8,'left-msb')],'left-msb');
data.GPSSeconds_Start = bi2de([de2bi(DRT0packet(7),8,'left-msb') de2bi(DRT0packet(8),8,'left-msb') de2bi(DRT0packet(9),8,'left-msb') de2bi(DRT0packet(10),8,'left-msb')],'left-msb');
data.DataFormat = DRT0packet(11);
data.SampleRate = bi2de([de2bi(DRT0packet(12),8,'left-msb') de2bi(DRT0packet(13),8,'left-msb') de2bi(DRT0packet(14),8,'left-msb') de2bi(DRT0packet(15),8,'left-msb')],'left-msb');
data.CH0FrontEndSelection = DRT0packet(16);
data.CH0LOFreq = bi2de([de2bi(DRT0packet(17),8,'left-msb') de2bi(DRT0packet(18),8,'left-msb') de2bi(DRT0packet(19),8,'left-msb') de2bi(DRT0packet(20),8,'left-msb')],'left-msb');
data.CH1FrontEndSelection = DRT0packet(21);
data.CH1LOFreq = bi2de([de2bi(DRT0packet(22),8,'left-msb') de2bi(DRT0packet(23),8,'left-msb') de2bi(DRT0packet(24),8,'left-msb') de2bi(DRT0packet(25),8,'left-msb')],'left-msb');
data.CH2FrontEndSelection = DRT0packet(26);
data.CH2LOFreq = bi2de([de2bi(DRT0packet(27),8,'left-msb') de2bi(DRT0packet(28),8,'left-msb') de2bi(DRT0packet(19),8,'left-msb') de2bi(DRT0packet(30),8,'left-msb')],'left-msb');
data.CH3FrontEndSelection = DRT0packet(31);
data.CH3LOFreq = bi2de([de2bi(DRT0packet(32),8,'left-msb') de2bi(DRT0packet(33),8,'left-msb') de2bi(DRT0packet(34),8,'left-msb') de2bi(DRT0packet(35),8,'left-msb')],'left-msb');


end

