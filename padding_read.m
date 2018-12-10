%% Author: Li Lu, written in Dec. 2018
function padding=padding_read(file,header,package)

len_header=8+4*7+4; % the last 4 is the length of subframe
package_len=cell2mat(package(:,2))+4+4;
length_all=sum(package_len)+len_header;
len_padding=header{2}-length_all;
if(len_padding~=0)
    padding=fread(file,len_padding,'uint8');
else
    padding=[];
end
