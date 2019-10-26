function varargout = PlugInWrap_BaseLineFitting(fcn, varargin)
% BaseLineFitting
%
% input: fitting degree, time=T
%
% This filter subtructs baseline that is(are) calcurated from
% the data those time periods are set by the user as "time"=T. 
% (Time period) = from (start time point of data) to ( T(sec))  and 
% from (end time point - T ) to (end time point).
%
% 2008.06.27 TK@HARL

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
%         BLOCKDATA    : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   basicInfo.name   = 'Baseline fitting';
   basicInfo.region = [2  3];
   % Display Kind :
   % <- Filter Display Mode Variable :: Load
   DefineOspFilterDispKind;
   basicInfo.DispKind=0;
  
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=getArgument(varargin) %#ok
% Set Data
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @BaseLineFitting.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.n: fitting degree
%        argData.t: time (sec)
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
   if isempty(data) || ~isfield(data, 'n'),
      data.n = '1';
   end
   if isempty(data) || ~isfield(data, 't'),
      data.t = '5';
   end

   % Display Prompt words
   prompt = {...
         ' fitting degree ( integer )',...
         ' time (sec)',...
         };
   % Default value
   def = {...
         data.n,...
         data.t,...
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
            data.n= def{1};
         catch
            errordlg(['data.n:Enter correct descript.' lasterr]);
            continue;
         end
      else
         data.n= '0';
      end

      if ~isempty(def{2}),
         try
            eval('def{2};');
            data.t= def{2};
         catch
            errordlg(['data.t:Enter correct descript.' lasterr]);
            continue;
         end
      else
         data.t= '0';
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
function str = write(region, fdata)  %#ok
% Make M-File of BaseLineFitting
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @BaseLineFitting.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.n: fitting degree
%        argData.t: time (sec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   make_mfile('code_separator', 3);   % Level  3, code sep 
   make_mfile('with_indent', ['% == ' fdata.name ' ==']);
   make_mfile('with_indent', '%     BaseLineFitting   v1.0 ');
   make_mfile('code_separator', 3);  % Level  3, code sep .
   make_mfile('with_indent', ' ');


   make_mfile('with_indent', 'try');
   make_mfile('indent_fcn', 'down');

   try
      make_mfile('with_indent', sprintf('n = %d;', str2num(fdata.argData.n)));
      make_mfile('with_indent', sprintf('t = %d;', str2num(fdata.argData.t)));
   catch
      errordlg(lasterr);
   end
   make_mfile('with_indent', '[data]=uc_BaseLineFitting(hdata,data,n,t);');

   make_mfile('indent_fcn', 'up');
   make_mfile('with_indent', 'catch');
   make_mfile('indent_fcn', 'down');
   make_mfile('with_indent', 'errordlg(lasterr);');
   make_mfile('indent_fcn', 'up');
   make_mfile('with_indent', 'end');

   make_mfile('with_indent', ' ');
   make_mfile('code_separator', 3);  % Level 3, code sep .
   make_mfile('with_indent', ' ');

   str='';
return;
