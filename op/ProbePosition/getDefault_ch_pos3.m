function [ch_pos3, msk]=getDefault_ch_pos3(mode, ch_num),
% Get default channel Position in 3-Dimensional from measuremode
%
% -------------------------------------
%  Optical topography Signal Processor 
%                    since Version 1.16
% -------------------------------------
%
% OSP - measuremode, read from ETG-Data-format,
% is variable simple data of channel position.
% Measure-mode is so simple to analysis data or
% treat as general position of brain. So we must
% modify position data.
%
% When OSP make position data by "setProbePosition",
% we make default position from measure.
% 
% This function is a table of measuremode to make
% 3D-channel position.
% 
% -------------------------------------
% How to use:
% Syntax :
% [pos3, msk]=getDefault_ch_pos3(mode, ch_num);
% -------------------------------------
% Input : 
%   mode   : measure-mode defined in ot_dataload
%            or time_axes_position.
%   ch_num : Number of Channel in the mode.
%            This value is for Error-check.
%
% Output :
%   pos3   : 3-Dimensional Position Data.
%            pos3 is 2-Dimensional-matrics of
%            [channel, axis].
%            axes is x, y, z. when
%            Nasion is ..
%            Left Ear
%            Right Ear ..
%   msk    : Default Mask-Data (channel of not in use).
%            vector of ..
%
% See also SETPROBEPOSITION, TIME_AXES_POSITION,
% OSP_CHNL2IMAGE, OT_DATALOAD.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2005.08.09
% $Id: getDefault_ch_pos3.m 180 2011-05-19 09:34:28Z Katura $
%

  % default:
  switch mode,
	  case -1,
		  errordlg({[mfilename ' : '], 'Not Defined for Multi-Probe'});
		  ch_pos3 = zeros([ch_num,3]);
		  msk     = true([1,ch_num]);
		  
	  otherwise,
		  %======================
		  % Default 
		  %======================
		  try,
			  % File Name get
			  pt=which('getDefault_ch_pos3');
			  pt = fileparts(pt);
			  fname = [pt filesep 'DefaultChannelPos3_' num2str(mode) '.mat'];
			  if ~exist(fname,'file')
				  error('Undefined Mode');
			  end
			  
			  % Load channel-position & msking-data
			  load(fname);
			  % -- when you set other method to .. --
			  if ~exist('ch_pos3','var') || ~exist('msk','var'),
				  error([fname ' : wrong format']);
			  end
			  
			  if ~all(size(ch_pos3)==[ch_num, 3]),
				  error('Channel Data Size Error');
			  end
			  if ~all(size(msk)==[1,ch_num]),
				  error('Masking Data Size Error');
			  end
		  catch,
		    warndlg({'======== [Platform] Warning!! ========', ...
			     '<< Default Channel Position', ...
			     '<<   Undefined 3-D Position>>', ...
			     ['<<  Measure-Mode : ' num2str(mode) '>>'], ...
			     lasterr, ...
			    '==============================='}, ...
			    'Undefined Position');
		    ch_pos3 = zeros([ch_num,3]);
		    msk     = true([1,ch_num]);
		  end
  end
return;

