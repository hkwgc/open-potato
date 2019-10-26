function varargout = Contents_function(mode,varargin)
% Contents Script Function
%
% Contents_functon('data_io','CLEAR'),
%   Clear Data base;
%
% fl = data_io('FUNCTION_LIST'); 
%    Get FUNCTION LIST.
%
% fl = Contents_functon('getFLwithCondition',TypeID, DirID,GroupID, NamePat)
%    get match FileList
%
% Contents_functon('SetData',TypeID, DirID,GroupID, Name)
%    Set new FunctionList.
%
% Contents_function('DoOSP')
%    make new list

% $Id: Contents_function.m 180 2011-05-19 09:34:28Z Katura $

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%-------------------
% Call Local Function
%  Do not use TRY/CATCh
  if nargout,
    [varargout{1:nargout}] = feval(mode, varargin{:});
  else
    feval(mode, varargin{:});
  end
return;
%-------------------

function DoOSP()
  % Clear Current Data;
  data_io('CLEAR');
  % Make Search List
  w=which('Contents_Script','-all');
  ospdir = fileparts(which('OSP'));
  % Check effective ( OSP Dir) Contents Script
  % Bugfix : Lower
  if ispc,
	  % In Windows,
	  % w, return value of which, confuse Large/Small value...
	  % That is w{1}= '.. OSP\Contents_Script.m'
	  %   and   w{2}= '.. osp\viewer\Contents_Script'.
	  % :: Bug fix :: 16-Mar-2006..
	  l=strmatch(lower(ospdir),lower(w));
  else,
	  % Different-Directory Large-Charactor & Small-Charactor;
	  l=strmatch(ospdir,w);
  end
  cwd =pwd;
  try
    for idx =l',
        try,
            cd(fileparts(w{idx}));
            Contents_Script;
        catch,
            warning([w{idx} ': Contents_Script : ' lasterr]);
        end
    end
  catch
    warning('Error Occur at : Contents Function');
  end
  cd(cwd);
  % if you want to sort by name
  if 1
    fl=Contents_function('data_io','FUNCTION_LIST');
    fl=struct_sort(fl,'Name');
    Contents_function('data_io','FUNCTION_LIST',fl);
  end

  % make index
  makeIndex;
return;
   
function SetData(TypeID, DirID,GroupID, Name)
% Set One Data
  msg = nargchk(4,4,nargin);

  % Check, Function exist?
  if ~exist(Name,'file'),
    warning(['No File, named ' Name ', exist']);
    return;
  end

  % -- set data --
  data.Name     = char(Name);
  data.TypeID   = TypeID;
  data.DirID    = DirID;
  data.GroupID  = GroupID;

  % Update
  fl = data_io('FUNCTION_LIST'); % Get
  if isempty(fl)
    fl=data;
  else
    fl(end+1) = data;
  end
  data_io('FUNCTION_LIST',fl)  % Set
return;

function makeIndex(num)
  if nargin==0,  num=15;  end

  fl = data_io('FUNCTION_LIST'); % Get
  if isempty(fl),
      error('No Function Listed');
  end


  tmpid      = [fl.TypeID];
  TypeID_IDX = repmat(logical(0), num, size(tmpid(:),1));
  for idx=1:num,
    tmp_ck = bitshift(1,(idx-1));
    TypeID_IDX(idx,:) = bitand(tmpid, tmp_ck) == tmp_ck;
  end
  data_io('TypeID_IDX', TypeID_IDX);

  tmpid      = [fl.DirID];
  DirID_IDX = repmat(logical(0), num, size(tmpid(:),1));
  for idx=1:num,
    tmp_ck = bitshift(1,(idx-1));
    DirID_IDX(idx,:) = bitand(tmpid, tmp_ck) == tmp_ck;
  end
  data_io('DirID_IDX', DirID_IDX);

  tmpid      = [fl.GroupID];
  GroupID_IDX = repmat(logical(0), num, size(tmpid(:),1));
  for idx=1:num,
    tmp_ck = bitshift(1,(idx-1));
    GroupID_IDX(idx,:) = bitand(tmpid, tmp_ck) == tmp_ck;
  end
  data_io('GroupID_IDX', GroupID_IDX);
return; 

function fl = getFLwithCondition(TypeID, DirID,GroupID, NamePat)
  fl = data_io('FUNCTION_LIST'); % Get

  FLG = repmat(logical(1), 1, length(fl));
  
  % Check Effective one
  FLG = FLG & getFlg(data_io('TypeID_IDX'),  TypeID);
  FLG = FLG & getFlg(data_io('DirID_IDX'),   DirID);
  FLG = FLG & getFlg(data_io('GroupID_IDX'), GroupID);

  fl(find(FLG==0)) =[]; clear FLG TypeID DirID GroupID;

  if isempty(fl), return; end

  if exist('NamePat','var') && ~isempty(NamePat),
    names = {fl.Name};
    s     = regexpi(names, NamePat);
    s     = cellfun('isempty', s);
    fl(find(s))=[]; % remove no match.
  end
return;
  

function info = getInfo(fd)
% get File Data Information by String

% default
info={};
if isempty(fd) || ~isstruct(fd),
	info={'no function data'};
	return;
end

% checking
%   data.Name     = char(Name);
%   data.TypeID   = TypeID;
%   data.DirID    = DirID;
%   data.GroupID  = GroupID;
Contents_Script_Header;
typeid = find(TypeIDX==fd.TypeID); typeid=typeid(end);
dirname = fileparts(which(fd.Name));
gid = find(GroupIDX==fd.GroupID); gid=gid(end);

info = {[ ' Function  : ' fd.Name], ...
		[ ' Directory : ' dirname], ...
		[ ' Type      : ' TypeStr{typeid}], ...
		[ ' Group     : ' GroupStr{gid}]};

return;

function FLGout = getFlg(flg, id)
  FLGout = repmat(logical(1), 1, size(flg,2));

  for idx = 1:size(flg,1),
      ck =bitshift(1,(idx-1));
    if bitand(ck,id) == ck,
      FLGout = flg(idx,:) & FLGout;
    end
  end

return;
  
  
%-- Local Data I/O --
function varargout=data_io(name,data)
  persistent FUNCTION_LIST;
  persistent TypeID_IDX;
  persistent DirID_IDX;
  persistent GroupID_IDX;

  % -- Special Case --
  if nargin==1 && nargout==0 && strcmpi(name,'CLEAR'),
    FUNCTION_LIST = struct([]);
    TypeID_IDX    = [];
    DirID_IDX     = [];
    GroupID_IDX   = [];
    return;
  end

  % -- PERSISTENT Variable  exist? --
  if ~exist(name,'var'),
    error([mfilename ':data_io: Not Defined Variable Name.']);
  end

  if nargin==1 && nargout==1,
    % -- GET (Output) --
    varargout{1} = eval([name ';']);
  elseif nargin==2 && nargout==0,
    % -- SET (Input) --
    eval([name '= data;']);
  else
    error([mfilename ':data_io: Number of argument Error']);
  end
return;

function htmlWrite(fname)
% test html write
  error('This is Test function cannot open');

  if narargin==0
    osppath  = fileparts(which('OSP'));
    fname    = [osppath filesep ...
		'html'  filesep ...
		'fnc'   filesep ...
		'test.html.txt'];
  end
  
  fl = data_io('FUNCTION_LIST'); % Get
  if isempty(fl),
    error('no data listed');
    return;
  end

  [fid,msg] = fopen(fname, 'w');
  if ~isempty(msg),
    error(msg);
  end
  
  fprintf(fid, '<HTML>\n');
  fprintf(fid, '<HEAD><TITLE>FUNCTION LIST</TITLE>');
  fprintf(fid, ['<LINK REL=""stylesheet"" HREF=""../css/matlab_like.css""' ...
		' TYPE=""text/css"">']);
  fprintf(fid, '</HEAD>\n');

  fprintf(fid, '<BODY><TABLE bgcolor=0 width=""100"%""">\n');
  
  for idx = 1:length(fl),
    fprintf(fid, ...
	    ['\t\t\t<!--- ' fl(idx).Name ' -->\n' ...
	     '\t\t\t<TR>\n']);
    
    fprintf(fid,'\t\t\t</TR>\n');
  end

  fprintf(fid, '</BODY>\n');
  fprintf(fid, '</HTML>\n');
return;
