function varargout=LAYOUT_CO_prmHistgram(fcn,varargin)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

%$ID$

% Help for noinput
if nargin==0,  fcn='help';end

%- check uicontrol call
if ishandle(fcn)
	fcn=varargin{2};
	varargin=varargin(3:end);
end
%---
	
%====================
% Swhich by Function
%====================
switch fcn
	case {'help','Help','HELP'},
		OspHelp(mfilename);
	case {'createBasicInfo','getDefaultCObject','drawstr','getArgument'},
		% Basic Information
		varargout{1} = feval(fcn, varargin{:});
	case 'make',
		varargout{1} = make(varargin{:});
	case 'ExeCallback'
		ExeCallback(varargin{:});
	otherwise
		% Default
		if nargout,
			[varargout{1:nargout}] = feval(fcn, varargin{:});
		else
			feval(fcn, varargin{:});
		end
end
%===============================
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
basicInfo.name   ='Histgram parameter setting';
basicInfo.fnc    =mfilename;
basicInfo.tagname = 'prmHist';
% File Information
basicInfo.rver   ='$Revision: 1.2 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/03/02 11:29:58 $';
basicInfo.date([1,end])   =[];
% Current - Variable Field-Name-List
basicInfo.cvfname  = {'prmHistgraim'};
basicInfo.uicontrol= {'button'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vdata=getArgument(varargin)
% Set vdata
%     vdata.name    : 'defined in createBasicInfo'
%     vdata.fnc     :  this Function name
%     vdata.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi=createBasicInfo;
vdata.name=bi.name;
vdata.fnc =bi.fnc;
vdata.VarName=bi.tagname;
vdata.p=[];
vdata.pos =[0, 0, 0.9, 0.1];

% p=varargin{1};
% if isfield(varargin{1},'VarName'), DefVal{1}=p.VarName; end
% if isfield(varargin{1},'DefVal'), DefVal{2}=p.DefVal; end
% if isfield(varargin{1},'Label'), DefVal{3}=p.Label; end
% if isfield(varargin{1},'pos'), DefVal{4}=num2str(p.pos); end
% if isfield(varargin{1},'LabelPos'), DefVal{5}=p.LabelPos; end
% if isfield(varargin{1},'DoCallback'), DefVal{6}=p.DoCallback; end
% 
p=SettingDialog;
% 
vdata.p =p;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=' mfilename '(''make'',handles, abspos,' ...
	'curdata, cbobj{idx});'];
return;

function str=mytag
bi=createBasicInfo;
str=bi.tagname;

function curdata=make(hs, apos, curdata,obj)
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->

%=====================
CCD.Name         = [mytag '_' obj.VarName];
CCD.CurDataValue = {obj.VarName, mytag};
CCD.handle       = []; % Update

pos=getPosabs(obj.pos,apos);
%pos = obj.pos;

% Set position of Time slider, Time edit, Time-Step popup components
A=POTATo_sub_MakeGUI(hs.figure1);A.PRMs.Visible='on';A.PRMs.Unit='Normalized';
A.PRMs.Position=pos;
%A.PosX=pos(1);A.PosY=pos(2);A.SizeX=pos(3);A.SizeY=pos(4);
A.UIType='button';
A.String={mfilename,'Callback_Histgram'};
A.Label='Histgram parameter';
A=POTATo_sub_MakeGUI(A);

A=POTATo_sub_MakeGUI(A,'SetAllValues',obj.p);


CCD.handle=A.newHS(1);


% Set handles to Time-UserData{1}
set(CCD.handle, 'UserData', {obj});

%curdata.(obj.VarName) = subRefineInputValue(obj.DefVal);

curdata.parmHistgram=CCD;

return;
%%
function Callback_Histgram(h)
ud=get(gcbo,'UserData');
p=SettingDialog(ud{1}.p);
Edit_Callback(h);

function P=SettingDialog(P)
h=dialog('windowstyle','normal');
p=get(h,'position');
set(h,'Position',[p(1) p(2)-300 600 600],'name','Histgram parameter setting');
A=POTATo_sub_MakeGUI(h);A.PRMs.visible='on';

%
A.UIType='edit';A.Name='Bin';A.Label = 'Bin number or vector';
A.String = '10';A.NextX=0;A.NextY=40;A.SizeY=30;A.SizeX=200;A.PosY=10;
A=POTATo_sub_MakeGUI(A);

A.UIType='edit';A.Name='Threshold';A.Label = 'Threshold (%)';
A.String = '100';A.NextX=0;A.NextY=50;
A=POTATo_sub_MakeGUI(A);

A.UIType='button';%A.String={mfilename,'SettingDialog_OK',gcf};
A.String='uiresume(gcf)';
A.Label='OK';
A=POTATo_sub_MakeGUI(A);

uiwait(h);
P=POTATo_sub_MakeGUI(A,'GetAllValues')
close(h);

function ret=SettingDialog_OK(h)
ret=[]
uiresume(h);

function s=subRefineInputValue(s)
%- check and refine input value
if isempty(str2num(s))
	%- for string
	%s=['''' s ''''];
	s=s;
else
	%- for numeric
	try
		s = eval([s ';']);
	catch %- is vector?
		try
			s = eval(['[' s '];']);
		catch %- impossible to understand
			errordlg(sprintf('Input value ''%s'' is wrong.',valuestr), 'Error value', 'modal');
			s = nan;
			return;
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Edit_Callback(h)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    timepos  : time  index
%    unit     : time-unit of Cdata
ud=get(h,'UserData');

valuestr = get(h,'String');

for idx=2:length(ud),
	% Get Data
	vdata = p3_ViewCommCallback('getData', ...
		ud{idx}.axes, ...
		ud{idx}.name, ud{idx}.ObjectID);
	
	% Update
	vdata.curdata.(ud{1}.VarName) = subRefineInputValue(valuestr);
	
	%- execute callbacks?
	if isfield(vdata.curdata,'VarEdit_DoCallback_flag') && ...
			isfield(vdata.curdata.VarEdit_DoCallback_flag,ud{1}.VarName) &&...
			~vdata.curdata.VarEdit_DoCallback_flag.(ud{1}.VarName)
		%- update curdata
		p3_ViewCommCallback('Update',vdata.handle, ud{idx}.name, ud{idx}.axes, vdata.curdata, vdata.obj,idx);
	else
		% Delete handle
		for idxh = 1:length(vdata.handle),
			try
				if ishandle(vdata.handle(idxh)),
					delete(vdata.handle(idxh));
				end
			catch
				warning(lasterr);
			end % Try - Catch
		end
		
		% Evaluate (Draw)
		try
			eval(ud{idx}.str);
		catch
			warning(lasterr);
		end % Try - Catch
		
	end
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
% apos : Absorute Position
lpos([1,3]) = lpos([1,3])*pos(3);
lpos([2,4]) = lpos([2,4])*pos(4);
lpos(1:2)   = lpos(1:2)+pos(1:2);

return;
