function varargout = graph24_2pn(varargin)
% GRAPH24_TST Application M-file for graph24_tst.fig
%    FIG = GRAPH24_TST launch graph24_tst GUI.
%    GRAPH24_TST('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 24-Feb-2004 17:25:15


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'new');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
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



% --------------------------------------------------------------------
function varargout = apgcapro_psb_Callback(h, eventdata, handles, varargin)

%Get handlenumber of current axes
%ph=get(gcf);
ch=get(gcf,'Children');
graph_num=length(get(gcf,'Children'));

a=get(gca);
pnm=fieldnames(a);

for ii=1:graph_num,
    dum=get(ch(ii),'Tag');
    %    ~
    if strcmp(dum(1:4),'Axes'),
        for jj=1:length(pnm),
            if ~strcmp(pnm(jj),'BeingDeleted')&~strcmp(pnm(jj),'Children')&~strcmp(pnm(jj),'CurrentPoint')&...
                ~strcmp(pnm(jj),'Tag')&~strcmp(pnm(jj),'Title')&~strcmp(pnm(jj),'Type')&...
                    ~strcmp(pnm(jj),'XLabel')&~strcmp(pnm(jj),'YLabel')&~strcmp(pnm(jj),'ZLabel'),
                
                dum2=getfield(a,char(pnm(jj)));
                
            if strcmp(pnm(jj),'Position'),
                
                orgpr=get(ch(ii),'Position');
                dum2=[orgpr(1:2),dum2(3:4)];
                set(ch(ii),pnm(jj),{dum2});
            else
                
                set(ch(ii),pnm(jj),{dum2});
            end
            clear dum2;
        end
        end
    end
    clear dum;
end




% --------------------------------------------------------------------
function varargout = listbox1_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = radiobutton1_Callback(h, eventdata, handles, varargin)

