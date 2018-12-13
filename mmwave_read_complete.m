%% Author: Li Lu, written in Dec. 2018
clear;
clc;
%% configuration
ADCsample_num=256;
range_bins_num=256; 
rx_num=4;
tx_num=1;
% the number of loops in frameCfg -> may be right
% according to https://e2e.ti.com/support/sensors/f/1023/t/626801
chirpsperframe=16; 
magicword_template=[2;1;4;3;6;5;8;7];

%% read data
file=fopen('xwr16xx_stream.dat');

% header
magicword=fread(file,8,'uint8');
header=header_read(file);

package=cell(header{7},3); % 3 means tag,len and payload
for i=1:header{7}
    TLV=parseTLV(file,header{6},range_bins_num,tx_num,rx_num,chirpsperframe);
    package(i,:)=TLV;
end
% descriptor process
do_payload=package(1,3);
descriptor=do_payload{1};
dec_obj_num=descriptor(1);
xyz_q_format=descriptor(2);

%% padding generation
padding=padding_read(file,header,package);

%% following frames
headerall=header';
packageall={package};
while(~feof(file))
    magicword=fread(file,8,'uint8');
    if(isempty(magicword) || ~all(magicword==magicword_template==1))
        break;
    end
    tmpheader=header_read(file);
    tmppackage=cell(tmpheader{7},3); % 3 means tag,len and payload
    for i=1:tmpheader{7}
        TLV=parseTLV(file,tmpheader{6},range_bins_num,tx_num,rx_num,chirpsperframe);
        tmppackage(i,:)=TLV;
    end
    padding=padding_read(file,tmpheader,tmppackage);
    headerall=[headerall;tmpheader'];
    packageall=[packageall;{tmppackage}];
end

fclose(file);
