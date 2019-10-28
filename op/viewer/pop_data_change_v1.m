function [data , axis_label, unit] = pop_data_change_v1(dc_option,data, axis_label, unit)
% pop_datachange_exe is the discreate Selected DataChange-popupmenu
%
% dc_option is 
%  dc_option = get(handles.pop_datachaneg,'String');
%  dc_option = dc_option{get(handles.pop_datachaneg,'Value')};
%  That is, 
%   'HB data'       : do nothing(input=output)
%   'FFT Power'     : FFT Power sepctrum ploting
%   'FFT Phase'     : FFT Phase spectrum ploting
%   'FFT Magnitude' : FFT Magnitude ploting
%
% transform of data along the 1st dimension by 
%  data, 3 Dimensional data, is Time x HB data x HBkind.
%
% Unit of Output data will be chaneg,
% so we output not only transfar data
% but also unit and axis_label 
% ---------------------------------------

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% original author Masanori Shoji.
% Date : 2005.06
%    Separation from Signal-viewer.
%
%    but it is better for the function 
%    to act with pop_datachange, 
%    one of ther Signal-viewer child. 
%

  % == Data Change ===
  switch dc_option
   case 'HB data'
    % Do nothing

   case 'FFT Power'
    axis_label.x = ' Frequency [Hz]';
    axis_label.y = [axis_label.y ' : Power'];

    data = fft(data);
    n = size(data,1);
    unit = n/unit;

    data = data(2:floor(n/2),:,:).^2/n;
    %data(1,:,:)=[];    %<- Needless : IN, AO Axis start from 0+alpha Hz
      
   case 'FFT Phase'
    axis_label.x = ' Frequency [Hz]';
    axis_label.y = [axis_label.y ': Phase [rad]'];

    data = fft(data);
    n = size(data,1);
    unit = n/unit;

    data = unwrap(angle(data));

   case {'FFT Magnitude','FFT Amplitude'}
    axis_label.x = ' Frequency (Hz)';
    axis_label.y = [axis_label.y ' Amplitude spectrum (mMmm)'];

    data = fft(data);
    n = size(data,1);
    unit = n/unit;

    data = abs(data(2:floor(n/2),:,:))/n;
    %data(1,:,:)=0; %<- Needless : IN, AO Axis start from 0+alpha Hz
   otherwise,
    errordlg({' Program Error ', ...
	      [' Unknow Data-Change Option : ' dc_option], ...
	      ' * Ignore Data Change Option'});
    OSP_LOG('perr', ...
	    [' Unknow Data-Change Option : ' dc_option]);
  end
return;
