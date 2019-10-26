function scriptMevalin(fname)
% Evaluate Script M-File and assign to Work-Space (base)
%
% Syntax:
%  scriptMevalin(fname)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2007.12.03
% $Id: scriptMevalin.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision : 1.1
%   Export form scriptMeval (r1.7)

if nargin<1,
	error('too few arguments');
end
[p fname e] = fileparts(fname);
if ~strcmpi(e,'.m'),
	error('Not a Script M-File');
end
clear e;

cwd = pwd;
% --> Always breke OSP_DATA in R2006a
cd(p); clear p;
try
  %rehash TOOLBOX
  rehash
  if length(fname)>=5 && strcmpi(fname(1:5),'mult_')
    multimode=true;
  elseif length(fname)>=6 && strcmpi(fname(1:6),'batch_')
    multimode=true;
  else
    multimode=false;
  end

  %--------------
  % Evaluate !!
  %--------------
  if multimode
    [data,hdata]=eval([fname ';']);
    assignin('base','data',data);
    assignin('base','hdata',hdata);
  else
    eval(fname);
    a=who;
    a=setdiff(a,{'p','multimode','cwd','fname'});
    if 0
      vl=cell(size(a));
      for i=1:length(a)
        vl{i}=eval(a{i});
      end
      [h,o]=export2wsdlg(a,a,vl,'Select Export Data');
      if 0, uiwait(h);end
      % --> include cancel
      if 0 && ~o,error('Export Error');end
    else
      for i=1:length(a)
        assignin('base',a{i},eval(a{i}));
      end
    end
  end
catch
  % Waiting MALTAB find Script M-File,
  cd(cwd);
  rethrow(lasterror);
end
cd(cwd);
