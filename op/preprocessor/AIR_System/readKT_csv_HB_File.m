function  [header,data]=readKT_csv_HB_File(filename,sdata)
% Load AIR Files
%----------------------------------------------------
%   Syntax : 
%----------------------------------------------------
% [hdata,data]=readKT_csv_MeasureFile(mesfile,sdata)
%
%  hdata, data : P3 Continuous Data
%  mesfile     : hiPOT-X : HB-Files(csv)
%  sdata       : hiPOT-X : Setting-File Inormation.
%                cf) readTKSettingFile


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Read File & Make Continuous-Data.
offs=0;
offs_ext=0;

[pathname, fname, ext] = fileparts(filename{1});
% Check Extension
if strcmpi(ext,{'.csv'})==0,
  error('WOT-Measure Mode : Extension Error');
end

% ====================================
% Read file,
% ====================================
% file open
finfo=dir(filename{1}); % Get for Data-Size
[fid,message] = fopen(filename{1}, 'r', 'l');
if fid == -1, error(message); end
fclose(fid);

try
  % -- read Header-parts
  [dum]=textread(filename{1},'%s',2,'headerlines',offs+1,'delimiter',',');
  fver=dum{2};

  switch fver
    case '1.01.01'
      % -- fixed value

      % Oxy Data
      % get data lines
      [dum] = textread(filename{1}, '%c%*[^\n]','headerlines',offs+60,'delimiter',',');
      datasize=length(dum);
     
      % read all row as number of data
      dum = textread(filename{1},'%s',-1,'headerlines',offs+60,'delimiter',',');
      [row_size col_size] = size(dum);
      one_data_len = row_size/datasize;
      all_data = reshape(dum,[one_data_len,datasize]);
      if ( one_data_len > (1+22+4) ) % data with hard info
          select_index=[2 6 10 14 18 22 26 30 34 38 42 46 50 54 58 62 66 70 74 78 82 86];
%          mpd_index = [8 9 10 11 12 13 14 15]; % by K.Nakajo 2010.03.16
          mpd_index = [1 4 7 10 13 16 19 22];
          mpd_index = (mpd_index-1)*4+1+3;
          mpd_index = [mpd_index mpd_index+1];
          time_index = 1+22*4+2;
          mark_index = 1+22*4+1;
          HbOffset_index = 1+22*4+4;
      else % data without hard info
          select_index=[2:1:23];
          mpd_index = [];
          time_index = 1+22+2;
          mark_index = 1+22+1;
          HbOffset_index = 1+22+4;
      end
      dataid   = zeros(datasize, 1);
      chnum    = 22;
      stimkind = zeros(datasize, 1);
      timer0=repmat(' ',12,datasize);
      mpd      = zeros(16,datasize);

      % -- read Data-parts
      for id=1:datasize
        dataid(id) = str2num(all_data{1,id});
        if dataid(id)==0
          %--------------------
          % Skip Loading
          %--------------------
          oxy(:,id)   = NaN;
          %timer0(id)  = NaN;
          stimkind(id)= stimkind(id-1);
          warning('Broken Data Exist in %d',id);
        else
          %--------------------
          % Load One-Time Data
          %--------------------
          % get Channel-data
          dum =all_data(select_index,id);
          [row col] = size(dum);
          for iii=1:1:row
            oxy(iii,id)   = str2num(dum{iii});
          end
          % get Time-data
          timer0(:,id)=sprintf('%12s',all_data{time_index,id});  %% HH:MM:SS
          
          % get Mark-data
          mark = str2num(all_data{mark_index,id});
          if(mark==0)
              stimkind(id)=hex2dec('0000');
          else % mark == 1~10
              if (id<=1)
                stimkind(id)=hex2dec('0300'); % SS:1, SE:1 continue
              elseif(str2num(all_data{mark_index,id-1})==0)
                  stimkind(id)=hex2dec('0200'); % SS:1, SE:0 start
              elseif(str2num(all_data{mark_index,id-1})~=0)
                  if(id>=datasize) % last data % SS:1, SE:1 continue
                      stimkind(id)=hex2dec('0300'); % SS:0, SE:1 end
                  elseif(str2num(all_data{mark_index,id+1})~=0)
                  	  stimkind(id)=hex2dec('0300'); % SS:1, SE:1 continue
                  else
                      stimkind(id)=hex2dec('0100'); % SS:0, SE:1 end
                  end
              end
              stimkind(id)=bitor(stimkind(id),bitshift(mark,4));
          end
          HbOffset = str2num(all_data{HbOffset_index,id});
          if(HbOffset~=0)
              stimkind(id)=bitor(stimkind(id),bitshift(1,14));
          end
          % get Reserve-data
          %fseek(fid,2,0);
          if(size(mpd_index)>0)
              dum = all_data(mpd_index,id);
              [row col] = size(dum);
              for iii=1:1:row
                mpd(iii,id)   = str2num(dum{iii});
              end
          end
          %fseek(fid,40,0); %Reserv A
          %fseek(fid,28,0); %Reserv B
          %fseek(fid, 8,0); %Reserv C
        end
      end
      oxy = oxy';
      % Deoxy Data
      dum = textread(filename{2},'%s',-1,'headerlines',offs+60,'delimiter',',');
      [row_size col_size] = size(dum);
      one_data_len = row_size/datasize;
      all_data = reshape(dum,[one_data_len,datasize]);
      for id=1:datasize
        dataid(id) = str2num(all_data{1,id});
        if dataid(id)==0
          deoxy(:,id)   = NaN;
          stimkind(id)= stimkind(id-1);
          warning('Broken Data Exist in %d',id);
        else
          % get Channel-data
          dum =all_data(select_index,id);
          [row col] = size(dum);
          for iii=1:1:row
            deoxy(iii,id)   = str2num(dum{iii});
          end
        end
      end
      deoxy = deoxy';
      % Total Data
      dum = textread(filename{3},'%s',-1,'headerlines',offs+60,'delimiter',',');
      [row_size col_size] = size(dum);
      one_data_len = row_size/datasize;
      all_data = reshape(dum,[one_data_len,datasize]);
      for id=1:datasize
        dataid(id) = str2num(all_data{1,id});
        if dataid(id)==0
          tot(:,id)   = NaN;
          stimkind(id)= stimkind(id-1);
          warning('Broken Data Exist in %d',id);
        else
          % get Channel-data
          dum =all_data(select_index,id);
          [row col] = size(dum);
          for iii=1:1:row
            tot(iii,id)   = str2num(dum{iii});
          end
        end
      end
      tot=tot';
    otherwise % Version ??
      error(['Unknown Version : ' ver])
  end
catch
  rethrow(lasterror);
end

%====================================
% Modify Reading Data
%====================================
data=reshape([oxy,deoxy,tot],[datasize,chnum,3]);

% Offset
of = bitget(stimkind,14);
% Original-Mark (in AIR Format)
om = bitshift(bitand(stimkind,240),-4);
% Stimulation-Start
ss = bitget(stimkind, 10);
% Stimulation-End
se = bitget(stimkind,  9);
% Timer Modify
ts= datenum(timer0(:,1)');
te= datenum(timer0(:,end)') ;
timerange  =te-ts;
measuretime=timerange*24*60*60; % Date to sec
period      = measuretime/(datasize-1); % now : not used !! ( for debug)

%=================================
% --> Script File <--
%=================================
% Transform sdata, raw, (of) om, ss, se, (period)
% to  header,data
%  if you have data already rm raw !
SCRIPT_HIPOTX;
return;
