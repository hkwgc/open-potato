function varargout=osp_ViewAxesObj_Results2DImage(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image2Dprop
% $Id: osp_ViewAxesObj_Results2DImage.m 364 2013-06-26 01:12:45Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History =-
% 2006.10.18 :: Change Colormap by menu.
%  Disable 'v_colormap' field  ;; Property

  
% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else,
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
  info.MODENAME='2DImage of Results';
  % --> @ funciton is difficult to save .. 
  %       R13<->R14 is different.
  info.fnc     ='osp_ViewAxesObj_Results2DImage';
%  data.ver  = 1.00;
info.ccb     = {'ImageProp','ResultsGETTER'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data),
% Set up : 2D-Image Axes-Object Data
%          (or change )
%
% Open Initial value setting GUI

%>>>>
%   data.image2Dprop.v_colormap = 1; % default
%<<<<

  % Open dialog, Get properties of 2D-Image
  try,
	  data=osp_vao_2Dimage_getargument('AxesObject',data);
  catch,
	  % When Error occur
	  h= errordlg({'OSP Error!!', ...
			  '  >> in 2D Image Axes-Object : getArgument', lasterr});
	  data=[]; return;
  end

  data.str = '2D Image of Results';
  data.fnc = 'osp_ViewAxesObj_Results2DImage';
  data.ver = 1.00;
  data.region ='auto';  
  data.image2Dprop.v_MP = 50;

  % other 2D image property
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
str=['osp_ViewAxesObj_Results2DImage(''testimage'', h.axes,' ...
		' curdata, obj{idx})'];
return;

function hout=draw(gca0, curdata, objdata, ObjectID),
if isempty(curdata.ResultsString), return;end
hout=testimage(gca0, curdata, objdata, ObjectID);

function hout=testimage(gca0, curdata, objdata, ObjectID),
% Plot 2D Axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output : initiarized
hout.h=[];
hout.tag={};
%-- check Results data
if ~isfield(curdata,'ResultsString') 
	text(0.1, 0.5,'No results in hdata.');
	axis off;
	return;
end

% --> Using Current Data in plot <--
% curdata0.ch     = curdata.ch;
% curdata0.time   = curdata.time;
% curdata0.ResultsString   = curdata.ResultsString;
% curdata0.cid0   = curdata.cid0;
% curdata0.gcf    = curdata.gcf;
% if isfield(objdata,'region') && ~strcmpi(objdata.region,'auto'),
% 	curdata.region = objdata.region;
% end
% curdata0.region = curdata.region;

%---> Additional Menu ; 2007.06.26
if isfield(curdata,'menu_current') && ~exist('ObjectID','var')
    % Make
    mtv=uimenu(curdata.menu_current,...
      'Label','Text-Value');
    curdata.menu_TextValue=mtv;  % <--- to Common  - Control
%     curdata0.menu_TextValue=mtv; % <--- to Special - Control
end
% if isfield(curdata,'menu_TextValue') && ishandle(curdata.menu_TextValue) 
% %   curdata0.menu_TextValue=curdata.menu_TextValue; % <--- to Special - Control
% end

%======================
% Get Image Properties 
%======================

% if isfield(objdata,'image2Dprop') && ~isempty(objdata.image2Dprop)
%     image2Dprop=objdata.image2Dprop;
% else
%     image2Dprop.dummy=[];
% end
% 
% if isfield(curdata,'ImageProp')
%     image2Dprop = curdata.ImageProp;
% end

try

	%======================
  % Make Data
  %======================
  [hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);

	% ------------
	% data Select
	% ------------
	data=eval(['hdata.Results.' curdata.ResultsString]);

  % Make Image Data
  % <--->
  imageData=potato_lao_image('makeImageData',hdata,data,curdata);
  clear hdata data;

  %=====================
  %=   Draw Image      =
  %=====================
  hout=potato_lao_image('SimpleDraw',gca0,curdata,imageData,hout);
	
	%===================
	% Axis Outer Setting
	%===================
	%caxis([cmin,cmax]);
	% 2006.10.18 :: Change Colormap by menu.
	%if isfield(image2Dprop,'v_colormap'),
	%	osp_set_colormap(image2Dprop.v_colormap,gca0);
	%end
  
	%axis auto;
	axis image;
	axis off;
  
catch
	set(curdata.gcf,'CurrentAxes',gca0);
	a=axis; a(3)=a(3) + a(4)/2;
	str = sprintf('Error : \n  %s',lasterr);
	hout.h(end+1)=text(a(1),a(3),str);
	hout.tag{end+1}= 'ErrorText';
	set(hout.h(end),'EdgeColor','Red', ...
		'Interpreter','none', ...
		'Tag', 'ErrorText');
end
    
%======================================
%=      Common-Callback Setting       =
% (temp)
%======================================
if exist('ObjectID','var'),
  potato_lao_image('SetCallback',hout,gca0,curdata,objdata,ObjectID);
else
  ObjectID=potato_lao_image('SetCallback',hout,gca0,curdata,objdata);
end


% %------------------------
% %  Results GETTER            
% %------------------------
% if isfield(curdata,'Callback_ResultsGETTER') && ...
% 		isfield(curdata.Callback_2DImageMode,'handles') && ...
% 		ishandle(curdata.Callback_2DImageMode.handles),
% 	% See also osp_ViewCallback_2DImageMode
% 	hout.axes=gca0;
% 	hout.curdata =curdata;
% 	hout.objdata = objdata;
% 	hout.ObjectID = ObjectID;
% 	%  udadd.str=['ud{idx}=osp_ViewAxesObj_Results2DImage(' ...
% 	%                '''ResultsGETTER'',ud{idx}, ResultsString);'];
% 	hout.str=['ud{idx}=osp_ViewAxesObj_Results2DImage(''testimage'', ud{idx}.axes,' ...
% 		' ud{idx}.curdata, ud{idx}.objdata,ud{idx}.ObjectID);'];
% 	h = curdata.Callback_ResultsGETTER.handles;
% 	ud=get(h,'UserData');
% 	%ud{end+1}=hout;
% 	ud{2}=hout;
% 	set(h,'UserData',ud);	
% end
