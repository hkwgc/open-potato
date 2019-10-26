function varargout = PlugInWrap_pushdata_popdata(fcn, varargin)
% Add Raw-Data at the end of data, when ETG-format.
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_AddRaw('createBasicIno');
%    Return Information for OSP Application.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_AddRaw('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_AddRaw('createBasicIno',region, fdata)
%
%  Make M-File of adding Raw
%
% See also OSPFILTERDATAFCN.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% Original author : Takusige Katura
% create : 2005.12.12
% Reversion : 1.00
%
%   No check..

%======== Launch Switch ========
  if strcmp(fcn,'createBasicInfo'),
    varargout{1} = createBasicInfo;
    return;
  end

  if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{:});
  else,
    feval(fcn, varargin{:});
  end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo,
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         BLOCK   : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'zzzzz# push|pop data #zzzzzz';
  basicInfo.region = [2 ];
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin),
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data0 = varargin{1}; % Filter Data
  if isfield(data0, 'argData')
    % Use Setting Value.
    % ( Change )
    data = data0.argData;
  else
    data = [];
  end

  % Default Value for start
  if isempty(data) || ~isfield(data,'Mode'),
    data.Mode='push';
    data.Kind='1:3';
	data.tmpNum=1;
  elseif strcmp(data.Mode,'clear')
	data.tmpNum=1;
  end
  

  % Display Prompt words

  % Figure
  fh=figure('MenuBar','none', 'Units','Characters');
  p=get(fh,'Position');  p(3:4)=[80,10];set(fh,'Position',p);
  set(fh,'Units','Normalized','name','push|pop','numbertitle','off'); set(fh,'DeleteFcn','error(''Push OK / Cancel'');');
  % Title
  th = uicontrol('Style','Text', ...
		 'Units','Normalized', ...
		 'Position',[5,80,90,15]/ 100, ...
		 'String','z# push | pop data #z', ...
		 'HorizontalAlignment','left');
  % Popup Menu1
  pstr1 = {'push','pop', 'clear'};  val=find(strcmp(pstr1,data.Mode));
  ph1 = uicontrol('Style','popupmenu', 'Units','Normalized',  'BackgroundColor',[1 1 1], ...
		 'Position',[10,50,70,20]/ 100,  'String', pstr1, 'Value', val);	 
  % Popup Menu 2
  pstr2 = {'# 1','# 2','# 3','# 4','# 5'};
  val  = data.tmpNum;
  ph2 = uicontrol('Style','popupmenu', 'Units','Normalized', 'BackgroundColor',[1 1 1], ...
		 'Position',[10,30,30,20]/ 100, 'String', pstr2, 'Value', val);	  
  % kind edit
  ph3 = uicontrol('Style','edit', 'Units','Normalized', 'BackgroundColor',[1 1 1], ...
		 'Position',[50,30,30,20]/ 100, 'String', data.Kind);	  

  % OK button
  oh = uicontrol('Units','Normalized', 'Position',[30,10,20,20]/ 100, 'BackgroundColor',[1 1 1], ...
		 'String', 'OK', 'Callback', ['set(gcbf,''DeleteFcn'',''''); set(gcbf,''UserData'',true);']);
  ch = uicontrol('Units','Normalized', 'Position',[60,10,20,20]/ 100, 'BackgroundColor',[1 1 1], ...
		 'String', 'Cancel', 'Callback', ['set(gcbf,''DeleteFcn'','''');set(gcbf,''UserData'',false);']);
  waitfor(fh,'DeleteFcn','');
  if ishandle(fh), flg = get(fh,'UserData');
    % Cancel
    if flg, 
		data.Mode=pstr1{get(ph1,'Value')};
		if ~strcmp(data.Mode,'clear')
			data.tmpNum=get(ph2,'Value');
			data.Kind=get(ph3,'String');
		else
			data.tmpNum=[];data.Kind=[];
		end
	  %data0.name=['z# ' data.Mode ' #' num2str(data.tmpNum) ' #z'];
	  
    else,
      data=[]; 
    end
    delete(fh);
  else,
    data=[];
  end
  
  data.ver = 1.00;
  data0.argData=data;
  varargout{1}=data0;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  A=fdata.argData;
  %make_mfile('with_indent', ['% == z#' A.Mode ' data #z ==']);
  switch A.Mode
	  case 'push'
		  make_mfile('with_indent', sprintf('push_tmp{%d}=data(:,:,%s); %% zzzzz# push <%d> # zzzzz -->>>',A.tmpNum,A.Kind,A.tmpNum));
	  case 'pop'
		  make_mfile('with_indent', sprintf('data(:,:,%s)=push_tmp{%d}; %% zzzzz# pop  <%d> # zzzzz <<<--',A.Kind,A.tmpNum,A.tmpNum));
	  case 'clear'
		  make_mfile('with_indent', 'clear push_tmp; %% zzzzz# clear # zzzzz ----');
  end
  make_mfile('with_indent', ' ');
  str='';
  
return;
