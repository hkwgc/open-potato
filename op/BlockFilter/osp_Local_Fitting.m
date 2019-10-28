function data=osp_Local_Fitting( data, negx, deg, mod, unfitx)
% osp_Local_Fitting. 
% apply poly-fitting
%
% Syntax :
%   data=osp_Local_Fitting( data, negx, deg, mod, fitx)
%
% IN: 
%   data(time, ch, :, ....): fitting data along time.
%   deg    : degree of Poly fit
%   unfitx : period not use for fitting 
%            if polyfit(x,data(:,x)), 
%              x(unfit)=[]; data(unfit)=[];
%   if there is no fitx,
%     negx([strat, end])= period not use for fitting 
%            :: eg. [50, 100]
%            -> polyfit([1:50 100:size(data)], data(:,x))
%
%   mod: 1: div fitting, 2: sub fitting
%    that is, if mode is 1
%     data(:,x) = data(:,x) 
%                ./ (polygonal-fitting-data of data(:,x))
%    if mode is 2
%     data(:,x) = data(:,x) 
%                - (polygonal-fitting-data of data(:,x))
%
% Out:
%   data=fitted data 
%   if mode is 1,
%     data(:,x) = data(:,x) 
%                - (polygonal-fitting-data of data(:,x))
%
% -- File Information : --
%   $Id: osp_Local_Fitting.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% History.
% 19-Oct-2004: [Modify] Normalized by Shoji.
% 04-Jun-2005: [ Add  ] fitx-mode by Shoji.

  % --- Make Data for Local Fitting --
  % Check Number of Arguments
  msg = nargchk(4, 5, nargin);
  if ~isempty(msg), error(msg); end

  % Regulation
  sz=size(data);
  deg = round(deg);

  % -- Get Periods --
  %x=[1:sz(1)];             % Make X-axis  
  x = linspace(-1,1,sz(1)); % <-Normalize for Error
  x  = x';                  % Axis to get polygomial value

  % Get Fitting Period
  if exist('unfitx','var'),
    % restruct unfitx 
    % remove underfllow/ overfllow period
    unfitx(find( (unfitx<1) | (unfitx>sz(1)) ) ) =[];
    % [max(unfitx) -1, min(unfitx)+1]; %display for range
    x3 = [1:sz(1)]; % confine row vector.
    x3(unfitx) = [];
    
    clear unfitx;
  else
    x3 = [1:negx(1) negx(2):sz(1)]';
  end
  x2 = x(x3);  % Axis for Polyfit (Normalized)

  % Make data for Fitting
  dum =data(:,:);  % Same as reshape(data,sz(1),prod(sz)/sz(1)) .
  dum2=dum(x3,:); 
  clear data x3;


  % -- Local Fitting --
  if (deg==1)
    for ii=1:size(dum,2)
      % To ignore NaN Period.
      uindex=find(isnan(dum2(:,ii))==0); % use only not-NaN data.
      if isempty(uindex), continue;end%mod by TK 090728@HARL
      
      %   Perform polyfit
      xx=[x2(uindex), ones(size(x2(uindex)))];
      pf=xx\dum2(uindex,ii);
      fit= pf(2) + x*pf(1); % Get fitting result
      
      % Get Difference
      if ( mod==1)
        fit = fit + (fit==0);
        dum(:, ii) = dum(:,ii) ./ fit;
      else
        dum(:, ii) = dum(:,ii)  - fit;
      end
    end
  elseif (deg==0)
    % TODO : no-loop
    for ii=1:size(dum,2)
      % To ignore NaN Period.
      uindex=find(isnan(dum2(:,ii))==0); % use only not-NaN data.
      if isempty(uindex), continue;end%mod by TK 090728@HARL
      
      %   Perform polyfit
      mv=mean(dum2(uindex,ii));
      fit= ones(size(x))*mv; % Get fitting result
      
      % Get Difference
      if ( mod==1)
        fit = fit + (fit==0);
        dum(:, ii) = dum(:,ii) ./ fit;
      else
        dum(:, ii) = dum(:,ii)  - fit;
      end
    end
    
  else
    for ii=1:size(dum,2)
      % To ignore NaN Period.
      uindex=find(isnan(dum2(:,ii))==0); % use only not-NaN data.
      if isempty(uindex), continue;end%mod by TK 090728@HARL
      
      %   Perform polyfit
      pf=polyfit(x2(uindex),dum2(uindex,ii),deg);
      fit=polyval(pf,x);    % Get fitting result
      
      % Get Difference
      if ( mod==1)
        fit = fit + (fit==0);
        dum(:, ii) = dum(:,ii) ./ fit;
      else
        dum(:, ii) = dum(:,ii)  - fit;
      end
    end
  end

  % -- reshape --
  data=reshape(dum,sz);
return;


%-- Old code
% sd1=size(data,1);
% sd2=size(data,2);
% sd3=size(data,3);
% sx=size(negx,2);
% 
% %data=data-repmat(min(data),[sd1 1 1])+1;
% 
% dum=data;
% 
% % --- Polyfit
% for i1=1:sd2
%     for i2=1:sd3
%         x=[1:sd1]';
% 		pf=polyfit( x([1:n(1) negx(2):end]), squeeze( dum([1:negx(1) negx(2):end],i1,i2) ), deg);
% 		fit=polyval(pf, x);
% 		% 		if (i1==5 )|(i1==6) ,fig;plot(squeeze(dum(:,i1,i2)));hold;plot(fit); end
% 		
% 		if (mod==1)
% 			fit=fit+(fit==0);
% 			data(:, i1, i2)=dum(:, i1, i2)./fit;
% 		else
% 			data(:,i1,i2)=dum(:,i1,i2)-fit;
% 		end	
% 	end
% 	
% end
% % ---
