function varargout=OSP_LOG(method,varargin)
% OSP Log-File Manager
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
% -------------------------------------
%
% This Program Make Log File for OSP
%   Warning : Don't use another Program
%
% -- How to use --
%   0. before using 
%     make print rule
%
%   1. Open by   OSP_LOG('open')
%     if you do not open,
%        use Std-out for Log File
%            Std-err for error Message File
%    
%   2. Logging
%     select message  type
%           ('msg' 'note' 'warn'.. and so on )
%     and set messages
%
%   3. Close
%      You Must Close
%
% -- File Manage --
%  OSP_LOG('open');
%    Start Logging at Default Files.
%  OSP_LOG('open','MODE',2);
%    Start Logging  at your set Files.
%  OSP_LOG('open','Debug_Mode',ture)
%    Start Logging : Debug-Write : ON
%
%  OSP_LOG('close')
%    Close Log Files & Setup-File
%
% -- Log (Log File Output) --
%  OSP_LOG('msg', Message)
%    Write Message in Std-out Log-File
%
% -- Error (Error Message File Output) --
%  OSP_LOG('note', Message)
%    Write Notice Message in Std-error Log-File
%
%  OSP_LOG('warn', Message)
%    Write Warning Message in Std-error Log-File
%       
%  OSP_LOG('err', Message)
%    Write Error Message 
%
%  OSP_LOG('perr', Message)
%    Write Program-Error Message
%       
%
%  OSP_LOG('dbg', Message)
%    Write Debug Messange, 
%
% -----------------------------------------
% You can change this Figure & GUI as you like


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2004.10.14
% $Id: OSP_LOG.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.09
%    Add Debug-File :
%      

% For Programmer
%   if you want to use other program
%       you must copy or make LogKey
%       in this version no key
%
%   Persistent Data
%      LOG_FILE   : Log file name
%      EM_FILE    : Error Message file name
%      DEBUG_FILE : Debug Message file name
%      DEBUG_MODE : true  : Debug-Write : ON
%                   false : Debug-Write : OFF
%      MODE       :  0 -> never output
%                    1 -> output

% Bugs : mail-to : shoji-masanori@hitachi-ul.co.jp

persistent isnew;
% change
fid=[];
try
    switch  method
      case 'isnew',
        varargout{1}=isnew;
        case {'open', 'Open'}
          openLog(varargin{:});
          isnew=false;
			
        case {'close', 'Close'}
          final;
          isnew=true;
          
            % Log File 
        case {'msg'}
            [fid,fname] =getfid('LOG');
            output(fid,'',varargin{:});
            
            % Error Message
        case {'note'}
            [fid,fname] =getfid('EM');
            output(fid,'[N]  : ',varargin{:});
            
        case {'warn'}
            [fid,fname] =getfid('EM');
            output(fid,'[W]  : ',varargin{:});
            
        case {'err'}
            [fid,fname] =getfid('EM');
            output(fid,'[E]  : ',varargin{:});
            
        case {'perr'}
            [fid,fname] =getfid('EM');
            output(fid,'[PE] : ',varargin{:});
	    
        case {'dbg'}
			% fid=2; % Standard Error SEE FOPEN
			dbmode=ldata('DEBUG_MODE');
			if dbmode,
				% Debug Mode is effective 
				[fid,fname] = getfid('Debug');
				output(fid,' * Debug Message : ',varargin{:});
			else,
				% Debug Mode is not effective
				return;
			end
            
        otherwise
            emsg.message=...
                sprintf('Program Error: %s\n Undefined Method : %s\n',...
                mfilename, method);
            emsg.identifire=[];
            errordlg(emsg.message);
            rethrow(emsg);
    end
	
	%=======================
	% Print Path Information
	%=======================
	if any(strcmp(method,{'err','perr','dbg'})) ~=0
		%------------------
		% Header :
		%------------------
		switch method,
			case 'perr'
				disp([ '******************** ' ...
						'Program Error : See error log' ...
						'*********************']);
			case 'dbg'
				fprintf(fid, ...
					[ '********************\n' ...
						'Debug Information : \n' ...
						'*********************\n']);
			case 'err'
				fprintf(fid, ...
					[ '********************\n' ...
						'Error Information\n' ...
						'*********************\n']);
		end % end switch ( header of Path )
		
		%------------------
		% Show Debug Trace
		%------------------
		st = dbstack;
		pa = which('OSP');
		if isempty(pa), pa='Unreach to OSP : Path Error'; end
		try
			state = OSP_DATA;
		catch
			state =-Inf;
		end
		fprintf(fid, ...
			[ ' ---------------------------  \n' ...
				' * Debug Inforamtion \n' ...
				'    OSP   : %s\n' ...
				'    Satus : %d\n' ...
				'    Date  : %s\n' ...
				'\n' ] ...
			, pa, state, datestr(now));
		
		for id = 2:length(st)
			try,
				fprintf(fid, ' %s : %d\n', st(id).name, st(id).line);
			catch,
				fprintf(fid,' Unknown : --\n');
			end
		end
		fprintf(fid, ' ---------------------------  \n');
		if strcmp(method,'perr'),edit(fname); end
	end	
	
catch     % For Debut    
    if ~isempty(fid) && fid~=1 && fid~=2
        fclose(fid);
    end
    rethrow(lasterror);
end

% fclose
if ~isempty(fid)
    if fid~=1 && fid~=2
        fclose(fid);
    end
end

%========================
% persistent Manage
%========================
function data=ldata(name,data)
persistent LOG_FILE EM_FILE MODE DEBUG_FILE DEBUG_MODE;
switch  name
    case 'LOG_FILE'
        if nargin == 2
            LOG_FILE=data;
        else
            data=LOG_FILE;
        end
        
    case 'EM_FILE'
        if nargin == 2
            EM_FILE=data;
        else
            data=EM_FILE;
        end
        
    case 'DEBUG_FILE'
        if nargin == 2
	  DEBUG_FILE=data;
        else
            data=DEBUG_FILE;
        end		
		
    case 'DEBUG_MODE'
        if nargin == 2
	  DEBUG_MODE=data;
        else
	  data=DEBUG_MODE;
        end		
		
	case 'MODE'
        if nargin == 2
            MODE=data;
        else
            data=MODE;
        end
		
	otherwise
		data=[];
end
return;

%=============
% openLog is Open Log file
%   Set File Identifier
%   & Setup MLOCK
%
% Last Modify
%    17-Nov-2004
%    M. Shoji
%    new
%=============
function openLog(varargin)
% Open Log-File's

%===========================
% Data Initialized
%===========================
% Init Log-File Name's
logfn='OSP.log';
emfn ='OSPerror.log';
dbgfn='OSP_Debug.txt';

% Loading Data
open_mode=1;
log  = ldata('LOG_FILE');
em   = ldata('EM_FILE');
dbgf = ldata('DEBUG_FILE');
% Output Mode
mode = ldata('MODE');if isempty(mode), mode=1; end
ldata('DEBUG_MODE',false);

% OSP Path
try
  wrk = which('OSP_DATA');
  pwd0 = fileparts(wrk); clear wrk;
catch
  pwd0 = pwd;
end

%================================
% Check Double Open
%================================
if ~isempty(log) || ~isempty(em) || ~isempty(dbgf)
    qans=questdlg(sprintf('Log File Already Opened\n'),...
        ' OSP LOG : OPEN Log', ...
        'Continue', 'Stop', 'Stop');
    switch qans
        case 'Continue'
            final([]);
        otherwise
            return;
    end
    clear qans;
end

%===================================
% Get Arguments
%===================================
for idx=2:2:length(varargin),
	prop = varargin{idx-1};
	data = varargin{idx};
	try,
		switch upper(prop),
			case 'MODE',
				if data==1 || data==2,
					open_mode=data;
				else,
					warndlg('Open Mode : Unknow');
				end
			case 'DEBUG_MODE',
				if islogical(data),
					ldata('DEBUG_MODE',data);
				else,
					warndlg('Debug Mode : Unknow');
        end
      case 'LOG',
        logfn=data;
      case 'ERROR',
        emfn=data;
      case 'DBG',
        dbgfn=data;
		end
	catch,
		warndlg({' Open Property Error : ', ...
				lasterr});
	end
end


mlock;     % Lock this File(persistent)

% Get Filename
switch open_mode,
    case 1,
		% Usual mode:
		%   Default Log Mode
        ldata('LOG_FILE',[pwd0 filesep logfn]);
        ldata('EM_FILE',[pwd0 filesep emfn]);
        ldata('DEBUG_FILE',[pwd0 filesep dbgfn]);
    case 2,
		% Select My-Log-File
        [fname, pname]=uisave({'*.log';'*.txt'}, ...
            ' Log File Name');
        if (fname==0 && pname ==0)
            ldata('MODE',mode);
        else
            ldata('LOG_FILE',[pname filesep fname]);
        end

		[fname, pname]=uisave({'*.log';'*.txt'}, ...
            ' Error Mesage File Name');
        if (fname==0 && pname ==0)
            ldata('MODE',mode);
        else
            ldata('EM_FILE',[pname filesep fname]);
        end

		[fname, pname]=uisave({'*.log';'*.txt'}, ...
            ' Debug Mesage File Name');
        if (fname==0 && pname ==0)
			ldata('DEBUG_FILE',[pwd0 filesep 'OSP_Debug.txt']);
        else
			ldata('DEBUG_FILE',[pname filesep fname]);
        end
		clear fname pname;
end

% remove Old Log File
try
    fname = ldata('LOG_FILE');
    if ~isempty(fname) && exist(fname,'file')
        delete(fname);
    end

    fname  = ldata('EM_FILE');
    if ~isempty(fname) && exist(fname,'file')
        delete(fname);
    end

	fname  = ldata('DEBUG_FILE');
	if ~isempty(fname) && exist(fname,'file')
		delete(fname);
	end
end
return;

function [fname, fid0]=getfname(ftype)
% Get Filename 
fid0=1; % Standard Out
switch ftype
	case 'LOG'
		fname = ldata('LOG_FILE');
	case 'EM'
		fid0=2; % Standerd Error
		fname = ldata('EM_FILE');
	case 'Debug',
		fname=ldata('DEBUG_FILE');
	otherwise
		fname='';
end
return;

%=============
% Get File Identifier
% +fid=getfid(ftype)
%
%   ftype is File-Type
%     'LOG' : Log File
%     'EM'  : Error Message File
%
% Last Modify
%    17-Nov-2004
%    M. Shoji
%    new
%=============
function [fid, fname]=getfid(ftype)
[fname, fid]=getfname(ftype);
if ~isempty(fname)
	fid=fopen(fname,'a');
	if fid==-1
		fid=1;
	end
end
return;
% =======================
% Open : File by Editor
% Date 26-Dec-2005 : M. Shoji
% =======================
function fname=edit_files(ftype),
fname=getfname(ftype);
if ~isempty(fname) && exist(fname,'file')
	edit(fname);
end
return;

%====================
% Out Put Function
%====================
function output(fid, head, varargin)

mode = ldata('MODE');
if ~isempty(mode) && mode==0
    return;
end

if isempty(varargin)
    return;
end

msg={};
for ii = 1:length(varargin)
  data = varargin{ii};
  if iscell(data)
    msg={msg{:}, data{:}};
    %[msg{end+1:end+length(data)}] = deal(data{:});
  else
    msg{end+1} = data;
  end
end

if ~isempty(msg{1})
  fprintf(fid,'%s%s\n', head, msg{1});
end

% Make Indent
head2='';
for ii=1:length(head)
    head2 = [head2 ' '];
end

for ii=2:length(msg)
    fprintf(fid,'%s%s\n', head2, msg{ii});
end

return;

% =======================
% Finish Logging
% =======================
function final(varargin)
munlock;
ldata('LOG_FILE'  ,[]);
ldata('EM_FILE'   ,[]);
ldata('MODE'      ,[]);
ldata('DEBUG_FILE',[]);

