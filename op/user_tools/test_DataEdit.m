function [rdata, tag]=test_DataEdit(varargin);
% Test Program for OSP_DataEdit
% 
% You can use This Function 3D-Matrix Editor
%   test_DataEdit(data,tag, tagDim3);
%      data is edit 3-D Matrix
%      tag  is Name of each Dimension
%      tagDim3 is Name of 3-Dimensional element
%
%   test_DataEdit(data,tag);
%      use default tagDim3
%
%   test_DataEdit(data);
%      use default tag tagDim3
%
%
%     Exsample 
%       data is HB-Data :  Time x Channel x HB Kind 
%       tag = {'Time','Channel','HB Kind'};
%
%       if HB-Kind is 2 (size(data,3)==2) 
%          and mean Oxy, Deoxy HB Data
%       tagDim3 ={'Oxy','Deoxy'}
%         

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original auther : Masanori Shoji
% create : 2004.12.23
% $Id: test_DataEdit.m 180 2011-05-19 09:34:28Z Katura $
%

if nargin ~= 0
    data=varargin{1};
    if ndims(data) >3
        error('Dimension of Data must be 3');
    elseif ndims(data) ==2
        sz=size(data);
        sz(3)=1;
        data=reshape(data,sz);
    end
    
    if nargin >=2
        tag = varargin{2};
    else
        tag={'Dim1','Dim2','Dim3'};
    end
    
    if nargin >=3
        tagDim3 = varargin{3};
    else
        tagDim3= {'1st','2nd','3rd'};  %  Error can be ignore in OSP_DataEdit
    end
    
    [rdata tag]=OSP_DataEdit('Data',data,...
        'Tag',tag,...
        'TagDim3',tagDim3,...
        'EditNum',16);
    
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Test Mode
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    sz=[200 40 3];
    
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Make Mat-File for Import-Test 
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    sz2=sz; sz2(3)=1;
    data=rand(sz2)+3.5;
    save('testDataEdit_import.mat','data');
    
    Fname='test_data';
    hoge =' Dust-Data test';
    hoge2=rand(24,31);
    save('testDataEdit_import.mat','Fname','data','hoge','hoge2');
    
    sz2(3)=4;
    data=rand(sz2)+6;
    save('testDataEdit_import_4.mat','data');
    clear data;
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Make TestData
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %testdata=rand(sz+1)+4;
    testdata=rand(sz)+4;
    testdata_tag={'time','Channel(T)','HB Kind(T)'};
    testdata_tagDim3={'Oxy(t)', 'Deoxy(t)', 'Total HB(t)'};
    
    %~~~~~~
    % Run
    %~~~~~~
    [rdata tag]=OSP_DataEdit('Data',testdata,...
        'Tag',testdata_tag,...
        'TagDim3',testdata_tagDim3,...
        'EditNum',15);
    
    disp(tag);
    disp(size(rdata));
    
end
