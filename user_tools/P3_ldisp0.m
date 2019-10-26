function str=P3_ldisp0(data,mod)
% data to String, where data must be string

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

if nargin<=1,
  mod=0;
end

% --> Change by Mode.
switch mod
  case 0,
    % Normal : Structure
    str=mode0(data);
  case 10,
    % Simple String for 2nd-Lvl-Ana 
    %  (1st-Lvl-Ana Selector)
    str=mode10(data);
  otherwise
    error('Undefined Mode');
end

function str=mode10(data)
% Simple String for 2nd-Lvl-Ana
%  -->(1st-Lvl-Ana Selector)
c=class(data);
switch c,
  case 'struct',
    str='struct...';
  case 'cell',
    %-------------
    str='cell...';
  case 'char',
    str=data;
 otherwise,
   if isnumeric(data)
     str='[';
     for idx=1:min(length(data(:)),10)
       str=[str num2str(data(idx)) ' '];
     end
     if length(data(:))>10
       str(end:end+3)='...]';
     else
       str(end)=']';
     end
   else
     error('Undefined Data : TODO Display String for 1st-Lvl-Ana Key');
   end
end

function str=mode0(data)
c=class(data);
switch c,
  case 'struct',
    fn=fieldnames(data);
    str={'Struct : '};
    dum= '       | ';
    for idx=1:length(fn),
      s0=sprintf('%s %s: ',dum,fn{idx});
      s1=P3_ldisp0(eval(['data.' fn{idx}]));
      s1=char(s1);
      s = [repmat(s0,[size(s1,1),1]), s1];
      s = cellstr(s);
      str={str{:},s{:}};
    end
  case 'cell',
    %-------------
    str= 'Cell : {';
    dum= '     | ';
    sz=size(data);
    for idx=1:length(sz)
      str=[str num2str(sz(idx)) 'x'];
    end
    str(end)='}';
    str={str};
    for idx=1:prod(sz)
      s0=sprintf('%s %d: ',dum,idx);
      s1=P3_ldisp0(data{idx});
      s1=char(s1);
      s = [repmat(s0,[size(s1,1),1]), s1];
      s = cellstr(s);
      str={str{:},s{:}};
    end

  case 'char',
    str={data};
 otherwise,
   if isnumeric(data)
     str='[';
     for idx=1:min(length(data(:)),10)
       str=[str num2str(data(idx)) ' '];
     end
     if length(data(:))>10
       str(end:end+3)='...]';
     else
       str(end)=']';
     end
     str={str};
   else
     str={c};
   end
end
