function h=P3_ApplyLineProperty(curdata,h,tag,od)
%  Apply Line Property to Handle h, for P3 Arix-Object Plugin.
%
% -------------------------------------------
% Syntax : 
%  h=P3_ApplyLineProperty(curdata,h,tag,od)
% - - - - - - - - - - - - - - - - - - - - - - 
%  h       : Line Handle 
%  curdata : Current Data of P3 Viewer (II)
%  tag     : Name of the Plotting Line
%  od      : ID of the Ploting Data.
% -------------------------------------------
%
% Connected Sources :
%    P3_ApplyAreaProperty     : Making curdata setting.
%    osp_ViewAxesObj_LinePlot : Example of Useing ot the code
%    Lparts_AreaTgl_Primary   : Setting of LineProperty
%    ViewGroupArea            : Convert VGArea --> VGG/VGC
%
% ---> more information <---
%    LayoutEditor             : Control for Making Layout
%    osp_LayoutViewer         : Startup of Drawing
%    ViewGroupGroup           : Area of Channel Distribution
%    ViewGroupCallback        : Normal Area of P3.
%    ViewGroupAxes            : Axes-Draw Area.
%
% -------------------------------------------
% Feature :
%   A.  Known Bugs
%       Marker Color Setting.
%       I think,..
%         this Bug must be fix in Lparts_AreaTgl_Primary.
%
%   B.  Apply Patch, Surface, and so on.
%         How to : switch by type of Handle


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2007.03.25
%  // Checking at 25-Mar-2007
%
% $Id: P3_ApplyLineProperty.m 180 2011-05-19 09:34:28Z Katura $


try
  % Is there LineProperty?
  if ~isfield(curdata,'LineProperty'),return;end
  
  %-----------
  % Check Tags
  %-----------
  if isstruct(tag)
    tag=tag.TAGs.DataTag{od};
  end
  tagidx=find(strcmpi({curdata.LineProperty.TAG.Name},tag));
  if ~isempty(tagidx)
    set(h,curdata.LineProperty.TAG(tagidx(1)).Property{:});
    return;
  end
  
  %-------------
  % Check Order
  %-------------
  if nargin<4,return;end
  if od<=length(curdata.LineProperty.ORDER) && ...
      ~isempty(curdata.LineProperty.ORDER{od})
    set(h,curdata.LineProperty.ORDER{od}{:});
  end
catch
  warning(['Faild to Apply Line Property : ' lasterr]);
end