function varargout=osp_ViewAxesObj_ErrorArea(fnc,varargin)
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



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
  info.MODENAME='Line Plot Block data overlay';
  info.fnc     ='osp_ViewAxesObj_BlockDataOverlay';
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
end
data.str = 'Line Plot Block data overlay';
data.fnc = 'osp_ViewAxesObj_BlockDataOverlay';
data.ver = 1.00;

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
str=['osp_ViewAxesObj_BlockDataOverlay(''draw'', ', ...
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
curdata.flag.MarkAveraging=false;
[hdata,data]=osp_LayoutViewerTool('getCurrentData',f,curdata);%<<= Flag ok.

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
%[plotdata.data, std_block, se_block] = uc_blockmean(data, hdata);
%[plotdata.data, std_block, se_block] = uc_blockmean(data(:,:,curdata.ch,:), hdata);%mod by TK@HARL 090306
% if ~isempty(std_block) && any(std_block(:)),
%   if 1,
%     % Error
%     plotdata.std = std_block;
%   else
%     % Standard Error
%     plotdata.std = se_block;
%   end
% end
% if isempty(plotdata.data),
%   error(['No data to Error-Area plot\n', ...
% 					   '\t1.Check if there is selected data\n', ...
% 					   '\t2.Check BlockArea is not overlap with other Stimulation.\n']);
% end   
%---------------------------
% Channel Required!
%---------------------------
%plotdata.data = plotdata.data(:,curdata.ch,:); % Remove Unused Data 
%plotdata.std  = plotdata.std(:,curdata.ch,:);
% mod by TK@HARL 090306

% %apply FLAG  
% for k=1:size(data,1)
%     data(k,:,logical(hdata.flag(1,k,:)) ) = NaN;
% end
% %-----------



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
%datatime =linspace(0, size(plotdata.data,1)/unit, size(plotdata.data,1))';
datatime =linspace(0, size(data,2)/unit, size(data,2))';
% if ~isfield(plotdata,'std'),return;end
% stddata = plotdata.std;
% estep   = 25; % errorplot
% if size(datatime,1)<1000
%   estep = ceil(size(stddata,1)/40);
% end
% idx = 1:estep:size(stddata,1);
% if idx(end)~=size(stddata,1)
%   idx(end+1)=size(stddata,1);
% end
% plottime    = datatime(idx);
 
% pldata=plotdata.data;
% err_p = pldata(idx,:,:) + stddata(idx,:,:);
% err_m = pldata(idx,:,:) - stddata(idx,:,:);

%==================================
% Draw
%==================================
h.h=[];
h.tag={}; 
% Kind is in a Data-Range? 
  
%---------------------------
% Plot Error-Area
%---------------------------
% if exist('stddata', 'var'),
  for kind=curdata.kind,
    % -- Draw --
    %h.h(end+1)=line(t,data(:,1,kind));
    %h.tag{end+1}=[tag_head hdata.TAGs.DataTag{kind}];
  
%     err_p0=squeeze(err_p(:,:,kind));
%     err_m0=squeeze(err_m(:,:,kind));
    %ep_h=getappdata(f,'BlockDataOverlay_PATCH_HANDLES');
    ep_h=[];
%     ep_h(end+1)= ... 
%             patch([plottime; plottime(end:-1:1)], ...
% 		        [err_p0; err_m0(end:-1:1)], ...
% 		        1, ...
% 		        'FaceColor', plotdata.color(kind,:), ...
% 		        'FaceAlpha', 0.1, ...
% 		        'Tag', [hdata.TAGs.DataTag{kind} ' : BlockDataOverlay']);
	%set(ep_h(end),'EdgeColor', plotdata.color(kind,:));		        
%     set(ep_h(end),'EdgeColor', 'none');		        

tmp=plot(datatime,squeeze(data(:,:,curdata.ch,kind))','color',plotdata.color(kind,:));
for k=1:length(tmp)
       ep_h(end+1)=tmp(k);
       P3_ApplyLineProperty(curdata,tmp(k),hdata,kind);
end
      h.h=[h.h ep_h];
      h.tag{end+1}=hdata.TAGs.DataTag{kind};
      if any(curdata.kind==kind),
        set(ep_h(:),'Visible','on');
      else
        set(ep_h(:),'Visible','off');
      end
%   end
  setappdata(f,'BlockDataOverlay_PATCH_HANDLES',ep_h);
  r=get(f,'Renderer');
%   if strcmpi(r,'painters'),
%     %set(f,'Renderer','zbuffer');
%     set(f,'Renderer','OpenGL'); % for 2006a
%   end
end

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_BlockDataOverlay';

if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
		       h.h, myName, ...
		       gca0, curdata, obj, ObjectID);
else
  p3_ViewCommCallback('CheckIn', ...
		       h.h, myName, ...
		       gca0, curdata, obj);
end

