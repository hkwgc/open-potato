function varargout=osp_ViewAxesObj_2DImage(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image2Dprop
% $Id: osp_ViewAxesObj_2DImage.m 298 2012-11-15 08:58:23Z Katura $

% == History =-
% 2006.10.18 :: Change Colormap by menu.
%  Disable 'v_colormap' field  ;; Property



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

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
info.MODENAME='2D-Image';
% --> @ funciton is difficult to save ..
%       R13<->R14 is different.
info.fnc     ='osp_ViewAxesObj_2DImage';
%  data.ver  = 1.00;
info.ccb     = {'Data',...
  'DataKind'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data)
% Set up : 2D-Image Axes-Object Data
%          (or change )
%
% Open Initial value setting GUI
data.str = '2D-Image';
data.fnc = 'osp_ViewAxesObj_2DImage';
data.ver = 1.00;
data.region ='auto';
% --> for New-Setting
%     :: Image-Setting :in Coltrol ::
if 1
  return;
end
data.image2Dprop.v_MP = 50;
%>>>>
%   data.image2Dprop.v_colormap = 1; % default
%<<<<

% Open dialog, Get properties of 2D-Image
try
  data=osp_vao_2Dimage_getargument('AxesObject',data);
catch
  % When Error occur
  h= errordlg({'OSP Error!!', ...
    '  >> in 2D Image Axes-Object : getArgument', lasterr});
  data=[]; return;
end
% other 2D image property
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
if 1
  str=[...
    'if ~isfield(curdata,''image2Dprop''),'...
    '   curdata.image2Dprop.v_timeposition=1;',...
    'end;',...
    'if ~isfield(curdata.image2Dprop,''v_timeposition''),'...
    '   curdata.image2Dprop.v_timeposition=1;',...
    'end;',...
    'curdata.image2Dprop.v_timeposition=curdata.image2Dprop.v_timeposition+10;',...
    'osp_ViewAxesObj_2DImage(''testimage'', h.axes,', ...
    ' curdata, obj{idx})'];
else
  str=[...
    'osp_ViewAxesObj_2DImage(''testimage'', h.axes,', ...
    ' curdata, obj{idx})'];
end
return;

function hout=draw(gca0, curdata, objdata, ObjectID)
if isempty(curdata.kind), curdata.kind=1;end
hout=testimage(gca0, curdata, objdata, ObjectID);

function hout=testimage(gca0, curdata, objdata, ObjectID),
% Plot 2D Axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output : initiarized
hout.h=[];
hout.tag={};
% --> Using Current Data in plot <--
curdata0.ch     = curdata.ch;
curdata0.time   = curdata.time;
curdata0.kind   = curdata.kind(1);
curdata0.cid0   = curdata.cid0;
curdata0.gcf    = curdata.gcf;
if isfield(objdata,'region') && ~strcmpi(objdata.region,'auto'),
  curdata.region = objdata.region;
end
curdata0.region = curdata.region;

%---> Additional Menu ; 2007.06.26
if isfield(curdata,'menu_current') && ~exist('ObjectID','var')
  % Make
  mtv=uimenu(curdata.menu_current,...
    'Label','Text-Value');
  curdata.menu_TextValue=mtv;  % <--- to Common  - Control
  curdata0.menu_TextValue=mtv; % <--- to Special - Control
end
if isfield(curdata,'menu_TextValue') && ishandle(curdata.menu_TextValue)
  curdata0.menu_TextValue=curdata.menu_TextValue; % <--- to Special - Control
end


%======================
% Get Image Properties
%======================
if isfield(curdata,'ImageProp')
  image2Dprop=curdata.ImageProp;
elseif isfield(curdata,'image2Dprop')
  image2Dprop=curdata.image2Dprop;
elseif isfield(objdata,'image2Dprop') && ...
    ~isempty(objdata.image2Dprop),
  image2Dprop=objdata.image2Dprop;
else
  % dumy sructure;
  image2Dprop.dummy=[];
end
disp('Old-Axis-Object in Layout!!')
disp('  --- <a href="matlab:LayoutEditor">LayoutEditor</a> ---');
disp('  :Use ''2D Image (**)'' insted of ''2D-Image''.');
disp(C__FILE__LINE__CHAR);

try
  %======================
  % Make Data
  %======================
  [hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);

  % ------------
  % Kind Select
  % ------------
  plot_kind=curdata.kind(1);
  % Remove
  data_kind1=data(:,:,plot_kind); clear data;

  % ------------
  % Mask ch data
  % ------------
  if isfield(image2Dprop,'mask_channel') && ...
      ~isempty(image2Dprop.mask_channel),
    data_kind1(:, image2Dprop.mask_channel)=0;
  end

  % ---------------
  % Time Mean
  %   data_kind1 to ydata
  % ---------------
  % Get 2d-Image Property : time
  if isfield(image2Dprop,'v_timeposition'),
    timepos        = image2Dprop.v_timeposition;
    % ===> Time pos Check <===
    if timepos> size(data_kind1,1),
      error(' Selecting Time-Index is too large');
    end
  else,
    timepos        = 1;
  end
  if isfield(image2Dprop,'v_MP'),
    v_MP           = image2Dprop.v_MP;
  else,
    v_MP           = 50;
  end
  % get single time point data
  v_tstart = timepos-fix(v_MP/2);
  v_tend   = timepos+fix(v_MP/2);
  if (v_tstart<1 ), v_tstart=1; end
  if (v_tend>size(data_kind1,1) ),
    v_tend=size(data_kind1,1);
  end
  ydata = nan_fcn('mean',data_kind1(v_tstart:v_tend, :), 1 );
  sz=size(ydata); sz(1)=[];
  if length(sz)==1, sz(2)=1; end
  ydata=reshape(ydata,sz); % Squeeze

  %============================
  % Interporation Setting
  %============================
  % Get value of Image-property
  % Interpolation mode
  %    1 : Not interpolation
  %    2 : Use function interp
  %    3 : Smooth Point
  %( for osp_chnl2imageM)
  if isfield(image2Dprop,'image_mode_ind'),
    image_mode     = image2Dprop.image_mode_ind;
  else
    image_mode     = 4;
  end
  % Interpolation x time
  if isfield(image2Dprop,'v_interpstep'),
    v_interpstep   = image2Dprop.v_interpstep;
  else
    v_interpstep   = 3;
  end
  % Interpolation method
  % See also interp2
  if isfield(image2Dprop,'interpmethod'),
    v_interpmethod = image2Dprop.interpmethod;
  else
    v_interpmethod = 'cubic';
  end


  %============================
  % Color Axis Setting
  %============================
  % Color-Axis
  % setup Color-Axis
  % get Color-Axis Max & Min
  if isfield(image2Dprop,'v_axisAuto') && ...
      isequal(image2Dprop.v_axisAuto,1),
    % automatic mode
    v_axMax=max(ydata(:));
    v_axMin=min(ydata(:));
  else
    % Setting Value
    % -- Color-Axis (max) --
    if isfield(image2Dprop,'v_axMax'),
      v_axMax        = image2Dprop.v_axMax;
    else
      v_axMax=max(ydata(:));
    end
    % -- Color-Axis (min) --
    if isfield(image2Dprop,'v_axMin'),
      v_axMin        = image2Dprop.v_axMin;
    else
      v_axMin=min(ydata(:));
    end
  end
  % Confine range of caix is not 0
  if isnan(v_axMax), v_axMax=0; end
  if isnan(v_axMin), v_axMin=0; end
  if (v_axMax==v_axMin),
    v_axMax=v_axMax+0.5;
    v_axMin=v_axMin-0.5;
  end

  % Set Pseude Colro-Axis Caling
  if isfield(image2Dprop,'v_zerofix') && ...
      isequal(image2Dprop.v_zerofix,1)
    cmax = max([abs(v_axMin), abs(v_axMax)]);
    cmin = -cmax;
  else
    cmax=v_axMax;
    cmin=v_axMin;
  end

  %=====================
  %=   Draw Image      =
  %=====================
  if image_mode<=3
    % -- Normal Image --
    % Real  Image Map
    [c0, x0, y0]=osp_chnl2imageM(ydata',...
      hdata, image_mode, ...
      v_interpstep, v_interpmethod);

    %axes(gca0);
    set(curdata.gcf,'CurrentAxes',gca0);
    hold on;
    for plid = 1: length(c0),
      %axes(gca0);
      set(curdata.gcf,'CurrentAxes',gca0);
      hout.h(end+1)=imagesc(x0{plid}, y0{plid}, ...
        c0{plid}',[v_axMin, v_axMax]);
      hout.tag{end+1}=['IMG_Probe' num2str(plid)];
      set(hout.h(end),'Tag',hout.tag{end});
      try,
        qflag = getappdata(curdata.gcf,'IMAGE_QUIVER');
        if ~isempty(qflag) && qflag && image_mode~=3
          %a=axis;axis(a);
          %contour(x0{plid},y0{plid},c0{plid}',10);
          x=x0{plid};y=y0{plid};
          [fx,fy]=gradient(c0{plid}',x(2)-x(1), y(2)-y(1));
          hout.h(end+1:end+2)=quiver(x,y,fx,fy);
          hout.tag{end+1}=['QVR1_Probe' num2str(plid)];
          set(hout.h(end-1),'Color','Red','Tag',hout.tag{end});
          hout.tag{end+1}=['QVR2_Probe' num2str(plid)];
          set(hout.h(end),'Color','Red','Tag',hout.tag{end});
        else
          if (image_mode~=3)
            setappdata(curdata.gcf,'IMAGE_QUIVER',false);
          end
        end
      end
    end
    % Enable Contol : 2007.06.26
    if isfield(curdata,'menu_TextValue')
      set(curdata.menu_TextValue,'Enable','off');
    end
  else
    % Tell at 2007.05.22 12:54 <--> 13:50 update..
    %  mail --> to confine
    % --> Plot <--
    psn=time_axes_position(hdata);
    set(0,'CurrentFigure',curdata.gcf);
    set(curdata.gcf,'CurrentAxes',gca0);
    hold on;
    if 0
      cm=colormap;
      id0=linspace(cmin,cmax,size(cm,1));
      id0(end+1)=0;idlen=length(id0);
      for idx=1:size(psn,1)
        id0(end)=ydata(idx);
        [c0,ia0]=sort(id0);ia0=find(ia0==idlen);
        if ia0==idlen,ia0=idlen-1;end
        cl1=cm(ia0,:);
        cl0=cl1*0.8;
        hout.h(end+1)=line(psn(idx,1),psn(idx,2));
        set(hout.h(end),'Marker','o','LineStyle','none',...
          'MarkerEdgeColor',cl0,...
          'MarkerFaceColor',cl1);
        if ~isfinite(ydata(idx))
          set(hout.h(end),'LineStyle','none',...
            'Marker','pentagram',...
            'MarkerEdgeColor',[0 0 0],...
            'MarkerFaceColor',[0 0 0]*0.8);

        end
      end
    else
      if isfield(image2Dprop,'PatchImageProp')
        pip = image2Dprop.PatchImageProp;
      elseif isfield(curdata,'PatchImageProp')
        pip=curdata.PatchImageProp;
      elseif isfield(objdata,'PatchImageProp')
        pip=objdata.PatchImageProp;
      else
        pip.Alpha=0.5;
        pip.EdgeColor=[0.8 0.8 0.8];
        pip.EdgeSize=0.01;
      end

      theta=linspace(0,2*pi,20);
      x0=pip.EdgeSize*cos(theta);y0=pip.EdgeSize*sin(theta);


      for idx=1:size(psn,1)
        hout.h(end+1)=fill(x0+psn(idx,1),y0+psn(idx,2),ydata(idx));
        set(hout.h(end),'LineStyle','-',...
          'LineWidth',pip.EdgeSize,...
          'EdgeColor',pip.EdgeColor);
        if ~isfinite(ydata(idx))
          set(hout.h(end),'LineStyle',':','FaceColor','none')
        end
        alpha(hout.h(end),pip.Alpha);

        % Draw Text :: 2007.06.26
        if isfield(curdata,'menu_TextValue')
          set(curdata.menu_TextValue,'Enable','on');
          if strcmpi(get(curdata.menu_TextValue,'Checked'),'on')
            d=0.1;
            mx=max(psn(:,[1,2]));mn=min(psn(:,[1,2]));
            mx=mx+d;mn=mn-d;
            hout.h(end+1)=line([mn(1);mx(1)],[mn(2);mx(2)]);
            set(hout.h(end),'LineStyle','none'); % Dumy
            hout.h(end+1)=text(psn(idx,1),psn(idx,2),num2str(ydata(idx),'%6.2f'));
          end
        end
      end

    end
    setappdata(curdata.gcf,'IMAGE_QUIVER',false);
  end

  %===================
  % Axis Outer Setting
  %===================
  caxis([cmin,cmax]);
  % 2006.10.18 :: Change Colormap by menu.
  %if isfield(image2Dprop,'v_colormap'),
  %	osp_set_colormap(image2Dprop.v_colormap,gca0);
  %end
  if strcmp(curdata.region,'Block'),
    title(['Block : ' hdata.TAGs.DataTag{plot_kind}]);
  else
    title(['Continuous : ' hdata.TAGs.DataTag{plot_kind}]);
  end
  % color bar setting : If you want
  if 0,
    colorbar_char = getColorbarFcn;
    eval(colorbar_char);
  end
  %axis auto;
  axis image;
  axis off;
catch
  set(curdata.gcf,'CurrentAxes',gca0);%axes(gca0)
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
myName='AXES_PlotTest_2DImageData_XX';
if exist('ObjectID','var'),
  firstflag=false;
  p3_ViewCommCallback('Update', ...
    hout.h, myName, ...
    gca0, curdata, objdata, ObjectID);
else
  firstflag=true;
  p3_ViewCommCallback('CheckIn', ...
    hout.h, myName, ...
    gca0, curdata, objdata);
end

%==================================
%=      Common-Data Setting       =
%==================================
od=getappdata(curdata.gcf,'AXES_PlotTest_2DImageData');
odadd.handle = hout.h; % Handles of connected function
odadd.curdata = curdata0;
odadd.image2Dprop = image2Dprop;
if exist('pip','var')
  odadd.PatchImageProp=pip;
end

% added
if isfield(curdata,'Callback_2DImageColor') && ...
    isfield(curdata.Callback_2DImageColor,'handles') && ...
    ishandle(curdata.Callback_2DImageColor.handles),
  odadd.image2Dprop.Colormaphandle=curdata.Callback_2DImageColor.handles;
  % color-map-axis initialize
  %change_ColormapCaxis(gca0,odadd.image2Dprop.Colormaphandle);
  axs=get(odadd.image2Dprop.Colormaphandle,'UserData');
  %  2007.02.09 Shoji >>
  if isempty(axs),
    axs=gca0;
  else
    axs(end+1)=gca0;
  end
  set(odadd.image2Dprop.Colormaphandle,'UserData',axs);
end

if isfield (odadd.image2Dprop,'Colormaphandle') && ...
    ishandle(odadd.image2Dprop.Colormaphandle)
  cmh = odadd.image2Dprop.Colormaphandle;
  axs = get(cmh,'UserData');
  % Execute Only Last Data
  if ~exist('ObjectID','var') || ...
      ObjectID==length(axs)
    axs(~ishandle(axs))=[];
    if ~isempty(axs)
      clim=get(axs,'Clim');
      if iscell(clim), clim=cell2mat(clim);end
      clim=[min(clim(:)),max(clim(:))];
      set(axs,'Clim',clim);
    end
    % Set Clim to Axes
    set(cmh,'UserData',axs);

    % Set Clim to ColorMap Axes
    ytick=get(cmh,'YTick');
    xtick=get(cmh,'XTick');
    unit=100;
    if isempty(ytick)
      set(cmh,'XTickLabel',round(unit*linspace(clim(1),clim(2),length(xtick)))/unit);
    else
      set(cmh,'YTickLabel',round(unit*linspace(clim(1),clim(2),length(ytick)))/unit);
    end
  end
end
% << 2007.02.09 Shoji

if exist('ObjectID','var'),
  od{ObjectID}=odadd;
else
  if isempty(od),
    od{1}=odadd;
    ObjectID=1;
  else
    od{end+1}=odadd;
    ObjectID=length(od);
  end
end
setappdata(curdata.gcf,'AXES_PlotTest_2DImageData',od);

if ~firstflag,return;end
% ==============================
% =    Callback Setting List   =
% ==============================

%----------------------------
% Uimenu : Text-Value
%   2007.06.26 : shoji -->
%----------------------------
if isfield(curdata,'menu_TextValue') && ...
    ishandle(curdata.menu_TextValue),
  ud.axes=gca0;
  ud.ObjectID = ObjectID;
  set(curdata.menu_TextValue,...
    'UserData', ud, ...
    'Callback',...
    ['ck=get(gcbo,''Checked'');'...
    'if strcmpi(ck,''on''),'...
    '   set(gcbo,''Checked'',''off'');'...
    'else,'...
    '   set(gcbo,''Checked'',''on'');'...
    'end;'...
    'ud=get(gcbo,''UserData'');' ...
    'od=getappdata(gcbf,''AXES_PlotTest_2DImageData'');' ...
    'od = od{ud.ObjectID};' ...
    'try,delete(od.handle);end;' ...
    'osp_ViewAxesObj_2DImage(''testimage'', ' ...
    'ud.axes, od.curdata, ' ...
    'od ,ud.ObjectID);']);
end

%---------------------------
% Uimenu : Block / Continous
%----------------------------
if isfield(curdata,'menu_current') && ...
    ~isempty(getappdata(curdata.gcf,'BHDATA'))
  ud.axes=gca0;
  ud.ObjectID = ObjectID;
  h0=uimenu(curdata.menu_current,...
    'Label', '2D Image DataType', ...
    'UserData', ud, ...
    'Callback', ...
    ['ud=get(gcbo,''UserData'');' ...
    'od=getappdata(gcbf,''AXES_PlotTest_2DImageData'');' ...
    'od = od{ud.ObjectID};' ...
    'try,delete(od.handle);end;' ...
    'r=menu(''Chose Block'',''Continuous'',''Block'');' ...
    'if r==1, od.curdata.region=''Continuous'';' ...
    'else, od.curdata.region=''Block'';end;' ...
    'osp_ViewAxesObj_2DImage(''testimage'', ' ...
    'ud.axes, od.curdata, ' ...
    'od ,ud.ObjectID);']);
end

%------------------------
%  Image Mode
%------------------------
if isfield(curdata,'Callback_2DImageMode') && ...
    isfield(curdata.Callback_2DImageMode,'handles') && ...
    ishandle(curdata.Callback_2DImageMode.handles),
  % See also osp_ViewCallback_2DImageMode
  h             = curdata.Callback_2DImageMode.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''image_mode_ind'', mode);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%------------------------
%  Method
%------------------------
if isfield(curdata,'Callback_2DImageMethod') && ...
    isfield(curdata.Callback_2DImageMethod,'handles') && ...
    ishandle(curdata.Callback_2DImageMethod.handles),
  % See also osp_ViewCallback_2DImageMode
  h             = curdata.Callback_2DImageMethod.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''interpmethod'', method);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%------------------------
%  Step
%------------------------
if isfield(curdata,'Callback_2DImageStep') && ...
    isfield(curdata.Callback_2DImageStep,'handles') && ...
    ishandle(curdata.Callback_2DImageStep.handles),
  % See also osp_ViewCallback_2DImageMode
  h             = curdata.Callback_2DImageStep.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''v_interpstep'', step);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%------------------------
%  Channel Mask
%------------------------
if isfield(curdata,'Callback_2DImageMaskCh') && ...
    isfield(curdata.Callback_2DImageMaskCh,'handles') && ...
    ishandle(curdata.Callback_2DImageMaskCh.handles),
  % See also osp_ViewCallback_2DImageMaskCh
  h             = curdata.Callback_2DImageMaskCh.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  %%%maskch=image2Dprop.mask_channel; % get callback
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''mask_channel'', maskch);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%------------------------
%  Mean Period
%------------------------
if isfield(curdata,'Callback_2DImageMeanP') && ...
    isfield(curdata.Callback_2DImageMeanP,'handles') && ...
    ishandle(curdata.Callback_2DImageMeanP.handles),
  % See also osp_ViewCallback_2DImageMeanP
  h             = curdata.Callback_2DImageMeanP.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  %%%meanp=image2Dprop.v_MP; % get callback
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''v_MP'', meanp);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%------------------------
%  Axis Auto
%------------------------
if isfield(curdata,'Callback_2DImageAuto') && ...
    isfield(curdata.Callback_2DImageAuto,'handles') && ...
    ishandle(curdata.Callback_2DImageAuto.handles),
  % See also osp_ViewCallback_2DImageAuto
  h             = curdata.Callback_2DImageAuto.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  %%%val=image2Dprop.v_axisAuto; % get callback
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''v_axisAuto'', val);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

if isfield(curdata,'Callback_2DImageMin') && ...
    isfield(curdata.Callback_2DImageMin,'handles') && ...
    ishandle(curdata.Callback_2DImageMin.handles),
  % See also osp_ViewCallback_2DImageAuto
  h             = curdata.Callback_2DImageMin.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  %%%val=image2Dprop.v_axMin; % get callback
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''v_axMin'', val);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

if isfield(curdata,'Callback_2DImageMax') && ...
    isfield(curdata.Callback_2DImageMax,'handles') && ...
    ishandle(curdata.Callback_2DImageMax.handles),
  % See also osp_ViewCallback_2DImageAuto
  h             = curdata.Callback_2DImageMax.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  %%%val=image2Dprop.v_axMax; % get callback
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''v_axMax'', val);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

if isfield(curdata,'Callback_2DImageZerofix') && ...
    isfield(curdata.Callback_2DImageZerofix,'handles') && ...
    ishandle(curdata.Callback_2DImageZerofix.handles),
  % See also osp_ViewCallback_2DImageAuto
  h             = curdata.Callback_2DImageZerofix.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  %%%zerofix=image2Dprop.v_zerofix; % get callback
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''v_zerofix'', zerofix);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%------------------------
%  Time Slider (or edit)
%------------------------
if isfield(curdata,'Callback_2DImageTime') && ...
    isfield(curdata.Callback_2DImageTime,'handles') && ...
    ishandle(curdata.Callback_2DImageTime.handles),
  % See also osp_ViewCallback_2DImageTime
  h             = curdata.Callback_2DImageTime.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  udadd.str=['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''imageProperty'',ud{idx}, ''v_timeposition'', timepos);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%------------------------
%  Kind Selector
%------------------------
if isfield(curdata,'Callback_KindSelector') && ...
    isfield(curdata.Callback_KindSelector,'handles') && ...
    ishandle(curdata.Callback_KindSelector.handles),
  % See also osp_view
  h             = curdata.Callback_KindSelector.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca0;
  udadd.str  = ['ud{idx}=osp_ViewAxesObj_2DImage(' ...
    '''KindSelect'',ud{idx}, kind);'];
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==================================
function ud=imageProperty(ud, fdname, value)
% Change Image property
% Callback of
%  fdname  : name of Property
%  value   : value of Property
%  (property : name of image2Dprop field
%       ex. image_mode_ind,v_interpstep,.....)
%==================================
%axes(ud.axes);
f = get(ud.axes,'Parent');
set(f,'CurrentAxes',ud.axes);
%--> Object Data of PLOT-TEST <--
od = getappdata(f,'AXES_PlotTest_2DImageData');
od = od{ud.ObjectID};
ud.handle=od.handle;
ud.curdata=od.curdata;
%update image property
%%% ex: od.image2Dprop.image_mode_ind=mode;
inst=['od.image2Dprop.' fdname '=value;'];
eval(inst);
ud.image2Dprop.image2Dprop=od.image2Dprop;  %%%

%%+alpha
if isfield(od,'PatchImageProp')
  ud.image2Dprop.PatchImageProp=od.PatchImageProp;
end
if strcmpi(fdname,'image_mode_ind') && value==4
  if isfield(ud,'PatchImageProp')
    ud.image2Dprop.PatchImageProp=ud.PatchImageProp;
  end
end

try,
  if ~isempty(ud.handle),delete(ud.handle);end
catch
  warning(['Miss Delete Function : ', ...
    'Operating Speed might be too fast to redraw.']);
end

% Check,draw, update color-map-axis
h=testimage(ud.axes, ud.curdata, ud.image2Dprop ,ud.ObjectID);
% if isfield(od.image2Dprop,'Colormaphandle')
%   change_ColormapCaxis(ud.axes,od.image2Dprop.Colormaphandle);
% end
return;

% %==================================
% function change_ColormapCaxis(axh,cmh)
% % Change color-map-axis
% %==================================
% % Change Colormap
% clim=get(axh,'CLim');
% ytick=get(cmh,'YTick');
% xtick=get(cmh,'XTick');
% unit=1000;
% if isempty(ytick)
%   set(cmh,'XTickLabel',round(unit*linspace(clim(1),clim(2),length(xtick)))/unit);
% else
%   set(cmh,'YTickLabel',round(unit*linspace(clim(1),clim(2),length(ytick)))/unit);
% end

%==================================
function ud=KindSelect(ud,kind)
% Change Kind
% Callback of Kind Select
%==================================

%--> Object Data of PLOT-TEST <--
f = get(ud.axes,'Parent');
od = getappdata(f,'AXES_PlotTest_2DImageData');
od = od{ud.ObjectID};
ud.handle=od.handle;
ud.curdata=od.curdata;
%update image property
ud.image2Dprop.image2Dprop=od.image2Dprop;  %%%
if isfield(od,'PatchImageProp')
  ud.image2Dprop.PatchImageProp=od.PatchImageProp;
end


try,
  delete(ud.handle);
catch
  warning(['Miss Delete Function : ', ...
    'Operating Speed might be too fast to redraw.']);
end

% Check,

if length(kind)>=2,
  kind=kind(1);
  warndlg({' Warning: Too many kinds for image', ...
    '          Ignore some kinds.'},'Axes 2D Image');
end
ud.curdata.kind=kind;
set(gcbf,'CurrentAxes',ud.axes);
%axes(ud.axes);
h=testimage(ud.axes, ud.curdata, ud.image2Dprop ,ud.ObjectID);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% temporpry func
function colorbar_fcn = getColorbarFcn()
% matlab ver7.0.0 colorbar axes size
try
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    colorbar_fcn = 'colorbar2(''EastOutside'');';
  else
    colorbar_fcn = 'colorbar';
  end
catch
  warning(lasterr);
  colorbar_fcn = 'colorbar';
end
return;

