function varargout=LayoutPartsIO(fnc,varargin)
%
%  [parts, path, apos]=LayoutPartsIO('get',handles, lpath)
%
%  path=LayoutPartsIO('set',handles,parts,lpath)
%
% if there is no lpath, folllow LPO-of Layout-Tree-Listbox.
% if lpath is empty, set LAYOUT it self.
%
% Data (1) I/O Function

if isempty(fnc),OspHelp(mfilename);return;end

switch fnc
  case 'get',
    [varargout{1:nargout}]=getCurrentParts(varargin{:});
  case 'set',
    if nargout==0,
      setCurrentParts(varargin{:});
    else
      [varargout{1:nargout}]=setCurrentParts(varargin{:});
    end
  case 'getPosabs',
    [varargout{1:nargout}]=getPosabs(varargin{:});
  case 'layoutpath2evalstr',
    [varargout{1:nargout}]=layoutpath2evalstr(varargin{:});
  otherwise,
    error('Could not call this function.')
end


% ---------------------------------------
function [parts, path, apos]=getCurrentParts(handles, path)
%
% Get vgdata
LAYOUT=getappdata(handles.figure1, 'LAYOUT');
if nargin<=1
  val=get(handles.lbx_layoutTree, 'Value');
  ud= get(handles.lbx_layoutTree, 'UserData');
  path=ud{val};
end
if nargout>=3
  [str, apos]=layoutpath2evalstr(path,LAYOUT);
else
  str=layoutpath2evalstr(path,LAYOUT);
end
parts=eval(str);
return;
% ---------------------------------------
function path=setCurrentParts(handles,parts,path)
% Replace 
% Get vgdata
LAYOUT=getappdata(handles.figure1, 'LAYOUT');
if nargin<=2
  val=get(handles.lbx_layoutTree, 'Value');
  ud= get(handles.lbx_layoutTree, 'UserData');
  path=ud{val};
end
str=layoutpath2evalstr(path);
if isempty(parts),
  sind=strfind(str,'{');
  eind=strfind(str,'}');
  str(sind(end))='(';
  str(eind(end))=')'; % right{}->()
  eval([str '=[];']);
else
  eval([str '=parts;']);
end
% Update vgdata
setappdata(handles.figure1, 'LAYOUT',LAYOUT);
% Update layoutTree List
create_layoutTreelist(handles);
% Set  LayoutChange flag
setappdata(handles.figure1, 'CurrentLayoutisChange',true);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [str, apos]=layoutpath2evalstr(npath,LAYOUT)
% Make LAYOUT Data I/O Path
apos=[0,0,1,1];
if isempty(npath),
  % FIGURE NAME
  str='LAYOUT';
  return;
end
str=sprintf('LAYOUT.vgdata{%d}',npath(1));
if length(path)>1,
  for idx=npath(2:end),
    if nargout>=2, apos=eval(['getPosabs(' str '.Position, apos);']); end
    % Current parts
    if idx>0,
      str=[str '.Object{' num2str(idx) '}'];
    else
      str=[str '.CObject{' num2str(-idx) '}'];
    end
  end
end

function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
  lpos([1,3]) = lpos([1,3])*pos(3);
  lpos([2,4]) = lpos([2,4])*pos(4);
  lpos(1:2)   = lpos(1:2)+pos(1:2);
return;
