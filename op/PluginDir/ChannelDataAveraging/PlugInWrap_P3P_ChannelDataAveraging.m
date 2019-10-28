function varargout=PlugInWrap_P3P_ChannelDataAveraging(fnc,varargin)
% Filter Plug-in
%
                                                                                        
% Edit the above text to modify the response to help PlugInWrap_P3P_ChannelDataAveraging
                                                                                        
% Made by P3_wizard_plugin_createMF $Revision: 1.4 $                                    
%              at 16-Jul-2011                                                           

%====================    
% In no input : Help     
%====================    
if nargin==0,            
  POTATo_Help(mfilename);
  return;                
end                      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargout                                         
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else                                               
  feval(fnc, varargin{:});                         
end                                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function List   
if 0              
  createBasicInfo;
  getArgument;    
  write;          
end               
return;           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bi=createBasicInfo
% Basic Information to control this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi.name='Channel Data Averaging';
bi.Version=1.0;
bi.region= 2 ;
bi.DispKind=0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fdata=getArgument(fdata,varargin)
% get Argument of this Filter
%     fdata.name    : defined in createBasicInfo
%     fdata.wrap    :  Pointer of this Function,
%     fdata.argData : Argument of Plug in Function.
%      argData.ch : ch (Character)
%      argData.newchpos : newchpos (Character)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% M-File to get Before Data
% (if you want : slow)
mfile0=varargin{1};
% Example :
[data, hdata]=scriptMeval(mfile0, 'data', 'hdata');

% **************************************
% Reading Argument
% **************************************
if isfield(fdata,'argData'),
  argD=fdata.argData;
else
	argD.ver = '1.0.0';
	argD.GroupNum=1;
	argD.ch{1}=1;
	argD.newchpos=1;
end

DlgTitleStr = '[[Channel Data Averaging]]';
while 1
	argD.GroupNum = inputdlg(sprintf('%s\n\nHow many averaging groups?',DlgTitleStr),'',1,{num2str(argD.GroupNum)});
	if isempty(argD.GroupNum), break;end
	if ~isempty(str2num(argD.GroupNum{1})), break;end
end
if isempty(argD.GroupNum)
	  fdata=[]; % ( cancel )
		return;
end		
argD.GroupNum=str2num(argD.GroupNum{1});

%- prepare for [check channel grouping
chgroup=zeros(1,size(data,2));
chgroup_str={};
for k=1:length(hdata.Pos.Group.ChData)
	chgroup(hdata.Pos.Group.ChData{k})=k;
	chgroup_str{end+1}=[sprintf('Group%d: ',k) sprintf('%d ',hdata.Pos.Group.ChData{k})];
end

%-
tg=1:size(data,2);
k=1;
while k<argD.GroupNum+1
	v=[];
	if length(argD.ch)>=k
		for kk=1:length(argD.ch{k})
			v(kk)=find(tg==argD.ch{k}(kk));
		end
	end
	[sel,ok]=listdlg('PromptString',{DlgTitleStr,'',sprintf('Selece channels for group%d',k)},...
		'SelectionMode','multiple','OKString','Next','ListSize',[160,300],...
		'ListString',cellstr(num2str(tg')),'InitialValue',v);
	if ok==0,fdata=[];return;end %-cancel
	
	%- check channel grouping
	if length(unique(chgroup(sel)))>1
		uiwait(warndlg([{'You can''t select channels from different channel-groups.'},...
			{'Please select again.'},chgroup_str],'','modal'));
	else
		argD.ch{k}=tg(sel);
		tg(sel)=[];
		k=k+1;
	end
end

%- new channel order
newchnum=size(data,2)-length([argD.ch{:}])+length(argD.ch);
tg=1:newchnum;
for k=1:argD.GroupNum
	[sel,ok]=listdlg('PromptString',{DlgTitleStr,'',...
		sprintf('Total channel number will be changed from [%d] to [%d].',...
		size(data,2),newchnum),...
		'Please set new channel order',...
		sprintf('   for averaged data #%d',k)},...
		'SelectionMode','single','OKString','Next','ListSize',[160,300],...
		'ListString',cellstr(num2str(tg')),'InitialValue',1);
	if ok==0,fdata=[];return;end %-cancel
	argD.newchpos(k)=tg(sel);
	tg(sel)=[];	
end	

%- confirm
s={};
for k=1:argD.GroupNum
	s{end+1}=['Original channels: ' sprintf('%d ', argD.ch{k})];
	s{end+1}=['----->> New averaged channel: ' sprintf('%d', argD.newchpos(k))];
	s{end+1}='';
end
a=questdlg(s,DlgTitleStr,'Yes','Cancel','Yes');
if strcmp(a,'Cancel'), fdata=[];return;end %-cancel

% **************************************
% Output
% **************************************
fdata.argData=argD;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=write(region,fdata)
% write M-Script to perform Channel Data Averaging
% Fdata is as same as getArgument's fdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

str='';
if 0,disp(region);end
bi=createBasicInfo;

% **************************************
%   Header Area
% **************************************
make_mfile('code_separator', 3);
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('with_indent', sprintf('%%  Version %f',bi.Version));
make_mfile('code_separator', 3);
make_mfile('with_indent', '');

% **************************************
%   Exexute Area
% **************************************
make_mfile('with_indent', 'try');
make_mfile('indent_fcn', 'down');

% ======================================
%   Argument Setting
% ======================================
try
	for k=1:length(fdata.argData.ch)
		make_mfile('with_indent', sprintf('ch{%d}=[%s];',k,num2str(fdata.argData.ch{k})));
		make_mfile('with_indent', sprintf('newchpos(%d)=%d;',k,fdata.argData.newchpos(k)));
	end
catch
  errordlg({[mfilename ': WRITE '],lasterr});
  make_mfile('with_indent', ['error(''' mfilename ' : Write Error'');']);
  make_mfile('with_indent', 'catch');
  make_mfile('indent_fcn', 'down');
  make_mfile('with_indent', 'errordlg(lasterr);');
  make_mfile('indent_fcn', 'up');
  make_mfile('with_indent', 'end');
end

% ======================================
%   Execute
% ======================================
make_mfile('with_indent',...
           '[data,hdata] = P3P_ChannelDataAveraging(data, hdata, ch, newchpos);');


make_mfile('indent_fcn', 'up');
% **************************************
%   Error Area
% **************************************
make_mfile('with_indent', 'catch');
make_mfile('indent_fcn', 'down');
make_mfile('with_indent', 'errordlg(lasterr);');
make_mfile('indent_fcn', 'up');
make_mfile('with_indent', 'end');
make_mfile('with_indent', '');
make_mfile('code_separator', 3);
make_mfile('with_indent', '');
return;
