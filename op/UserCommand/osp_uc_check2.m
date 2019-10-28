function [code, ckmsg]=osp_uc_check2(header,data,lvl)
% Check OSP User-Command Data : Version 2.0
%  This Function is not completion!!
% 
%-------------------------------
% Syntax :
% [code,ckms]g=osp_uc_check(header,data,lvl);
%    header : OSP User Command Data (header part)
%    data   : OSP User Command Data (data part)
%    lvl    : Check Levle (1-3)
%             (Default : 1)
%             1 : Data
%             2 : Data Check :
%             3 : 
%
%    code   : Check-Result
%              0: Data is in format.
%              1: Warning
%             -1: Error 
%    ckmsg  : Cell array of Character.
%             Message of Check Data
%
%-------------------------------
% Meaning of Ecode in ckmsg ::
%-------------------------------
% Ecode : 00-00-00
%  1st Number : Header Error
%    1 : Bad Value.
%    2 : Bad Data type / Size (field).
%    4 : Lack of essential field.
%    8 : Bad Data Type.
%  2nd Number : Header Warning
%    1 : Discouraged Value (field).
%    2 : Discouraged Data type / Size (field).
%    4 : Lack of basic field.
%    8 : Discouraged Field-Name.
%
%  3rd Number : Data Error
%    4 : Bad Size
%    8 : Bad Data Type
%  4th Number : Data Warning
%
%  5th Number : Contradiction Error
%    1 : Bad Value
%    2 : Bad Data type / Size (field)
%    4 : Lack of essential field.
%    8 : Bad Data Type.
%  6th Number : Contradiction Warning
%
%
%  ckmsg=osp_uc_check2(header,data);
%  char(ckmsg);
%
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2006.06.22
% $Id: osp_uc_check2.m 180 2011-05-19 09:34:28Z Katura $
%

% Now Program Memo 
lvlmax=3;

%=======================
% Check Arguments
%=======================
nmsg=nargchk(2,3,nargin);
if ~isempty(nmsg), error(nmsg);end

% -- Check Level --  
if nargin<3, lvl=1; end
if ~isnumeric(lvl),
  warning('3rd Argument: Check Level : must be Natural Number');
  lvl=1;
end
if length(lvl)~=1,
  warning('3rd Argument: Check Level : must be scalar.');
  if isempty(lvl),  lvl=1;
  else, lvl=lvl(1);end
end
lvl=round(lvl);

if lvl>lvlmax, 
  warning('Check Level : Extend Maximum'); 
  lvl=lvlmax;
end
if lvl<0,
  warning('Check Level : must be Natural Number'); 
  lvl=1;
end

%=======================
% Initialized Data
%=======================
% uint8 is not for normal programing...
% -> (sprintf, some function does not work)
%    :: but I mean Max of ecode is 255
%
%hecode=uint8(0);  % Header Error Code 
%decode=uint8(0);  % Data   Error Code
%ecode =uint8(0);  % not Consistent Error Code
hecode=0;
decode=0;
ecode =0;

%=======================
% 1st Level Check : 
%  Data Level Check (Error Check )
%=======================
ckmsg={'User-Command Check II : $Revision: 1.3 $', ...
       [' Check Level : ' num2str(lvl)]};

%-------------
% Data Check
%-------------
ds=size(data);
if isnumeric(data),
  % Numerical
  if length(ds)==3,
    dtype='Continuous';
  elseif length(ds)==4,
    dtype='Block';
  else,
    decode=bitset(decode,7);
    dtype='unknown';
    ckmsg{end+1}=' E00-40-00 : Undefined Data - Size';
  end
else,
  % -- Undefined --
  decode=bitset(decode,8);
  dtype='unknown';
  ckmsg{end+1}=' E00-80-00 : Undefined Data-Type';
end

%-------------
% Header Check
%-------------
if ~isstruct(header),
  hecode=bitset(hecode,8);
  ckmsg{end+1}=' E80-00-00 : Header is not Structure';
else,

  % -- Stim Check --
  if isfield(header,'stim'),
    if isnumeric(header.stim),
      sz=size(header.stim);
      % Size Check
      if isempty(header.stim) && ~strcmp(dtype,'Block'),
	hecode=bitset(hecode,2);
	ckmsg{end+1}=' E02-00-00 : Stim is Empty';
      else,
	if length(sz)~=2,
	  % Dimension's 
	  hecode = bitset(hecode,6);
	  ckmsg{end+1}=[' E20-00-00 : Stim : Bad Data Dimension Size'];
	elseif sz(2)==3,
	  if ~strcmp(dtype,'Continuous'),
	    ecode = bitset(ecode,6);
	    ckmsg{end+1}=[' E00-00-20 :', ...
			  ' Contradiction between stim-size & data'];
	  end
	elseif sz(2)==2,
	  if ~strcmp(dtype,'Block'),
	    ecode = bitset(ecode,6);
	    ckmsg{end+1}=[' E00-00-20 :', ...
			  ' Contradiction between stim-size & data'];
	  end
	else,
	  hecode = bitset(hecode,6);
	  ckmsg{end+1}=[' E20-00-00 : Stim : Bad Data Size'];
	end 

	% Check Value
	if any(header.stim<=0),
	  hecode = bitset(hecode,5);
	  ckmsg{end+1}=[' E10-00-00 : Stim : Bad Value below 0'];
	end
	if strcmp(dtype,'Block') && any(header.stim(:) >=ds(2)),
	  hecode = bitset(hecode,5);
	  ckmsg{end+1}=' E10-00-00 : Stim : Bad Time-Value'
	elseif strcmp(dtype,'Continuous') && any(header.stim(1,:,:) >=ds(1)),
	  hecode = bitset(hecode,5);
	  ckmsg{end+1}=' E10-00-00 : Stim : Bad Time-Value'
	end
      end
      % End of Size Check
    else,
      % Bad Data Type
      hecode = bitset(hecode,6);
      ckmsg{end+1}=' E20-00-00 : Stim : Bad Type';
    end 
  else,
    hecode = bitset(hecode,7);
    ckmsg{end+1}=' E40-00-00 : Field stim';
  end
end  


%=======================
% 2nd Level Check : 
%  Extend Data Check I
%  Pos, Result, VIEW, TimeSeriese
%=======================

%=======================
% 3rd Level Check : 
%  Extend Data Check II
%  data NaN Check, data
%=======================

%========================
% Show Summary
%========================
if hecode==0 && decode==0 && ecode==0,
  code=0;
  ckmsg{end+1}=[' DataType : ' dtype];
  ckmsg{end+1}=' Check    : OK';
elseif hecode<=16 && decode<=16 && ecode<=16,
  code=1;
  ckmsg{end+1}=[' DataType : ' dtype];
  ckmsg{end+1}=sprintf(' Warning: %02x-%02x-%02x',...
		       hecode, decode, ecode);
else,
  code=-1;
  ckmsg{end+1}=sprintf(' Error  : %02x-%02x-%02x',...
		       hecode, decode, ecode);
end
