function varargout=P3(varargin)
% Platform for Optical Topography Analysis Tools,
%   Platform Version 3
persistent p3ash;
if nargin==1
  if  isequal(varargin{1},'getStatusHandle')
    varargout{1}=p3ash;return;
  end
  if  ishandle(varargin{1})
    p3ash=varargin{1};return;
  end
end
if nargin>=2 && strcmp(varargin{1},'hiPOTX')
  % Open hiPOTX
  P3_path;
  P3_hiPOTX_IO(varargin{2:end}); 
  return;
end

% (...)
% try
%   fnt=get(0,'FixedWidthFontName');
%   set(0,'defaultUicontrolFontName',fnt);
% catch
% end
%==========================================================================
% Open Start-up Window
%==========================================================================
%[h0 h2 p3ash]=POTATo_About('StartUp','Launching P3'); %#ok h2 is not use
[h0 h2 p3ash]=POTATo_About('StartUp','Launching...'); %#ok h2 is not use

%==========================================================================
% Delete Old Data
set(p3ash,'String',{'Delete working M-File ....'});
POTATo_About;
%==========================================================================
wkdir=[fileparts(which('P3')) filesep 'ospData' filesep];
delete([wkdir 'ana_*']);
% Book-Mark Update
d=dir([wkdir 'FilterBookMarkData*.mat']);
inewfbm=find(strcmpi({d.name},'FilterBookMarkData_new.mat'));
ioldfbm=find(strcmpi({d.name},'FilterBookMarkData.mat'));
if length(inewfbm)==1 
  l0=length(ioldfbm);
  if l0==0
    copyfile([wkdir filesep 'FilterBookMarkData_new.mat'],...
      [wkdir filesep 'FilterBookMarkData.mat']);
  elseif l0==1 &&  (datenum(d(ioldfbm).date) < datenum(d(inewfbm).date))
    a=questdlg({'Filter List is updated:','Do you want to Replace?'},...
      'Platform Update Information','Yes','No','No');
    if strcmpi(a,'Yes')
      copyfile([wkdir filesep 'FilterBookMarkData_new.mat'],...
        [wkdir filesep 'FilterBookMarkData.mat']);
    else
      movefile([wkdir filesep 'FilterBookMarkData_new.mat'],...
          [wkdir filesep 'FilterBookMarkData_default.mat']);
    end
  end
end




%==========================================================================
% Path Setting
set(p3ash,'String',{'Path Setting : ....'});
POTATo_About;
%==========================================================================
P3_path;
% Confine Same POTATo_About
[h00 h2 p3ash0]=POTATo_About('StartUp','Launching P3'); %#ok h2 is not use
if ~isequal(h0,h00)
  delete(h0);
  h0=h00; p3ash=p3ash0;
  P3(p3ash); %<-- path confuce in MATLAB...
end
set(p3ash,'String',{'Path Setting : Done','Open Platform...'});
POTATo_About;


%==========================================================================
% Open POTATo
%==========================================================================
h=POTATo;

%==========================================================================
% ========>  Try to Open External .<=======
%==========================================================================
n=length(varargin);
s=get(p3ash,'String');
for idx=1:n
  try
    s(end+1:end+2)={'Evalationg +Alpha Options...',varargin{idx}};
    set(p3ash,'String',s);
    POTATo_About;
  catch
    % --> Coments...
  end
  eval(varargin{idx},'warndlg(lasterr)');
end
if nargout>=1
  varargout{1}=h; % Default : do not return;
end

p3ash=[];delete(h0);
