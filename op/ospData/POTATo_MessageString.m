function s=POTATo_MessageString(name)
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================






[names,str]=subMake;

s=str{strcmp(names,name)};

function [n,s]=subMake

n{1000}='Help_Dialog_BetaVerNoticeMessage_JP';
s{1000}={'ヘルプを表示するためにブラウザが起動されます。','','ヘルプは未完成です。不備があるかもしれませんが，ご了承ください。','',...
	'基本操作は同梱のPDFファイル（ステップガイドなど）に記載があります。'};

