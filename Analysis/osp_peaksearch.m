function [areadata,areamap,varargout]= osp_peaksearch(data0,area,searcharea,tag,time_axis)
%  OSP_PEAKSEARCH Search Peak of Blocking Data Area
%
%  OSP_PEAKSEARCH Search Period that Mean-value along Block and
%  Time is Maximum. If HB kind is Deoxy( 4-dimensional id is 2) ,
%  we substitute Minimum value for Maximum value.
%
% Syntax is as following
%  [areadata,areamap]= osp_peaksearch(data0,area,searcharea,tag,time_axis)
%
%    Input Data
%       data0 is 4-Dimensional Data
%            block x time x channel x HBkind
%
%       area  is [Original-Period-start-time,
%                 Original-Period-end-time]
%              here unit of time is sampling data points
%
%       searcharea is relaxing time of area
%           value include + or minus
%           Generary, one of then is negative 
%           like [ -100 100]
%              here unit of time is sampling data points
%
%       tag  is HB-kind meaning
%          if tag exist, the function plot figure.
%          else not plt
%
%       time_axis is data to determine axis of time.
%           time_axis is [unit, start_time];
%           default is [1, 1] .
%           ( argument of data(:,T,:,:)is time_axis)
%           
%
%    Return Value
%         areadata is period of  
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


  
% Peak Search checked ---

  if nargin < 3,  error('Too few arguments');  end

  % Area Sort
  if area(1) > area(2)
    area([2 1]) = area([1 2]);
  end
  if searcharea(1) > searcharea(2)
    searcharea([2 1]) = searcharea([1 2]);
  end
  % no search
  if (searcharea(2)==searcharea(1))
    areadata=data0(:,area(1):area(2),:,:);
    areamap  = zeros(2, size(data0,3), size(data0,4));
    areamap(1,:,:)=area(1);
    areamap(2,:,:)=area(2);
    if nargout>=3,
      varargout{1}=[];
    end
    return;
  end
  if (area(2) == area(1) ) || size(data0,1)==0
    areadata=[];
    areamap=[];
    if nargout>=3,
      varargout{1}=[];
    end
    return;
  end
  
  % Check Reasion
  if area(1) <= 0, area(1)=1; end
  if area(2) >= size(data0,2), area(2)=size(data0,2); end
  
  % Overflow/ underflow is region is ignore
  if area(1)  <= -searcharea(1);
    searcharea(1) = 1 - area(1);
  end
  if (area(2) + searcharea(2)) > size(data0,2)
    searcharea(2) = size(data0,2)-area(2);
  end

  % Callock and Size Def
  area_size0 = area(2) - area(1); %+1; % diff(area) -1
  size_1 = [size(data0,3), size(data0,4)];
  size_2 = [area_size0+1, size_1];
  peakVm=zeros(searcharea(2)-searcharea(1)+1,...
	       size(data0,3), size(data0,4) );

  % == Mean Value of Each Region == 
  cnt=1;
  for st=area(1) + searcharea(1) : area(1) + searcharea(2),
    tmp = nan_fcn('mean',data0(:, st:st+area_size0, :, :),1);
    peakVm(cnt,:,:)=reshape(nan_fcn('mean',reshape(tmp,size_2),1),size_1);
    cnt=cnt+1;
  end

  % max/min of area, ant get Region
  [peakV peakT]=max( peakVm);
  [peakV2 peakT2]=min( peakVm);

  % HB plot -> for deoxy, search min
  peakV(1,:,2)=peakV2(1,:,2); 
  peakT(1,:,2)=peakT2(1,:,2); 
  clear peakV2 peakT2;

  % If Figure Plot
  if exist('tag','var')

    % Plot setting
    sz=size(data0,4);
    sttime_x = area(1) + searcharea(1) : area(1) + searcharea(2);
    if exist('time_axis','var'),
        sttime_x = time_axis(2) + (sttime_x-1) * time_axis(1);
    end        
    stime_x3 = repmat(sttime_x',[1,size(peakVm,2)]);
    ch_y     = 1:size(peakVm,2);
    ch_y3    = repmat(ch_y,[length(sttime_x),1]);

    % Figure Setting
    fig_h = figure;
    set(fig_h, ...
	'Name', 'Peak Search Result', ...
	'Renderer', 'OpenGL', ...
	'Color', [.75 .75 .5]);

    for kind = 1:sz
      figure(fig_h); % confine
      subplot(1,sz,kind);
      % h=plot(sttime_x', squeeze(peakVm(:,:,kind)));
      plot3(stime_x3,ch_y3,squeeze(peakVm(:,:,kind)));
      hold on; axi_d = axis; axis(axis);
      try
	title(tag{kind});
      catch
	title(['HB Kind no : ' num2str(kind)]);
      end
      xlabel('Start Time of the Region');
      ylabel('Channel');
      zlabel('Mean-Value of the region');
      if exist('time_axis','var'),
          h=plot3(time_axis(2) + ...
              (squeeze(peakT(:,:,kind)+area(1) +searcharea(1)-1))*...
              time_axis(1),...
              ch_y, ...
              squeeze(peakV(:,:,kind)),'*');
      end        
      h=plot3(squeeze(peakT(:,:,kind)+area(1) +searcharea(1)),...
	      ch_y, ...
	      squeeze(peakV(:,:,kind)),'*');
      grid on;
    end
  end

  %---				
  peakT=squeeze(peakT+area(1)+searcharea(1)-1);
	
  size_3 = [size(data0,1) size_2];
  areadata = zeros(size_3);
  areamap  = zeros(2, size(peakT,1), size(peakT,2));
  for hbkind=1:size(peakT,2); % HB loop
    for ch=1:size(peakT,1) % ch loop
      % mean of c2 : data_c2(block,time,ch,HB)
      areamap(:,ch,hbkind) = [peakT(ch,hbkind), peakT(ch,hbkind)+area_size0];
      areadata(:,:,ch,hbkind) = ...
	  data0(:, areamap(1,ch,hbkind):areamap(2,ch,hbkind) , ch, hbkind);
    end
  end

  if nargout>=3,
    if exist('fig_h','var'),
      varargout{1}=fig_h;
    else
      varargout{1}=[];
    end
  end
    
return;


