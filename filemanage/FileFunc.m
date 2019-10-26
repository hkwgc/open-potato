function varargout = FileFunc(funcname, varargin)
% Data file Function
%
% namelist = FileFunc('getChildren', filename, varname [,listtype])
%   Get  nest name-list of varname's Children.
%
% list = getchild_sub(filename,varname, inlist) 
%    Get name-list of varname's Children.
%
% FileFunc('getVariable', filename, varname)
%    Load value of varname.
%
% FileFunc('setVariable', filename,  var, var-name)
%    Save value of varname.
%

% $Id: FileFunc.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Revision 1.14 : ADD Buffering-Mode

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Buffering Control 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent bufmode;
if isempty(bufmode),bufmode=false;end
switch (funcname)
  case 'BufferingMode'
    bufmode=true;
    StreamRelation(0);
    return;
  case 'Flush'
    bufmode=false;
    StreamRelation(1);
    return;
end

if (bufmode)
  if strcmpi(funcname,'StreamRelation')
    StreamRelation(varargin{:});
  else
    bufmode=false;
    error('** Program-Error ** File-Relation : Buffering-Mode');
  end
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normal Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------
% Call Local Function
%  Do not use TRY/CATCh
if nargout,
  % -- Check file exist
  if nargin>=2
    filename = varargin{1};
    if ischar(filename) && ~exist(filename,'file')
      error(['No file exist ' filename]);
    end
  end
  [varargout{1:nargout}] = feval(funcname, varargin{:});
else
  feval(funcname, varargin{:});
end
return;
%-------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Essensial-System-Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StreamRelation(name,val)
% Buffering and .. 
%  ( I presume "ADD" case only)
persistent Relation0;
%=============================
% Buffuring Start/End
%=============================
if isnumeric(name)
  if name==0
    % Start Buffering
    rfile=getRelationFileName;
    load(rfile,'Relation');
    Relation0=Relation;
  elseif name==1
    % !! Flush !!
    saveRelation(Relation0);
  else
    error('Invalid Input');
  end
  return;
end
%=============================
% Data Modification
%=============================
% Check Error
if length(name)~=length(val)
  error('Different Data-Set');
end

for idx=1:length(name)
  if isfield(Relation0,name{idx})
    % Merge (I presume ADD Only)
    % --> setdiff for delete insted on union
    %     Relation0.(name{idx}).Parent   =  ...
    %       union(Relation0.(name{idx}).Parent,   val{idx}.Parent);
    Relation0.(name{idx}).Children =  ...
      union(Relation0.(name{idx}).Children, val{idx}.Children);
  else
    % ADD
    if isfield(val{idx},'data')
      try
        Relation0.(name{idx})=val{idx};
      catch
        warning(lasterr);
      end
    end
  end
end
  
function StructType()
% New Project format

% Empty-check
x=DataDef2_RawData('loadlist');
if isempty(x),return;end

rfile=getRelationFileName;
load(rfile,'Relation');
if ~exist('Relation','var')
  Relation=load(rfile); % Old Version
end
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(rfile,'-v6','Relation');
else
  save(rfile,'Relation');
end

function saveRelation(Relation)
rfile=getRelationFileName;
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(rfile,'-v6','Relation');
else
  save(rfile,'Relation');
end



function varargout = getChildren(filename, varname, varargin)
% ---get Children
if isempty(filename),filename=getRelationFileName;end
if nargin>2,
  listtype = varargin{1};
else
  listtype = 1;    % only simple
end

try
  switch(listtype),
    case 1,
      % simple List
      varargout{1} = getchild_sub(filename, varname, {});
    otherwise,
      %% html
  end
catch
  rethrow(lasterror);
end
return;

function list = getchild_sub(fname, vname, inlist)
try
  if ischar(fname)
    load(fname,'Relation');
  else
    Relation=fname;
  end
  %load(fname, vname);
  list = inlist;
  if ~exist('Relation','var') || ~isstruct(Relation) || ~isfield(Relation,vname)
    warndlg(['Lost Relation Data: ' vname '.']);
    return; % Noting to do 
  end
  if ~isstruct(Relation.(vname)), return;end
  child_l = Relation.(vname).Children;
  
  for i=1:length(child_l),
    % Check recursive definition
    inlist{end+1} = child_l{i};
    list = getchild_sub(Relation, child_l{i}, inlist);
    inlist=list;
  end
catch
  rethrow(lasterror);
end
return;

function getParent(fname, vname)
% Load Parent with Error
error('Inline Expand.');

%% ---update Parent
function clearParent(filename, varname)
clist=clearParent_relation(filename, varname,{varname});

load(filename,'Relation');
for i=1:length(clist)
  if isfield(Relation,clist{i})
    Relation=rmfield(Relation,clist{i});
  end
end
%fn=fieldnames(Relation);
%fn=setdiff(fn,clist);
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
%load(filename,'Relation');
if rver >= 14,
  save(filename,'-v6','Relation');
else
  save(filename,'Relation');
end

function clist=clearParent_relation(fname, vname,clist)
% Delete Relation
val = getVariable(fname, vname); % Load
plist = val.Parent;

% Delete My Relation
if ~isempty(plist),
  for i=1:length(plist),
    vl=getVariable(fname, plist{i});
    vl.Children(strcmp(vl.Children, vname))=[];
    if isempty(vl.Children),vl.Children={};end
    setVariable(vl, plist{i},fname,true); % Save
  end
end
% Delete for Children
lclist = val.Children; % Local Clist
clear vl val plist; %<-- clean up.
for i=1:length(lclist)
  clist=clearParent_relation(fname, lclist{i},clist);
  clist{end+1}=lclist{i};
end

return;

function  val = getVariable(fname, vname)
% Load Relation Data
try
  load(fname,'Relation');
  %load(fname, vname);
  val = Relation.(vname);
catch
  error(['Variable not found in ' fname '.' lasterr]);
end
return;

  
function setVariable(var_1, vname,fname,ovw)
% Intput to Relation File.
%    This is only Input Function for Relation File.
%    :: I want to ... but clear also.
%
% Upper Link : DataDef2_**/addRelation

% memo: Multi-Data Save:
% Use Cell and Multi Save.
%  save(fname,vname{:},'-append',....

%=================
% Argument Check
%=================
% Check Number of Argument
msg = nargchk(2,4,nargin);
if msg, error(msg);end
% Get Relastion File-Name
if nargin<=2,fname=getRelationFileName;end
if nargin<=3,ovw=false;end

%------------------------------
% Setting Variable Format Check
%------------------------------
if ~isfield(var_1,'name') || ...
    ~isfield(var_1,'data') || ...
    ~isfield(var_1,'fcn') || ...
    ~isfield(var_1,'Parent') || ...
    ~isfield(var_1,'Children'),
  % ==> never occur, but checkking format <==
  error('Program Eror : Making Relation Error!');
end

%------------------------------
% Load & Set
%------------------------------
if exist(fname,'file')
  load(fname, 'Relation');
end
Relation.(vname)=var_1;
% Overwrite Check! 
if ~ovw
  if ~exist('Relation','var') || ~isstruct(Relation) || ~isfield(Relation,vname)
    error('[E] Bad input Name : Rename Data!');
  end
end

%=================
% Making Function
%=================

%=================
% Save
%=================
try
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  % --> it can be simplifies
  if rver >= 14,
    save(fname,'-v6','Relation');
  else
      save(fname, 'Relation');
  end
catch
  rethrow(lasterror);
end
return;

function ConfineRelationFile
% Resave Relation File by -v6 Option.
%
% This function is for BUG in Save-File Error.
%   :: Can not load Relation-File in MATLAB 6.5.1
%      If some one use P3 in MATLAB 7 or later.
%
% -------------------------------------------------------
%  I think Some-One save Relation File without '-v6' Option.
%  But I could not find when/who Save.
%
%  So, Resave Relation File by -v6 Option.
%  ( when P3 Closing..)
%
%  Of course, almost function that save Relation-File 
%  use -v6 option, and this is one of our cording rule.
% -------------------------------------------------------
% at 25-Mar-2007, shoji.
%
% See also POTATo_ini_fin/clearOsp

%=================
% Save
%=================
try
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  % --> it can be simplifies
  if rver >= 14,
    fname=getRelationFileName(false);
    if ~isempty(fname) && exist(fname, 'file'),
      s=load(fname);
      fn=fieldnames(s);
      load(fname);
      save(fname, '-v6', fn{:});
    end
  end
catch
  rethrow(lasterror);
end

function [fname, msg]=getRelationFileName(erdlg_flg)
% is as same as POTAToProject/private/getRelationFileName
if nargin==0,erdlg_flg=true;end
msg='';
path0 =OSP_DATA('GET','PROJECTPARENT');
pj=OSP_DATA('GET','PROJECT');
% Opening Check.
if isempty(path0) || isempty(pj)
  msg='Project is not Opened.';
  if erdlg_flg
    errordlg(msg);error(msg);
  else
    fname='';return;
  end
end
if ~strcmpi(path0,pj.Path),
  msg='Project Data might be broken';
  if erdlg_flg
    errordlg(msg);error(msg);
  else
    fname='';return;
  end
end

% fname = [pj.Path ...
fname =[path0 filesep pj.Name ...
  filesep 'Relation.mat'];

