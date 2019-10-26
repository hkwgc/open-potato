function varargout=POTATo_win_Research_PreMix(fnc,varargin)
% POTATo Analysis-Status : Research-PreMix Analysis
%  Analysis-GUI-sets, 
%  when Research (P3-Mode), multi-data.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
%  2010.11.02 : New! (2010_2_RA01-3)
%  2010.11.02 : Add GUI
%  2010.11.05 : Update Activate (2010_2_RA02-2)
%               Add    SaveData (2010_2_RA02-2)

%======== Launch Switch ========
switch fnc,
  case 'Suspend',
    Suspend(varargin{:});
    
  case 'Activate',
    Activate(varargin{:});    
  
  case 'SaveData'
    % 2010_2_RA02-2
    varargout{1}=SaveData(varargin{:});
    
  case 'DrawLayout'
    % 2010_2_RA02-5
    varargout{1}=DrawLayout(varargin{:});
    
  case {'DisConnectAdvanceMode','ChangeLayout','Export2WorkSpace','ConnectAdvanceMode'},
    % (mean Do nothing)
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  otherwise
    try
      % sub Function
      if nargout,
        [varargout{1:nargout}] = feval(fnc, varargin{:});
      else
        feval(fnc, varargin{:});
      end
    catch
      % --> Undefined Function : Use Default Function
      if nargout,
        [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
      else
        POTATo_win(fnc,varargin{:});
      end
    end
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make GUI & Handle Control
function h=myHandles(hs)
% For Debug Print
%h=hs.([mfilename '_TODO']);
h=[];
% Handles
h=[h,hs.txt_RPMix_title,...
  hs.pop_RPMix_AnaFile, hs.lbx_RPMix_AnaFileInfo,...
  hs.lbx_RPMix_RecipeGroup, hs.psb_RPMix_RecipeGroup,...
  hs.psb_RPMix_RecipeGroup_Edit,...
  hs.frm_RPMix_EditableFilters,...
  hs.txt_RPMix_EF_title, hs.pop_RPMix_EF_function,...
  hs.psb_RPMix_EF_Change, hs.psb_RPMix_EF_Disable,...
  hs.psb_RPMix_EF_Enable,hs.psb_RPMix_EF_Remove,...
  hs.psb_RPMix_GrandAveragePlot];

h=[h,hs.txt_fileListNum,hs.psb_extended_search];

%**************************************************************************
function Suspend(hs)
% Suspend Window : Visible off
h=myHandles(hs);
set(h,'Visible','off');
set(hs.frm_AnalysisArea,'Visible','off');

%**************************************************************************
function Activate(hs)
% Activate Single-Analysis Mode!

%---------------
% Create GUI's
%---------------
if ~isfield(hs,[mfilename '_TODO']) || ~ishandle(hs.([mfilename '_TODO']))
  % Debug Message
  hs.([mfilename '_TODO'])=uicontrol(hs.figure1,...
    'Units','pixels','Position',[150 480 250 20],...
    'BackgroundColor',[1 0 0],...
    'Style','text','Visible','off',...
    'String',['TODO: ' mfilename]);
  hs=P3_gui_Research_PreMix('create_win',hs);
elseif 0
  % for debug
  delete(myHandles(hs));
  hs.([mfilename '_TODO'])=uicontrol(hs.figure1,...
    'Units','pixels','Position',[150 480 250 20],...
    'Style','text','Visible','on',...
    'String',['TODO: ' mfilename]);
  hs=P3_gui_Research_PreMix('create_win',hs);
  disp('debug');
  disp(C__FILE__LINE__CHAR);
end
%---------------
% Visible GUI
%---------------
h=myHandles(hs);
set(hs.frm_AnalysisArea,'Visible','on');
set(h,'Visible','on');

%--------------------------
% Make Local-Active-Data
%-------------------------
% get DataDef (II) Function
fcn=get(hs.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
else
  actdata.fcn=fcn{get(hs.pop_filetype,'Value')};
  clear fcn;
end
% get Data-File
filedata=get(hs.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
else
  vls=get(hs.lbx_fileList,'Value');
  % ==> Select 1st Data to Edit
  actdata.data=filedata(vls(1));
end
setappdata(hs.figure1, 'LocalActiveData',actdata);

%--------------------------
% Make Our Window-Data
%-------------------------
RPreMixData.fcn=actdata.fcn;
RPreMixData.data=filedata(vls);
ll=length(vls);
RPreMixData.Recipe=cell(1,ll);
for ii=1:ll
  tmp=feval(RPreMixData.fcn,'load',RPreMixData.data(ii));
  try
    RPreMixData.Recipe{ii}=tmp.data.filterdata;
  catch
    RPreMixData.Recipe{ii}= struct([]);
  end
end
setappdata(hs.figure1, 'RPreMixData',RPreMixData);

% Update Selected File Number
try
  set(hs.txt_fileListNum,'Visible','on',...
    'String',sprintf('Selected:%d/%d',ll,...
    length(get(hs.lbx_disp_fileList,'String'))));
catch
end


%--------------------------
% Update Recipe
%-------------------------
P3_gui_Research_PreMix('UpdateRecipe',hs);

%**************************************************************************
function msg=SaveData(hs)
% Save Single Analysis Data Status!
msg='';  
%========================
% get Save-File
%========================
RPreMixData=getappdata(hs.figure1, 'RPreMixData');

%========================
% Make Active Data
%========================
ll=length(RPreMixData.Recipe);
actdata.fcn=RPreMixData.fcn;
try
  for ii=1:ll
    actdata.data=feval(RPreMixData.fcn,'load',RPreMixData.data(ii));
    try
      actdata.data.data.filterdata=RPreMixData.Recipe{ii};
      feval(RPreMixData.fcn,'save_ow',actdata.data);
    catch
      msg=['Error in Save-Data : ' lasterr];
      OSP_LOG('err',msg);
    end
  end
catch
  msg=['Error in load-Data : ' lasterr];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=DrawLayout(hs)
% Draw Figues
msg='';
%========================
% Get Layout File
%========================
layoutfile=get(hs.pop_Layout,'UserData');
layoutfile=layoutfile{get(hs.pop_Layout,'Value')};
load(layoutfile,'LAYOUT');

%========================
% Get Draw Data
%========================
RPreMixData=getappdata(hs.figure1, 'RPreMixData');
ll=length(RPreMixData.Recipe);
actdata.fcn=RPreMixData.fcn;

figh=[];
hoge={};
for ii=1:ll
  try
    % Evaluate Files
    fname=feval(actdata.fcn,'make_mfile',RPreMixData.data(ii));
    [chdata, cdata, bhdata, bdata] = ...
      scriptMeval(fname,...
      'chdata', 'cdata', ...
      'bhdata', 'bdata');
    % Draw!
    if isempty(bhdata)
      h=osp_LayoutViewer(LAYOUT,chdata,cdata);
    else
      h=osp_LayoutViewer(LAYOUT,chdata,cdata, ...
        'bhdata',bhdata, 'bdata', bdata);
    end
    % =Check Figures
    figh(end+1)=h.figure1;
    hoge{end+1}=fname;
  catch
    msg='Cannot Make M-File';
  end
end
for idx=1:length(hoge)
  % disp(hoge{idx});
  try,delete(hoge{idx});end
end

%==> Figure Distribute ==>
n=length(figh);
pos0=get(figh(1),'Position');
poss=[pos0(1) ,pos0(2)+pos0(4)];
pose=[pos0(1)+pos0(3) ,pos0(2)];
posd=(pose - poss)./(n+3);
for idx=2:n
  pos0([1 2]) = pos0([1 2]) + posd;
  set(figh(idx),'Position',pos0);
end

fc=figure_controller;
hs=guidata(fc);
try
  for idx=1:n
   figure_controller('setFigureHandle',figh(idx),[],hs);
  end
catch
  if isempty(msg)
    msg='Cannot Open Figure Controller';
  end
end



