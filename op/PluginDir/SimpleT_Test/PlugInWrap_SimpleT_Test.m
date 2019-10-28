function varargout = SimpleT_(fcn, varargin)
% TEST__NAME Function of Wrapper of Plag-In Function 
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = SimpleT_('createBasicIno');
%
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%         BLOCKDATA    : 3
%     if allowed Region-Number  is either Continuos and Blocks
%        set basic_info.region=[2, 3];
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = SimpleT_('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @SimpleT_.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.tm: [1:100]
%        argData.T_Mean: 0
%        argData.T_Alpha: 0.05
%        argData.T_Tail: 'both'
%
%     mfilename : M-File, before PlugInWrap-TEST__NAME.
%
% ** write **
% Syntax:
%  str = SimpleT_('createBasicIno',region, fdata)
%
%  Make M-File, correspond to Plug-in function.
%  by usinge make_mfile.
%  if str, out-put by str.
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
% Reversion : 1.00
%

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
%         CONTINUOUS   : 2
%         BLOCKDATA    : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   basicInfo.name   = 'Simple T-Test';
   basicInfo.region = [3];
   % Display Kind :
   % <- Filter Display Mode Variable :: Load
   DefineOspFilterDispKind;
   basicInfo.DispKind=0;
  
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=getArgument(varargin),
% Set Data
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @SimpleT_.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.tm: [1:100]
%        argData.T_Mean: 0
%        argData.T_Alpha: 0.05
%        argData.T_Tail: 'both'
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
   if isempty(data) || ~isfield(data, 'tm'),
      data.tm = '[1:100]';
   end
   if isempty(data) || ~isfield(data, 'T_Mean'),
      data.T_Mean = '0';
   end
   if isempty(data) || ~isfield(data, 'T_Alpha'),
      data.T_Alpha = '0.05';
   end
   if isempty(data) || ~isfield(data, 'T_Tail'),
      data.T_Tail = 'both';
   end

   % Display Prompt words
   prompt = {...
         ' Enter : mean period of input data ( integer (array) )',...
         ' Enter : hypothsys mean value M ( integer )',...
         ' Enter : threshold ( float )',...
         ' Enter : Tail both or right or left (means data==M or data>M or data<M) ( character )',...
         };
   % Default value
   def = {...
         data.tm,...
         data.T_Mean,...
         data.T_Alpha,...
         data.T_Tail,...
         };
   % Open Input-Dialog
   while 1,
      % input-dlg
      def = inputdlg(prompt, data0.name, 1, def);
      if isempty(def),
         data=[]; break; %while
      end

      % Check Argument

      if ~isempty(def{1}),
         try
            eval('def{1};');
            data.tm= def{1};
         catch
            errordlg(['data.tm:Enter correct descript.' lasterr]);
            continue;
         end
      else
         data.tm= '0';
      end

      if ~isempty(def{2}),
         try
            eval('def{2};');
            data.T_Mean= def{2};
         catch
            errordlg(['data.T_Mean:Enter correct descript.' lasterr]);
            continue;
         end
      else
         data.T_Mean= '0';
      end

      if ~isempty(def{3}),
         try
            eval('def{3};');
            data.T_Alpha= def{3};
         catch
            errordlg(['data.T_Alpha:Enter correct descript.' lasterr]);
            continue;
         end
      else
         data.T_Alpha= '0';
      end

      if ~isempty(def{4}),
               data.T_Tail= def{4};
      else
         data.T_Tail= '';
      end

      break;
   end
   if isempty(data)
      data0=[]; %Not inputed ( cancel )
   else
      data0.argData=data;
   end
   varargout{1}=data0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) 
% Make M-File of SimpleT_
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @SimpleT_.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.tm: [1:100]
%        argData.T_Mean: 0
%        argData.T_Alpha: 0.05
%        argData.T_Tail: 'both'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   make_mfile('with_indent', ['% == ' fdata.name ' ==']);
   make_mfile('with_indent', ['%     SimpleT_   v1.0 ']);

   try
   t_arg=[];
      make_mfile('with_indent', sprintf('tm = %s;', fdata.argData.tm));
      make_mfile('with_indent', sprintf('T_Mean = %d;', str2num(fdata.argData.T_Mean)));
      make_mfile('with_indent', sprintf('T_Alpha = %d;', str2num(fdata.argData.T_Alpha)));
      t_arg = fdata.argData.T_Tail;
      t_arg = strrep(t_arg, '''','''''');
      make_mfile('with_indent', sprintf('T_Tail = ''%s'';', t_arg ));
   catch
      errordlg(lasterr);
   end
   make_mfile('with_indent', 'hdata=uc_SimpleT_Test(data,hdata,chdata,tm,T_Mean,T_Alpha,T_Tail);');

   make_mfile('code_separator', 3);  % Level 3, code sep .
   make_mfile('with_indent', ' ');

   str='';
return;
