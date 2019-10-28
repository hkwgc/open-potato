function curdata=P3_ApplyAreaProperty(curdata,LP)
%  Apply curdata to LP.Property


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: P3_ApplyAreaProperty.m 180 2011-05-19 09:34:28Z Katura $
if ~isfield(LP,'Property'),return;end

% Script
if isfield(LP.Property,'Script')
  for sid=1:length(LP.Property.Script)
    try
      eval(LP.Property.Script{sid});
    catch
      disp('-------------------------');
      disp(' Area : Script Error');
      disp(['        Named : ' LP.NAME]);
      disp(lasterr);
      disp(' * Bad Layout');
      disp('-------------------------');
    end
  end
end

%CObject
if isfield(LP.Property,'SelectData'),
  % Modify 
  tmp=LP.Property.SelectData{1};
  try
    switch tmp
      case 'Continuous'
        curdata.region=tmp;
      case {'Auto','auto','AUTO','Default','default'}
      otherwise
        error(['Unexpected Value ' tmp]);
    end
  catch
    warndlg({'Too Old Layout :',...
      '  xx Unexpected Initial-Value for Select-Data''s Region.'},...
      'Too Old Layout: 20071019','replace');
  end
  curdata.cid0=min(LP.Property.SelectData{2},curdata.cidmax);
  curdata.bid0=LP.Property.SelectData{3};
end
if isfield(LP.Property,'Channel'),
  curdata.ch=LP.Property.Channel;
end
if isfield(LP.Property,'DataKind'),
  curdata.kind=LP.Property.DataKind;
end
% 
% LineProperty
if isfield(LP.Property,'LineProperty'),
  curdata.LineProperty=LP.Property.LineProperty;
end
%   if isfield(LP.Property.LineProperty,'TAG'),
%     for id=1:length(LP.Property.LineProperty.TAG),
%       h=LP.Property.LineProperty.TAG(id).Property;
%       eval(h);
%     end
%   end
%   if isfield(LP.Property.LineProperty,'ORDER'),
%     for id=1:length(LP.Property.LineProperty.ORDER),
%       h=LP.Property.LineProperty.TAG(id).Property;
%       for eid=1:2:length(h);
%         a=h{eid},h{eid+1}
%       eval(a);
%       end
%     end
%   end
% end