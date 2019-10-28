function varargout=osp_ViewAxesObj_background(fnc,varargin)
% Axes Plugin Data : Draw Background Image
%
% Known bugs:
%
% bug report:
%
% See also VIEWGROUPAXES,
%          OSP_VAO_BACKGROUND_GETARGUMENTS.


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
else,
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
  info.MODENAME='Background Image';
  info.fnc     ='osp_ViewAxesObj_background';
%  data.ver  = 1.00;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set up : Plot Data
  % --- change ---
  if length(varargin)>=1,
	  data=varargin{1};
  end
  % Confine Default Value..
  data.str = 'Background Image';
  data.fnc = 'osp_ViewAxesObj_background';
  data.ver = 1.00;
  % Default Data ( fro add )
  if ~isfield(data,'SaveFormat'),
	  data.SaveFormat='Path';
  end
  if ~isfield(data,'imgfile'),
	  % save-format : Path
	  data.imgfile='';
  end
  if ~isfield(data,'imgdata'),
	  % save-format : InnerData
	  data.imgdata=[];
  end
  data=osp_vao_background_getargument('AxesObject',data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% See also VIEWGROUPAXES,
%          OSP_VAO_BACKGROUND_GETARGUMENTS.
str='osp_ViewAxesObj_background(''setimage'', obj{idx},curdata)';
return;

function h=setimage(axobj,curdata)
% Write Image 
if isempty(axobj),
	tmp=gca;
	axobj=osp_vao_background_getargument;
	axes(tmp);
end

%=============
% Initiarized
%=============
h=[];
imdata=[]; % default

%================
% Make Image Data
%================
if strcmp(axobj.SaveFormat,'Path'), 
	%--------------------------
	% Get Image-Data From File
	%--------------------------
	% ===> Check Image File <==
	if ~isfield(axobj,'imfile'),
		error('AO : Background Image : No Image File path exist...');
	end
	if isempty(axobj.imfile) 
		error('AO : Background Image : Image File path is empty...');
	end
	if ~ischar(axobj.imfile)
		disp(axobj.imfile);
		error('AO : Background Image : Image File path is not charactor...');
	end
	
	% ===> getimgae <==
	if exist(axobj.imfile,'file'),
		imdata=imread(axobj.imfile);
	else,
		disp(axobj.imfile);
		error('AO : Background Image : Lost Image File.')
	end
end

if strcmp(axobj.SaveFormat,'InnerData'),
	%---------------------------
	% Get Image-Data Axes-Object
	%---------------------------
	% ===> Check Image File <==
	if ~isfield(axobj,'imgdata'),
		error('AO : Background Image : No Image Data exist...');
	end
	if isempty(axobj.imgdata)
		error('AO : Background Image : Image Data is empty...');
	end
	if ~isnumeric(axobj.imgdata)
		error('AO : Background Image : Image Data is not numerical...');
	end
	% save-format : InnerData
	imdata = axobj.imgdata;
end

if isempty(imdata),
	error('AO : Background Image : No effective data to image exist.');
end

%================
% Draw Now
%================
try,
	imdata=flipdim(imdata,1);
	h.h=image(imdata); axis off;axis tight;
	h.tag={'Image'};
catch
	error(['AO : Background Image : ' lasterr]);
end

if nargin==2 && isfield(curdata,'menu_current'),
    ud.axes=gca;
    ud.h   =h.h;
    uimenu(curdata.menu_current, ...
        'Label', 'Change &Background Image', ...
        'UserData', ud, ...
        'Callback', ...
        ['ud=get(gcbo,''UserData'');' ...
            'axes(ud.axes); delete(ud.h);' ...
            'osp_ViewAxesObj_background(''setimage'', []);']);
elseif (nargin~=2),
    % Send to back
    try,
        ud.axes=gca;
        ud.h   =h.h;
        set(gcbo,'UserData',ud);
        c=get(gcbf,'Children');
        %set(gcf,'Children',c([2:end, 1]))
        idx=find(c==ud.axes); % 1 : in this MATLAB version.
        c(idx)=[];c(end+1)=ud.axes;
        set(gcf,'Children',c);
    end
end
