function varargout = PlugInWrap_SelectMark(fcn, varargin)
% Mark edit is Plug-in Function of POTATo.
%  Mark edit change Stimulation-Mark temporarily.

% Add Raw-Data at the end of data, when ETG-format.
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_SelectMark('createBasicIno');
%    Return Information for OSP Application.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_SelectMark('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_SelectMark.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_SelectMark('createBasicIno',region, fdata)
%
%  Make M-File of adding Raw
%
% See also OSPFILTERDATAFCN.

% == History ==
% Original author : Masanori Shoji
% create : 2005.07.21
% Reversion : 1.00
%
% Reversion 1.00, Date 07.21
%   No check..

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

%======== Launch Switch ========
if strcmp(fcn,'createBasicInfo'),
  varargout{1} = createBasicInfo;
  return;
end

if nargout,
  [varargout{1:nargout}] = feval(fcn, varargin{:});
else
  feval(fcn, varargin{:});
end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%       DispKind :: Add Kind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   = 'Mark Edit';
basicInfo.region = 2;
% Display Kind :
% <- Filter Display Mode Variable :: Load
DefineOspFilterDispKind;
basicInfo.DispKind=F_Flag;
basicInfo.Description='Select Mark';
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin)
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_SelectMark.
%     filterData.argData : Argument of Plug in Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data0 = varargin{1}; % Filter Data
data0.ver = 1.00;

% Make Raw Data
[hd,d]=scriptMeval(varargin{2},'hdata','data');

% ==> Open Marker Setting
% Open Mark Setting
h0  = getArgument_SelectMark;
hs0 = guidata(h0);
getArgument_SelectMark('setContinuousData',h0,[],hs0,hd,d);
if isfield(data0,'argData')
  getArgument_SelectMark('setArgData',h0,[],hs0,data0.argData);
end
set(hs0.psb_ok,'Visible','on');
waitfor(hs0.psb_ok,'Visible','off');
data=[];
if ishandle(h0)
  data=getArgument_SelectMark('getArgData',h0,[],hs0);
  delete(h0);
end

%-------------------------
% Return;
%-------------------------
if isempty(data),
  % Cancel
  data0=[];
else
  % Return
  data0.argData=data;
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata)
% Make M-File of PlugInWrap_SelectMark
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_SelectMark.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('with_indent', ['%    ' mfilename ' v' num2str(fdata.ver)]);
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent', ' ');

argData=fdata.argData;
make_mfile('with_indent', 'clear tmp');
make_mfile('with_indent','% -- Setting --');
make_mfile('with_indent', sprintf('tmp.mode    = %d;',argData.mode));
if length(argData.DeleteFlag)~=1
  make_mfile('with_indent', ['tmp.DeleteFlag = [' num2str(argData.DeleteFlag(:)') '];']);
else
  make_mfile('with_indent', ['tmp.DeleteFlag = ' num2str(argData.DeleteFlag) ';']);
end
make_mfile('with_indent','% -- Data to Check --');
make_mfile('with_indent', sprintf('tmp.stimnum = %d;',argData.stimnum));
if argData.mode==2
  if argData.Interval~=1
    make_mfile('with_indent', ['tmp.Interval = [' num2str(argData.Interval(:)') '];']);
  else
    make_mfile('with_indent', ['tmp.Interval = ' num2str(argData.Interval(:)') ';']);
  end
  
end
make_mfile('with_indent', 'hdata=PlugInWrap_SelectMark(''execute0'',hdata,tmp);');

make_mfile('with_indent', ' ');
make_mfile('code_separator', 3); % Level 3, code separator
make_mfile('with_indent', ' ');

str='';

return;

function hdata=execute0(hdata,argData)
% Make Stimulation Time
x=find(hdata.stimTC);
x(x>length(hdata.stimTC))=[];

tmp=find(argData.DeleteFlag>length(x));
if ~isempty(tmp)
  warning('Too few Stimulation Point');
  argData.DeleteFlag(tmp)=[];
end

hdata.stimTC(x(argData.DeleteFlag))=0;
hdata=uc_makeStimData(hdata,argData.mode);
if argData.mode==2
  % Check Block Difference
  if 0
    % 0.5 [sec]
    d0 = 0.5*1000/hdata.samplingperiod;
  else
    % Setting
    d0 = OSP_DATA('GET','OSP_STIMPERIOD_DIFF_LIMIT');
  end
  for idx=1:min(size(hdata.stim,1),length(argData.Interval))
    if abs(hdata.stim(idx,3)-hdata.stim(idx,2)-argData.Interval(idx))>d0
      warning('Stimulation is So Different');
    end
  end
end

      
if size(hdata.stim,1)~=argData.stimnum
  warndlg('Stimulation Number is different');
end
 
