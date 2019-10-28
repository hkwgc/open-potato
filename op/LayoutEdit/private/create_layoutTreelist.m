function create_layoutTreelist(handles)
% Get vgdata

%vgdata=getappdata(handles.figure1, 'LAYOUTPARTS');
%treeStr={'FIGURE NAME'};treeUd={[]};
%LAYOUT=getappdata(handles.figure1, 'LAYOUT');
LAYOUT=LayoutPartsIO('get',handles,[]);

try
  treeStr={LAYOUT.FigureProperty.Name};
catch
  treeStr={'Untitled'};
end
treeUd={[]};
vgdata=LAYOUT.vgdata;

if ~isempty(vgdata),
  for i=1:length(vgdata),
    if isempty(vgdata{i}),continue;end
    path=i;
    [treeStr, treeUd]=data2Tree(vgdata{i}, treeStr, treeUd, path);
  end
end
% Set layoutTree
set(handles.lbx_layoutTree, ...
  'String', treeStr, ...
  'UserData',treeUd);
return;

function [str, ud]=data2Tree(data,str,ud,path)
% vgdata{path}--> array for lbx_layoutTree-String,UserData
sp=[];indent='    ';
if ~isempty(path),
  for i=1:length(path),
    sp=[sp indent];
  end
end
if isfield(data, 'NAME'),
  % View Group 
  if ~isfield(data,'CObject')
    % ViewGroupAxes
    if (isfield(data,'Object') && ~isempty(data.Object))
      if ~data.ExpandFlag,
        hstr='{+} ';  %close
      else
        hstr='{-} ';  %open
      end
    else
      hstr='{ } ';  %childless
    end
  else
      % ViewGroupArea
    if (isfield(data,'Object') && ~isempty(data.Object)) ||...
         ~isempty(data.CObject),
      if ~data.ExpandFlag,
        hstr='[+] ';  %close
      else
        hstr='[-] ';  %open
      end
    else
      hstr='[ ] ';  %childless
		end
		if isfield(data.Property,'Script') && ~isempty(data.Property.Script{1})
			hstr=[hstr(1:end-1) 's '];
		end
  end
  % Add name of ViewGroupArea,ViewGroupAxes
  str{end+1}=[sp hstr data.NAME];
  ud{end+1}=path;
  if ~data.ExpandFlag, return; end
  if isfield(data, 'CObject') && ~isempty(data.CObject),
    for idx=1:length(data.CObject)
      % 2013.07.04
	  if isfield(data.CObject{idx},'name_Label')
		  str{end+1}=[sp indent '*' data.CObject{idx}.name_Label];
	  else
		  str{end+1}=[sp indent '*' data.CObject{idx}.name];
	  end
      ud{end+1}=[path -idx];
    end
  end
  if isfield(data, 'Object') && ~isempty(data.Object),
    for idx=1:length(data.Object)
      d=data.Object{idx};
      p=[path idx];
      [str,ud]=data2Tree(d,str,ud,p);
    end
  end
else
  % Add name of axesObject
  str{end+1}=[sp '>' data.str];
  ud{end+1}=path;
end
return;
