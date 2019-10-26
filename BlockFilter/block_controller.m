function varargout = block_controller(varargin)
% BLOCK_CONTROLLER Application M-file for block_controller.fig
%    FIG = BLOCK_CONTROLLER launch block_controller GUI.
%    BLOCK_CONTROLLER('callback_name', ...) invoke the named callback.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Last Modified by GUIDE v2.5 26-Jan-2005 21:19:31

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUB-FUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switch-yard
		else
			feval(varargin{:}); % FEVAL switch-yard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function varargout = data_capture_psb_Callback(h, eventdata, handles, varargin)
% Transform data from CHB to Block

mode=get(handles.ppmMode, 'Value');
signal=getappdata(gcf,'signal');

BCW_Mark_Value=signal.modstim;
BCW_Mark_State=(signal.modstim>=1);
BCW_Mark_Time=signal.time(find(BCW_Mark_State));

% Set Filter option data and Block length
N=sum(BCW_Mark_State);
j=find(BCW_Mark_State==1);
editBlk1=str2num(get(handles.pltsig_starttime,'String'));
editBlk2=str2num(get(handles.pltsig_endtime,'String'));
mv=str2num(get(handles.edtMovingAverage,'String'));
deg=str2num(get(handles.edtFitting,'String'));
frflt=[];
if get(handles.frqflt_valu,'value')
    frtyp=get(handles.flttyp_value,'String');
    frtyp=frtyp{get(handles.flttyp_value,'Value')};
    if get(handles.frqrng_value,'Value')~=1,
        dum=get(handles.frqrng_value,'String');
        j1=find(dum=='(');j2=find(dum==',');j3=find(dum==')');    
        for ii=1:length(j1),
            frflt=[frflt,str2num(dum(j1(ii)+1:j2(ii)-1)),str2num(dum(j2(ii)+1:j3(ii)-1))]; 
        end
    end
else
    frtyp=[];
end

% -----------------------------------------
% Use the following(if-end), Filtering before transferring RAW data to CHB data.
% -----------------------------------------
if (get( handles.cbxMovingAverage, 'Value' ) | get( handles.cbxFitting, 'Value' )) | ~isempty(frflt)
% ------------------------------------------
% ---- Filter option(Moving Average, Local Fitting or filtering)
% ---- USE RAW DATA
% ------------------------------------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for HB Filter 
    %    21-Dec-2004  ( This Code will be change to function in next Version )
    %    M. Shoji
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FiltData='HB';
%    FiltData='Raw';
    
    if strcmp(FiltData,'Raw')
        data=signal.data; % Object for Fitting
        LclFtMod = 1;     % Raw is Local Fitting Mode is 1 ( Div )
    else
        data=signal.chb;  % Object for Fitting
        LclFtMod = 2;     % HB is Local Fitting Mode is 2 ( Sub  ~= 1)
    end
    
    tm_num=length(signal.chb(:,1,1));% temporal data size number
    smpl_pld=signal.sampleperiod;% sampling period [ms]
    datapara=[smpl_pld,tm_num]; 
    
    %---- Moving Average
    if get( handles.cbxMovingAverage, 'Value' )
        mv=str2num( get( handles.edtMovingAverage, 'String' ) );
        data=osp_Movingaverage(data, mv);
    end
    
    %---- Local Fitting 
    %  -- Fitting Area --
    st= - str2num( get(handles.pltsig_starttime, 'String') )  * 1000/smpl_pld;
    rx=   str2num( get(handles.rlx_edt, 'String') )           * 1000/smpl_pld;
    ed=   str2num( get(handles.pltsig_endtime, 'String') )    * 1000/smpl_pld;
    ast=abs(st);
    
    stm=find(signal.modstim);
    
    % 21-Dec-2004  M. Shoji
    %    Add Check of Over/Under Flow
    if  get( handles.cbxFitting, 'Value' )
        deg=str2num( get(handles.edtFitting, 'String') );
        if mode==2  % Set ( Block Stimulate )
            for ii=1:2:size(stm)
                st0 = stm(ii) + st;
                if st0 <= 0, st0=0; end % check 
                ast2=stm(ii)-st0;
                ed0 = stm(ii+1) +ed;
                if ed0 > tm_num, st0=tm_num; end % check Overflow, where tm_num is size(data,1)
                data(st0:ed0, :, :)=...
                    osp_Local_Fitting( data(st0:ed0, :, :),...
                    [ast2, ast2+stm(ii+1)-stm(ii)+rx], deg ,...
                    LclFtMod);
            end
        elseif mode==1 % Single ( Event Stimulate )
            for ii=1:size(stm)
                st0=stm(ii)+st;
                if st0 <= 0, st0=0; end % check 
                ast2=stm(ii)-st0;
                ed0 = stm(ii) +ed;
                if ed0 > tm_num, st0=tm_num; end % check Overflow, where tm_num is size(data,1)
                data(st0:ed0, :, :)=...
                    osp_Local_Fitting( data(st0:ed0, :, :),...
                    [ast2, ast2+rx], deg ,...
                    LclFtMod);
            end
        end
    end
    
    if ~isempty(frflt),
        if floor(length(frflt)/2)==ceil(length(frflt)/2),
            pairnum=length(frflt)/2;
            for ii=1:pairnum,hpf(ii)=frflt(ii*2-1);lpf(ii)=frflt(ii*2);end
            frtyp=char(frtyp);
            switch frtyp,
                case {'box for fft'}
                    %                 switch plttyp{1},            
                    %                 case {'time','time-block'},
                    %                     typ='time';
                    %                 otherwise
                    %                     typ='fft';
                    %                 end
                    %                data=real(ot_bandpass2(data,hpf,lpf,pairnum,datapara(1)/1000,1,typ));   
                    % Changed by Shoji 21-Oct-2004;
                    %   PLTTYP is Undefined variable -> 
                    %          --- DATA is not fft-data, so PLTTYP is 'time' ---
                    data=real(ot_bandpass2(data,hpf,lpf,pairnum,datapara(1)/1000,1,'time'));   
                    
                case {'butterworth(bpf)','butterworth(bsf)','butterworth(hpf)','butterworth(lpf)'}
                    filttyp=frtyp(13:15);        
                    for ii=1:pairnum,
                        hpf=frflt(ii*2-1);lpf=frflt(ii*2);
                        [b,a]=ot_butter(hpf,lpf,1000/datapara(1),5,filttyp);%Use 5 degree
                        [data]=ot_filtfilt(data,a,b,1);
                    end
            end
        else
            errordlg('The pair of HPF and LPH is insufficient !!');
            return;
            %            break
        end
    end
    
   if strcmp(FiltData,'Raw') % 21-Dec-2004  M. Shoji
        wavelength=signal.wavelength;
        data=osp_chbtrans2(data, wavelength, 5);
    end
    
else
% ---- USE HB DATA, or Filtering after transferring RAW data to CHB data
    data=signal.chb;
end

% Make block data from CHB data
switch mode
case {1}%Single
    % Input Data Size
    datasize0= size(data);
    datamaxidx =datasize0(1);
    % Out put Data size
    fowardnum=editBlk1*(1000/signal.sampleperiod);
    addnum   =editBlk2*(1000/signal.sampleperiod);
    datasize = addnum+fowardnum+1;
    % malloc
    data_idx=zeros(datasize,1);
    datasize0(1)=datasize;
    datasize0 =([ N; datasize0(:)])';
    BCW_MB=zeros(datasize0);
    clear dasize0;
    for i0=1:N
        stnum(i0)=j(i0)-fowardnum;
        endnum(i0)=j(i0)+addnum;
%       -- Here  Check Memory Broken Error --
%       ( meaning of the code is same as following )
%   A. smart
%         data_idx=stnum(i0):endnum(i0);
%         tmp=find(data_idx<=0);
%         if ~isempty(tmp), data_idx(tmp)=1;end
%         tmp=find(data_idx>datamaxid);
%         if ~isempty(tmp), data_idx(datamaxid)=datamaxid;end
%
%  B.  fast??
        if stnum(i0) <= 0       % Under flow case
             data_idx(:)=1;    % init
             data_idx(2-stnum(i0):end) = 1:endnum(i0);
         else
             data_idx=stnum(i0):endnum(i0);
         end
         if endnum(i0) > datamaxidx % Over flow case
            data_idx((end-(endnum(i0)-datamaxidx)+1):end)=datamaxidx;
         end
% C. 
%   try, catch and if error do A

% ??? Code Over write And delete ...
%         B=data(data_idx,:,:);
% 
%         BM=B;
%         BMF=BM;
%         BMFF=BMF;
%         BCW_MB(i,:,:,:)=BMFF;
        BCW_MB(i0,:,:,:)=data(data_idx,:,:);
    end % Block(i0) Loop
    
case {2}%Set
    [aa,bb,cc]=size(signal.chb(j(1)-editBlk1*(1000/signal.sampleperiod):j(2)+editBlk2*(1000/signal.sampleperiod),:,:));
    BCW_MB=zeros([ceil(N/2) aa bb cc]);
    for i0=1:2:N-1
        ll=j(i0+1)+editBlk2*(1000/signal.sampleperiod)-(j(i0)-editBlk1*(1000/signal.sampleperiod))+1;
        B=zeros(aa,bb,cc);
        if ll<=aa
            stnum((i0+1)/2)=j(i0)-editBlk1*(1000/signal.sampleperiod);
            endnum((i0+1)/2)=j(i0+1)+editBlk2*(1000/signal.sampleperiod);
            B(1:ll,:,:)=data(stnum((i0+1)/2):endnum((i0+1)/2),:,:);
            if ll<aa
                msgflag((i0+1)/2)=-1;
                for k=ll+1:aa
                    B(k,:,:)=data(endnum((i0+1)/2),:,:);
                end
            else
                msgflag((i0+1)/2)=0;
            end
        else
            stnum((i0+1)/2)=j(i0)-editBlk1*(1000/signal.sampleperiod);
            endnum((i0+1)/2)=j(i0)-editBlk1*(1000/signal.sampleperiod)+aa-1;
            B=data(stnum((i0+1)/2):endnum((i0+1)/2),:,:);
            msgflag((i0+1)/2)=1;
        end

%         BM=B;
%         BMF=BM;
%         BMFF=BMF;
        BCW_MB((i0+1)/2,:,:,:)=B;
        if msgflag((i0+1)/2)<0
            warning(['Adding data(same as final value) after the end of this array,', ...
					'because this(index=', num2str((1+i0)/2), ') is smaller than the first one.']);
        elseif msgflag((i0+1)/2)>0 
            warning(['Cutting the end of data in this array,', ...
					'because this(index=',num2str((1+i0)/2),') is bigger than the last index.']);
        end
    end
end

fullname=get(handles.strdir_sigp_edt,'String');
[pathname, filename]=pathandfilename(fullname);

BCW_MBP.filename=filename; % Filename
BCW_MBP.markstate=j;    % Mark state
BCW_MBP.stnum=stnum;    % Start point of each block
BCW_MBP.endnum=endnum;  % End Point of each block
BCW_MBP.frtyp=frtyp;%['Filter Type: ',frtyp{:},'  Filter Parameter: ',num2str(frflt)];
BCW_MBP.frflt=frflt;
BCW_MBP.mode=mode;  % Set or Single
BCW_MBP.sampleperiod=signal.sampleperiod;
BCW_MBP.stim=signal.stim;

% here we must renew in the future version.
tmp1=signal.modstim;
tmp5=size(tmp1(:),1);
for i=1:length(stnum)
    % azy program, 
    % if this is too late to make modstim,
    %  Set tmp3 in before Loop (BCW_MB making )
    tmp3=stnum(i):stnum(i)+endnum(1)-stnum(1);
    tmp4=find(tmp3<=0);   
    if ~isempty(tmp4), tmp3(tmp4)=1;end
    tmp4=find(tmp3>tmp5); 
    if ~isempty(tmp4), tmp3(tmp4)=tmp5;end
    tmp2(:,i)=tmp1(tmp3);
end
BCW_MBP.modstim=tmp2;

BCW_MBP.wavelength=signal.wavelength;
BCW_MBP.date=signal.date;
BCW_MBP.age=signal.age;
BCW_MBP.sex=signal.sex;
BCW_MBP.plnum=signal.plnum;
BCW_MBP.comment=signal.comment;
BCW_MBP.measuremode=signal.measuremode;
BCW_MBP.subjectname=signal.subjectname;

datapara=[signal.sampleperiod, length(signal.chb(:,1,1)) -1000/signal.sampleperiod*editBlk1 1000/signal.sampleperiod*editBlk2]; %-for function datapara(1)=sampling period, datapara(2)=data size,
BCW_MBP.datapara=datapara;
BCW_MBP.relax=str2num( get(handles.rlx_edt, 'String') )*1000/signal.sampleperiod;

vecaxisx=[0:datapara(1)/1000:(datapara(2)-1)*datapara(1)/1000]; 
stmdat=signal.modstim;

% Data information
for i=1:N/mode
    if mode==1
        tempnumnum=find(signal.stim);
        tempnumnum=find(tempnumnum==j(i));
        tempnum=num2str(tempnumnum);
        tempidx=i;
    else
        tempnum=[num2str(i*mode-1), ' ', num2str(i*mode)];
        tempidx=i*mode-1;
    end
    if isempty(BCW_MBP.frtyp)
        frtyp_tmp='--';
    else
        frtyp_tmp=BCW_MBP.frtyp;
    end
    if isempty(BCW_MBP.frflt)
        frflt_tmp='--';
    else
        frflt_tmp=['(',num2str(BCW_MBP.frflt),')'];
    end
    temp{i}=[BCW_MBP.filename,'  [ ', tempnum,' ]  < ',num2str(signal.stim(j(tempidx))),' >  ',...
            num2str(BCW_MBP.endnum(i)-BCW_MBP.stnum(i)),', ',...
            num2str(BCW_MBP.stnum(i)),', ',num2str(BCW_MBP.endnum(i)),', ',...
            'Filter Type: ',frtyp_tmp,'  Filter Parameter: ',frflt_tmp];
end

set(handles.listData,'String',temp);

setappdata(gcf,'BCW_MB',BCW_MB);
setappdata(gcf,'BCW_MBP',BCW_MBP);

% --------------------------------------------------------------------
function varargout = file_save_psb_Callback(h, eventdata, handles, varargin)

% save as
BCW_MB=getappdata(gcf,'BCW_MB');
BCW_MBP=getappdata(gcf,'BCW_MBP');
MotionBlockMark=getappdata(gcf, 'MotionBlockMark');   % -- Temp --result of Motion check
fullname=get(handles.strdir_sigp_edt,'String');
[pathname, filename]=pathandfilename(fullname);

[fn pn]=uiputfile(['b',filename],'*.mat')
save([pn,fn],'BCW_MB','BCW_MBP','MotionBlockMark')

% --------------------------------------------------------------------
function varargout = file_select_psb_Callback(h, eventdata, handles, varargin)

%Select file
[fn pn]=uigetfile('s_*.mat');cd(pn);
set( handles.datcnt_lsb, 'String', {pn(1:end-1) fn})
set( handles.strdir_sigp_edt, 'String', [pn fn])

otplotsigfigchld;
signal=getappdata(gcf,'signal');
marker_search_Callback(h, eventdata, handles, varargin);
setappdata(gcf, 'MotionBlockMark',[]);
set(handles.motion_state_psb,'Visible','off');

% --------------------------------------------------------------------
function varargout = plot_psb_Callback(h, eventdata, handles, varargin)

% Plot
signal=getappdata(gcf,'signal');
hold off;

if get(handles.ppmKind,'value')==1
	% Raw   
	plot(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2-1 ),'Color',[1 0.2 0.5]);
    hold on;
	plot(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2 ),'Color',[0.6 0 0]);
	title(['channel ' get(handles.edtChnl, 'String') '  780nm & 800nm ']);
	m1=max(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2, 1));
	m2=min(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2, 1));
else
	%Hb	
	plot(signal.chb(:, str2num(get(handles.edtChnl, 'String')) ,1),'r');
    hold on;
	plot(signal.chb(:, str2num(get(handles.edtChnl, 'String')) ,2),'b');
	plot(signal.chb(:, str2num(get(handles.edtChnl, 'String')) ,3),'k');
	title(['channel ' get(handles.edtChnl, 'String') '  Oxy Deoxy Total']);
	m1=max(signal.chb(:, str2num(get(handles.edtChnl, 'String')), 1));
	m2=min(signal.chb(:, str2num(get(handles.edtChnl, 'String')), 1));
end
hold on

% marker
mode=get(handles.ppmMode, 'Value');

% tmp Plot Point : Add by M. Shoji
axtmp = axis;
rng  =axtmp(4)-axtmp(3);
orgn = axtmp(3);
clear axtmp;

switch mode
    case {1}%Single
        
        % Not Selected Data (x)  Plot ??
        tg=find(signal.stim>0 & signal.modstim==0);
        if isempty(tg)==0,plot(tg,orgn+0.1*rng,'mx');end
        
        % Plot from here
        tg=find(signal.stim>0 & signal.modstim>0);
        % y is Print Stim-Timing ??  or for next plot ? 
        y=zeros(1,signal.datanum);
        if isempty(tg)==0
            y(tg) = signal.modstim(tg);
            ord = 0.1*rng / max(y);    % Order of plot
            plot(tg,orgn + 0.8*rng + y(tg) * ord,'go');
            clear ord;
        end

% Ignore After Here
%         tg=find(signal.stim>0);
%         y=0;
        
    case {2}%Set
        tg=find(signal.modstim>0);
        y=zeros(1,signal.datanum);
        for i=1:2:size(tg,1)-1
            y(1, tg(i):tg(i+1))=signal.modstim(tg(i));   % Plot Only modstim is On
        end	
        plot(y+m2,'k:');
    otherwise,
        error('Block Controller : Unknown ppmMode, neither Single / Set');
end	
    
text(tg,repmat(m1,size(tg)),num2str((1:size(tg,1))'));
varargout={y,m1,m2};

% Select mark
st=get(handles.lbxMarker, 'String');
tg=get(handles.lbxMarker, 'Value');
selmark=[];
for i=tg
	s=st{i};
	n=sscanf(s,'%s [%02d] <%d> %d - [%02d] <%d> %d');
	if ( size(n,1)~=9 )
		%Event	
		%selmark=[selmark i];
        selmark=[selmark n(4)];
	else %Block
		n=n(3:end);
		selmark=[selmark n(4):(n(7)-n(4))/10:n(7)];
	end
end
plot(selmark,(m1-m2)+m2,'b.');
% ---


% --------------------------------------------------------------------
function varargout = ppmMode_Callback(h, eventdata, handles, varargin)

marker_search_Callback(h, eventdata, handles, varargin);%Marker Search


% --------------------------------------------------------------------
function varargout = lbxMarker_Callback(h, eventdata, handles, varargin)

if (get(handles.cbxChangeOnSelect, 'Value') )
	sub_invert(h, eventdata, handles, varargin)
end

[y m1 m2]=marker_search_Callback(h, eventdata, handles, varargin);%Marker search

% --------------------------------------------------------------------
function varargout = invert_psb_Callback(h, eventdata, handles, varargin)
%invert
sub_invert(h, eventdata, handles, varargin)
[y m1 m2]=marker_search_Callback(gcf, eventdata, handles, varargin);% Marker Search

% --------------------------------------------------------------------
function varargout = select_psb_Callback(h, eventdata, handles, varargin) 
% marker select mode
mode=get(handles.marker_select_pop, 'Value');
signal=getappdata(gcf,'signal');

st=get(handles.lbxMarker, 'String');
tg=get(handles.lbxMarker, 'Value');

nums=str2num(get(handles.edtSelectCond,'String'));

switch mode
case {1}%Series num [?]
	for i=1:size(st,1)
		s=st{i};
        n=sscanf(s,'%s [%02d] <%d> %d - [%02d] <%d> %d'); 
		if (size(n,1)==9), n=n(3:end);end
		if (size(n,1)==6), n=n(3:end);end
		for j=nums
			if ( n(2) == j ), tg=[tg i];end
		end
	end 

case {2}%type <?>
	% tg=[];   % for init;
	for i=1:size(st,1)
		s=st{i};
		n=sscanf(s,'%s [%02d] <%d> %d - [%02d] <%d> %d');
		if (size(n,1)==9), n=n(3:end);end
		if (size(n,1)==6), n=n(3:end);end
		for j=nums
			if ( n(3) == j ), tg=[tg i];end
		end
	end

case {3}% Kind
	msgbox('This function is not made yet','Error','error');
end

set(handles.lbxMarker, 'Value',tg);
[y m1 m2]=plot_psb_Callback(h, eventdata, handles, varargin);%Plot

% --------------------------------------------------------------------
function varargout = reset_psb_Callback(h, eventdata, handles, varargin)
%reset
signal=getappdata(gcf,'signal');
signal.modstim=signal.stim;
setappdata(gcf, 'signal', signal);
[y m1 m2]=marker_search_Callback(gcf, eventdata, handles, varargin);% Marker Search



% --------------------------------------------------------------------
% --------------------------------------------------------------------
%sub routine 
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = sub_invert(h, eventdata, handles, varargin)

signal=getappdata(gcf,'signal');

stm=find(signal.stim>0);
mstm=find(signal.modstim>0);

st=get(handles.lbxMarker, 'String');
tg=get(handles.lbxMarker, 'Value');

for i=tg
	s=st{i};
	n=sscanf(s,'%s [%02d] <%d> %d - [%02d] <%d> %d');

	mode=get(handles.ppmMode, 'Value');

	if ( size(n,1)~=9 )
		%Single
		if ( n(1)=='o' )
			signal.modstim( stm( n(2) ) )=0;
		else
			signal.modstim( stm( n(2) ) )=signal.stim( stm( n(2) ) );
		end
	else %Set
		n=n(3:end);
		if ( n(1)=='o' )
			signal.modstim( stm( n(2) ) )=0;
			signal.modstim( stm( n(5) ) )=0;
		else
			signal.modstim( stm( n(2) ) )=signal.stim( stm( n(2) ) );
			signal.modstim( stm( n(5) ) )=signal.stim( stm( n(5) ) );
		end
	end
end

ph=findobj('Tag','otplot_fig');
setappdata(gcf, 'signal', signal);

% --------------------------------------------------------------------
% --------------------------------------------------------------------
% Marker Search Callback
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = marker_search_Callback(h, eventdata, handles, varargin)

% Marker Search
signal=getappdata(gcf,'signal');

mode=get(handles.ppmMode, 'Value');

stm=find( signal.stim >0 );
mstm=find(signal.modstim>0);


switch mode
case {1} % Single

	st='';
	for i=1:size(stm,1)
		if isempty(find(mstm==stm(i)))==0
			st{end+1}=['o [' sprintf('%02d',i) '] <' num2str(signal.stim(stm(i))) '> ' num2str(stm(i))];
		else
			st{end+1}=['x [' sprintf('%02d',i) '] <' num2str(signal.stim(stm(i))) '> ' num2str(stm(i))];
		end
		set(handles.lbxMarker, 'String', st);
	end
	
case {2} % Set

	st='';b=0;s='';m=0;bmark=1;
	for i=1:size(stm,1)
		if ( ~isempty( find(mstm==stm(i)) ) )
		% << o >>
			if (m==2)
				st{end+1}=s(3:end);
			end
			if (b==0)
				s=sprintf('%02do [%02d] <%d> %d', bmark, i, signal.stim(stm(i)), stm(i) );
				b=1;
			else 
				st{end+1}=[s ' - [' sprintf('%02d',i) '] <' num2str(signal.stim(stm(i))) '> ' num2str(stm(i))];
				b=0;s='';bmark=bmark+1;
			end
			m=1;
			
		else
		% << x >>
			if (m==2)
				st{end+1}=[s '- [' sprintf('%02d',i) '] <' num2str(signal.stim(stm(i))) '> ' num2str(stm(i))];
				m=0;s='';bmark=bmark+1;
			else
				s=sprintf('%02dx [%02d] <%d> %d', bmark, i, signal.stim(stm(i)), stm(i) );
				m=2;
			end
		end
	end
	if ~strcmp(s,''), st{end+1}=s(3:end);end
	set(handles.lbxMarker, 'String', st);

end

if max( get(handles.lbxMarker,'Value') )>size(st,2)
	set(handles.lbxMarker,'Value',1);
end

[y m1 m2]=plot_psb_Callback(h, eventdata, handles, varargin);%Plot
varargout={y,m1,m2};
% --------------------------------------------------------------------
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function varargout = pltexe_btn_Callback(h, eventdata, handles, varargin)

plot_bcw

% --------------------------------------------------------------------
function varargout = frqflt_valu_Callback(h, eventdata, handles, varargin)

if get(h,'value')
	% checked
	set( handles.flttyp_value, 'enable', 'on');
	set( handles.frqrng_value, 'enable', 'on');    
else
	% unchecked
	set( handles.flttyp_value, 'enable', 'off');
	set( handles.frqrng_value, 'enable', 'off');   
end

% --------------------------------------------------------------------
function varargout = cbxMovingAverage_Callback(h, eventdata, handles, varargin)

if get(h,'value')
	% checked
	set( handles.edtMovingAverage, 'enable', 'on');
else
	% unchecked
	set( handles.edtMovingAverage, 'enable', 'off');
end

% --------------------------------------------------------------------
function varargout = cbxFitting_Callback(h, eventdata, handles, varargin)

if get(h,'value')
	% checked
	set( handles.edtFitting, 'enable', 'on');
	set( handles.rlx_edt, 'enable', 'on');
    
else
	% unchecked
	set( handles.edtFitting, 'enable', 'off');
	set( handles.rlx_edt, 'enable', 'off');    
end

% --------------------------------------------------------------------
function varargout = motion_chk_Callback(h, eventdata, handles, varargin)

% -- Load Data --
signal=getappdata(gcf,'signal');
hold off;

% -- Raw Data Plot --
% if get(handles.ppmKind,'value')==1
% 	% Raw   
% 	plot(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2-1 ),'Color',[1 0.2 0.5]);
%     hold on;
% 	plot(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2 ),'Color',[0.6 0 0]);
% 	title(['channel' get(handles.edtChnl, 'String') ' 780nm & 800nm ']);
% 	m1=max(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2, 1));
% 	m2=min(signal.data(:, str2num(get(handles.edtChnl, 'String'))*2, 1));
% else
%	%Hb	
% 	plot(signal.chb(:, str2num(get(handles.edtChnl, 'String')) ,1),'r');
%     hold on;
% 	plot(signal.chb(:, str2num(get(handles.edtChnl, 'String')) ,2),'b');
	plot(signal.chb(:, str2num(get(handles.edtChnl, 'String')) ,3),'g');
	title(['channel ' get(handles.edtChnl, 'String') ' Motion artifact check']);
	m1=max(signal.chb(:, str2num(get(handles.edtChnl, 'String')), 3));
	m2=min(signal.chb(:, str2num(get(handles.edtChnl, 'String')), 3));
% end
hold on;

% motion artifact check
ma_chk=signal.chb(:, : ,3);
%       size(ma_chk)
%       handles.ppmMode

% stm=find( signal.stim >0 );
% mstm=find(signal.modstim>0);
% 
% stmMax=max(signal.stim)
% [stmM,stmN]=size(stm)

smpl_pld=signal.sampleperiod;% sampling period [ms]

stmMax=max(signal.stim);    % stmMax = 3 ???mark ? C ???????? A,B,C ??? A,C ??? B,C ??? C ??
if stmMax <= 0              % Mark??
  errordlg('No Mark');
else
  % === Preprocessing : Butter worth Distal Filtering ===
  %                     hpf=frflt(ii*2-1);lpf=frflt(ii*2);
  %                     hpf=0.02;lpf=1.00;
  if exist('butter')==0 
    warndlg(...
	sprintf('%s\n\t%s\n',...
		'No butter worth : There is no function ''butter''', ...
		' Use FFT'),' Debug Mode');
    
    data0=fft(signal.chb(:,:,3),[],1); % fft
    a=length(data0);
    data0([1:ceil(a*0.1)  fix(a*0.8):end],:,:)=0;
    data=ifft(data0,[],1);
    clear data0, a;
    data=real(data);
    axes(handles.axes1);
  else
    hpf=str2num(get(handles.hp_freq,'String'));lpf=str2num(get(handles.lp_freq,'String'));
    [b,a]=ot_butter(hpf,lpf,10,5,'bpf');%Use 5 degree
    data=ot_filtfilt(signal.chb(:,:,3),a,b,1);
    %                     size(data)
  end 
  
  % Plot Butter Worth By Black 
  plot(data(:, str2num(get(handles.edtChnl, 'String'))),'k');
  
  % Start Time Check;
  st_time=str2num(get(handles.pltsig_starttime,'String'))*1000/smpl_pld;
  ed_time=str2num(get(handles.pltsig_endtime,'String'))*1000/smpl_pld;
    stmKind=1;
	
	motionByChannel= get(handles.motion_by_c_cbx,'Value');
	blkmk=cell(signal.chnum, stmMax); % For Block-Data Motion Check Flag, by each Channel.
	% == Stim Kind Loop ==
	mode=get(handles.ppmMode, 'Value');
    while stmKind<=stmMax
		
		% --- Indexing  Stim Kind ---
%         stm=isempty(find(signal.stim==i));
%         while stm
        stm=find(signal.stim==stmKind);
        while isempty(stm)
            stmKind=stmKind+1;
            stm=find(signal.stim==stmKind);
%             stm=isempty(find(signal.stim==i));
        end
%         stm=find(signal.stim == i);


        
   		% --- Get  Stim Kind Information ---
		switch mode   % Change by M.Shoji 08-Dec-2004
			case {1}%Single
                tmp=[stm(:)'; stm(:)'];
                stm=tmp(:);
			case {2}%Set
			otherwise
				error(' Program Error : Mark Information Mode Error');
		end		
        
        [stmM,stmN]=size(stm);      % example [10,1]        
 		blk_num=floor(stmM/2);



% 		% ===== Old Code  ======
%                 Add : Check by channel
%                      Changed By M. Shoji 08-Dec-2004
%
%         for ii=1:blk_num
% %             chk_ori=signal.chb((stm(2*ii-1)-st_time):(stm(2*ii)+ed_time),:,3);  % pre,post???????????%             chk_ori=data((stm(2*ii-1)-st_time):(stm(2*ii)+ed_time),:);  % pre,post???????????%             [chkX,chkY]=size(chk_ori);     % ?????u??????????????
%             if get(handles.sd_3sigma,'Value')
%                 chkStd=3*std(data,0,1);
% %                 size(chkStd)
%                 c_base_pre=repmat(chkStd,[1 1 chkX-2]);                  % ?????????[mMmm]
% %                 size(chk_base_pre)
%                 chk_base=squeeze(permute(chk_base_pre,[3 1 2]));
% %                 size(chk_base)
%             else
%                 chk_base = str2num(get(handles.chkBase,'String'));  % ?????????[mMmm]
%             end
% 
%             chk_1=chk_ori(1:(chkX-2),:);      % ?????u???????????????????200msec??????z?
% %             size(chk_1)
%             chk_2=chk_ori(3:chkX,:);          % ?????u???????????????????200msec??????z?
%             chkAns=abs((chk_1-chk_2))>chk_base; % ??????????200msec????????????????
%             if ~isempty(find(chkAns))
%                 plot(stm(2*ii-1):stm(2*ii),(m1-m2)+m2-0.5*i,'rx');
% %                 msgbox('Motion Artifact !!');
%             else
% %                 msgbox('OK');
%             end
% %             for iii=1:signal.chnum
% %                 chk_max=max(signal.chb(stm(2*ii-1):stm(2*ii),iii,3));
% %                 chk_min=min(signal.chb(stm(2*ii-1):stm(2*ii),iii,3));
% %                 if (chk_max - chk_min < chk_base)
% %                     msgbox('OK');
% %                 else
% %                     
% %                     %msgbox('Motion Artifact !!');
% %                 end 
% %             end
%         end
% 		%%%%%%%%


        for ii=1:blk_num
			% --- Get Block Data Time-Range ---
			% blk_stime is Start Time of the Block Data
			% blk_etime is End   Time of the Block Data
    		blk_stime=stm(2*ii-1)-st_time;
			blk_etime=stm(2*ii)+ed_time;

			% Check Memory Bound Array
			if blk_stime<=0, blk_stime=1;end
			if blk_etime>size(signal.chb,1), blk_etime=size(signal.chb,1);end
			
			% --- Get Check Data (Original)  ---
			chk_ori=data(blk_stime:blk_etime,  :);  % signal.chb ? data ?
			chksize=size(chk_ori);

			% Get Motion Check Standard-Value 
			% ( data is Butterworth-Filtered Data )
            if get(handles.sd_3sigma,'Value')
                chkStd=3*std(data,0,1);
                chk_base_pre=repmat(chkStd,[1 1 chksize(1)-2]);
                chk_base=squeeze(permute(chk_base_pre,[3 2 1]));
            else
                chk_base = str2num(get(handles.chkBase,'String'));  % ?????????[mMmm]
            end

            chk_1=chk_ori(1:end-2,:,:);      % ?????u???????????????????200msec??????z?
            chk_2=chk_ori(3:end,:,:);          % ?????u???????????????????200msec??????z?
            chkAns=abs((chk_1-chk_2))>chk_base; % ??????????200msec????????????????
			
			% --- Plot Error ---
			if ~isempty(find(chkAns)) % Is there Motion ? 
				% There is Motion 
				if motionByChannel==0  || ... 
						~isempty(find(chkAns(:,str2num(get(handles.edtChnl, 'String')),:)))
					plot(blk_stime:blk_etime,m1,'rx');
				end
			end
			
			% --- Set blkmk ---
			if motionByChannel==1
				for chnl_id=1:signal.chnum
					if isempty(find(chkAns(:,chnl_id,:) ) )
						blkmk{chnl_id, stmKind} = ...
                            [blkmk{chnl_id,stmKind}; ....
                                blk_stime, ...
                                stm(2*ii-1), stm(2*ii), ...
                                blk_etime];
					end
				end 
			end
        end  % Block Number Loop
		stmKind=stmKind+1;
        
	end   % Stim Kind Loop
	if motionByChannel==1
		setappdata(gcf, 'MotionBlockMark',blkmk);
		if ~isempty(blkmk)
			set(handles.motion_state_psb,'Visible','on');
		else
			msgbox(' No Available Data', 'Motion Check Result');
			set(handles.motion_state_psb,'Visible','off');
		end			
	end
end

switch mode
case {1}%Single
	tg=find(signal.stim>0 & signal.modstim>0);
	if isempty(tg)==0,plot(tg,m1,'go');end
	tg=find(signal.stim>0 & signal.modstim==0);
	if isempty(tg)==0,plot(tg,m1,'mx');end

	tg=find(signal.stim>0);
	y=0;
    
case {2}%Set
	tg=find(signal.modstim>0);
	y=zeros(1,signal.datanum);
	for i0=1:2:size(tg,1)-1
		y(1, tg(i0):tg(i0+1))=signal.modstim(tg(i0));
	end	
	plot(y+m2,'k:')
end	

text(tg,repmat(m1,size(tg)),num2str((1:size(tg,1))'))
varargout={y,m1,m2};

% Select mark
st=get(handles.lbxMarker, 'String');
tg=get(handles.lbxMarker, 'Value');
selmark=[];
for i0=tg
	s=st{i0};
	n=sscanf(s,'%s [%02d] <%d> %d - [%02d] <%d> %d');
	if ( size(n,1)~=9 )
		%Event	
		selmark=[selmark i0];
	else %Block
		n=n(3:end);
		selmark=[selmark n(4):(n(7)-n(4))/10:n(7)];
	end
end
plot(selmark,(m1-m2)+m2,'b.');
% ---



% --- Executes on button press in motion_state_psb.
function motion_state_psb_Callback(hObject, eventdata, handles)
% hObject    handle to motion_state_psb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% blkmk{chnl_id, stmKind} = ...
% [blkmk{chnl_id,stmKind}; ....
% blk_stime, ...
% stim(2*ii-1), stim(2*ii), ...
% blk_etime];
blkmk=getappdata(gcf, 'MotionBlockMark');
if isempty(blkmk)
	errordlg(' No Motion Check Result');
	return;
end

s= zeros(size(blkmk));
totalnum=0;

for ch=1: size(blkmk,1)    % Channel Loop
    for stmkind=1:size(blkmk,2)
        if isempty(blkmk{ch,stmkind})
            s(ch,stmkind)=0;
        else
	        s(ch,stmkind)=size(blkmk{ch,stmkind},1);
        end
        totalnum=totalnum+s(ch,stmkind);
    end
end
if totalnum==0
    msgbox(sprintf('No Available Data'), ...
        'Motion Check Result');
    return;
end

h0=figure;
bar(s,'stacked');
set(h0,...
    'NumberTitle','off', ...
    'Name',' Motion Check Result',...
    'Color',[0.8, 0.8, 0.2]);
title(' Motion Check Result');
xlabel(' Channel Number ');
ylabel(' Available Data Number');
return;

% --------------------------------------------------------------------
function varargout = sd_3sigma_Callback(h, eventdata, handles, varargin)

if get(h,'value')
	% checked
	set( handles.chkBase, 'enable', 'off');
else
	% unchecked
	set( handles.chkBase, 'enable', 'on');
end



%-------------------------
% --------------------------------------------------------------------
function varargout = datcnt_lsb_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = listbox5_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = popupmenu6_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = popupmenu8_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = popupmenu11_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edit3_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edit4_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edit17_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edit19_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edit21_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edit22_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edit23_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = rlx_edt_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = edtFitting_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = checkbox12_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = checkbox16_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = checkbox17_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = checkbox18_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = checkbox19_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = checkbox20_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = checkbox21_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = hp_freq_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = lp_freq_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = chkBase_Callback(h, eventdata, handles, varargin)

% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
osp_ComDeleteFcn;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


