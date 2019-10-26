function varargout=vgdata2txt(vgdata,mode,varargin)
% vgdata2txt transfar View-Group-Object Data to Text
%
%  celltxt = vgdata2txt(DATA);
%    DATA     : LAYOUT-Data / View-Group-Data
%    celltxt  : Cell String, correnspond to DATA.
%
% VGDATA2TXT with Mode :::
% == Text Mode ==
%  celltxt = vgdata2txt(LAYOUT,'text');
%    is as same as celltxt = vgdata2txt(DATA);
%
% [celltxt, pathlist, idx]=vgdata2txt(vgdata,'text',ObjectPath);
%     ObjectPath : Path of Object that you want to search.
%     idx         : Index of celltxt, correspond to ObjectPath
%
%  celltxt2 = vgdata2txt(LAYOUT,'text2');
%    celltxt2  : Cell String, correnspond to DATA.
%                with ID-Number for header.
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arguments Check
%%%%%%%%%%%%%%%%%%%%%%%%%%
msg =nargchk(1,10,nargin);
if ~isempty(msg), error(msg); end

%========================
% 1st Argument
%========================
% If Input data is LAYOUT
if ~iscell(vgdata) ...
    && isfield(vgdata,'vgdata')
  vgdata = vgdata.vgdata;
end

%========================
% 2nd Argument
%========================
if nargin==1, mode='Text';end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initilize
%%%%%%%%%%%%%%%%%%%%%%%%%%
cvgp0=[];

switch lower(mode),
  %%%%%%%%%%%%%%%%%%%%%%
  case 'text'
    %%%%%%%%%%%%%%%%%%%%%%
    txt = {' === Selected View Group-Data ==='};
    ud  = {[]};
    head= '  >>';
    %=================
    % Execution
    %=================
    [txt, ud]=getText(vgdata,txt,cvgp0,head,ud);
    %=================
    % Output of Text
    %=================
    if nargout >=1,
      varargout{1}=txt;
      if nargout>=2
        varargout{2}=ud;
      end
    end
    %=================
    % Output of Index
    %=================
    if nargout >=3,
      opidx=1; % Default
      if length(varargin)>=1,
        ObjectPath=varargin{1};
        for idx=1:length(ud),
          if isequal(ud{idx},ObjectPath),
            opidx=idx;
          end
        end
      end
      varargout{3}=opidx;
    end
    %%%%%%%%%%%%%%%%%%%%%%
  case 'text1'
    %%%%%%%%%%%%%%%%%%%%%%
    txt = {' === Selected View Group-Data ==='};
    ud  = {[]};
    head= '  >>';
    head2 = '             ';
    %=================
    % Execution
    %=================
    [txt, ud]=getText1(vgdata,txt,cvgp0,head,head2,ud);
    %=================
    % Output of Text
    %=================
    if nargout >=1,
      varargout{1}=txt;
      if nargout>=2
        varargout{2}=ud;
      end
    end
    %=================
    % Output of Index
    %=================
    if nargout >=3,
      opidx=1; % Default
      if length(varargin)>=1,
        ObjectPath=varargin{1};
        for idx=1:length(ud),
          if isequal(ud{idx},ObjectPath),
            opidx=idx;
          end
        end
      end
      varargout{3}=opidx;
    end
    %%%%%%%%%%%%%%%%%%%%%%
  case 'text2'
    %%%%%%%%%%%%%%%%%%%%%%
    txt = {' === View Group-Data ==='};
    ud  = {[]};
    head  = '> ';
    head2 ='';
    %=================
    % Execution
    %=================
    [txt, ud]=getText2(vgdata,txt,cvgp0,head,head2, ud);
    %=================
    % Output of Text
    %=================
    if nargout >=1,
      varargout{1}=txt;
      if nargout>=2
        varargout{2}=ud;
      end
    end
    %=================
    % Output of Index
    %=================
    if nargout >=3,
      opidx=1; % Default
      if length(varargin)>=1,
        ObjectPath=varargin{1};
        for idx=1:length(ud),
          if isequal(ud{idx},ObjectPath),
            opidx=idx;
          end
        end
      end
      varargout{3}=opidx;
    end
  otherwise,
    error(['Unknown Mode : ' mode]);
end
return;

%%%%%%%%%%%%%%%%%%%%%%
% Text Mode
%%%%%%%%%%%%%%%%%%%%%%
function [txt, ud]=getText(vgdata,txt,cvgp0,head0, ud)
% vgdata : Current View Group Data.
% txt    : output txt
% cvgp   : Current ViweGroup Data Path.
% head   : Header of Text

for idx =1:length(vgdata)
  % Get Basic Information
  info=feval(vgdata{idx}.MODE,'getBasicInfo');

  %================================
  % Set Line
  % head ( this Object Line-header)
  % head3 (Child Ojbect Line-Header)
  %=================================
  if idx==length(vgdata),
    if idx==1,
      head  = [head0 '  *-- '];
    else
      head  = [head0 '  *-- '];
    end
    head3 = [head0 '       '];
  else
    head  = [head0 '  |-- '];
    head3 = [head0 '  |    '];
  end

  if isfield(info,'strhead'),
    head2=[head '[' info.strhead '] '];
  else
    head2=[head '[XX] '];
  end
  % View Box
  txt{end+1}=[head2 vgdata{idx}.NAME];
  ud{end+1} = [cvgp0, idx];

  % Can be down?
  if info.down,
    [txt,ud]=getText(vgdata{idx}.Object,txt,ud{end},head3,ud);
  end
end
return;




function [txt, ud]=getText1(vgdata,txt,cvgp0,head01,head02,ud)
% vgdata : Current View Group Data.
% txt    : output txt
% cvgp   : Current ViweGroup Data Path.
% head01 : Header of Text (Index)
% head02 : Header of Text (Tab)
% ud     : Data of txt path

for idx =1:length(vgdata)
  % Get Basic Information
  info=feval(vgdata{idx}.MODE,'getBasicInfo');

  %================================
  % Set Line
  % head11 ( this Object Line-header)
  % head21 (Child Ojbect Line-Header)
  %=================================
  head11= [head01 num2str(idx) ' '];
  head21= [head01 num2str(idx) '.'];
  head22=head02;
  if length(head02)>=2,
    head22(end-1:end)=[];
  end

  if isfield(info,'strhead'),
    head=[head11 head02 '[' info.strhead '] '];
  else
    head=[head11 head02 '[XX] '];
  end
  % View Box
  txt{end+1}=[head vgdata{idx}.NAME];
  ud{end+1} = [cvgp0, idx];

  % Can be down?
  if info.down,
    [txt,ud]=getText1(vgdata{idx}.Object,txt,ud{end},head21,head22,ud);
  end
end
return;

function [txt, ud]=getText2(vgdata,txt,cvgp0,head01,head02,ud)
% vgdata : Current View Group Data.
% txt    : output txt
% cvgp   : Current ViweGroup Data Path.
% head01 : Header of Text (Normal)
% head02 : Header of Text (Index)
% ud     : Data of txt path

for idx =1:length(vgdata)
  % Get Basic Information
  info=feval(vgdata{idx}.MODE,'getBasicInfo');

  %================================
  % Set Line
  % head11 ( this Object Line-header)
  % head21 (Child Ojbect Line-Header)
  %=================================
  if idx==length(vgdata),
    if idx==1,
      head11  = [head01 '  *-- '];
    else
      head11  = [head01 '  *-- '];
    end
    head21 = [head01 '       '];
  else
    head11  = [head01 '  |-- '];
    head21 = [head01 '  |    '];
  end
  head12= [head02 num2str(idx) '   '];
  head22= [head02 num2str(idx) '.'];

  if isfield(info,'strhead'),
    head=[head11 head12 '[' info.strhead '] '];
  else
    head=[head11 head12 '[XX] '];
  end
  % View Box
  txt{end+1}=[head vgdata{idx}.NAME];
  ud{end+1} = [cvgp0, idx];

  % Can be down?
  if info.down,
    [txt,ud]=getText2(vgdata{idx}.Object,txt,ud{end},head21,head22,ud);
  end
end
return;
