% Script M-File  : Check Size of Block
%    Input  : 
%         strctMultiBlock : Structure of Multi Block 
%    Output : 
%          blocksize : size of Block in need
%
%    Cleared Variable
%           blocksize1 blocksize2 blocksize3 blocksize4 tmp;
%
%  Use Script File not to use neevr need Memory


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Argument Check
if ~exist('strctMultiBlock', 'var')
  OSP_LOG('perr','No structMultiBlock');
  error('No structMultiBlock');
end
if exist('tmp', 'var') || ...
      exist('blocksize1', 'var') || ...
      exist('blocksize2', 'var') || ...
      exist('blocksize3', 'var') || ...
      exist('blocksize4', 'var')
  OSP_LOG('perr','Working Space have forbidden Variable');
  error('Working Space have forbidden Variable');
end

% temporaly data
tmp = 1:length(strctMultiBlock);
[blocksize1{tmp}] = deal(strctMultiBlock.blocknum);

% Check Block Number
blocksize1 = [blocksize1{:}]; blocksize(1) = sum(blocksize1);

% Check Block (number of sampling) size
[blocksize2{tmp}] = deal(strctMultiBlock.maxblock);
blocksize2 = [blocksize2{:}]; blocksize(2) = max(blocksize2);

% Check Number of Channel
[blocksize3{tmp}] = deal(strctMultiBlock.chnum);
blocksize3 = [blocksize3{:}]; blocksize(3) = blocksize3(1);
if ~all(blocksize3 == blocksize(3))
  OSP_LOG('dbg','Number of Channel is different');
  error('Number of Channel in the Group is different');
end

% Check Number of HB-Kind
[blocksize4{tmp}] = deal(strctMultiBlock.hbkindnum);
blocksize4 = [blocksize4{:}]; blocksize(4) = max(blocksize4);
clear blocksize1 blocksize2 blocksize3 blocksize4 tmp;
