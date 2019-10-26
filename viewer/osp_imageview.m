function varargout = osp_imageview(varargin)
% OSP_IMAGEVIEW Application M-file for osp_imageview.fig
%    FIG = OSP_IMAGEVIEW launch osp_imageview GUI.
%    OSP_IMAGEVIEW('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 10-Dec-2003 15:04:11


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original
%
% 2005.05.10 : Change colorbar to colorbar2.
%              for MATLAB version 7.0.0
%
% $Id: osp_imageview.m 180 2011-05-19 09:34:28Z Katura $

% Reversion 1.4
%  Apply Position Data

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	handles.figure1 = fig;
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = sldPos_Callback(h, eventdata, handles, varargin)

  timepos=round(get(h,'Value'));
  set( handles.edtPos, 'String', timepos );

  HB=[];
  if get(handles.cbxHB1,'Value'), HB=[HB 1];end
  if get(handles.cbxHB2,'Value'), HB=[HB 2];end
  if get(handles.cbxHB3,'Value'), HB=[HB 3];end
  if isempty(HB),return;end

  %HB=get( findobj(gcf,'Tag','ppmHB'), 'Value' );

  xdata=getappdata(handles.figure1,'xdata');
  ydata=getappdata(handles.figure1,'ydata');
  measuremode=getappdata(handles.figure1,'measuremode');
  header=getappdata(handles.figure1,'HEADER');

  % Mask ch data
  ydata(:, str2num( get(handles.edtMaskCh, 'String') ), :)=0;

  % get single time point data
  v_MP=str2num( get( handles.edtMeanPeriod, 'String') );
  v_tstart=timepos-fix(v_MP/2);
  v_tend=timepos+fix(v_MP/2);
  if (v_tstart<1 ) v_tstart=1;, end
  if (v_tend>size(ydata,1) ) v_tend=size(ydata,1);, end    

  ydata=squeeze( mean( ydata(v_tstart:v_tend, :, :), 1) );

  % setup Axis
  if get( handles.cbxAxisAuto, 'Value')
    v_axMax=max(max(max(ydata)));
    v_axMin=min(min(min(ydata)));
    set( handles.edtAxisMax, 'String', num2str(v_axMax));
    set( handles.edtAxisMin, 'String', num2str(v_axMin));
  else
    v_axMax=str2num( get(handles.edtAxisMax, 'String') );
    v_axMin=str2num( get(handles.edtAxisMin, 'String') );
  end
  if (v_axMax==v_axMin) v_axMax=v_axMax+1;,end

  % convert channel to image
  v_interpstep=str2num( get(handles.edtInterpMatrix, 'String' ) );
  v_interpmethod=get(handles.ppmInterpMethod, 'String');
  v_interpmethod=char(v_interpmethod(get(handles.ppmInterpMethod, 'Value')));
  image_mode=get( handles.ppmImgmode, 'Value');

  % -- figure setup --
  % image_h for ploting 3D..
  image_h = getappdata(handles.figure1, 'IMAGE_HANDLE');
  if isempty(image_h) || ~ishandle(image_h),
    image_h=figure;
    set(handles.figure1, 'Units', 'Normalize');
    set(image_h, 'Units', 'Normalize');
    pos     = get(handles.figure1, 'Position');
    pos2    = get(image_h,'Position');
    pos2(1) = pos(1);                 % right
    pos2(2) = pos(2) + pos(4)*1.2;    % bottom
    if pos2(2) > 0.5, pos2(2)=0.5; end
    pos2(3) = pos(3);                 % width
    if pos(2)+pos(4) > 1,             % heigh
      pos2(4)= 1-pos(4) + 0.2;
    end
    set(image_h, ...
	'Units', 'Normalized', ...
	'Position',pos2, ...
	'Name', 'OSP-IMGVIEW');
    setappdata(handles.figure1, 'IMAGE_HANDLE',image_h);
  else
    % change Set Image Handle to Current Figure.
    figure(image_h);
  end

  osp_set_colormap(get(handles.ppmColormap,'Value'));
  if get(handles.cbxZerofix,'Value')
    cmin=-max([abs(v_axMin), abs(v_axMax)]);
    cmax=max([abs(v_axMin), abs(v_axMax)]);
  else
    cmax=v_axMax;
    cmin=v_axMin;
  end
  %

  sz=size(HB,2);
  for i=1:sz

    [c0, x0, y0] = osp_chnl2imageM(ydata(:,HB(i))',...
				   header, image_mode, ...
				   v_interpstep, v_interpmethod);

    subplot(sz, 1,i);
    hold on;

    for plid = 1:length(c0),
      imagesc(x0{plid}, y0{plid}, ...
	      c0{plid}',[v_axMin, v_axMax]);
    end
    caxis([cmin,cmax]);colorbar2;
    axis auto;
    axis image;
	axis off;
	switch HB(i),
		case 1,
			title('Oxy');
		case 2,
			title('Deoxy');
		case 3,
			title('Total');
	end

  end

% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = figure1_CreateFcn(h, eventdata, handles, varargin)
% On Create



% --------------------------------------------------------------------
function varargout = cbxAxisAuto_Callback(h, eventdata, handles, varargin)
% Axis Auto Checkbox
  if get(h,'Value')
    set( handles.edtAxisMax, 'Enable', 'off');
    set( handles.edtAxisMin, 'Enable', 'off');
  else
    set( handles.edtAxisMax, 'Enable', 'on');
    set( handles.edtAxisMin, 'Enable', 'on');
  end
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = ppmImgmode_Callback(h, eventdata, handles, varargin)
% Image Mode Change

  switch get(h, 'Value')
   case {1, 3} % POINTS
    set( handles.edtInterpMatrix, 'Visible', 'off');
    set( handles.txtInterpMatrix, 'Visible', 'off');
    set( handles.ppmInterpMethod, 'Visible', 'off');
   case 2 % INTERPED
    set( handles.edtInterpMatrix, 'Visible', 'on');
    set( handles.txtInterpMatrix, 'Visible', 'on');
    set( handles.ppmInterpMethod, 'Visible', 'on');
  end

% --------------------------------------------------------------------
function varargout = ppmSldSpeed_Callback(h, eventdata, handles, varargin)
% Slider Speed

  xdata         = getappdata(handles.figure1, 'xdata');
  if isempty(xdata)
          warndlg('No Image Data exist');return;
  end
 sld_v = get( handles.sldPos, 'Value');
 if sld_v<=0, sld_v=1; end

 sldsp=2^(get( handles.ppmSldSpeed,'Value')-1);%Slide Speed
 stepOfButton = sldsp/size(xdata,2);
 if stepOfButton>1, stepOfButton = 1; end % This is rate, so 0 to 1

 if sld_v>size(xdata,2), sld_v=size(xdata,2); end
 set(handles.sldPos, ...
     'Value',sld_v, ...
     'Min',1, ...
     'Max', size(xdata,2), ...
     'SliderStep', [ stepOfButton 0.05]);

% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)
% Save as AVI
  h0      = handles.figure1;
  h       = handles.sldPos;
  image_h = getappdata(handles.figure1, 'IMAGE_HANDLE');

  v_pushpos=get(h,'Value');
  set(h,'Value',1); % set start frame postition 
  
  h1=findobj(h0,'Tag','ppmSldSpeed');% get frame speed
  v_speed=2^(get(h1,'Value')-1);
  v_frameend=size(getappdata(h0,'xdata'), 2);% get frame end

  [f p]=uiputfile('*.avi');% get save file name
  if ( f==0 ) & ( p==0) , return, end

  movF=avifile([p f]); % prepare for AVI file

  for i=1:v_speed:v_frameend
    figure(h0);
    set(h,'Value',i); % set frame postition     
    sldPos_Callback(h,[],handles);
    mov(i)=getframe(image_h);
    movF=addframe(movF,mov(i));    
  end
  movF=close(movF) % close AVI file

  figure(h0);
  set(h,'Value',v_pushpos); % pop start frame postition 
  sldPos_Callback(h,[],handles);

% --------------------------------------------------------------------
function varargout = figImageview_DeleteFcn(h, eventdata, handles, varargin)
% destructer
  try
    image_h = getappdata(handles.figure1, 'IMAGE_HANDLE');
    if ~isempty(image_h) && ishandle(image_h)
      close(image_h);
    end
  catch
    % - print error by warning  -
    % -- !! Warning !! --
    % Do not user error for DeleteFcn,
    % or can not delete this figure.
    % * shoji:13-Mar-2005
    warning(lasterr);
  end


% --------------------------------------------------------------------
function varargout = pushbutton2_Callback(h, eventdata, handles, varargin)
% save as jpg

  image_h = getappdata(handles.figure1, 'IMAGE_HANDLE');
  if isempty(image_h) || ~ishandle(image_h)
    errordlg(sprintf([' No figrue to Save!\n' ...
		      'Set Option and change  slid bar.']));
    return;
  end
  [f p]=uiputfile({'*.jpg';'*.bmp';'*.tif'});
  saveas(image_h, [p f]);
  cd(p)


% --------------------------------------------------------------------
function varargout = edtInterpMatrix_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = popupmenu3_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = ppmInterpMethod_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edtChMask_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = popupmenu5_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = ppmColormap_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = cbxZerofix_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = sldPos_ButtonDownFcn(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = cbxHB1_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = cbxHB2_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = cbxHB3_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = figImageview_ResizeFcn(h, eventdata, handles, varargin)
function varargout = ppmHB_Callback(h, eventdata, handles, varargin)
function varargout = edtAxisMax_Callback(h, eventdata, handles, varargin)
function varargout = edtAxisMin_Callback(h, eventdata, handles, varargin)
function varargout = edtPos_Callback(h, eventdata, handles, varargin)
function varargout = popupmenu1_Callback(h, eventdata, handles, varargin)
function varargout = edtMeanPeriod_Callback(h, eventdata, handles, varargin)

% ============= Aditional Function ==================
function init_imageview(hObject,eventdata,handles,varargin)

  if ~isfield(handles,'figure1'), 
    handles = guidata(handles);
  end

  set( handles.edtMeanPeriod, ...
       'String', '1', ...
       'Enable', 'inactive');
  set( handles.cbxAxisAuto, 'Value', 1);

  set( handles.ppmSldSpeed,'Value',1);
  ppmSldSpeed_Callback(handles.ppmSldSpeed,[],handles);
  set( handles.edtPos, 'String','1');
  set( handles.sldPos, 'Min',1);
  
  % init plot : total
  if ~any([get(handles.cbxHB1,'Value'), ...
	   get(handles.cbxHB2,'Value'), ...
	   get(handles.cbxHB3,'Value')]),
    set(handles.cbxHB3,'Value',1);
  else
    disp([get(handles.cbxHB1,'Value'), ...
	  get(handles.cbxHB2,'Value'), ...
	  get(handles.cbxHB3,'Value')])
  end
  sldPos_Callback(handles.sldPos, [], handles);
return;
