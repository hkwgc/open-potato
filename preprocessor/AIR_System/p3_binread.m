function c=p3_binread(filename,opt0)
% test function for reading binary
%  like od


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin<=0
  filename='C:\AirControlCenterDataBase\SaveData\AirSaveInfoManager.asimtable';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Option 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.MachineFormat='n';
    
%--------------------
% Input Option
%--------------------
if nargin>=2
  if isfield(opt0,'MachineFormat')
    opt.MachineFormat=opt0.MachineFormat;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,msg]=fopen(filename,'r',opt.MachineFormat);
if fid==-1, error(msg); end
c=fread(fid,Inf,'*char');
l=length(c);
len=32;
m=mod(l,len);
if m~=0
  c(end+1:l+(len-m))=' ';
end
c=reshape(c,len,ceil(l/len));


disp(c');

fclose(fid);



