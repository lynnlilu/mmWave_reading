%% Author: Li Lu, written in Dec. 2018
function header=header_read(file)

version=fread(file,2,'uint16');
version=num2str(version);
version=[version(4) '.' version(3) '.' version(2) '.' version(1)];
total_package_length=fread(file,1,'uint');
platform=fread(file,1,'uint');
platform=dec2hex(platform);
frame_num=fread(file,1,'uint');
CPU_time=fread(file,1,'uint');
object_num=fread(file,1,'uint');
data_structure_num_in_package=fread(file,1,'uint');
subframe=fread(file,1,'uint'); % this part is different from the document

header={version;total_package_length;platform;frame_num;...
    CPU_time;object_num;data_structure_num_in_package};
