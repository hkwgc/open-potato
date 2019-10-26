function ydata = osp_chnl2image(ydata, probe_mode, image_mode, v_interpstep, v_interpmethod)
% function ydata = osp_chnl2image(ydata, probe_mode, image_mode,smooth,smooth method)
% IN:
%    ydata: (1, ch)
%    probe_mode: ETG100 ->  1: 3x3+3x3,  2: 4x4,  3: 3x5, 
%                ETG7000-> 50: 8x8,     51: 4x4, 52: 3x5
%                Othere -> 199,99: Unkonw Pattern
%    image_mode: 1=point, 2=interp, 3=smooth point
%    smooth: smoothing pxiel size
%    smooth method: 'linear', 'cubic', 'nearest', 'v4' ('invdist')
% OUT:
%     ydata( x, y )


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% 2005.07.19 : M.Shoji
%  probe_mode can be use, that set time_axes_position:
%  Even though, not fast code.
%
% Revision : 1.15
%    Extend  : for probe_mode 99
%    Blushup : (For M-Lint)

switch image_mode, % switch Image Mode

  case 1 % Image Mode = POINTS
    switch probe_mode
      case 50 % ETG-7000 8x8 mode
        % mask channels NOT USED for infant probe ----------------
        mtx=[ 19 26:27 33:35 40:43 46:67 69:74 77:81 85:88 93:95 101:102 109 ];
        ymask=zeros(1,112); ymask(1,mtx)=1;
        ydata=ydata.*ymask;
        %------------------------------------------------------
        dz=zeros(1,112);
        dz1=[dz ;ydata];
        dz2=reshape(dz1,[1 112*2]); dz2=[dz2 0];
        ydata=reshape(dz2,[15 15]);

      case 1 % ETG-100 24ch (3x3)x2 mode
        dz=zeros(1,12);
        dz1=[dz; ydata(1,1:12)];
        dz2=reshape(dz1, [1 12*2]);
        dz2=[dz2 0];
        dz2=reshape(dz2,[5 5]);
        dz1=[dz; ydata(1,13:24)];
        dz3=reshape(dz1, [1 12*2]);
        dz3=[dz3 0];
        dz3=reshape(dz3,[5 5]);
        ydata=[dz2' dz3']';

      case {2, 51} % ETG-100 24ch (4x4) mode && ETG-7000 4x4 mode
        dz=zeros(1,24);
        dz1=[dz ;ydata];
        dz2=reshape(dz1,[1 24*2]); dz2=[dz2 0];
        ydata=reshape(dz2,[7 7]);

      case {3, 52} % ETG-100 22ch (3x5) mode && ETG-7000 3x5 mode
        dz=zeros(1,22);
        dz1=[dz ;ydata];
        dz2=reshape(dz1,[1 22*2]); dz2=[dz2 0];
        ydata=reshape(dz2,[9 5]);

      otherwise,
        % Common
        % case 101,
        tmp = find(isnan(ydata));
        if ~isempty(tmp),
          ydata(tmp)=0;    % not plot == 0
        end

        % Dumy-header
        if probe_mode==199 || probe_mode==99
          dheader.flag=true([1, 1,size(ydata,2)]);
          dheader.measuremode=199;
          p  = time_axes_position(dheader);
        else
          p  = time_axes_position(probe_mode);
        end
        p = [p(:, 1:2), ydata'];
        x=sort(p(:,1));
        y=sort(p(:,2));
        x2= x([1; find(abs(diff(x))>0.01)+1]);
        y2= y([1; find(abs(diff(y))>0.01)+1]);
        sz00=[length(y2),length(x2)];
        csize=sz00;
        c=zeros(csize(end:-1:1));
        for index=1:size(p,1),
          xtmp = find(p(index,1)-0.010 <x2 & x2<p(index,1)+0.011);
          ytmp = find(p(index,2)-0.010 <y2 & y2<p(index,2)+0.011);
          if ~isempty(xtmp) && ~isempty(ytmp),
            c(xtmp(1),sz00(1)-ytmp(1)+1) = p(index,3);
          end
        end
        ydata  = c;

    end % end of Probe Mode Switch.
    %============================
    %============================
  case 2 % Image Mode = INTERPED
    switch probe_mode
      case 50 % ETG-7000 8x8 mode
        mtx=[19 26:27 33:35 40:43 46:67 69:74 77:81 85:88 93:95 101:102 109];
        ymask=zeros(1,112);
        ymask(1,mtx)=1;
        ydata=ydata.*ymask;

        [XI YI]=meshgrid(1:1/v_interpstep:15, 1:1/v_interpstep:15);
        x=[2:2:14 1:2:15];x=repmat(x, [1 7]); x=[x 2:2:14];
        y=inf; for i=1:15, y=[y repmat(i,1,7+mod(i+1,2))]; end; y=y(1,2:end);
        try
          ydata=griddata(x, y, ydata, XI, YI, v_interpmethod)';
        catch
          % R2006a ?
          ydata=griddata(x, y, ydata, XI, YI, v_interpmethod, ...
            {'Qt','Qbb','Qc','Qz'})';
        end
      case 1 % ETG-100 24ch (3x3)x2 mode
        [XI YI]=meshgrid(1:1/v_interpstep:6, 1:1/v_interpstep:6);
        x=[2:2:4 1:2:5 2:2:4 1:2:5 2:2:4];
        y=[ 1 1 2 2 2 3 3 4 4 4 5 5];
        try
          ydata0=griddata(x, y, ydata(1,1:12), XI, YI, v_interpmethod)';
        catch
          ydata0=griddata(x, y, ydata(1,1:12), XI, YI, v_interpmethod, ...
            {'Qt','Qbb','Qc','Qz'})';
        end
        try
          ydata1=griddata(x, y, ydata(1,13:24), XI, YI, v_interpmethod)';
        catch
          ydata1=griddata(x, y, ydata(1,13:24), XI, YI, v_interpmethod, ...
            {'Qt','Qbb','Qc','Qz'})';
        end

        ydata=[ydata0' ydata1']';

      case {2, 51} % ETG-100 24ch (4x4) mode && ETG-7000 4x4 mode
        [XI YI]=meshgrid(1:1/v_interpstep:7, 1:1/v_interpstep:7);
        x=[2:2:6 1:2:7];x=repmat(x, [1 3]); x=[x 2:2:6];
        y=inf; for i=1:7, y=[y repmat(i,1,3+mod(i+1,2))]; end; y=y(1,2:end);
        try
          ydata=griddata(x, y, ydata, XI, YI, v_interpmethod)';
        catch
          ydata=griddata(x, y, ydata, XI, YI, v_interpmethod, ...
            {'Qt','Qbb','Qc','Qz'})';
        end

      case {3, 52} % ETG-100 22ch (3x5) mode && ETG-7000 3x5 mode
        [XI YI]=meshgrid(1:1/v_interpstep:9, 1:1/v_interpstep:5);
        x=[2:2:8 1:2:9];x=repmat(x, [1 2]); x=[x 2:2:8];
        y=inf; for i=1:5, y=[y repmat(i,1,4+mod(i+1,2))]; end; y=y(1,2:end);
        try
          ydata=griddata(x, y, ydata, XI, YI, v_interpmethod)';
        catch
          ydata=griddata(x, y, ydata, XI, YI, v_interpmethod, ...
            {'Qt','Qbb','Qc','Qz'})';
        end
      otherwise,
        % Common
        % case 101,
        if probe_mode==199 || probe_mode==99
          dheader.flag=true([1, 1,size(ydata,2)]);
          dheader.measuremode=199;
          p  = time_axes_position(dheader);
        else
          p  = time_axes_position(probe_mode);
        end
        p = [p(:, 1:2), ydata'];
        tmp = find(isnan(ydata));
        if ~isempty(tmp),
          p(tmp,:)=[]; % delete ignore data.
        end
        x=sort(p(:,1));
        y=sort(p(:,2));

        x2= x([1; find(abs(diff(x))>0.01)+1]);
        y2= y([1; find(abs(diff(y))>0.01)+1]);

        x2= linspace(x(1),x(end), round(length(x2)*v_interpstep));
        df = x2(2)-x2(1);
        x2 = [x2(1)-df, x2, x2(end)+df];

        y2= linspace(y(1),y(end), round(length(y2)*v_interpstep));
        df = y2(2)-y2(1);
        y2 = [y2(1)-df, y2, y2(end)+df];

        [x3,y3]=meshgrid(x2,y2(end:-1:1));
        % [x3,y3]=meshgrid(x2,y2);
        ydata =griddata(p(:,1), p(:,2), p(:,3), x3, y3, v_interpmethod)';

    end % end of Probe Mode Switch.
    %============================
    %============================
  case 3 % Image Mode = smooth POINTS
    g=sqmap(14);
    %g=(g>0.5)+(g<=0.5).*g;
    switch probe_mode
      case 50 % ETG-7000 8x8 mode
        % mask channels NOT USED for infant probe ----------------
        mtx=[19 26:27 33:35 40:43 46:67 69:74 77:81 85:88 93:95 101:102 109];
        ymask=zeros(1,112); ymask(1,mtx)=1;
        ydata=ydata.*ymask;
        %------------------------------------------------------
        d=zeros(1,150*150);

        mt0=150*4+10+5:20:150*4+14*10+5;
        mt=[mt0 150*14+0+5:20:150*14+14*10+5];
        mt1=[mt mt+150*20 mt+150*40 mt+150*60 mt+150*80 mt+150*100 mt+150*120 mt0+150*140 ];
        d(1,mt1)=ydata;
        d1=reshape(d, [150 150]);
        d1=conv2(d1,g);
        ydata=d1;

      case 1 % ETG-100 24ch (3x3)x2 mode
        % plane1
        d=zeros(1,2500);
        mt=[ 200+15 200+35 700+5 700+25 700+45 ];
        mt=[mt mt+1000]; mt=[mt 2200+15 2200+35];
        d(1,mt)=ydata(1,1:12);
        d1=reshape(d,[50 50]);
        d1=conv2(d1,g);
        % plane2
        d=zeros(1,2500);
        d(1,mt)=ydata(1,13:24);
        d=reshape(d,[50 50]);
        d=conv2(d,g);

        ydata=[d1' d']';

      case {2, 51} % ETG-100 24ch (4x4) mode && ETG-7000 4x4 mode
        d=zeros(1,4900);
        mt0=70*4+10+5:20:70*4+6*10+5;
        mt=[ mt0 70*14+0+5:20:70*14+6*10+5];
        mt1=[mt  mt+70*20 mt+70*40 mt0+70*60];
        d(1,mt1)=ydata;
        d1=reshape(d,[70 70]);
        d1=conv2(d1,g);
        ydata=d1;

      case {3, 52} % ETG-100 22ch (3x5) mode && ETG-7000 3x5 mode
        d=zeros(1,4500);
        mt0=90*4+10+5:20:90*4+8*10+5;
        mt=[ mt0 90*14+0+5:20:90*14+8*10+5];
        mt1=[mt  mt+90*20 mt0+90*40];
        d(1,mt1)=ydata;
        d=reshape(d,[90 50]);
        d=conv2(d,g);
        ydata=d;

      otherwise,
        % Common
        % case 101,
        tmp = find(isnan(ydata));
        if ~isempty(tmp),
          ydata(tmp)=0;    % not plot == 0
        end
        if probe_mode==199 || probe_mode==99
          dheader.flag=true([1, 1,size(ydata,2)]);
          dheader.measuremode=199;
          p  = time_axes_position(dheader);
        else
          p  = time_axes_position(probe_mode);
        end
        p = [p(:, 1:2), ydata'];
        x=sort(p(:,1));
        y=sort(p(:,2));
        x2= x([1; find(abs(diff(x))>0.01)+1]);
        y2= y([1; find(abs(diff(y))>0.01)+1]);
        sz00=[length(y2),length(x2)];
        sz = 10;
        sz_o = -sz/2;
        csize=sz00 * sz;
        c=zeros(csize(end:-1:1));
        for index=1:size(p,1),
          xtmp = find(p(index,1)-0.010 <x2 & x2<p(index,1)+0.011);
          ytmp = find(p(index,2)-0.010 <y2 & y2<p(index,2)+0.011);
          if ~isempty(xtmp) && ~isempty(ytmp),
            c(sz_o+sz*xtmp(1),csize(1)-(sz_o+sz*ytmp(1))+1) = p(index,3);
          end
        end
        ydata = conv2(c, g);
        %ydata = ydata';
    end % end of Probe Mode Switch.

  otherwise,
    % ===== Error message add =====
    % 2005.08.25
    % @since 1.7
    if image_mode==4,
      errordlg({'Image Mode 4 is special value,', ...
        ' there is no image to plot'});
    end
    error(['Image Mode(' num2str(image_mode) ')' ...
      ' is out of range (1, 2, 3)']);
end % end of switch Image Mode
return;
