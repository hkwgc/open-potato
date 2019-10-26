function str=ImportBrainHeadFile__P3_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Import BH-File';
if nargin<=0,return;end
HeadSurfaceSet=0;
BrainSurfaceSet=0;
BrainMapDic1=0;
BrainMapDic2=0;

try
    current_dir = pwd;
    osp_path=OSP_DATA('GET','OspPath');
    if isempty(osp_path)
      osp_path=fileparts(which('POTATo'));
    end
    [pp ff] = fileparts(osp_path);
    if( strcmp(ff,'WinP3')~=0 )
      try
        cd('WinP3_mcr\BenriButton\D3Mapping\HeadBrainData');
        target_dir=pwd;
      catch
        uiwait(msgbox([...
'WinP3_mcr\BenriButton\D3Mapping\HeadBrainData' ...
 ': current is ' current_dir],'Cannot find directory') );
        return;
      end
    else
        cd('BenriButton\D3Mapping\HeadBrainData');
        target_dir=pwd;
    end
    cd(current_dir);
    dir_name=uigetdir('','specify Dir contains Brain Head Files');
    if(isnumeric(dir_name))
        uiwait(msgbox(['Import : cancelled']) );
        return;
    else
        cd(dir_name);
        if(exist('HeadSurfEdge.mat','file')&&...
            exist('HeadSurfEdge.txt','file')&&...
            exist('HeadSurfVertex.txt','file') )
            HeadSurfaceSet=1;
        end
        if(exist('BrainSurfEdge.mat','file')&&...
            exist('BrainSurfEdge.txt','file')&&...
            exist('BrainSurfVertex.txt','file') )
            BrainSurfaceSet=1;
        end
        if(exist('BrainMap1.mat','file') )
            BrainMapDic1=1;
        end
        if(exist('BrainMap2.mat','file') )
            BrainMapDic2=1;
        end
    end
    if(HeadSurfaceSet==1)
        selection = questdlg('Import HeadSurf Data?',...
            'Select Yes/No','Yes','No','Yes');
        if(strcmp(selection,'Yes') )
            [status,message,messageId]=copyfile('HeadSurfEdge.mat',...
            target_dir,'f');
            [status,message,messageId]=copyfile('HeadSurfEdge.txt',...
            target_dir,'f');
            [status,message,messageId]=copyfile('HeadSurfVertex.txt',...
            target_dir,'f');
        end
    end
    if(BrainSurfaceSet==1)
        selection = questdlg('Import BrainSurf Data?',...
            'Select Yes/No','Yes','No','Yes');
        if(strcmp(selection,'Yes') )
            [status,message,messageId]=copyfile('BrainSurfEdge.mat',...
            target_dir,'f');
            [status,message,messageId]=copyfile('BrainSurfEdge.txt',...
            target_dir,'f');
            [status,message,messageId]=copyfile('BrainSurfVertex.txt',...
            target_dir,'f');
        end
    end
    if(BrainMapDic1==1)
        selection = questdlg('Import Brain Map1 Dictionary?',...
            'Select Yes/No','Yes','No','Yes');
        if(strcmp(selection,'Yes') )
            [status,message,messageId]=copyfile('BrainMap1.mat',...
            target_dir,'f');
        end
    end
    if(BrainMapDic2==1)
        selection = questdlg('Import Brain Map2 Dictionary?',...
            'Select Yes/No','Yes','No','Yes');
        if(strcmp(selection,'Yes') )
            [status,message,messageId]=copyfile('BrainMap2.mat',...
            target_dir,'f');
        end
    end
    cd(current_dir);
catch
    cd(current_dir);
    errordlg(lasterr);
    return;
end

return;
