%% Author: Li Lu, written in Dec. 2018
function TLV=parseTLV(file,object_num,range_bins_num,...
    tx_num,rx_num,chirpsperframe)

tag=fread(file,1,'uint');
len=fread(file,1,'uint');
payload=[];

if(tag==1) % detected objects
    descriptor=fread(file,2,'uint16');
    % contradictory in the document, now I use 4 bytes, since this value leads
    % to z-coordinate of all-zeros
    % descriptor process
    dec_obj_num=descriptor(1);
    xyz_q_format=descriptor(2);
    i=0;
    range_index=[];
    doppler_index=[];
    peak_value=[];
    x_coordinate=[];
    y_coordinate=[];
    z_coordinate=[];
    while(i~=object_num)
        i=i+1;
        range_index=[range_index,fread(file,1,'uint16')];
        doppler_index=[doppler_index,fread(file,1,'uint16')];
        peak_value=[peak_value,fread(file,1,'uint16')];
        % x,y,z coordinate can be derived through divide with 2^q_format
        x_coordinate=[x_coordinate,fread(file,1,'int16')/2^xyz_q_format];
        y_coordinate=[y_coordinate,fread(file,1,'int16')/2^xyz_q_format];
        z_coordinate=[z_coordinate,fread(file,1,'int16')/2^xyz_q_format];
    end
    payload={descriptor;range_index;doppler_index;peak_value;x_coordinate;...
        y_coordinate;z_coordinate};
elseif(tag==2) % range profile
    size_range=range_bins_num;
    range_profile_log=fread(file,size_range,'uint16'); % the unit of two profiles is 2 bytes
    payload={range_profile_log};
elseif(tag==3) % noise profile
    size_range=range_bins_num;
    noise_profile_log=fread(file,size_range,'uint16'); % the unit of two profiles is 2 bytes
    payload={noise_profile_log};
elseif(tag==4) % range azimuth heatmap
    virtual_ant_num=rx_num*tx_num;
    size_rahp=range_bins_num*virtual_ant_num;
    tmp_ra_heatmap=fread(file,size_rahp*2,'uint16'); % prior 16bit is imag, and posterior 16bit is real
    tmp_complex=zeros(size_rahp,1);
    dif=0;
    for i=1:2:size_rahp*2-1
        index=i-dif;
        tmp_complex(index)=complex(tmp_ra_heatmap(i+1),tmp_ra_heatmap(i));
        dif=dif+1;
    end
    ra_heatmap=reshape(tmp_complex.',virtual_ant_num,range_bins_num);
    ra_heatmap=ra_heatmap.';
    payload={ra_heatmap};
elseif(tag==5) % range doppler heatmap
    doppler_bins_num=chirpsperframe/tx_num;
    size_rdhp=range_bins_num*doppler_bins_num;
    tmp_rd_heatmap=fread(file,size_rdhp,'uint16');
    rd_heatmap=reshape(tmp_rd_heatmap.',doppler_bins_num,range_bins_num);
    rd_heatmap=rd_heatmap.';
    payload={rd_heatmap};
elseif(tag==6) % stats
    interframe_process_time=fread(file,1,'uint');
    transmit_output_time=fread(file,1,'uint');
    interframe_prcocess_margin=fread(file,1,'uint');
    interchirp_process_margin=fread(file,1,'uint');
    active_frame_cpu_load=fread(file,1,'uint');
    interframe_cpu_load=fread(file,1,'uint');
    payload={interframe_process_time;transmit_output_time;interframe_prcocess_margin;...
        interchirp_process_margin;active_frame_cpu_load;interframe_cpu_load};
end
TLV={tag;len;payload};
