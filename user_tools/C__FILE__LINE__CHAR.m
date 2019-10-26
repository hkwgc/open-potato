function info = C__FILE__LINE__CHAR(fmt)
% Get M-File Line Information Charactor
%
% See also DBSTACK

% Modify : to display file and function name
% $Id: C__FILE__LINE__CHAR.m 393 2014-02-03 02:19:23Z katura7pro $

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin<1
	fmt=0;
end

try
	st = dbstack;
	st0=st;
	if length(st)<2
		info = sprintf(' * Call from base');
	else
		st=st(2);
		if ~isfield(st,'file')
			% MATLAB 6.5.1
			id=findstr(st.name,'(');
			if ~isempty(id)
				id=id(1);
				st.file=st.name(1:id-2)';
				st.name=st.name(id+1:end-1)';
			end
		end
		switch fmt
			case 0
                if 0
                    info = ...
                        sprintf(' * <a href="matlab:opentoline(which(''%s''),%d)">%s(%s) : %4d</a>',...
                        st.file, st.line, st.file, st.name, st.line);
                else
                    info = ...
                        sprintf(' * <a href="matlab:opentoline(''%s'',%d)">%s(%s) : %4d</a>',...
                        which(st.file), st.line, st.file, st.name, st.line);
                end
			otherwise
				if fmt==inf, fmt=length(st);end
				for k=2:length(st0);
					info{k-1} = ...
						sprintf(' * %s(%s) : %4d',st0(k).file, st0(k).name, st0(k).line);
				end
				if fmt==1
					info=info{1};
				end
		end
	end
catch
	info = lasterr;
end
return;
