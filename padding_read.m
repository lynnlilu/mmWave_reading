%% Author: Li Lu, written in Dec. 2018
function padding=padding_read(file)

padding=fread(file,1,'uint8');
count=1;
while(padding~=2)
    padding=[padding;fread(file,1,'uint8')];
    count=count+1;
    if(count>=31)
        break;
    end
end
