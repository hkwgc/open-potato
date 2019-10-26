function varargout=dev3dpos_isotrack(cmd,varargin)
% serial I/O handling for ISO TRAK II 3D measure device 
% dev3dpos_isotrack(cmd, s)
% cmd : 'ini2click', 'go2ini', 'hold', 'click2point', 'point2click', 'GetPoint'
%   'ini2click' : transit initial-mode to stylus-click mode
%   'go2ini' : reset 3D-device to initialte it
%   'hold' : hold 3D-device mode ; no-operation
%   'click2point' : transit from stylus-click mode to point mode
%     * point mode is used as auto-mode in Navigation 
%   'point2click' : transit from point mode to stylus-click mode
%   'getpoint' : get point by sending 'P' command
%   'readpos' : read 3D-device position
% s : serial port
%
persistent pos01; % stylusÇÃç¿ïW
pos=[0.0,0.0,0.0];

[dum nargin] = size(varargin);

if( (nargin ~=1 ) )
    error('dev3dpos_isotrack() : specify 2 input argments\n');
end

switch lower(cmd)
case 'ini2click'
      s=varargin{1};
      fprintf(s,'Y');
      fprintf(s,'u');
      fprintf(s,'E');
      CtrlD=char(4);
      fprintf(s,CtrlD);
      fprintf(s,'C');

case 'go2ini'
      s=varargin{1};
      CtrlY=char(25);
      fprintf(s,CtrlY);

case 'hold'
      ;

case 'click2point'
      s=varargin{1};
      fprintf(s,'c');
      CtrlD=char(4);
      fprintf(s,CtrlD);

case 'point2click'
      s=varargin{1};
      CtrlD=char(4);
      fprintf(s,CtrlD);
      fprintf(s,'C');

case 'getpoint'
      s=varargin{1};
      fprintf(s,'P');
      
case 'readpos'
      s=varargin{1};
      if( (nargout~=2 ) )
          error('dev3dpos_isotrack() : specify 2 output argments for ''readpoint'' \n');
      end
      varargout{2} = pos;
      xx=fgetl(s);
      [str_row str_col] = size(xx);
      if( str_col <24 )
          varargout{1} = -1;
      end
      if( xx(4:8)=='ERROR')
          varargout{1} = -1;
      end
      if( xx(2)=='1' )
         pos01=[str2num(xx(4:10)) str2num(xx(11:17)) str2num(xx(18:24))];
         pos01=pos01*10.0;
         varargout{1} = 1;
         varargout{2} = pos01;
      end
      if( xx(2)=='2' )
         [pos01_row pos01_col] = size(pos01);
         if( pos01_col~=3 || pos01_row~=1 )
            varargout{1} = -1;
         end
         pos02=[str2num(xx(4:10)) str2num(xx(11:17)) str2num(xx(18:24))];
         pos02=pos02*10.0;
         pos=pos01-pos02;
         if (length(pos)<3)
            pos(3)=0;
         end
         varargout{1} = 2;
         varargout{2} = pos;
      end
end
