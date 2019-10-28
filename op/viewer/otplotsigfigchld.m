function [varargout]=otplotsigfigchld(varargin)
% This function automatically check the type of loaded file.
% fnumh: the handle number of list box including processed files
% fkh: the handle number of Popup menu to indicate file type
%
%
%
%
%
%Sep. 23rd, 2002 Maki
%=========================================================


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



h(3)=findobj(gcf,'Tag','frqflt_valu');
h(4)=findobj(gcf,'Tag','flttyp_value');
h(5)=findobj(gcf,'Tag','frqrng_value');
h(7)=findobj(gcf,'Tag','pltexe_btn');
h(10)=findobj(gcf,'Tag','datcnt_lsb');

set(h(7),'enable','on');

flag=0;%0 = all files in a directroy, 1 = a file in a directory

t=cputime;

%Set input filenames
fdum=get(h(10),'String');     
fnms=fdum(2:end);
pthnm=char(strcat(fdum(1),filesep));
fnnum=length(fnms);

for ii=1:fnnum,

    load(strcat(pthnm,char(fnms{ii})))
    setappdata(gcf,'signal',signal);
    
    fldnm=fieldnames(signal);
    fld_num=length(fldnm);
    
    for jj=1:fld_num,
        a=getfield(signal,fldnm{jj});        
        if isnumeric(a),
            b=size(a);
            if b(1)==1 & b(2)==1,
                a=num2str(a);
            elseif strcmp(fldnm{jj},'age'),
                a=num2str(a(1));
            else
                a=num2str(b);
                a=strcat('[',a,']');
            end            
        end
% ---------------------------------------------
% Modified by Dohi,Neorium 
% Not to show the information of the field 'stimkind' or 'modstimkind'
        if ~(strcmp(fldnm{jj},'stimkind') | strcmp(fldnm{jj},'modstimkind'))
            fldnm{jj}=strcat(fldnm{jj},':  ',char(a));
        end
% ---------------------------------------------
    clear a, b;
    end
    
    set(h(10),'String',fldnm);       

end

cputime-t;
