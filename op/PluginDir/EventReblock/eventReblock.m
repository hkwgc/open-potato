function [h, d]=eventReblock(hdata, data, kind, prestim, poststim, varargin)
% GET Data around a Stim-Kind from Block-Data and Reblocking.
%
% This function is wrapper function.
%
%=================================================================
% Get Data only.
% Syntax:
%  [hdata, data]=eventReblock(hdata, data, kind, prestim, poststim)
%
%  hdata : Header of Block include the filed "stimTC2" (structure)
%          "stimTC2" was added since UC_BLOCKING version 1.8 or later
%
%  data  : Block Data (double)
%         [block, time, channel, data-kind]
%
%  kind   : Stimulation Kind (integer)
%           Getting Stimulation-Kindb
%           
%  prestim: Pre-Stimulation(task) Time  in sec 
%
%  poststim: Post-Stimulation(task) Time  in sec 
%=================================================================
%
%  See also : UC_BLOCKING, PLUGINWRAP_ENVENT_REBLOCK, 
%             SETEVENTREBLOCKARG.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% Original author : Masanori Shoji
% create : 2005.11.11
% $Id: eventReblock.m 180 2011-05-19 09:34:28Z Katura $

  % ===============
  % Argument Check
  % ===============
  msg=nargchk(2,5,nargin);
  if isempty(msg) && ~isfield(hdata,'stimTC2'),
    msg=sprintf('* OSP Error\n Event Reblock Need a field ''stimTC2''.');
  end

  % Output Argument Check
  if isempty(msg) 
    msg=nargoutchk(2,2,nargout);
  end

  % CHECK stimTC2
  if isempty(msg) && ~isfield(hdata,'stimTC2'),
    msg=sprintf(' * OSP Error\n * Event Reblock Need a field ''stimTC2''.');
  end

  % size of data
  if isempty(msg) && ndims(data)~=4
    msg=sprintf(' * OSP Error\n * Input-Block-Data Dimension Error');
  end
  
  % Error ?
  if ~isempty(msg) 
    % show useage
    help enentReblock
    error(msg);
  end

  % ===============
  % Initialize
  % ===============
  % <<--- Unit Change --->>
  prestim  = round( prestim(1)*1000/hdata.samplingperiod);
  poststim = round(poststim(1)*1000/hdata.samplingperiod);
  
  % <<<--- Kind Loop --->>>
  % Reshape ->row-vector
  kind=reshape(kind,1,prod(size(kind)));
  % == Alloc ==
  bsz=0;
  for ikind=kind,
    p=find(hdata.stimTC2==ikind);
    bsz = bsz+length(p);
  end
  d=zeros(bsz,prestim(1)+poststim(1)+1,size(data,3),size(data,4));
  d(:)=NaN; % inti
  h=hdata; 
  h.stim    = [prestim(1)+1,prestim(1)+1];
  h.stimTC  = zeros(1,prestim(1)+poststim(1)+1);
  h.stimTC(prestim(1)+1)=kind(1);
  h.stimTC2 =zeros(bsz,prestim(1)+poststim(1));
  h.stimkind= zeros(bsz,1);
  h.flag    = repmat(logical(0),[size(hdata.flag,1),bsz,size(d,3)]);
  if bsz==0, 
    return;
  end

  bid = 1;				% Block ID
  % Set Point (Initial)
  sp0 = 1:size(d,2);
  % Getp Point (Initial)
  gp0 = sp0 - (prestim(1)+1);

  % <<<--- Kind Loop --->>>
  for ikind=kind,
      for blk=1:size(hdata.stimTC2,1),
          p=find(hdata.stimTC2(blk,:)==ikind);
          if isempty(p) continue; end
          
          % << -- Point Loop -->
          for ip=p(:)',
              sp = sp0;
              gp = gp0 +ip;
              
              uf = find(gp<1);		% Under Flow
              of = find(gp>size(data,2));	% Over Flow
              gp([uf, of])=[];
              sp([uf, of])=[];
              
              d(bid,sp,:,:)     = data(blk,gp,:,:);
              h.stimTC2(bid,sp) = hdata.stimTC2(blk,gp);
              h.stimTC2(bid,sp) = hdata.stimTC2(blk,gp);
              h.stimkind(bid)   = ikind;
              h.flag(:,bid,:)   = hdata.flag(:,blk);
              bid = bid+1;
              
          end
      end
  end % <<<--- Kind Loop --->>>

return;
