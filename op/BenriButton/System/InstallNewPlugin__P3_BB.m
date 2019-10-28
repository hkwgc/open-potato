function str = InstallNewPlugin__P3_BB(hs)

%- my name
str='Install new plugin';
if nargin<=0,return;end
%- 

p=uigetdir;
p3p=which('P3');
tg=strfind(p,filesep);
p3p=[p3p(1:end-4) 'PluginDir' p(tg(end):end)];
copyfile(p,p3p,'f');

[FilterList, Regions, DispKind] = OspFilterDataFcn('ListReset');
OspFilterCllbacks('pop_FilterDispKind_Callback',...
     hs.pop_FilterDispKind,[],hs);