function m_out=meansqueeze(m_in,num)
% m_out =meansqueeze(m_in,num) :
%  mean(m_in,num) and squeeze for num
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% The code is as same as Folloing Code : Shoji 21-Oct-2004
%
%% Get Average of num
% tmp=mean(m_in,num);
%% Squeeze for num
% if ndifs(tmp)>2
% 	sz=size(tmp);
% 	sz(num) = [];
% 	m_out=reshape(tmp,sz);
% else
% 	m_out=tmp
% end
% return;

sz=size(m_in);

tmp1='';
tmp2='';
for i=1:length(sz)
    if i~=num
        tmp1=[tmp1,',size(m_in,',num2str(i),')'];
        tmp2=[tmp2,',:'];
    end
end
tmp1=tmp1(2:end);
tmp2=tmp2(2:end);
m_out=eval(['zeros(',tmp1,');']);
tmp3=mean(m_in,num);
eval(['m_out(',tmp2,')=tmp3;']);

return;


% == Result of Grep
% Upper function : viewer/plot_stat2.m
% 286:  data=meansqueeze(data,1);
% 304:	peakVm(cnt,:,:)=meansqueeze(meansqueeze( data0(:, i:i+c2e-c2s, :, :) ,2),1);
% 313:	peakVm(cnt,:,:)=meansqueeze(meansqueeze( data0(:, i:i+c2e-c2s, :, :),2 ),1);
% 360:	data_c1=meansqueeze(data_c1,2);% [ block, ch, HB ]
% 361:	data_c2=meansqueeze(data_c2,2);
% 
