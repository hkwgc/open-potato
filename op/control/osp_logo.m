function osp_logo(ax,fname,bc)
% Load OSP Logo &  Plot
%  backcolor will be chaneg to the upper GUI


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original auther : Masanori Shoji
% create : 2004.10.14
% $Id: osp_logo.m 180 2011-05-19 09:34:28Z Katura $
%

% disp([mfilename ' : open, ' num2str(ax)]);
if nargin <2 || isempty(fname)
    fname=[OSP_DATA('GET','OSPPATH') filesep ...
            'ospData' filesep ...
            'osplogo.mat'];
    if fname(1)==filesep
        fname='osplogo.mat';
    end
end
    
try
    load(fname);   % Get Image : I
    I; % Check if I is exist
catch
    return;
end
        
% Color Change
if nargin==3
    try
        % Color check
        if bc(1) <= 1 && bc(2)<=1 && bc(3)<=1
            bc=round(bc*255);
        end
        
        if sum(bc==255)==3 % default is white
            return; % notneed;
        end
        
        % change Background Color
        sz=size(I);
        for xx=1:sz(1)
            for yy=1:sz(2)
                tmp=I(xx,yy,:);
                if sum(tmp(:)==255)==3
                    I(xx,yy,:) = bc;
                end
            end % dim2
        end % dim1
        
    end % try
end
            
axes(ax);
image(I); axis image; axis off;
return;
