function P3_Write_Mfile_Comment(varargin)
% Write M-File's Comment of P3
%
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 05-Mar-2008.
% $Id: P3_Write_Mfile_Comment.m 398 2014-03-31 04:36:46Z katura7pro $
%
% Revision 1.0:
%    Recode of Meeting on 19-Oct-2007.
%

try
  localmain(varargin{:});
catch
  % TODO: Warning
  disp(' == Comment Write Error ==');
  disp(C__FILE__LINE__CHAR);
  disp(lasterr);
  disp(date);
end

function localmain(type,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Check Enviroment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ArgumentChedk
msg=nargchk(1,20,nargin);
if msg,error(msg);end
if isempty(type),return;end

% POTATo Status Check
if ~strcmp(type,'recipeInfo')
  if OSP_DATA<1,
    error('POTATo Status Error');
  end
end

% M-File Status Check
fid=make_mfile('getfileinfo');
if isempty(fid),
  error('Open Mfile at fast');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Execute Function's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch type
  case 'projectInfo'
    projectInfo;
  case 'recipeInfo'
    msg=nargchk(1,2,nargin);
    if msg,error(msg);end
    recipeInfo(varargin{1});
  case 'multiRecipeInfo'
    msg=nargchk(1,2,nargin);
    if msg,error(msg);end
    multiRecipeInfo(varargin{1});
  otherwise
    error('No Type exist');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function projectInfo
% Write Project Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pppath=OSP_DATA('GET','PROJECTPARENT');
prj=OSP_DATA('GET','PROJECT');
make_mfile('with_indent',['% Project : ' pppath]);
make_mfile('with_indent',['%           ' prj.Name]);
make_mfile('with_indent',['% Operator: ' prj.Operator]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function recipeInfo(fdata)
% Recipe Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('with_indent', '% == Recipe Information ==');

%==================================
% Continuos
%==================================
if isfield(fdata,'HBdata'),
  % -- Set Filter --
  for fidx=1:length(fdata.HBdata),
    try
      if isfield(fdata.HBdata{fidx},'enable') && ...
          strcmpi(fdata.HBdata{fidx}.enable,'off'),
        continue;
      end
      bi = P3_PluginEvalScript(fdata.HBdata{fidx}.wrap,'createBasicInfo');
      if isfield(bi,'Description')
        make_mfile('with_indent', ['% * ' bi.Description]);
      else
        make_mfile('with_indent', ['% * ' bi.name]);
      end
    catch
      % Error for :::
      warning(lasterr);
      make_mfile('with_indent', '% * Unknown filter');
    end % try-catch
  end % filter output
end % HBdata?

%==================================
%  Blocking
%==================================
% No - Blocking
if ~isfield(fdata,'BlockPeriod'),
  return;
end
if isfield(fdata,'block_enable') && fdata.block_enable==0,
  return;
end


% == Data Blocking ==
if isfield(fdata,'TimeBlocking'),
  try
    blocking=fdata.TimeBlocking{1};
    if isfield(blocking,'enable') && ...
        strcmpi(blocking.enable,'off'),
      return;
    end
    bi = P3_PluginEvalScript(blocking.wrap,'createBasicInfo');
    if isfield(bi,'Description')
      make_mfile('with_indent', ['% * ' bi.Description]);
    else
      make_mfile('with_indent', ['% * ' bi.name]);
    end
  catch
    % Error for :::
    warning(lasterr);
    make_mfile('with_indent', '% * Unknown filter');
  end % try-catch
else
  make_mfile('with_indent','% Make Block Data');
end

%==================================
% Blocked Data
%==================================
if isfield(fdata,'BlockData'),
  % -- Set Filter --
  for fidx=1:length(fdata.BlockData),
    try
      if isfield(fdata.BlockData{fidx},'enable') && ...
          strcmpi(fdata.BlockData{fidx}.enable,'off'),
        continue;
      end
      bi=P3_PluginEvalScript(fdata.BlockData{fidx}.wrap,'createBasicInfo');
      if isfield(bi,'Description')
        make_mfile('with_indent', ['% * ' bi.Description]);
      else
        make_mfile('with_indent', ['% * ' bi.name]);
      end
    catch
      % Error for :::
      warning(lasterr);
      make_mfile('with_indent', '% * Unknown filter');
    end % try-catch
  end % filter output
end % BlockData?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function multiRecipeInfo(recipe)
% Recipe Information for Multi-Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isstruct(recipe),return;end
make_mfile('with_indent', '% == Recipe Information ==');
if isfield(recipe,'FileIOMode') && recipe.FileIOMode
  make_mfile('with_indent', '% File I/O Mode : ON');
else
  make_mfile('with_indent', '% File I/O Mode : OFF');
end

if isfield(recipe,'default')
  % -- Set Filter --
  for fidx=1:length(recipe.default),
    try
      if isfield(recipe.default{fidx},'enable') && ...
          strcmpi(recipe.default{fidx}.enable,'off'),
        continue;
      end
      bi = P3_PluginEvalScript(recipe.default{fidx}.wrap,'createBasicInfo');
      if isfield(bi,'Description')
        make_mfile('with_indent', ['% * ' bi.Description]);
      elseif isfield(bi,'name')
        make_mfile('with_indent', ['% * ' bi.name]);
      else
        make_mfile('with_indent', '% * Unknown-Plugin');
      end
    catch
      warning(lasterr);
      make_mfile('with_indent', '% * Unknown filter');
    end % try-catch
  end % filter output
end
 
