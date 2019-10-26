function Matrix = affine_trans(varargin)
% affine convert from real-3D vector to 
%      This module has 5 functions.
%
%    (1)Ma = affine_trans('make_mat',Observed_RefPoints)
%    input : 2 arguments
%      1st(string) : 'make_mat' indicates make affine translate matrix operation
%      2nd(5x3 double) : Observed_RefPoints is refference points vectors
%        in array case:
%            5 vectors consist below sequence and resulting 5x3 matrix:
% [RightEar_vector; RightEar_vector; Nasion_vector; Back_vector; Top_vector]
%            remark: each vetcor is column vector(not row matrix)
%        in struct case:
%           struct contains 5 vectors consist below elements or 5x3 matrix
%              (here b is copied struct name)
%       sequence case exmample:[b.LeftEar,b.RightEar,b.Nasion,b.Back,b.Top]'
%       5x3 matrix case exmample:b.S10_20
%       these specification is done in D3_ini.txt file
%    output(4x4) : affine translate matrix
%
%    (2)Std_vec = affine_trans('translate', Ma, Observed_vec)
%    input : 3 arguments
%      1st(string) : 'translate' indicates affine translate operation
%      2nd(4x4 matrix) : affine translate matrix made by (1)-operation.
%      3rd(Nx3 double) : input vectors (Observed N-vectors)
%            remark: each vetcor is column vector(not row matrix)
%    output : output vectors translated by Ma*Observed_vec
%   
%   (3)Minv = affine_trans('make_inv',Observed_RefPoints)
%    input : 2 arguments
%    1st(string) : 'make_inv' indicates make inverse translate matrix operation
%    2nd(5x3 double) : Observed_RefPoints is refference points vectors
%            5 vectors consist below sequence and resulting 5x3 matrix:
% [RightEar_vector; RightEar_vector; Nasion_vector; Back_vector; Top_vector]
%            remark: each vetcor is column vector(not row matrix)
%    output(4x4) : affine inverse translate matrix
%
%   (4)Msize = affine_trans('get_size_part',Minv)
%    input : 2 arguments
%    1st(string) : 'get_size_part' indicates get size-part of inverse matrix
%    2nd(4x4 double) : inverse-affine translate matrix made by (3)-operation.
%    output(3x3) : size part of affine inverse translate matrix   
%
%   (5)Obs_sized = affine_trans('observed_size_translate', Msize, Std_vec)
%      1st(string) : 'observed_size_translate' indicates
%                    size-translate of std vectors to observed vectors in size
%      2nd(3x3 matrix) : size part of affine inverse translate matrix
%                    made by (4)-operation
%      3rd(Nx3 double) : input vectors (Std N-vectors)
%            remark: each vetcor is column vector(not row matrix)
%    output : output vectors translated by Msize*Std_vec

[dum nargin] = size(varargin);

if( (nargin<2) || (nargin)>3 )
    error('affine_trans() : specify 2 or 3 input argments\n');
end

switch lower(varargin{1})
    case 'make_mat'
        if(nargin~=2)
            error('affine_trans(''make_mat'',vec) : specify 2 input arguments\n');
        end
        IniFile='\ini\D3_ini.txt';

	try
          fid=fopen(IniFile,'r');
	catch
          error(['Ini-File not opend: ' IniFile]);
          return;
	 end
        [Serial Std_Ref GuiAppli Navigation D3View]=Ini_file_read(fid);
        fclose(fid);

        if isstruct(varargin{2})
          b=varargin{2};
          try
              if( (isfield(b,'LeftEar'))&&(isfield(b,'RightEar'))&&...
                      (isfield(b,'Nasion'))&&(isfield(b,'Back'))&&...
                      (isfield(b,'Top')) )
                  Observed_RefPoints = [b.LeftEar,b.RightEar,b.Nasion,b.Back,b.Top]';
              elseif( isfield(b,'S10_20') )
                  Observed_RefPoints = b.S10_20;
              else
                  Observed_RefPoints = eval(D3View.Observed_RefPoints);
              end
          catch
            error('affine_trans(''make_mat'',Base) : specify Pos.D3.Base.\n');
          end
        else
          Observed_RefPoints = varargin{2};
        end
        [row col] = size(Observed_RefPoints);
        if( (row~=5) || (col~=3) )
            error('affine_trans(''make_mat'',vec) : specify 5x3 matrix to vec\n');
        end
        if( ~isnumeric(Observed_RefPoints) )
            error('affine_trans(''make_mat'',vec) : specify numeric value to vec\n');
        end

        S = [Std_Ref.LeftEar' Std_Ref.RightEar' Std_Ref.Nasion' ...
            Std_Ref.Back' Std_Ref.Top'];
        S = [S; [1 1 1 1 1]];
        O = [Observed_RefPoints'; [1 1 1 1 1]];
        sS = sparse(S);
        sO = sparse(O);
        sAos = sS / sO;
        Matrix = full(sAos);
    case 'translate'
        if(nargin~=3)
            error('affine_trans(''make_mat'',Ma,vec) : specify 3 input arguments\n');
            return;
        end
        Ma = varargin{2};
        [row col] = size(Ma);
        if( (row~=4) || (col~=4) )
            error('affine_trans(''translate'',Ma,vec) : specify 4x3 matrix to Ma\n');
            return;
        end
        if( ~isnumeric(Ma) )
            error('affine_trans(''translate'',Ma,vec) : specify numeric value to Ma\n');
            return;
        end
        Observed_vec = varargin{3};
        [row col] = size(Observed_vec);
        if( col~=3 )
            error('affine_trans(''translate'',Ma,vec) : specify Nx3 matrix to vec\n');
            return;
        end
        if( ~isnumeric(Observed_vec) )
            error('affine_trans(''translate'',Ma,vec) : specify numeric value to vec\n');
            return;
        end
        Observed_vec(:,4) = 1.0;
        Observed_vec = Observed_vec';
        Std_vec = Ma*Observed_vec;
        Matrix = Std_vec(1:3,:);
        Matrix = Matrix';
    case 'make_inv'
        if(nargin~=2)
            error('affine_trans(''make_inv'',vec) : specify 2 input arguments\n');
        end
        IniFile='\ini\D3_ini.txt';

	try
          fid=fopen(IniFile,'r');
	catch
          error(['Ini-File not opend: ' IniFile]);
          return;
	 end
        [Serial Std_Ref GuiAppli Navigation D3View]=Ini_file_read(fid);
        fclose(fid);

        Observed_RefPoints = varargin{2};
        [row col] = size(Observed_RefPoints);
        if( (row~=5) || (col~=3) )
            error('affine_trans(''make_inv'',vec) : specify 5x3 matrix to vec\n');
        end
        if( ~isnumeric(Observed_RefPoints) )
            error('affine_trans(''make_inv'',vec) : specify numeric value to vec\n');
        end

        S = [Std_Ref.LeftEar' Std_Ref.RightEar' Std_Ref.Nasion' ...
            Std_Ref.Back' Std_Ref.Top'];
        S = [S; [1 1 1 1 1]];
        O = [Observed_RefPoints'; [1 1 1 1 1]];
        sS = sparse(S);
        sO = sparse(O);
        sAso = sO / sS;
        Matrix = full(sAso);
    case 'get_size_part'
        if(nargin~=2)
            error('affine_trans(''get_size_part'',matrix) : specify 2 input arguments\n');
        end

        Aso = varargin{2};
        [row col] = size(Aso);
        if( (row~=4) || (col~=4) )
            error('affine_trans(''get_size_part'',matrix) : specify 4x4 matrix to matrix\n');
        end
        if( ~isnumeric(Aso) )
            error('affine_trans(''make_inv'',matrix) : specify numeric value to matrix\n');
        end

        Aso_part = Aso(1:3,1:3);
        x_in_o=Aso_part*[1 0 0]';
        lx_in_o=norm(x_in_o);
        x_in_o=x_in_o/lx_in_o;

        y_in_o=Aso_part*[0 1 0]';
        ly_in_o=norm(y_in_o);
        y_in_o=y_in_o/ly_in_o;

        z_in_o=Aso_part*[0 0 1]';
        lz_in_o=norm(z_in_o);
        z_in_o=z_in_o/lz_in_o;

        Aso_rot = [x_in_o y_in_o z_in_o];
        Matrix = Aso_part/Aso_rot;

    case 'observed_size_translate'
        if(nargin~=3)
            error('affine_trans(''observed_size_translate'',Msize,vec) : specify 3 input arguments\n');
            return;
        end
        Msize = varargin{2};
        [row col] = size(Msize);
        if( (row~=3) || (col~=3) )
            error('affine_trans(''observed_size_translate'',Msize,vec) : specify 3x3 matrix to Msize\n');
            return;
        end
        if( ~isnumeric(Msize) )
            error('affine_trans(''observed_size_translate'',Msize,vec) : specify numeric value to Msize\n');
            return;
        end
        Std_vec = varargin{3};
        [row col] = size(Std_vec);
        if( col~=3 )
            error('affine_trans(''observed_size_translate'',Msize,vec) : specify Nx3 matrix to vec\n');
            return;
        end
        if( ~isnumeric(Std_vec) )
            error('affine_trans(''observed_size_translate'',Msize,vec) : specify numeric value to vec\n');
            return;
        end
        Std_vec = Std_vec';
        Matrix = Msize*Std_vec;
        Matrix = Matrix';

end
