function varargout = uiPCA2(varargin)
% UIPCA2 M-file for uiPCA2.fig
%      UIPCA2, by itself, creates a new UIPCA2 or raises the existing
%      singleton*.
%
%      H = UIPCA2 returns the handle to a new UIPCA2 or the handle to
%      the existing singleton*.
%
%      If you want to chaneg Using Data or Start up UIPCA2, 
%      set value that used in UIPCA2. To Set Value 
%      UIPCA2('SetValue',hObject,[],handles, ...
%              BlockData, BlockKind, HBkindTag, ...
%              Astimtimes, Unit, MeasureMode);
%      Those Value can get by using getappdata.
%      if you want to check data, 
%          getappdata(uiPCA2)
%
%      UIPCA2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIPCA2.M with the given input arguments.
%
%      UIPCA2('Property','Value',...) creates a new UIPCA2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uiPCA2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uiPCA2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 26-Sep-2005 15:19:33

% ===================================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ===================================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.04.04
% $Id: uiPCA2.m 180 2011-05-19 09:34:28Z Katura $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiPCA2_OpeningFcn, ...
                   'gui_OutputFcn',  @uiPCA2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   GUI Control functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uiPCA2_OpeningFcn(hObject, eventdata, handles, varargin)
%----------------------------------------------------------------
% Open Figure with No Data.
%  Data must set by calling Callback 'SetValue'
%----------------------------------------------------------------
  handles.output = hObject;
  set(hObject,'Color',[1 1 1]);
  guidata(hObject, handles);


function varargout = uiPCA2_OutputFcn(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Output is handle of uiTttest
%----------------------------------------------------------------
  varargout{1} = handles.output;


function figure1_KeyPressFcn(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Common Keybind Setting
%----------------------------------------------------------------
  osp_KeyBind(hObject,[],handles,mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Data Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetValue(hObject, eventdata, handles, varargin)
%----------------------------------------------------------------
% Init Function : Set Apprication Value
%   This Function Input must be common in Statistic Analysis GUI
%----------------------------------------------------------------

  if 0,
	  h= handles.figure1;
	  argName={'BlockData', ...
			  'BlockKind', ...
			  'HBkindTag', ...
			  'Astimtimes', ...
			  'Unit', ...
			  'MeasureMode'};
	  
	  % -- Set Apprication Data --
	  % use max, to detect error 
	  for vid = 1: max( (nargin-3), length(argName)),  
		  setappdata(h, argName{vid},varargin{vid});
	  end
	  
	  %===  Initial Value Setting ===
	  
	  % -- Block Data --
	  sz=size(varargin{1});
	  set(handles.text_bknum, 'String', num2str(sz(1)));
	  set(handles.text_chnum, 'String', num2str(sz(3)));
	  set(handles.text_hbnum, 'String', num2str(sz(4)));
	  
	  % -- Stimtime --
	  astimtimes = varargin{4};
	  astimtime = astimtimes(1); clear astimtimes;
	  set(handles.text_iniBlock, 'String', num2str(astimtime.iniBlock));
	  set(handles.text_iniStim,  'String', num2str(astimtime.iniStim));
	  set(handles.text_finStim,  'String', num2str(astimtime.finStim));
	  set(handles.text_finBlock, 'String', ...
		  num2str(astimtime.finBlock));
	  
	  % -- HB kind --
	  hbtag=getappdata(h, 'HBkindTag');
	  set(handles.pop_hbkind,'String',hbtag);
  else,
	  % since OSP version 1.10 
	  h= handles.figure1;
	  msg=nargchk(5,5,nargin);
	  if ~isempty(msg), error(msg); end;
	  
	  data  = varargin{1};
	  hdata = varargin{2}; 
	  clear varargin;
	  setappdata(h, 'BlockData', data);;
	  % setappdata(h, 'Header', hdata);
	  try,
		  setappdata(h,'HBkindTag', hdata.TAGs.DataTag);
		  if ~isempty(hdata.TAGs.DataTag),
			  set(handles.pop_hbkind,...
				  'Value',1, ...
				  'String',hdata.TAGs.DataTag);
		  end
	  end

	  try,
		  setappdata(h,'MeasureMode', hdata.measuremode);
	  end
	  %===  Initial Value Setting ===
	  
	  % -- Block Data --
	  sz=size(data);
	  set(handles.text_bknum, 'String', num2str(sz(1)));
	  set(handles.text_chnum, 'String', num2str(sz(3)));
	  set(handles.text_hbnum, 'String', num2str(sz(4)));
	  
	  % Stimulation timing in Block-Data-Time-cordinate
	  asimtime.iniBlock =  0;
	  astimtime.iniStim  = hdata.stim(1);
	  astimtime.finStim  = hdata.stim(2);
	  astimtime.finBlock = sz(2);
	  setappdata(h,'Astimtimes', astimtime);
	  
	  % unit transrate
	  unit      = 1000/hdata.samplingperiod;
	  setappdata(h,'Unit', unit);
	  
	  start_p   = -(hdata.stim(1)  -1)/unit;
	  setappdata(h, 'StartIndexTime',start_p);
	  
	  astimtime.iniBlock = start_p;
	  astimtime.iniStim  = 0;
	  astimtime.finStim  = start_p+(hdata.stim(2)  -1)/unit;
	  astimtime.finBlock = start_p+(sz(2) -1)/unit;
	  
	  set(handles.text_iniBlock, 'String', num2str(astimtime.iniBlock));
	  set(handles.text_iniStim,  'String', num2str(astimtime.iniStim));
	  set(handles.text_finStim,  'String', num2str(astimtime.finStim));
	  set(handles.text_finBlock, 'String', num2str(astimtime.finBlock));
	  set(handles.edit_channel, 'String',['1:' num2str(sz(3))]);
  end

  pop_ref_wav_Callback(hObject, eventdata, handles)

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Make Analys Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pop_AD_Mat_CreateFcn(hObject, eventdata, handles)
% --------------------------------------------
% Create Function of Popupmenu.
% The Popupmenu selecte Analysis Data Matrix Making Mothod 
%
%  Here is Setting of 'String', USERDATA for the Callback-Function.
%  USERDATA is Structure data array for the 'String'.
%  Meaning of field data is following. 
%
% --------------------------------------------
  
  str = { ...
      'Block Mean : Channel x Time', ...
      'Channel Mean : Block x Time', ...
      'Block x (Channel + Time)', ...
      '(Block + Channel) + Time'};

  % now 
  str(2:end) = [];
  set(hObject,'String', str);

function pop_AD_Mat_Callback(hObject, eventdata, handles)
% --------------------------------------------
% CALLBACK Function of Popupmenu.
% The Popupmenu selecte Analysis Data Matrix Making Mothod.
%  Now Do Nothing in paticular
% --------------------------------------------
  
function ch=edit_channel_Callback(hObject, eventdata, handles)
% --------------------------------------------
% CALLBACK Function of Channel-Setting Edit-Text
%  This Edit-Text written using chnannel number.
%  Check Channel Overfllow, Underfllow.
% --------------------------------------------
  try
    ch = str2num(get(hObject,'String'));
    ch = round(ch);
  catch
    errordlg('Input Data Must be Integer');
    return;
  end

  chflg = 0;

  % undef flow check
  uf = find(ch<=0);
  if ~isempty(uf)
    warndlg({'Channel must be Positive', ...
	     ' Ignore Negative and 0 value.'});
    ch(uf)=[]; chflg=1;
  end
  % over flow check
  of = find(ch>str2num(get(handles.text_chnum, 'String')));
  if ~isempty(of)
    warndlg('Channel must be smaller than channel number');
    ch(of)=[]; chflg=2;
  end
    
  if isempty(ch)
    errrordlg('No Effective Channel.');
  elseif chflg~=0
    set(hObject,'String',num2str(ch));
  end
return;
  
function mat=make_mat(handles)
% --------------------------------------------
% Make Analysing Matrix
% --------------------------------------------

  fig_h = handles.figure1;

  % Load Data
  % First Filtering : using data 
  ch = edit_channel_Callback(handles.edit_channel, [], handles);
  data = getappdata(fig_h, 'BlockData');
  % now no time filter
  data = data(:,:,ch,get(handles.pop_hbkind,'Value'));

  str = { ...
      'Block Mean : Channel x Time', ...
      'Channel Mean : Block x Time', ...
      'Block x (Channel + Time)', ...
      '(Block + Channel) + Time'};
  str = get(handles.pop_AD_Mat, 'String');
  str = str{get(handles.pop_AD_Mat, 'Value')};
  switch str
   case 'Block Mean : Channel x Time',
    if size(data,1) > 1
      data = nan_fcn('mean', data, 1);
    end
    sz = size(data); sz(1)=[];
    if sz(end)==1, sz(end)=[]; end
    if length(sz)==1, sz(2)=1; end
    data = reshape(data,sz);

   otherwise
    errordlg(['Cannot make Analysis Matrix for ' str]);
  end
  
  if get(handles.chb_transpose,'Value')
    mat=data';
  else
    mat=data;
  end

  return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Execute PCA : ( Plot )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_plot_Callback(hObject, eventdata, handles)
% -- perform PCA --

  mat=make_mat(handles);
  n=size(mat,1);
  if n<=1, errordlg('Not enogh Rank for PCA');return;end
  % - get matrix 
  % mat0, n-by-p, is normarized data
  % mat1, p-by-p, is (covariance/correlate) matrix 
  mat0 = mat - repmat(nan_fcn('mean',mat,1),n,1);
  %mat1 = conj(mat0)'*mat0;
  mat1 = corrcoef(mat0);

  % eigen-value
  [w0 U]=eig(mat1);w=w0';
  PC=w'*(mat0');
  PC=flipdim(PC,1);

  ref_wav=getReferenceWave(handles,mat0);
  
  figure;
  sz_plot = size(U,1);
  if (sz_plot > 6) sz_plot=6; end

  subplot(sz_plot+1,1,1);
  plot(ref_wav);
  axis tight;
  
  for id=1:sz_plot,
	  pc_id = size(PC,1)+1-id;

	  %
	  ax_h(1)=subplot(sz_plot+1,2,id*2+1);
	  cr=corrcoef( PC(pc_id,:), ref_wav);
	  plot(PC(pc_id,:));
	  axis tight;
	  ax=axis;
	  t_h=text((ax(1)+ax(2))/2, ax(4),...
		  [' Correlation : ' num2str(cr(1,2))]);
	  set(t_h, ...
		  'BackgroundColor', 'white', ...
		  'interpreter', 'none');
	  ax_h(2)=subplot(sz_plot+1,2,id*2+2);
      bar(w(:,pc_id));
	  axis tight;
	  if (id~=sz_plot), 
		  set(ax_h,'Xtick',[]);
	  end
  end
return;
%   d=-sort(-diag(U)/sum(diag(U)));
%   c=cumsum( d );
%   cT=( c>edit_threshold_Callback(handles.edit_threshold, [], handles));

  % -- Plot --
%   st = get(handles.pop_plotkind,'String');
%   st = st{get(handles.pop_plotkind,'Value')};
% 
% 
%   switch st,
% 
%    case 'Eigen Value',
%     handles2.figure1= figure('name','Eigen-Value'); 
%     handles2.bar0   = bar( d *100,'b'); hold on
%     handles2.baruse = bar( cT.*d*100 ,'m');    
%     xlabel('Variable');
%     ylabel('Eigen Value [%]');
%     ax0=axis; ax0(3:4)=[0 100];  axis(ax0);
% 
%    case 'correration'
%     figure('name','correration');
%     delay=1; %% --
%     s=size(mat0,1);
%     Box0=zeros(1, (s+500+500));
%     Box0(1, 501:end-500)=mat0(:,1)';
%     Box=Box0(1, 501+delay:end-500+delay);
% 
%     for j=1:size(PC,1)
%       cr=corrcoef( PC(j,:), Box);
%       crm(1,j)=cr(1,2);
%     end
%     bar(crm(end:-1:1));
%     h2=axes('position',[0.7 0.7 0.2 0.2]);
%     plot(squeeze(mean(mat0,2)));
%     hold on;
%     plot(Box+0.1,'r','Linewidth',2);
% 
%    case 'PCs'
%     figure('name','PCs')
%     osp_plots(PC(end:-1:1,:))
%     
%    case 'W',
%     figure('name', 'W');PC=PC';       
%     s=size(PC,2);
%     for i=1:s
%       subplot(ceil(sqrt(s)), ceil(sqrt(s)), i)
%       bar(w(:,i));
%       axis([0 s+1 -1 1]);title(['ch ' num2str(i)])
%     end
% 
%    otherwise,
%     errordlg(' Program Error : No plot method');
%   end
    

function ref_wav=getReferenceWave(handles, mat0),
% Make Reference Wave 
% --> This function will be changed

sz=size(mat0,1);
mode = get(handles.pop_ref_wav,'String');
mode = mode{get(handles.pop_ref_wav,'value')};

switch mode,
	case 'rectangle',
		top     = str2double(get(handles.edt_rf1,'String'));
		st      = str2double(get(handles.edt_rf2,'String'));
		ed      = str2double(get(handles.edt_rf3,'String'));
		[st, ed] = sec2point(handles,  st, ed);
		if st<=0, st=1; end
		if ed>sz(1), ed=sz(1); end
		
		ref_wav = zeros(1,sz(1));
		ref_wav(1,st:ed) = top;
	case 'trapz',
		top    = str2double(get(handles.edt_rf1,'String'));
		a      = str2double(get(handles.edt_rf2,'String'));
		b      = str2double(get(handles.edt_rf3,'String'));
		c      = str2double(get(handles.edt_rf4,'String'));
		d      = str2double(get(handles.edt_rf5,'String'));
		[a, b, c, d] = sec2point(handles, a, b, c, d);
		
		ref_wav          = zeros(1,sz(1));
		ref_wav(1,a:b)   = linspace(0,top, b-a+1);
		ref_wav(1,b+1:c) = top;
		ref_wav(1,c:d)   = linspace(top,0, d-c+1);
	otherwise,
		delay =str2double(get(handles.edt_rf1,'String'));

		Box0=zeros(1,(sz(1)+500+500));
		Box0(1, 501:end-500)=mat0(:,1)';
		Box=Box0(1, 501+delay:end-500+delay);
		ref_wav = Box0(1, 501+delay:end-500+delay);
end
return;


% --- Executes on selection change in pop_ref_wav.
function rcode=pop_ref_wav_Callback(hObject, eventdata, handles)
rcode=0;
mode = get(handles.pop_ref_wav,'String');
mode = mode{get(handles.pop_ref_wav,'value')};
switch mode,
	case 'rectangle',
		set(handles.text_rf1,'String','top',...
			'Visible','on');

		set(handles.text_rf2,'String','start',...
			'Visible','on');

		set(handles.text_rf3,'String','end',...
			'Visible','on');

		set([handles.edt_rf1, handles.edt_rf2, handles.edt_rf3],...
			'Visible','on');

		set([handles.text_rf4 , handles.edt_rf4, ...
				handles.text_rf5 , handles.edt_rf5], ...
				'Visible','off');
	case 'trapz',
		set(handles.text_rf1,'String','top',...
			'Visible','on');

		set(handles.text_rf2,'String','start',...
			'Visible','on');
		
		set(handles.text_rf3,'String','start top',...
			'Visible','on');

		set(handles.text_rf4,'String','end top',...
			'Visible','on');
		
		set(handles.text_rf5,'String','end',...
			'Visible','on');
		set([handles.edt_rf1, handles.edt_rf2, ...
				handles.edt_rf3, handles.edt_rf4, handles.edt_rf5],...
			'Visible','on');

	otherwise,
		set(handles.text_rf1,'String','delay',...
			'Visible','on');
		set(handles.edt_rf1,'Visible','on');
		set([handles.text_rf2 , handles.edt_rf2, ...
				handles.text_rf3 , handles.edt_rf3, ...
				handles.text_rf4 , handles.edt_rf4, ...
				handles.text_rf5 , handles.edt_rf5], ...
				'Visible','off');
end

  mat=make_mat(handles);
  n=size(mat,1);
  if n<=1, errordlg('Not enogh Rank for PCA');return;end
  mat0 = mat - repmat(nan_fcn('mean',mat,1),n,1);
  ref_wav=getReferenceWave(handles,mat0);
  axes(handles.ax_refwav);
  start_p   = str2double(get(handles.text_iniBlock, 'String'));
  end_p     = str2double(get(handles.text_finBlock, 'String'));
  t = linspace(start_p, end_p,size(ref_wav(:),1));
  plot(t(:),ref_wav(:));
  axis tight;

function edt_rf0_Callback(hObject,eventdata,handles)
	rcode=pop_ref_wav_Callback(handles.pop_ref_wav,[],handles);
	if (rcode),
		set(hObject,'FontColor','red');
	end
return;


% --- Executes on selection change in pop_hbkind.
function pop_hbkind_Callback(hObject, eventdata, handles)
pop_ref_wav_Callback(handles.pop_ref_wav,[], handles);

function varargout = sec2point(handles, varargin),

data=[varargin{:}];
unit = getappdata(handles.figure1,'Unit');
start_p   = str2double(get(handles.text_iniBlock, 'String'));

data = round((data-start_p).*unit + 1);

mx = max(nargout, length(data));
for id=1:mx,
	varargout{id}=data(id);
end
