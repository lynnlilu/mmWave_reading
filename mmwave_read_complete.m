%% Author: Li Lu, written in Dec. 2018
clear;
clc;
%% configuration
ADCsample_num=256;
range_bins_num=256; 
rx_num=4;
tx_num=1;
chirpsperframe=16; 

%% read data
file=fopen('xwr16xx_stream.dat');
size_frame=[];

% header
magicword=fread(file,8,'uint8');
header=header_read(file);
size_frame=[size_frame,8+4*7];

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
package_len=cell2mat(package(:,2))+4+4;
length_all=sum(package_len)+size_frame(1);
padding=padding_read(file);

%% following frames
magicword_template=[2;1;4;3;6;5;8;7];
headerall=header';
packageall={package};
while(~feof(file))
    magicword=[2;fread(file,7,'uint8')];
    if(~all(magicword==magicword_template==1))
        break;
    end
    tmpheader=header_read(file);
    tmppackage=cell(tmpheader{7},3); % 3 means tag,len and payload
    for i=1:header{7}
        TLV=parseTLV(file,tmpheader{6},range_bins_num,tx_num,rx_num,chirpsperframe);
        tmppackage(i,:)=TLV;
    end
    padding=padding_read(file);
    headerall=[headerall;tmpheader'];
    packageall=[packageall;{tmppackage}];
end

fclose(file);
