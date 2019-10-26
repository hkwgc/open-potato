function [psn] = time_axes_position_D3(pos_data, pa_size, pa_pos, testflg)
% Make Time-Axes Position, for measure mode
%
% --------------
% Syntax:
%  [psn] = time_axes_position(measure_mode, pa_size, pa_pos, testflg)
% --------------
%   * Input
%     measure_mode :  Measure Mode Defined in ETG,
%                     1  : ETG-100 24ch (3x3)x2 mode
%                     2  : ETG-100 24ch (4x4) mode
%                     3  : ETG-7000 3x5 mode
%                    50  : ETG-7000 8x8 mode
%                    51  : ETG-7000 4x4 mode
%                    52  : ETG-7000 3x5 mode
%                    54  : ETG-4000 3x11 mode
%
%                   for Shimadzu-format ),
%                   101  : Shimadzu Format (24 ch)
%                   102  : Shimadzu Format (35 ch)
%                   103  : Shimadzu Format (45 ch)
%                   199  : Shimadzu Format (Free)
%
%                   WOT System
%                   200  : WOT-Format (2x10)
%                   201  : WOT-Format (2x8)
%                   202  : WOT-Format (2x4)
%
%     pa_size      :  Plot Area Size in Figure
%                     Normalized unit : [width height]
%                     if no pa_size,  use [1 1]
%
%     pa_pos       :  Position of Plot Area
%                     Normalized unit : [left bottom]
%                     if no pa_pos,  use [0 0]
%
%    testflg       : Test flag, if this value exist
%                    Plot Figure
%
%
%  *  Output
%     psn          :   Position of Axes
%                      Notarized
%                       Low   :  Data of Channel
%                       column : [left bottom width height]
%
% ========= Example ============
%    psn = time_axes_position(1, [1 0.6], [0 0.4], 1)
%
%      Measuremode = 1, 2-plane, of 3x3(?)
%      Plot-Axes-Area  is 100% x 60%,
%      40%  is Blank from bottom
%
% --------------
% Syntax 2:
%  [psn] = time_axes_position(header, pa_size, pa_pos, testflg)
% --------------
% Differance bettween Syntax 1 and 2 is only header,
% where header is structure of User-Command-Data
%
%  We can available following measuermode,
%  when header is correct.
%          -1   : Position Data Exist,

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create :
% $Id: time_axes_position_D3.m 180 2011-05-19 09:34:28Z Katura $
%
% reversion 1.1:
%  Bug fixed by hisa
%
% reversion 1.2:
%
%  Multiprobe view
%
% reversion 1.3:
%  Axes Size Change.
%
% reversion 1.4:
%  Modify Comment.
%
% Revision 1.12:
%   Bugfix : Measuremode 199
%
% Revision 1.14:
%   Bugfix : MF_060718_1 : Axes-Size of Measure-Mode -1
%            (Same Size)
%
% Revision 1.22 :
%   Add-Mode 200 : for 2x10 WOT-Format


if isstruct(pos_data),
  measure_mode = pos_data.measuremode;
else
  measure_mode = pos_data;
end

% ===========================
% Definition of Size of Mode
% ===========================
SZ_MODE1   = [0.13   0.15];
SZ_MODE2   = [0.18   0.08];
SZ_MODE3   = [0.15   0.15];

SZ_MODE50  = [0.1    0.05];
% SZ_MODE51  = [0.18   0.08];
% SZ_MODE52  = [0.15   0.15];
% SZ_MODE54  = [0.15   0.15];

SZ_MODE101 = [0.1 0.18];

% ===========================
% Channel Position Setting &
%  Size Selecting
% ===========================
% See also: MAKE_BASE
%   [x, y, sz] = make_base(parea, sizex, sizey)

switch measure_mode

  case 50
    % ------------------
    % ETG-7000 8x8 mode
    % ------------------
    % [x, y, sz] = make_base(0.8, 8, 15)

    x{1} = [0.0875 0.2125 0.3375 0.4625 0.5875 0.7125 0.8375];
    x{2} = [0.0250    0.1500    0.2750    0.4000    0.5250 ...
      0.6500    0.7750    0.9000];
    y    = [0.9467    0.8800    0.8133    0.7467    0.6800 ...
      0.6133    0.5467    0.4800    0.4133    0.3467 ...
      0.2800    0.2133    0.1467    0.0800    0.0133];
    [x, y, sz] = check_xy(x, y, SZ_MODE50);
    psn=etgform(x, y); % ETG pattern position maker

  case {2, 51}
    % ------------------
    % ETG-100 24ch (4x4) mode &&
    % ETG-7000 4x4 mode
    % ------------------
    % [x, y, sz] = make_base(0.8, 4, 7)
    x{1} = [0.1750    0.4250    0.6750];
    x{2} = [0.0500    0.3000    0.5500    0.8000];
    y    = [0.8857    0.7429    0.6000 ...
      0.4571    0.3143    0.1714  0.0286];
    [x, y, sz] = check_xy(x, y, SZ_MODE2);
    psn=etgform(x, y); % ETG pattern position maker

  case {3, 52}
    % ------------------
    % ETG-100 22ch (3x5) mode
    % ETG-7000 3x5 mode
    % ------------------
    % [x, y, sz] = make_base(0.8, 5, 5)
    x{1} = [0.1400    0.3400    0.5400    0.7400];
    x{2} = [0.0400    0.2400    0.4400    0.6400    0.8400];
    y    = [ 0.8400    0.6400    0.4400    0.2400    0.0400];
    [x, y, sz] = check_xy(x, y, SZ_MODE3);
    psn=etgform(x, y); % ETG pattern position maker

  case {53}
    [x, y, sz] = make_base(0.8, 3, 9);
    [x, y, sz] = check_xy(x, y, sz);
    psn=etgform(x, y); % ETG pattern position maker

  case {54}
    % ------------------
    % ETG-4000 3x11 mode?
    % ------------------
    [x, y, sz] = make_base(0.8, 11, 5);
    % sz = SZ_MODE54;
    %x{1} = [0.1400    0.3400    0.5400    0.7400];
    %x{2} = [0.0400    0.2400    0.4400    0.6400    0.8400];
    % y    = [ 0.8400    0.6400    0.4400    0.2400    0.0400];
    [x, y, sz] = check_xy(x, y, sz);
    psn=etgform(x, y); % ETG pattern position maker

  case 1
    % ------------------
    % ETG-100  24ch (3x3)x2 mode
    % ------------------
    % [x, y, sz] = make_base(0.8, 6, 4)
    %   --> Modify

    % ( Bug Code detected by hisa )
    % hisa delete 05/07/05
    %   x{1} = [0.1163    0.2830              0.6170    0.7837];
    %   x{2} = [0.0330    0.1997    0.3663    0.5337    0.7003    0.8670];

    % hisa modefy 05/07/05
    x{1} = [0.1163    0.2830];
    x{2} = [0.0330    0.1997    0.3663];
    xx{1} = [0.6170    0.7837];
    xx{2} = [0.5337    0.7003    0.8670];

    y    = [0.8400    0.6400    0.4400    0.2400    0.0400];
    [x, y, sz] = check_xy(x, y, SZ_MODE1);
    [xx, y]    = check_xy(xx,y);
    psn=etgform(x, y, xx); % ETG pattern position maker

  case 101,
    % ------------------
    % Shimadzu Format Ch=24
    % ------------------
    sz = SZ_MODE101;

    % ( transpose of case 2 so copyfrom there)
    ytmp = [0.1750    0.4250    0.6750];
    y{1} = ytmp(end:-1:1);
    ytmp = [0.0500    0.3000    0.5500    0.8000];
    y{2} = ytmp(end:-1:1);
    x    = [0.8857    0.7429    0.6000 ...
      0.4571    0.3143    0.1714  0.0286];
    x=x(end:-1:1);
    tsz = [sz(2) sz(1)];
    [y, x, tsz]=check_xy(y, x, tsz);
    sz  = [tsz(2) tsz(1)];
    % update size
    lid  = 1;
    psn  = [];
    for x2 = x,
      psn = [psn;  repmat(x2, length(y{lid}), 1), y{lid}'];
      % Change Line
      lid = lid + 1;
      if lid > length(y), lid = 1; end
    end

    %     case 102,
    %       % ------------------
    %       % Shimadzu Format (Ch=35)
    %       % ------------------
    %       ch_num=35;
    %       height0 = 0.9/ch_num;
    %       sz=[0.8, height0*0.8]; % insert space of each axes
    %       psn=zeros(ch_num,2);
    %       for ii=1:ch_num
    %         psn(ii,:)=[0.1, 0.95-height0*ii];
    %       end

  case 103,
    % ------------------
    % Shimadzu Format (Ch=45)
    % ------------------
    %ch_num=45;
    width0  = 0.9/13;
    height0 = 0.9/4;
    sz=[width0*0.9, height0*0.8]; % insert space of each axes
    %x{1} = width0 * [1:2:11] + 0.08;
    %x{2} = width0 * [0:2:12] + 0.08;
    %y    = [3:-0.5:0]*height0 + 0.1;
    x{1}=width0+0.08:2*width0:11*width0+0.08;
    x{2}=0.08:2*width0:12*width0+0.08;
    y    = 3*height0+0.1:-height0/2:0.1;

    [x, y, sz]=check_xy(x, y, sz);
    psn=etgform(x, y); % ETG pattern position maker

  case {199,102}
    % ------------------
    % Shimadzu Format (Free Format)
    % ------------------
    if measure_mode==102
      ch_num=35;
    else
      if ~isstruct(pos_data)
        error('OSP Error!!  <<Not suported data>>');
      end
      ch_num=size(pos_data.flag,3);
    end
    g = ceil(sqrt(ch_num*2));
    if mod(g,2)~=0,
      g=g+1; % Even
      if g*g/2 > ch_num,
        g=g-1; % Odd
      end
    end
    x0=linspace(0,0.9,g+1);
    sz(1)=x0(2)-x0(1);
    sz(2)=sz(1);
    sz   =sz*0.9;
    psn=[];

    p=1;
    n=1; m=1; % set parity: here
    for idx=1:ch_num
      psn(end+1,:)=[x0(n), x0(g+1-m)];
      n=n+2;
      if n>g,
        n=1+p;
        m=m+1;
        if p==1,
          p=0;
        else
          p=1;
        end
      end
    end

  case 200,
    % ------------------
    % WOT Format [2x10]
    % ------------------
    ch_num=28;
    psn=zeros(ch_num,2);
    width0  = 0.9/19;
    height0 = 0.9/3;

    sz=[width0*0.9, height0*0.8]; % insert space of each axes
    x =  0:18;   x = (x+0.05)*width0;
    y =  2:-1:0; y = (y+0.1) *height0;

    psn(1:3:28)=x(1:2:19);
    psn(2:3:26)=x(2:2:18);
    psn(3:3:27)=x(2:2:18);
    psn(1:3:28,2)=y(2);
    psn(2:3:26,2)=y(1);
    psn(3:3:27,2)=y(3);

  case 201,
    % ------------------
    % WOT Format [2X8]
    % ------------------
    ch_num=22;
    width0  = 0.9/15;
    height0 = 0.9/3;
    sz=[width0*0.9, height0*0.8]; % insert space of each axes
    % x = width0 * [0:14] + 0.08;
    % y = [2:-1:0]*height0 + 0.1;
    x= 0.08:width0:14*width0+0.08;
    y = 2*height0+0.1:-height0:0.1;

    psn=zeros(ch_num,2);
    psn(1:3:22)=x(1:2:15);
    psn(2:3:20)=x(2:2:14);
    psn(3:3:21)=x(2:2:14);
    psn(2:3:20,2)=y(1);
    psn(1:3:22,2)=y(2);
    psn(3:3:21,2)=y(3);


  case 202,
    % ------------------
    % WOT Format [2X4]
    % ------------------
    ch_num=10;
    width0  = 0.9/7;
    height0 = 0.9/3;
    sz=[width0*0.9, height0*0.8]; % insert space of each axes
    %x = width0 * [0:6] + 0.08;
    %y = [2:-1:0]*height0 + 0.1;
    x=0.08:width0:6*width0+0.08;
    y=2*height0+0.1:-height0:0.1;
    psn=zeros(ch_num,2);
    psn(1:3:10)=x(1:2:7);
    psn(2:3:8)=x(2:2:6);
    psn(3:3:9)=x(2:2:6);
    psn(2:3:8,2)=y(1);
    psn(1:3:10,2)=y(2);
    psn(3:3:9,2)=y(3);

  case -93,
    % ------------------
    % OLD ::: Not in use :::
    % ------------------
    if ~isstruct(pos_data)
      error('OSP Error!!  <<Not suported data>>');
    end
    ch_num=size(pos_data.flag,3);
    height0 = 0.9/ch_num;
    sz=[0.8, height0*0.8]; % insert space of each axes
    psn=zeros(ch_num,2);
    for ii=1:ch_num
      psn(ii,:)=[0.1, 0.95-height0*ii];
    end


  case -1,
    % =====================
    % == More Probe Mode ==
    % =====================
    % make sz & psn
    if ~isstruct(pos_data) || ~isfield(pos_data,'Pos'),
      error('OSP Error!!  <<Lack of Position Data to Input Data>>');
    end

    % ** Position Setting **
    psn = pos_data.Pos.D2.P;
    sz = 5; %<- Cercle size
    psn = [psn; psn+sz];
    psz0=size(psn);
    % normarized
    ch_num = size(psn,1);
    psn  = psn  - repmat(min(psn),[ch_num,1]);
    if max(psn)~=0,
      %pp=max(psn);
      pp=max(psn(:));
      %psn  = psn ./ repmat(pp,[ch_num,1]);
      psn  = psn /pp;
    else
      pp=sz/2;
    end
    % y-reversing
    % psn(:,2) = 1-psn(:,2);
    psn=psn(1:psz0(1)/2,:);
    %sz=repmat([sz, sz]./pp,[ch_num/2,1]);
    sz=repmat([1,1] * (sz/pp),[ch_num/2,1]);

    % ** margin set **
    mgn  = 0.03;
    psn  = (mgn+ psn)/(1+min(sz(:,1))+mgn*2);

  otherwise
    if 0
      warndlg({'No Mode exist, cannot determine x, y, sz', ...
        ' cf: [x, y, sz] = make_base(parea, sizex, sizey)'});
    end
    %    OSP_LOG('perr','No Mode exist, cannot determine x, y, sz',...
    %	    ' cf: [x, y, sz] = make_base(parea, sizex, sizey)');
    % example
    %disp(' -- Example --');
    %[x, y, sz] = make_base(0.8, 4, 3);
    if isstruct(pos_data),
      pos_data.measuremode=199;
      switch nargin
        case 1,
          [psn] = time_axes_position_D3(pos_data);
        case 2,
          [psn] = time_axes_position_D3(pos_data, pa_size);
        case 3,
          [psn] = time_axes_position_D3(pos_data, pa_size, pa_pos);
        otherwise
          [psn] = time_axes_position_D3(pos_data, pa_size, pa_pos, testflg);
      end
      return;
    else
      error([' Program Error : Not assined Mode.' ...
        '  Change preprocessor | Set Measure Mode here']);
    end
    return;
end


% ==== Set width & height ====
if measure_mode==-1,
  psn  = [psn sz];
else
  psn = [psn ...
    repmat(sz(1),size(psn,1),1) ...
    repmat(sz(2),size(psn,1),1)];
end


% Change Size
if nargin >= 2
  psn(:, [1 3]) =  psn(:, [1 3]) * pa_size(1);
  psn(:, [2 4]) =  psn(:, [2 4]) * pa_size(2);
end

% ==== Carnage Position ====
if nargin >= 3
  psn(:,1) = psn(:,1) + pa_pos(1);
  psn(:,2) = psn(:,2) + pa_pos(2);
end

% ==== Data Check  ====
if nargin >= 4, % if exist testflag, plot test
  h=figure;
  set(h, 'Unit', 'normalized');
  chid=1;
  for lpsn = psn'
    subplot('position', lpsn);
    h=fill([0; 1; 0.5; 0] , [0, 0, 1, 0],[1, .8, .8] );
    set(h,'EdgeColor', [1, .8, .8] );
    text(0.2, 0.5,sprintf('ch%d',chid ));
    chid= chid+1;
  end
end

return;

function psn=etgform(x, y, xx)
% === Make Potision ===
% for reshape ..
lid  = 1;
psn  = [];
for y2 = y
  psn = [psn; x{lid}', repmat(y2, length(x{lid}), 1)];
  % Change Line
  lid = lid + 1;
  if lid > length(x), lid = 1; end
end

% hisa modify 05/07/05
if exist('xx','var'), % need 2nd-Probe
  lid  = 1;
  for y2 = y
    psn = [psn; xx{lid}', repmat(y2, length(xx{lid}), 1)];
    % Change Line
    lid = lid + 1;
    if lid > length(xx), lid = 1; end
  end
end

return;

% ==== Function for Make x, y, sz ======
function [x, y, sz] = make_base(parea, sizex, sizey)
% parea   : Rate of Plot Axes Area : if 0.8 , 80%
% sizex   : Divide Number along x axis
% sizey   : Divide Number along y axis

sizex2=parea/sizex; sizey2=parea/sizey;  % Real Plot Size
sz = [sizex2 sizey2];

y=(sizey-1):-1:0; y= y+(1-parea);
y=y./sizey;

x_tmp(2,:) = 0:(sizex-1);
x_tmp(2,:) = x_tmp(2,:)  + (1-parea); % Normal Size
x_tmp(1,:)=x_tmp(2,:) + 0.5;

x_tmp=x_tmp./sizex;

x{1} = x_tmp(1,1:end-1);
x{2} = x_tmp(2,:);

return;

function [x, y, msize]=check_xy(x, y, msize)
if nargin<3, msize=[];end

if iscell(x),dx  = x{1}(2)-x{1}(1);end
if ~iscell(x),dx  = x(2)-x(1);end
dy2 = (y(2)-y(1))*2;
adx  =abs(dx);
ady2 =abs(dy2);

if ady2<adx,
  if dx<0,
    dx = -ady2;
  else
    dx = ady2;
  end
  if iscell(x),
    xp0=x{1}(1);
    xp0m = xp0*0.9;
    for i=1:length(x),
      if x{i}(1) < xp0m
        xp = xp0 - dx/2; %disp('M');
      elseif x{i}(1) > xp0*1.1
        xp = xp0 + dx/2; %disp('P');
      else
        xp  = xp0; %disp('N');
      end
      for ii=1:length(x{i}),
        x{i}(ii)=xp;
        xp=xp+dx;
      end
    end
  else
    xp  = x(1);
    for ii=2:length(x),
      xp=xp+dx;
      x(ii)=xp;
    end
  end
  if nargin>2, msize(1) = msize(1)*ady2/adx*0.9;end
end
if ady2>adx,
  if dy2<0,
    dy2 = -adx;
  else
    dy2 = adx;
  end
  yp  = y(1);
  for i=2:length(y),
    yp=yp+dy2/2;
    y(i)=yp;
  end
  if nargin>2, msize(2) = msize(2)*adx/ady2*0.9;end
end
return;
