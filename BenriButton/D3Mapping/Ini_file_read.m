function [Serial Std_Ref GuiAppli Navigation D3View] = Ini_file_read(fid)

Serial = struct('Port','com1','BaudRate',115200,'Parity','none','Device','isotrak2');
Std_Ref = struct('LeftEar',[],'RightEar',[],'Nasion',[],'Back',[],'Top',[]);

GuiAppli = struct('GetProbePos',[],'Navigation',[],'HeadSurfaceVertex',[],...
	'HeadSurfaceEdge',[],'BrainSurfaceVertex',[],'BrainSurfaceEdge',[]);
Navigation = struct('HeadSurfaceFile',[],'BrainDicFile1',[],'BrainDicFile2',[]);

D3View = struct('BrainSurfaceFile',[],'BrainResolutionIn2Power',[],...
    'Observed_RefPoints',[]);

pos_Cz=[0.0,0.0,0.0];
pos_Nz=[0.0,0.0,0.0];
pos_Iz=[0.0,0.0,0.0];
pos_AR=[0.0,0.0,0.0];
pos_AL=[0.0,0.0,0.0];

line=fgetl(fid);
[rows colms]=size(line);
while(line~=-1)
	if(line(1,1)=='[')
		last_idx=findstr(line,']');
		read_mode = line(1,2:(last_idx-1));
	else
		split_idx=findstr(line,'=');
		[size_row size_col]=size(split_idx);
		if(size_col<=0), continue, end;
		split_idx=split_idx(1,1);
		Param_Name = line(1,1:(split_idx-1));
    if(colms<=split_idx)
      Param_Value=' ';
    else
		  Param_Value = line(1,(split_idx+1):end);
    end

		switch read_mode
		case 'Serial'
			switch lower(Param_Name)
			case 'port'
				Serial.Port=Param_Value;
			case 'baudrate'
				Serial.BaudRate=str2num(Param_Value);
			case 'parity'
				Serial.Parity=Param_Value;
			case 'device'
				Serial.Device=Param_Value;
            end
		case 'D3View'
			switch lower(Param_Name)
			case 'brainresolutionin2power'
			    D3View.BrainResolutionIn2Power=str2num(Param_Value);
	        case 'observed_refpoints'
			    D3View.Observed_RefPoints=Param_Value;
            end
		otherwise
			switch lower(Param_Name)
			case 'x'
				xyz_index = 1;
			case 'y'
				xyz_index = 2;
			case 'z'
				xyz_index = 3;
			end
			switch lower(read_mode)
			case 'leftear'
				pos_AL(1,xyz_index)=str2num(Param_Value);
			case 'rightear'
				pos_AR(1,xyz_index)=str2num(Param_Value);
			case 'nasion'
				pos_Nz(1,xyz_index)=str2num(Param_Value);
			case 'back'
				pos_Iz(1,xyz_index)=str2num(Param_Value);
			case 'top'
				pos_Cz(1,xyz_index)=str2num(Param_Value);
			end
		end
    end
    line=fgetl(fid);
    [rows colms]=size(line);
end

Std_Ref.LeftEar=pos_AL;
Std_Ref.RightEar=pos_AR;
Std_Ref.Nasion=pos_Nz;
Std_Ref.Back=pos_Iz;
Std_Ref.Top=pos_Cz;

GuiAppli.GetProbePos = 'BenriButton\D3Mapping\bin\HeadSurfaceGUI.exe';
GuiAppli.Navigation = 'BenriButton\D3Mapping\bin\Brain_HeadSurfaceGUI.exe';
GuiAppli.HeadSurfaceVertex='BenriButton\D3Mapping\HeadBrainData\HeadSurfVertex.txt';
GuiAppli.HeadSurfaceEdge='BenriButton\D3Mapping\HeadBrainData\HeadSurfEdge.txt';
GuiAppli.BrainSurfaceVertex='BenriButton\D3Mapping\HeadBrainData\BrainSurfVertex.txt';
GuiAppli.BrainSurfaceEdge='BenriButton\D3Mapping\HeadBrainData\BrainSurfEdge.txt';

Navigation.HeadSurfaceFile='BenriButton\D3Mapping\HeadBrainData\HeadSurfEdge.mat';
Navigation.BrainDicFile1='BenriButton\D3Mapping\HeadBrainData\BrainMap1.mat';
Navigation.BrainDicFile2='BenriButton\D3Mapping\HeadBrainData\BrainMap2.mat';

D3View.BrainSurfaceFile='BenriButton\D3Mapping\HeadBrainData\BrainSurfEdge.mat';
