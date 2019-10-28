function varargout=osp_ViewAxesObj_ErrorArea(fnc,varargin)
% Control Function to Draw "Line" in Viewer II
%
% osp_ViewAxesObj_ErrorArea is "View-Axes-Object",
% so osp_ViewAxesObj_ErrorArea is based on the rule.
%
% osp_ViewAxesObj_ErrorArea use "Common-Callback", 
% so osp_ViewAxesObj_ErrorArea is based on the rule.
%
%
% === Open Help Document ===
% Defined in View Axes Object :
%   Upper-Link :  ViewGroupAxes/HelpObj
%
% Syntax : 
%   osp_ViewAxesObj_ErrorArea
%     Open Help of the Function for user.
%
% === Other  ===
%
% Syntax : 
% varargout=osp_ViewAxesObj_ErrorArea(fnc,varargin)
%
% See also : OSP_VIEWCOMMCALLBACK,
%            OSP_LAYOUTVIEWER,
%            LAYOUTMANAGER,
%            VIEWGROUPAXES.

% $Id: osp_ViewAxesObj_ErrorArea.m 396 2014-03-29 07:38:19Z katura7pro $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == Warning !! ==
% When you want to edit this function,
%  you must be based on View-Axes-Object rules.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch .. sub-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No argument : Help : (Defined in View-Axes-Object )
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
  info.MODENAME='Error Area';
  info.fnc     ='osp_ViewAxesObj_ErrorArea';
  % Useing Common-Callback-Object
  info.ccb     = {'Data',...
		  'Channel', ...
		  'Kind', ...
		  'stimkind',...
		  'TimeRange'};
  % No TimePoint
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set up : Plot Data
% Load Argument Data
if length(varargin)>=1,
  data=varargin{1};
else
	data.str = 'Error Area';
	data.fnc = 'osp_ViewAxesObj_ErrorArea';
	data.ver = 1.10;
	data.Mode='SE';
	data.Step=1;
end

prmpt={'SD/SE','Step ofr drawing data (1 means use all)'};
defans={'SD','1'};
r=inputdlg(prmpt, 'Setting for Error area draw',1,defans);
data.Mode=r{1};
data.Step=eval(r{2});



%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% DrawStr : 
%
% See also osp_ViewAxesObject_PlotTest/getArgument,
%          ViweGroupAxes/exe,
%          p3_ViewCommCallback.
str=['osp_ViewAxesObj_ErrorArea(''draw'', ', ...
     'h.axes ,curdata, obj{idx})'];
return;

function h=draw(gca0, curdata,obj, ObjectID)
% Draw / Redraw Line-Axes-Object
%
% GCA0      : The Draw Axeis( Usually Current Axis);
% CURDATA   : Current Data in Drawing.
%             Defined in ViewerII -> 
%             rf). osp_LayoutViewer
% OBJ       : This Axes-Object.
%             Made in subfunction getArgument.
% OBJECT_ID : When draw   : There is no ObjectID.
%             When Redraw : INDEX of Redraw Object.
%             This variable for CommonCallabck.

%===========================
% Get Current-Figure 
%===========================
f=curdata.gcf;   
%===========================
% Create Draw-Data
%===========================
%---------------------------
%    Get Data
%---------------------------
[hdata,data]=...
  osp_LayoutViewerTool('getCurrentDataRaw',f,curdata);
%---------------------------
%    Check Block-Data or Not 
%---------------------------
if ndims(data)~=4, return; end
%---------------------------
%    Make Standard Deviation,
%         Standard Error.
%---------------------------
% --> Modify <-- 
% Use SE::

%- check selected stimkind
if isfield(curdata,'stimkind')
	[plotdata.data, std_block, se_block] = uc_blockmean(data, hdata,curdata.stimkind);
else
	[plotdata.data, std_block, se_block] = uc_blockmean(data, hdata);
end

%[plotdata.data, std_block, se_block] =
%uc_blockmean(data(:,:,curdata.ch,:), hdata);%- mod by TK@HARL 090306-> caused bug. fixed back TK@HARL 20110207
if ~isempty(std_block) && any(std_block(:)),
  if strcmp(obj.Mode,'SD')
    % Error
    plotdata.std = std_block;
  elseif strcmp(obj.Mode,'SE')
    % Standard Error
    plotdata.std = se_block;
  end
end
if isempty(plotdata.data),
  error(['No data to Error-Area plot\n', ...
					   '\t1.Check if there is selected data\n', ...
					   '\t2.Check BlockArea is not overlap with other Stimulation.\n']);
end   
%---------------------------
% Channel Required!
%---------------------------
plotdata.data = plotdata.data(:,curdata.ch,:); % Remove Unused Data 
plotdata.std  = plotdata.std(:,curdata.ch,:);
%- mod by TK@HARL 090306 -> caused bug. fixed back TK@HARL 20110207

%===========================
%   Setting Options
%===========================
%---------------------------
%    Line Property 
%---------------------------
if isfield(curdata,'lineprop') && ~isempty(curdata.lineprop),
  linepropflag=true;
else
  linepropflag=false;
end
%---------------------------
% Default Color
%---------------------------
a=max(curdata.kind(:));
if a<10; a=10;end
dcol=hot(a);
dcol(1:3,:)=[1, 0, 0; ...
	     0, 0, 1; ...
	     0, 0, 0]; 
%---------------------------
% Set Color of Error-Area
%---------------------------
%tmp_kind= find((curdata.kind<=0) + (curdata.kind>size(data,3)),1);
tmp_kind= find((curdata.kind<=0) + (curdata.kind>size(data,3)));
if ~isempty(tmp_kind) || linepropflag==false,
  plotdata.color=dcol;
else
  for kind=curdata.kind,
    	idx=find(strcmp(hdata.TAGs.DataTag{kind},curdata.lineprop.name));
      if length(idx) ~=1,
        plotdata.color(kind,:)=dcol{kind,:};
      else
        plotdata.color(kind,:)=curdata.lineprop{idx}.color;
      end
  end	
end

%===========================
% Time Range Change
%===========================
% t0=1:size(data,2);
% t=(t0 -1)/unit;
% % Time Range Require!
% of=find(t<curdata.time(1));t0(of)=[]; t(of)=[];
% uf=find(t>curdata.time(2));t0(uf)=[]; t(uf)=[];
% data = data(:,t0,:,:);

%================================
% Thin out? data
%================================ 
%stdx=stdx(1:25:end);
unit = 1000/hdata.samplingperiod;
datatime =linspace(0, size(plotdata.data,1)/unit, size(plotdata.data,1))';
if ~isfield(plotdata,'std'),return;end
stddata = plotdata.std;
estep   = obj.Step; % errorplot
% if size(datatime,1)<1000
%   estep = ceil(size(stddata,1)/40);
% end
idx = 1:estep:size(stddata,1);
if idx(end)~=size(stddata,1)
  idx(end+1)=size(stddata,1);
end
plottime    = datatime(idx);
 
pldata=plotdata.data;
err_p = pldata(idx,:,:) + stddata(idx,:,:);
err_m = pldata(idx,:,:) - stddata(idx,:,:);

%==================================
% Draw
%==================================
h.h=[];
h.tag={}; 
% Kind is in a Data-Range? 
  
%---------------------------
% Plot Error-Area
%---------------------------
if exist('stddata', 'var'),
  for kind=1:size(err_p,3),
    % -- Draw --
    %h.h(end+1)=line(t,data(:,1,kind));
    %h.tag{end+1}=[tag_head hdata.TAGs.DataTag{kind}];
  
    err_p0=squeeze(err_p(:,:,kind));
    err_m0=squeeze(err_m(:,:,kind));
    ep_h=getappdata(f,'ERROR_PATCH_HANDLES');
    ep_h(end+1)= ... 
            patch([plottime; plottime(end:-1:1)], ...
		        [err_p0; err_m0(end:-1:1)], ...
		        1, ...
		        'FaceColor', plotdata.color(kind,:), ...
		        'FaceAlpha', 0.1, ...
		        'Tag', [hdata.TAGs.DataTag{kind} ' : Error']);
	%set(ep_h(end),'EdgeColor', plotdata.color(kind,:));		        
    set(ep_h(end),'EdgeColor', 'none');		        
       
      h.h(end+1)=ep_h(end);
      h.tag{end+1}=hdata.TAGs.DataTag{kind};
      if any(curdata.kind==kind),
        set(ep_h(end),'Visible','on');
      else
        set(ep_h(end),'Visible','off');
      end
  end
  setappdata(f,'ERROR_PATCH_HANDLES',ep_h);
  r=get(f,'Renderer');
  if strcmpi(r,'painters'),
    %set(f,'Renderer','zbuffer');
    set(f,'Renderer','OpenGL'); % for 2006a
  end
end

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_ErrorArea';

if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
		       h.h, myName, ...
		       gca0, curdata, obj, ObjectID);
else
  p3_ViewCommCallback('CheckIn', ...
		       h.h, myName, ...
		       gca0, curdata, obj);
end



