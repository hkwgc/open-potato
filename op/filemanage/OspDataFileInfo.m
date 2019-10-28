function info_cel=OspDataFileInfo(mode, modex, info);
% Get Information cell aray from Structure
%
% info_cel=OspDataFileInfo(mode, modex, info);
%
% ********************************
%   mode is Load Data Mode, Default is 0
% ********************************
%   ===  Singnal Processor ====
%     mode 0 : 
%       Print All Osp_LocalData.info
%       See also ot_dataload.m, OSP_DATA
%
%     mode 2:
%       Print Osp_LocalData.info Field
%       That listed in DataFileInfo.mat
%                      InfoViewField
%
% ********************************
%   modex is Print mode, Default is 1
% ********************************
%   bit 1 
%     0 : Simpl String
%     1 : Ajust Location of ':' 
%   bit 2
%     0 : no waitbar
%     1 : with waitbar
%
% ********************************
%   modex is Print mode, Default is OSP_LOCALDATA.info
% ********************************
%  Structure of Print Data
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  % Example :
%  %    info.ID_number  = '0013';
%  %    info.CreateDate = now;
%  %    info.a          = 3
%  %
%  %    c=OspDataFileInfo(0,0,info) return
%  %    c{1} = 'ID_number : 0013'
%  %    c{2} = 'CreateDate : 21-Jan-2005 13:59'
%  %    c{3} = 'a : 3'
%  %     
%  %    c=OspDataFileInfo(2,0,info) return
%  %    c{1} = 'ID_number : 0013'
%  %
%  %    c=OspDataFileInfo(0,1,info) return
%  %    c{1} = 'ID_number  : 0013'
%  %    c{2} = 'CreateDate : 21-Jan-2005 13:59'
%  %    c{3} = 'a          : 3'
%  %
%  %    c=OspDataFileInfo(1,0,info) return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.01.14
% $Id: OspDataFileInfo.m 366 2013-06-29 09:57:12Z Katura $
%
%% 2007.01.17 :
%  Change : when "INFO" is Structure-Array, 
%           use only 1st-Data

if nargin==0
  mode = 0;
end

if nargin < 2
  modex = 1;
end

info_cel={};
if nargin < 3
  ldata=OSP_DATA('GET','OSP_LOCALDATA');
  if isempty(ldata)
    info_cel={' === No Active Data ===',...
        '   Load File at First!'};
    return;
  end
  info = ldata.info;
end

if length(info)>=2,info=info(1);end

switch mode
  case 0
    % Copy From Signal Preprocessor Ver 0
    %   with a little modification
    %  14-Jan-2005
    % 1. Dont plot Field
    % 2. Wainting bar rate
    
    % -- init --
    if bitget(modex,2)
      w=waitbar(0,'getting file information ...');
    end
    fldnm=fieldnames(info);
    
    % -- Cut Ignore Fild --
    % Modified by Dohi,Neorium
    % Not to show the information of the field 
    % 'stimkind' or  'modstimkind'
    %
    % Mode 2005.01.14 M. Shoji
    %  Bugfix : for MATLAB 6.5.1 (B070605B)
    if ~isempty(fldnm)
      tmp   = regexp(fldnm,'tag$');if ~iscell(tmp),tmp={tmp};end
      fldnm = fldnm( cellfun('isempty',tmp) );
    end
    % setting Ignore Field 
    ignore_field ={'stimkind'; 'modstimkind';'TimeBlock'};
    [xx,rmid]=setdiff(fldnm,ignore_field); %#ok I need rmid only.
    clear xx;
    fldnm=fldnm(sort(rmid)); % unsort
    
    if bitget(modex,1)
      maxsz=max(cellfun('length',fldnm)) + 1;
    end
    
    % Waiting bar Setting 
    fld_num=length(fldnm);
    if bitget(modex,2)
      waitbar(0.1,w);  % 10% done
    end
    % Make Information Strings
    for jj=1:fld_num,
      val= info.(fldnm{jj});
      if isempty(val),val='-Empty-'; end
      
      % Numeriacl Value Transrate
      if isnumeric(val),
        switch fldnm{jj}
          case {'age','Age'}
            val = num2str(val(1));
            
          case {'sex','Sex'}
            if val==1
              val = 'Female';
            else
              val = 'Male';
            end
            
          case {'CreateDate', 'date'}
            try
              val = datestr(val);
            catch
              val = '-------';
            end
            
          otherwise
            sz=size(val);
            if length(sz)<=2 && min(sz)==1 && max(sz)<5
              val2 = num2str(val);
              if length(val(:)) ~= 1
                val = ['[' val2 ']' ];
              else
                val = val2;
              end
            else
              ctype = class(val);
              val = [ '[ ' num2str(sz(1)) ];
              for szi = 2:length(sz)
                val = [val 'x' num2str(sz(szi)) ];
              end
              val = [val ' ' ctype ' ]'];
            end
        end % end switch
      end % end Numerical Transrate
      
      if bitget(modex,1)
        fldnm{jj}(end+1:maxsz)=' ';
      end
      try
        if iscell(val), 
          vall='';
          for idxx=1:length(val),
            if isnumeric(val{idxx})
              vall=[vall ',' num2str(val{idxx})];
            else
              vall=[vall ',' val{idxx}];
            end
          end
          if ~isempty(vall)
            val=vall(2:end);
          else
            val='[]';
          end
        end
        if isstruct(val),
          info_cel{end+1}=[fldnm{jj} ' : Structure ...'];
          tmp=OspDataFileInfo(mode, modex, val);
          tmp=char(tmp);
          tmp0=fldnm{jj};tmp0(:)=' ';
          for sidx=1:size(tmp,1)
            info_cel{end+1}=[tmp0 ' | ' tmp(sidx,:)];
          end
		elseif ischar(val)
			if size(val,1)==1
				tmp=val;
			else
				tmp=cat(2,val,repmat(';',[size(val,1) 1]))';
				tmp=tmp(:)';
			end
			info_cel{end+1}=[fldnm{jj} ' : ' char(tmp)];
        end
      catch
        warning([' Not Defined Print Data. ', ...
            fldnm{jj} ': class = ' class(val)]);
        disp(val);
      end
      
      if bitget(modex,2)
        waitbar(0.1 + 0.9*jj/fld_num,w);
      end
    end
    clear val jj;
    if bitget(modex,2)
      close(w)
    end
    
  case 2
    % Copy From Signal Preprocessor Ver 0
    %   with a little modification
    %  17-Jan-2005
    
    % Load Printing Tag
    load([OSP_DATA('GET', 'OSPPATH') ...
        filesep 'ospData' ...
      filesep 'DataFileInfo.mat'],...
      'InfoViewField');
      if ~exist('InfoViewField','var')
        error(' No ''InfoViewField'' Exist in DataFileInfo.mat');
      end
      if bitget(modex,2)
        w=waitbar(0,'getting file information ...');
      end
      fldnm={};
      for fld = 1:size(InfoViewField)
        if isfield(info,InfoViewField{fld})
          fldnm{end+1}=InfoViewField{fld};
        end
      end
      if bitget(modex,1)
        maxsz=max(cellfun('length',fldnm)) + 1;
      end
      
      % Waiting bar Setting 
      fld_num=length(fldnm);
      if bitget(modex,2)
        waitbar(0.1,w);  % 10% done
      end
      % Make Information Strings
      for jj=1:fld_num,
        val= getfield(info,fldnm{jj});
        % Numeriacl Value Transrate
        if isnumeric(val),
          switch fldnm{jj}
            case {'age','Age'}
              val = num2str(val(1));
              
            case {'sex','Sex'}
              if val==1
                val = 'Female';
              else
                val = 'Male';
              end
              
            otherwise
              val2 = num2str(val);
              if length(val(:)) ~= 1
                val = ['[' val2 ']' ];
              else
                val = val2;
              end
              
          end % end switch
        end % end Numerical Transrate
        
        if bitget(modex,1)
          fldnm{jj}(end+1:maxsz)=' ';
        end
        info_cel{end+1}=[fldnm{jj} ' : ' char(val)];
        
        if bitget(modex,2)
          waitbar(0.1 + 0.9*jj/fld_num,w);
        end
      end
      clear val jj;
      
      if bitget(modex,2)
        close(w)
      end
      
    otherwise
      error('Undefined Mode');
  end
  
  return;
