function snirf = read_snirf(fileName)

% snirf = read_snirf(fileName)
% 
% Reader of a Shared Near Infrared Spectroscopy Format (SNIRF) file.
% 
% The specification of SNIRF can be found at
% https://github.com/fNIRS/snirf/blob/master/snirf_specification.md
% 

% (C) Hiroshi Kawaguchi, Ph.D., AIST, Japan

% History
% 
% 2023-02-01 First version
% 


% for DEBUG
% fileName =('/Users/kwgc/Desktop/Project_FRESH/test/sub-01/ses-01/nirs/sub-01_ses-01_task-FRESHAUDIO_nirs.snirf');

formatVersion = CheckVersion(fileName);

snirf.fileName = fileName;
snirf.formatVersion = formatVersion;


info = h5info(fileName,'/');

nNirs = numel(info.Groups); % number of /nirs{i}
nirs = repmat(struct([]),nNirs,1);

for n = 1:nNirs

    nirsRootName = info.Groups(n).Name;
    subInfo = h5info(fileName,nirsRootName);
    
    % Read metaDataTags
    metadata = ReadMetaDataTag(fileName,strjoin({nirsRootName,'metaDataTags'},'/'));
    nirsstr.metaDataTags = metadata;
    
    % Read probe
    probe    = ReadProbe(fileName,strjoin({nirsRootName,'probe'},'/'));
    nirsstr.probe = probe;

    % Read data
    nData   = GetNumGroups(subInfo.Groups,'data'); % number of data{i}
    data = repmat(struct([]),nData,1);
    for m = 1:nData
        dataRootName = [nirsRootName, '/', 'data', int2str(m)];
        if m >1
            data(m) = ReadData(fileName,dataRootName);
        else
            data = ReadData(fileName,dataRootName);
        end
        nirsstr.data = data;
    end
    
    % Read stim
    nStim   = GetNumGroups(subInfo.Groups,'stim'); % number of stim{i}
    if nStim >0
        stim = repmat(struct([]),nStim,1);
        for m = 1:nStim
            stimRootName = [nirsRootName, '/', 'stim', int2str(m)];
            if m >1
                stim(m) = ReadStim(fileName,stimRootName);
            else
                stim = ReadStim(fileName,stimRootName);
            end
        end
        nirsstr.stim = stim;
    end
    % Read aux
    nAux   = GetNumGroups(subInfo.Groups,'aux'); % number of aux{i}
    if nAux >0
        aux = repmat(struct([]),nAux,1);
        for m = 1:nStim
            auxRootName = [nirsRootName, '/', 'aux', int2str(m)];
            if m >1
                aux(m) = ReadAux(fileName,auxRootName);
            else
                aux = ReadAux(fileName,auxRootName);
            end
        end
        nirsstr.aux = aux;
    end
    
    if n > 1
        nirs(n) = nirsstr;
    else
        nirs = nirsstr;
    end
end



snirf.nirs = nirs;




% END OF MAIN FUNCTION

    function sstr = ReadStim(fileName,spath)
        required ={...
            'name'
            'data'
            };
        optional = {'dataLabels'};

        sstr = ReadValuesToStruct(fileName,spath,required,optional);
    end

    function dstr = ReadData(fileName,spath)
        required ={...
            'dataTimeSeries'
            'time'};

        dstr = ReadValuesToStruct(fileName,spath,required,[]);

       % read measurement list
        dinfo = h5info(fileName, spath);
        nML = GetNumGroups(dinfo.Groups,'measurementList');
        ml = repmat(struct([]),nML,1);
        for num = 1:nML
            mlRootName = [spath, '/', 'measurementList', int2str(num)];
            if num >1
                ml(num) = ReadMeasurementList(fileName, mlRootName);
            else
                ml= ReadMeasurementList(fileName, mlRootName);
            end
        end

        dstr.MeasurementList = ml;
    end


    function ml = ReadMeasurementList(fileName, spath)
        required = {
            'sourceIndex'
            'detectorIndex'
            'wavelengthIndex'
            'dataType'
            'dataTypeIndex'
            };
        optional ={...
            'wavelengthActual'
            'wavelengthEmissionActual'
            'dataUnit'
            'dataTypeLabel'
            'sourcePower'
            'detectorGain'
            'moduleIndex'
            'sourceModuleIndex '
            'detectorModuleIndex '
            };
        ml = ReadValuesToStruct(fileName,spath,required,optional);

    end

    function md = ReadMetaDataTag(fileName,spath)
        required ={...
            'SubjectID'
            'MeasurementDate'
            'MeasurementTime'
            'LengthUnit'
            'TimeUnit'
            'FrequencyUnit'
            };

        md = ReadValuesToStruct(fileName,spath,required,[]);

    end


    function pr = ReadProbe(fileName,spath)
        required = {...
            'wavelengths'
            'sourcePos2D'
            'sourcePos3D'
            'detectorPos2D'
            'detectorPos3D'
            };
        optional ={...
            'wavelengthsEmission'
            'frequencies'
            'timeDelays'
            'timeDelayWidths'
            'momentOrders'
            'correlationTimeDelays'
            'correlationTimeDelayWidths'
            'sourceLabels'
            'detectorLabels'
            'landmarkPos2D'
            'landmarkPos3D'
            'landmarkLabels'
            'coordinateSystem'
            'coordinateSystemDescription'
            'useLocalIndex'};
        
        pr = ReadValuesToStruct(fileName,spath,required,optional);

        if ~CheckPosition(pr)
            error('Neither Pos2D nor Pos3D not found.')
        end

        function tf = CheckPosition(pr)
            tf = ...
                (isfield(pr,'sourcePos3D') && isfield(pr,'detectorPos3D')) || ...
                (isfield(pr,'sourcePos2D') && isfield(pr,'detectorPos2D'));
        end

    end

    function str = ReadValuesToStruct(fileName,spath,required,optional)
        %  struct with dummy field
        str = struct('tmp',[]);

        if ~isempty(required)
            for num = 1:numel(required)
                v = GetFieldData(fileName,spath, required{num},true);
                if isempty(v)
                    continue
                end
                str.(required{num}) = v; %#ok<*SFLD>
            end
        end

        if ~isempty(optional)
            for num = 1:numel(optional)
                v = GetFieldData(fileName,spath, optional{num},false);
                if isempty(v)
                    continue
                end
                str.(optional{num}) = v; %#ok<*SFLD>
            end
        end
        str = rmfield(str,'tmp'); % remove dummy field

        
    end



    function v = GetFieldData(fileName, spath, field, isrequired)
        dpath = [spath, '/', field];
        v = [];
        try
            v  = h5read(fileName,dpath);
        catch
            if isrequired
                warning(['Cannot read ' dpath] );
            end
        end
    end


    function v = CheckVersion(fileName)
        v = h5read(fileName,'/formatVersion');
        
        switch v
            case '1.0'
            otherwise
            error('File version is invalid')
        end
    end


    function num = GetNumGroups(grp,str)
        % Get number of groups that contains 'str' in its name
        names = {grp.Name};
        tf = cellfun(@contains,names,repmat({str},size(names)));
        num = sum(tf);
    end

    

end