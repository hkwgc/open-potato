function subLAYOUT_checkRegion(region)

if ~strcmpi(evalin('caller','curdata.region'),region)
	uiwait(...
		warndlg(sprintf('This LAYOUT is for [%s].\nPlease check the recipe.',region),...
		'Warnning: LAYOUT','modal')...
		);
	evalin('caller','curdata=[];');
	return;
end

	
