function [psn] = time_axes_positionCell(header, pa_size, pa_pos, testflg)
% Make Time-Axes Position, for measure mode
%
%  [psn] = time_axes_position(header, pa_size, pa_pos, testflg)
%   * Input: header : 
%        User Command Data
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
  

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% [x, y, sz] = make_base(parea, sizex, sizey)  

  if isfield(header,'Pos'),
  else
    psn = time_axes_position(header.measur_mode);
  end
  switch measure_mode
   case 50 % ETG-7000 8x8 mode

    % [x, y, sz] = make_base(0.8, 8, 15)
    sz = [0.1 0.05];
    
    x{1} = [0.0875 0.2125 0.3375 0.4625 0.5875 0.7125 0.8375];
    x{2} = [0.0250    0.1500    0.2750    0.4000    0.5250 ...
	    0.6500    0.7750    0.9000];
    y    = [0.9467    0.8800    0.8133    0.7467    0.6800 ...
	    0.6133    0.5467    0.4800    0.4133    0.3467 ...
	    0.2800    0.2133    0.1467    0.0800    0.0133];
    psn=etgform(x, y); % ETG pattern position maker

   case {2, 51} 
    % ETG-100 24ch (4x4) mode &&
    % ETG-7000 4x4 mode

    % [x, y, sz] = make_base(0.8, 4, 7)
    sz = [0.18 0.08];

    x{1} = [0.1750    0.4250    0.6750];
    x{2} = [0.0500    0.3000    0.5500    0.8000];
    y    = [0.8857    0.7429    0.6000 ...
	    0.4571    0.3143    0.1714  0.0286];
    psn=etgform(x, y); % ETG pattern position maker

   case {3, 52} 
    % ETG-100 22ch (3x5) mode 
    % ETG-7000 3x5 mode

    % [x, y, sz] = make_base(0.8, 5, 5)
    sz = [0.1500    0.1500];
   
    x{1} = [0.1400    0.3400    0.5400    0.7400];
    x{2} = [0.0400    0.2400    0.4400    0.6400    0.8400];
    y    = [ 0.8400    0.6400    0.4400    0.2400    0.0400];
    psn=etgform(x, y); % ETG pattern position maker

   case 1 
    % ETG-100  24ch (3x3)x2 mode

    % [x, y, sz] = make_base(0.8, 6, 4)
    %   --> Modify
    sz   = [0.13      0.1500];
 % hisa delete 05/07/05
 %   x{1} = [0.1163    0.2830              0.6170    0.7837];
 %   x{2} = [0.0330    0.1997    0.3663    0.5337    0.7003    0.8670];
 
 % hisa modefy 05/07/05
    x{1} = [0.1163    0.2830];
    x{2} = [0.0330    0.1997    0.3663];
    xx{1} = [0.6170    0.7837];
    xx{2} = [0.5337    0.7003    0.8670];
 
    y    = [0.8400    0.6400    0.4400    0.2400    0.0400];
    psn=etgform(x, y, xx); % ETG pattern position maker

    % == Set Shimadzu Format Position Here ==
   case 101,
    sz = [0.1 0.18];
    % ( transpose of case 2 so copyfrom there) 
    ytmp = [0.1750    0.4250    0.6750];
    y{1} = ytmp(end:-1:1);
    ytmp = [0.0500    0.3000    0.5500    0.8000];
    y{2} = ytmp(end:-1:1);
    x    = [0.8857    0.7429    0.6000 ...
	    0.4571    0.3143    0.1714  0.0286];
    x=x(end:-1:1);
    
    lid  = 1;
    psn  = []; 
    for x2 = x,
      psn = [psn;  repmat(x2, length(y{lid}), 1), y{lid}'];
      % Change Line
      lid = lid + 1;
      if lid > length(y), lid = 1; end
    end


   otherwise
    errordlg({'No Mode exist, cannot determine x, y, sz', ...
	      ' cf: [x, y, sz] = make_base(parea, sizex, sizey)'});
    OSP_LOG('perr','No Mode exist, cannot determine x, y, sz',...
	    ' cf: [x, y, sz] = make_base(parea, sizex, sizey)');
    % example
    disp(' -- Example --');
    [x, y, sz] = make_base(0.8, 4, 3)
    return;
  end


  % ==== Set width & height ====
  psn = [psn repmat(sz(1),size(psn,1),1) repmat(sz(2),size(psn,1),1)];

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
    figure;
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

function psn=etgform(x, y, xx),
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
