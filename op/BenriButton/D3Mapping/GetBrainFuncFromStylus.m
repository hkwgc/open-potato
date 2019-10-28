function result = GetBrainFuncFromStylus(varargin)
% affine convert from real-3D vector to 
%      This module has 4 functions.
%
%    (1)Hash = GetBrainFuncFromStylus('MakeHash',HeadSurfaceStruct)
%    input : 2 arguments
%      1st(string) : 'MakeHash' indicates make hash table operation
%      2nd(x,y,z data struct) :head vertex data {xallHEM,yallHEM,zallHEM}
%    output : Hash table indexed by (theta,phi)
%
%    (2)indeces=GetBrainFuncFromStylus('GetNearest',Hash,heads,pos,num)
%    input : 5 arguments
%      1st(string) : 'GetNearest' indicates get nearest num-points around
%      pos
%      2nd : Hash, Hash table made through (1)-step.
%      3rd : heads, head vertex data{xallHEM,yallHEM,zallHEM}
%      4th : pos(3), current position in standard coordinate
%      5th : num, get number of position near stylus
%    output : index for heads(array)
%
%   (3)af2 = GetBrainFuncFromStylus('GetCenter',heads,indeces);
%      1st(string) : 'GetCenter' indicates get sphere-center of nearest-num %                    points got through step-(2)
%      2nd : heads, head vertex data{xallHEM,yallHEM,zallHEM}
%      3rd : index for heads(array) got through step-(2)
%    output : center position
%
%   (4)index=GetBrainFuncFromStylus('GetIndexOnBrain',Brain, styluspoint,
%                    norm_vec, tr_end)
%      1st(string) : 'GetIndexOnBrain' indicates get brain position cross or
%                    near-by line made by headpoint & norm_vec
%      2nd : Brain, brain dictionary :(:,1):x, (:,2):y, (:,3):z,
%                               (:,4): dic index(unused here)
%      3rd : styluspoint, stylus position
%      4th : norm_vec, normal vector on Head surface point
%      5th : tr_end, candidate search width in y-axis along norm_vec
%   output : result function index for brain dictionary
%

[dum nargin] = size(varargin);

if( (nargin<2) || (nargin)>5 )
    error('GetBrainFuncFromStylus() : specify 2 - 5 input argments\n');
end

switch lower(varargin{1})
    case 'makehash'
        if(nargin~=2)
            error('GetBrainFuncFromStylus(''MakeHash'',...) : specify 2 input arguments\n');
        end
        if isstruct(varargin{2})
          s=varargin{2};
          try
            x=s.xallHEM(1:1:end);
            y=s.yallHEM(1:1:end);
            z=s.zallHEM(1:1:end);
          catch
            error('GetBrainFuncFromStylus(''make_mat'',HeadSurfaceStruct) :specify 2nd-arg has struct member{xallHEM,yallHEM,zallHEM}.\n');
          end
        else
          error('GetBrainFuncFromStylus(''make_mat'',HeadSurfaceStruct) :specify 2nd-arg as struct has member{xallHEM,yallHEM,zallHEM}.\n');
        end
        r=sqrt(x(:).^2+y(:).^2+z(:).^2);
        phi=acos(z(:)./r)*180/pi;
        theta=atan2(x(:),y(:))*180/pi;
        phi = rem(round(phi),180)+1;
        theta = rem(round(theta+180),360)+1;
        
        result=repmat(struct('r',0,'theta',0,'phi',0,'index',[]),361,181);
        [row_n col_n]=size(r);
        for n=1:1:row_n
          [row_no col_no] = size(result(theta(n),phi(n)).index);
          result(theta(n),phi(n)).r = r(n);
          result(theta(n),phi(n)).index(col_no+1) = n;
          result(theta(n),phi(n)).theta = theta(n)-1;
          result(theta(n),phi(n)).phi = phi(n)-1;
        end
  case 'getnearest'
    if(nargin~=5)
            error('GetBrainFuncFromStylus(''GetNearest'',...) : specify 5 input arguments\n');
    end
    H_sphere=varargin{2}; % hash
    s = varargin{3}; % head vertex
    x = s.xallHEM; y = s.yallHEM; z = s.zallHEM;
    pos = varargin{4}; % stylus position in std-coordinate
    pos_x = pos(1); pos_y = pos(2); pos_z = pos(3);
    num_pos = varargin{5}; % get number of positions near stylus
    pos_r=sqrt(pos_x^2+pos_y^2+pos_z^2);
    pos_phi=acos(pos_z/pos_r)*180/pi;
    pos_theta=atan2(pos_x,pos_y)*180/pi;
    pos_phi = rem(round(pos_phi),180)+1;
    pos_theta = rem(round(pos_theta+180),360)+1;
    result = [];
    indexes = GetIndexAroundPos(H_sphere, pos_theta, pos_phi, num_pos);
    [num_row num_col]=size(indexes);
    if( num_col <=0 )
      return; % [] vector
    end
    len = sqrt((x(indexes)-pos_x).^2 + (y(indexes)-pos_y).^2 + (z(indexes)-pos_z).^2);
    [temp index] = sort(len);
    result = indexes(index); % nearest points index for head vertex data (s).
    
  case 'getcenter'
    if(nargin~=3)
            error('GetBrainFuncFromStylus(''GetCenter'',...) : specify 3 input arguments\n');
    end
    heads = varargin{2}; % head vertex
    indeces = varargin{3}; % nearest points index of head vertex data (heads)
    
    xxx=heads.xallHEM(indeces);
    yyy=heads.yallHEM(indeces);
    zzz=heads.zallHEM(indeces);

    warning off all
    try
      a0 = [0,0,0,100];
      f = @(a) norm( (xxx-a(1)).^2 + (yyy-a(2)).^2 + (zzz-a(3)).^2 - a(4).^2 );
      options = optimset('TolFun',1e-3,'TolX',1e-3);
      af2 = fminsearch(f, a0,options);
    catch
    end
    warning on all

    result = af2;

  case 'getindexonbrain'
    if(nargin~=5)
            error('GetBrainFuncFromStylus(''GetIndexOnBrain'',...) : specify 5 input arguments\n');
    end
    result = 0; % initial value 0 means "not found"
    Brain = varargin{2}; % Brain Func Dictionaly
    headpoint = varargin{3}; % Head surface point -> changed to stylus point
    norm_vec = varargin{4}; % Normal vector on Head surface point
    tr_end = varargin{5}; % cancidate search width in y-axis along norm_vec
    
    tr_unit=1;
    bx1=Brain(:,1)-headpoint(1); by1=Brain(:,2)-headpoint(2); bz1=Brain(:,3)-headpoint(3);
    [theta, phi, nrm_l] = cart2sph(norm_vec(1), norm_vec(2), norm_vec(3));
  
    cos_theta = cos(theta); sin_theta = sin(theta);
    bx2 = bx1*cos_theta + by1*sin_theta;
    by2 = -bx1*sin_theta + by1*cos_theta;
    clear bx1 by1;
  
    trange=[]; tr=tr_unit;
    while length(trange) < 10
      trange=find(abs(by2) < tr);
      tr=tr+tr_unit;
      if tr > tr_end
        return;
      else
        continue;
      end
    end
    bx2=bx2(trange); bz2=bz1(trange);
 
    clear bz1;
  
    cos_phi=cos(phi); sin_phi=sin(phi);
    bx3 = bx2*cos_phi + bz2*sin_phi;
    bz3 = -bx2*sin_phi + bz2*cos_phi;
    clear bx2 bz2;
  
    prange=[]; tr2=tr_unit;
    while isempty(prange)
      prange=find(abs(bz3) < tr2);
      tr2=tr2+tr_unit;
      if tr2 > tr && isempty(prange)
        return;
      end
    end
    clear bz3;
  
    index3=trange(prange);
    work = find(max(bx3(prange))==bx3(prange));
    %index = index3(work(1));
    result = index3(work(1));
    
end

function indeces = GetIndexAroundPos(H_sphere, pos_theta, pos_phi, req_points)
for delta=1:1:45
	indeces = [];
	min_theta = max(pos_theta-delta,1);
	max_theta = min(pos_theta+delta,361);
	min_phi = pos_phi-delta;
	max_phi = pos_phi+delta;
	if(min_phi<=0)
%		max_phi = max_phi - min_phi +1;
		min_phi = 1;
    min_theta=1;    max_theta=360;
  end
  if(max_phi>181)
    max_phi = 181;
    min_theta=1;    max_theta=360;
  end

	for c_phi=min_phi:1:max_phi
		for c_theta=min_theta:1:max_theta
			r_theta = rem(c_theta-1,360)+1;
			indeces = [indeces H_sphere(r_theta,c_phi).index];
		end
	end
	indeces = unique(indeces);

	[row col] = size(indeces);
	if(col>=req_points) 
        break
    end
end

