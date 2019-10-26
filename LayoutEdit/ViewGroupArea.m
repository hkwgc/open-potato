function varargout=ViewGroupArea(fnc,varargin)
% Viewer-Group-Area : File I/O Function.
%      Functions : getBasicInfo, getDefaultData,
%                  getGUIdata, exe
%      Callbacks :
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

if 0
  getBasicInfo;
  getDefaultData;
  changeToArea;
  changeToGroup;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=getBasicInfo
% Basic Info
info.MODENAME = 'GROUP';
info.fnc  = 'ViewGroupArea';
info.down = true;
info.col  = [.9 .9 1];
info.strhead  = 'G '; % Group-Data
return;

function data=getDefaultData
data.NAME    = 'Untitled Area';
data.MODE    = 'ViewGroupArea';
data.Position =[0 0 1 1];
data.Property.dumy =true;
data.Object   ={};
data.CObject  ={};
%data.DistributionMode = 'Simple Area';
data.DistributionMode = '';
%data.ExpandFlag = false; %expand-status:true-open,false-close)
data.ExpandFlag = true;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Conversion(to Area)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=changeToArea(data)
% Convert View-Group
%    --> to 'ViewGroupArea'
% return ; data=axesobject/callbackobject

% ------------------------------------------
% Do notihng if data is not View-Group Object
% ------------------------------------------
if ~isfield(data,'MODE'),return; end

% ------------------------------------------
% OLD-DATA format==>CURRENT-DATA format
% ------------------------------------------
if isfield(data,'lineprop'),
  data.Property.lineprop=data.lineprop;
  data=rmfield(data, 'lineprop');
end

% ------------------------------------------
% Change MODE :
% View-Group-XX =>ViewGroupArea/ViewGroupAxes
% ------------------------------------------
try
  switch data.MODE
    case {'ViewGroupData', 'ViewGroupCallback'}
      if ~isfield(data,'DistributionMode'),
        data.DistributionMode=[];
      end
    case 'ViewGroupGroup',
    case 'ViewGroupAxes',
      if ~isfield(data,'ExpandFlag'),
        data.ExpandFlag=false;end
      return;   % not change MODE
    otherwise,
      % axesobject, callbackobject
      return;
  end
catch
  warning(lasterr);
end
if ~isfield(data,'ExpandFlag'),data.ExpandFlag=false;end
data.MODE='ViewGroupArea';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Conversion(to old Group)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=changeToGroup(data)
% Convert ViewGroupArea
%    --> to View-Group
% return ; data=axesobject/callbackobject

% ------------------------------------------
% Do notihng if data is not View-Group Object
% ------------------------------------------
if ~isfield(data,'MODE'),return; end


% ------------------------------------------
% Change MODE :
% ViewGroupArea => View-Group-XX
% ------------------------------------------
try

  switch data.MODE
    case 'ViewGroupArea',
      if isfield(data,'DistributionMode'),
        if isempty(data.DistributionMode),
          data.MODE='ViewGroupCallback';
          if ~isfield(data,'CObject')
            data.CObject={};
          end
        else
          data.MODE='ViewGroupGroup';
        end
        return;
      end
    otherwise,
      % ViewGroupAxes
      return;
  end
catch
  warning(lasterr);
end
return;



