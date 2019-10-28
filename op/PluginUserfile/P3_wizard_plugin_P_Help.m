function varargout = P3_wizard_plugin_P_Help(fnc,varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin Help-Comment
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%

% ===================================================================================
% Copyright(c) 2019, National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ===================================================================================

% $Id: P3_wizard_plugin_P_Help.m 180 2011-05-19 09:34:28Z Katura $

% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

if 0
  % Sub function List
  createBasicInfo;
  OpenPage;
  ClosePage;
  psb_more_Callback; % for Open "Help-Option Window"
  writeHelpTop;      % Write M-File
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=createBasicInfo
% Information of Page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.islast=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mydata=OpenPage(hs,mydata)
% Open Help Setting Page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if 0
  %-----------------------------
  % Debugmode : Delete All Handle
  %-----------------------------
  disp('------- Debug Mode is Running -----');
  disp(C__FILE__LINE__CHAR);
  if isfield(mydata,'P_Help')
    fn=fieldnames(mydata.P_Help);
    for idx=1:length(fn)
      try
        delete(mydata.P_Help.(fn{idx}));
      catch
        disp(lasterr);
      end
    end
    mydata=rmfield(mydata,'P_Help');
  end
end

if ~isfield(mydata,'P_Help')
  %=============================
  % Create 
  %=============================
  % --> 1st-Level-Analysis Function-Name
  myhs.txt_main   = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.78, 0.7,0.05],...
    'HorizontalAlignment','left',...
    'String','Main  Help Comment: ',...
    'BackgroundColor',[1 1 1]);
  myhs.edt_flaname=uicontrol(hs.figure1,...
    'Style','edit',...
    'MAX',5,...
    'Units','Normalized','Position',[0.22, 0.48, 0.64,0.3],...
    'HorizontalAlignment','left',...
    'FontSize',11,...
    'String','',...
    'BackgroundColor',[1 1 1]);
  myhs.txt_paper   = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.42, 0.7,0.05],...
    'HorizontalAlignment','left',...
    'String','Reference: ',...
    'BackgroundColor',[1 1 1]);
  myhs.edt_paper=uicontrol(hs.figure1,...
    'Style','edit',...
        'Units','Normalized','Position',[0.22, 0.32, 0.64,0.1],...
    'HorizontalAlignment','left',...
    'FontSize',11,...
    'String','',...
    'BackgroundColor',[1 1 1]);
  myhs.psb_more   = uicontrol(hs.figure1,...
    'Style','pushbutton',...
    'Units','Normalized','Position',[0.2, 0.17, 0.7,0.1],...
    'String','More Information',...
    'UserData',[],...
    'Callback','P3_wizard_plugin_P_Help(''psb_more_Callback'',gcbf,gcbo)');

  mydata.P_Help=myhs;
else
  fn=fieldnames(mydata.P_Help);
  for idx=1:length(fn)
    set(mydata.P_Help.(fn{idx}),'Visible','on');
  end
end

function mydata=ClosePage(hs,mydata)
% 
fn=fieldnames(mydata.P_Help);
for idx=1:length(fn)
  set(mydata.P_Help.(fn{idx}),'Visible','off');
end

if 0,disp(hs);end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% More Setting Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_more_Callback(fh,h)
%
data=get(h,'UserData');
if ~isempty(data)
  data=P3_wizard_plugin_P_Help_sub('DefaultValue',data);
else
  data=P3_wizard_plugin_P_Help_sub;
end
if ishandle(fh)
  set(0,'CurrentFigure',fh);
  if ~isempty(data)
    set(h,'UserData',data);
  end
else
  disp(C__FILE__LINE__CHAR);
  disp(' Plugin Wizard was close, could not setup Save-Option.');
  disp(data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeHelpTop(mydata)
% Write Help Comment by 
hs=mydata.P_Help;
% Main Comment
s=get(hs.edt_flaname,'String');
if isempty(s)
  make_mfile('with_indent',['% ' mydata.PluginType]);
else
  for idx=1:size(s,1)
    make_mfile('with_indent',['% ' s(idx,:)]);
  end
end
make_mfile('with_indent','%');

% Paper
p=get(hs.edt_paper,'String');
if ~isempty(p)
  make_mfile('with_indent','% -----------------');
  make_mfile('with_indent','%  Related Paper:');
  make_mfile('with_indent','% -----------------');
  make_mfile('with_indent',['% ' p]);
  make_mfile('with_indent','%');
end


data=get(hs.psb_more,'UserData');
if isempty(data),return;end

% --> Function Information <--
if ~isempty(data.function.Syntax)
  make_mfile('with_indent','% -----------------');
  make_mfile('with_indent','%  Syntax :');
  make_mfile('with_indent','% -----------------');
  make_mfile('with_indent',['% ' data.function.Syntax]);
  make_mfile('with_indent','%');
end
if ~isempty(data.function.Example)
  make_mfile('with_indent','% -----------------');
  make_mfile('with_indent','%  Example :');
  make_mfile('with_indent','% -----------------');
  s=data.function.Example;
  for idx=1:size(s,1)
    make_mfile('with_indent',['% ' s(idx,:)]);
  end
  make_mfile('with_indent','%');
end
if ~isempty(data.function.SeeAlso)
  make_mfile('with_indent',['% See also: ' data.function.SeeAlso]);
  make_mfile('with_indent','%');
end

% --> Autohr Information <--
if ~isempty(data.copyright.CopyRight)
  make_mfile('with_indent','% == Copyright ==');
  make_mfile('with_indent',['% ' data.copyright.CopyRight]);
end
if ~isempty(data.copyright.Author);
  make_mfile('with_indent',['% author : ' data.copyright.Author]);
end
make_mfile('with_indent',['% create : ' datestr(now)]);


  