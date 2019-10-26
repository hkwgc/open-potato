function [r_bp,mrk,opt]=BlockPeriodInputdlg(bp, title,mrk,opt)
% Input Dialog of Time-Blocking 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% $Id: BlockPeriodInputdlg.m 180 2011-05-19 09:34:28Z Katura $
%-mod by TK 20101220

if nargin<1 || isempty(bp), bp=[5,15]; end
if nargin<2, title=''; end

r_bp=[];

% -- Set Pre-Post Stimulation Data --
if nargin==3
  prompt ={'Relaxing time of Pre-Stimulation [sec].', ...
    'Relaxing time of Post-Stimulation. [sec]',...
    'Using Marker'};
  if isnumeric(mrk)
    def={num2str(bp(1)), num2str(bp(2)) ,num2str(mrk)};
  else
    def={num2str(bp(1)), num2str(bp(2)) ,mrk};
  end
  
elseif nargin==4
	prompt ={'Relaxing time of Pre-Stimulation [sec].', ...
    'Relaxing time of Post-Stimulation. [sec]',...
    'Using Marker','(Option)'};
  if isnumeric(mrk)
    def={num2str(bp(1)), num2str(bp(2)) ,num2str(mrk)};
  else
    def={num2str(bp(1)), num2str(bp(2)) ,mrk};
  end
  def{end+1}=opt;
  
else
  mrk='''All''';
  opt='';
  prompt ={'Relaxing time of Pre-Stimulation.', ...
    'Relaxing time of Post-Stimulation.'};
  def={num2str(bp(1)), num2str(bp(2)), mrk};
end

while 1
  def = inputdlg(prompt, ['Set Block Period' title], 1, def);
  % Cancel?
  if isempty(def), return;end

  % check data-format
  styleck1=regexp(def{1}, '^\s*[0-9.]*\s*$');
  styleck2=regexp(def{2}, '^\s*[0-9.]*\s*$');
  if isempty(styleck1) || isempty(styleck2) 
    errordlg({' Input Error : ', ...
      '   Your input Relax is outof Format.'})
    continue;
  end
  if nargin>=3,
    styleck3=regexp(def{3}, '^\s*([0-9]*\s*)*$');
    if isempty(styleck3) && ~any(strcmpi(def{3},{'all','auto'}))
      errordlg({' Input Error : ', ...
        '   Your input Marker is outof Format.'})
    continue;
    end
  end

  % check positive
  bp(1) = str2double(def{1});
  bp(2) = str2double(def{2});
  if nargin>=3,
    if styleck3
      mrk   = str2num(def{3});
    else
      mrk   = def{3};
    end
  end
  if bp(1)<0 || bp(2)<0,
    errordlg({' Input Error : ', ...
      '   Relax must be Positive.'});
    continue;
  end
  
  % update
  r_bp= bp;
  
  %- mod by TK@HARL 20110202
  if length(def)>=4
	  opt=def{4};
  else
	  opt='';
  end
  
  return;
end,  % end of while
% never reach
return;
