function varargout = osp_PCA(varargin)
% OSP_PCA M-file for osp_PCA.fig


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @osp_PCA_OpeningFcn, ...
  'gui_OutputFcn',  @osp_PCA_OutputFcn, ...
  'gui_LayoutFcn',  [] , ...
  'gui_Callback',   []);
if nargin && ischar(varargin{1})
  gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
  [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
  gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before osp_PCA is made visible.
function osp_PCA_OpeningFcn(hObject, eventdata, handles, varargin) %#ok

% Out put is PCA Using Component
handles.output = struct([]);
guidata(hObject, handles);

% == Read Property ==
ecode=0;
for vargid = 1:2:length(varargin)-1
  switch varargin{vargid}
    case 'InitData'
      try
        inidata = varargin{vargid+1};
        if ~isstruct(inidata)
          error('Init Data for osp_PCA must be Structure');
        end
        % inidata is as same as output one, See psb_ok_Callback
        cmp = num2str(inidata.UseComps);
        set(handles.edtComps,'String', cmp);

      catch
        ecode = bitand(ecode,2);
        OSP_LOG('err',' Argument Error :', lasterr);
      end

    case 'Mfile',
      try
        mfile_in = varargin{vargid+1};
        setappdata(handles.figure1, 'MFILE', mfile_in);
      catch
        ecode = bitand(ecode,2);
        OSP_LOG('err',' Argument Error :', lasterr);
      end
    otherwise
      ecode = bitand(ecode,1);
      OSP_LOG('err',' Unknown Property Inputed');
  end
end
if ecode~=0
  errordlg({' Argument Error : ', ...
    ['     Error Code ' num2str(enum)], ...
    lasterr});
end

try
  if ~exist('mfile_in','var'),
    psb_LoadData_Callback(handles.psb_LoadData,...
      [], handles)
  else
    [data, header] = scriptMeval(mfile_in,'data','hdata');
    setappdata(handles.figure1, 'Data', data);
    setappdata(handles.figure1, 'header', header);
  end
  header=getappdata(handles.figure1, 'header');
  fname = header.TAGs.filename;
  if iscell(fname),
    fname=fname{1};
  end
  set(handles.txt_filename, ...
    'String',fname);
catch
  warning(lasterr);
end

% Wait for Return;
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);
return;


% --- Outputs from this function are returned to the command line.
function varargout = osp_PCA_OutputFcn(hObject, eventdata, handles) %#ok
varargout{1} = handles.output;
delete(handles.figure1);

function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok
try
  if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    uiresume(handles.figure1);
  else
    delete(handles.figure1);
  end
catch
  delete(hObject);   % fig - open;
end

function psb_cancel_Callback(hObject, eventdata, handles) %#ok
handles.output = struct([]);
guidata(handles.figure1, handles);
uiresume(handles.figure1);
return;

function psb_ok_Callback(hObject, eventdata, handles) %#ok
cmp=str2num(get(handles.edtComps,'String')); %#ok
handles.output = struct('UseComps',cmp);
guidata(handles.figure1, handles);
uiresume(handles.figure1);
return;

function figure1_KeyPressFcn(hObject, eventdata, handles) %#ok
curKey=get(hObject,'CurrentKey');
if strcmp(curKey,'escape')
  figure1_CloseRequestFcn(hObject, eventdata, handles);
else
  % == OSP Common KeyBind ==
  try
    osp_KeyBind(hObject, eventdata, handles);
  catch  
  end
end
return;

% --- Executes on button press in psb_LoadData.
function psb_LoadData_Callback(hObject, eventdata, handles) %#ok

ad_tmp = OSP_DATA('Get','ActiveData');
ad = [];
try
  if strcmp(get(hObject,'Visible'),'off');
    ad = OSP_DATA('Get','ActiveData');
  end

  if isempty(ad) || isempty(ad.fcn)
    fs_h = uiFileSelect('DataDif',{'SignalPreprocessor'});
    waitfor(fs_h);
    ad = OSP_DATA('Get','ActiveData');
    set(hObject,'Visible','on');
  end
catch
  
end

OSP_DATA('Set','ActiveData',ad_tmp);

try
  tmp.empty_dumy=[];
  key.actdata = ad;
  key.filterManage = tmp;
  [data, header] = feval(ad.fcn, 'make_ucdata', key);
  setappdata(handles.figure1, 'Data', data);
  setappdata(handles.figure1, 'header', header);
catch
  set(hObject,'Visible','on');
  set(handles.txt_filename, ...
    'String','No File');
end

return;

% --- Executes on button press in ckb_plot_rstructdata.
function psb_plot_Callback(hObject, eventdata, handles) %#ok

% === Load Data ===
% global PC w U signal
%
% [f p]=uigetfile('s_*.mat');
% cd(p);load(f);
data   = getappdata(handles.figure1, 'Data');
%header = getappdata(handles.figure1, 'header');
if isempty(data),
  errordlg('no data to test plot');
  return;
end

if ndims(data)==4,
  sz=size(data); sz(1)=[];
  data = reshape(data(1,:,:,:), sz);
elseif ndims(data)~=3,
  errordlg('Input Data Dimension Error');
  return;
end

% b=squeeze(signal.chb(:,:,1))';
% z=b*b';
b = squeeze(data(:,:,1))'; % channel x time
mb = mean(b,2);
mb = repmat(mb,1,size(b,2));
b2 = b-mb;   % average

z=b2*b2';   % Variance-Covariance Matrix

% Now U is sort by ascending order,
%    so use flipud
[w0 U]=eig(z);
w=w0';
PC=w*b2;

% Print Relative-Contribution
if get(handles.ckb_plot_contribu, 'Value')
  figure;
  bar(flipud(diag(U))/sum(diag(U))*100);
  xlabel('Component');
  ylabel('Relative-Contribution [%]');
  title('PCA - Contribution');
end

% Print Channel
if get(handles.ckb_plot_rstructdata,'Value')
  % Using Component
  cmp=str2num(get(handles.edtComps,'String')); %#ok
  PC2=zeros(size(PC));
  PC1=flipdim(PC,1);
  PC2(cmp,:)=PC1(cmp,:);
  PC2=flipdim(PC2,1);
  sig2=w0*PC2 + mb;

  % Original Data ( for Plot )
  % sig=signal.chb(:,:,1)';
  sig = b;

  ch=str2num(get(handles.edtShowCh,'String')); %#ok
  spz=size(ch,2);
  figure;
  for ich=1:spz
    subplot(ceil(sqrt(spz)),ceil(sqrt(spz)),ich);
    plot(sig(ch(ich),:));
    hold on
    plot(sig2(ch(ich),:),'r');
    title(sprintf('Channel %d',ch(ich)));
  end
end

if get(handles.ckb_score,'Value')
  if ~exist('PC1','var')
    PC1=flipdim(PC,1);
  end
  cp1_str = get(handles.edt_comp1,'String');
  cp2_str = get(handles.edt_comp2,'String');
  cp1 = str2double(cp1_str);
  cp2 = str2double(cp2_str);
  figure;
  scatter(PC1(cp1,:), PC1(cp2,:));
  xlabel(['Principal Component :' cp1_str]);
  ylabel(['Principal Component :' cp2_str]);
  title('PCA Score');
end
return;
