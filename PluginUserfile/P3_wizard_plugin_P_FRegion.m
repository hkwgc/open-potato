function varargout = P3_wizard_plugin_P_FRegion(fnc,varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%
% $Id: P3_wizard_plugin_P_FRegion.m 180 2011-05-19 09:34:28Z Katura $

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

if 0
  % Sub function List
  createBasicInfo;
  OpenPage;
  ClosePage;
end

function data=createBasicInfo
data.islast=false;

function mydata=OpenPage(hs,mydata)
% Open Page
if ~isfield(mydata,'P_Freation')
  %-------
  % Create 
  %-------
  myhs.txt_title    = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.78, 0.7,0.05],...
    'HorizontalAlignment','left',...
    'String','Apply Data-Type',...
    'BackgroundColor',[1 1 1]);
  myhs.ckb_Continuos=uicontrol(hs.figure1,...
    'Style','checkbox',...
    'Units','Normalized','Position',[0.25, 0.70, 0.64,0.05],...
    'HorizontalAlignment','left',...
    'String','Continuous',...
    'BackgroundColor',[1 1 1]);
  myhs.ckb_Block    =uicontrol(hs.figure1,...
    'Style','checkbox',...
    'Units','Normalized','Position',[0.25, 0.65, 0.64,0.05],...
    'HorizontalAlignment','left',...
    'String','Block',...
    'BackgroundColor',[1 1 1]);
  
  mydata.P_Freation=myhs;
else
  set([mydata.P_Freation.txt_title;...
    mydata.P_Freation.ckb_Continuos;...
    mydata.P_Freation.ckb_Block],'Visible','on');
end


function mydata=ClosePage(hs,mydata)
% 
set([mydata.P_Freation.txt_title;...
  mydata.P_Freation.ckb_Continuos;...
  mydata.P_Freation.ckb_Block],'Visible','off');

mydata.Region_Continuous=get(mydata.P_Freation.ckb_Continuos,'Value');
mydata.Region_Block     =get(mydata.P_Freation.ckb_Block,'Value');

if (mydata.page_diff>0) && ...
    (mydata.Region_Continuous + mydata.Region_Block)<=0
  mydata.emsg='No Data-Region to Apply Filter.';
  error(mydata.emsg);
end
if 0,disp(hs);end

