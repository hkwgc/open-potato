function [data,hdata] = P3P_ChannelDataAveraging(data, hdata, ch, newchpos)
%- Channel Data Averaging
%
%
% $Id: P3P_ChannelDataAveraging.m 352 2013-05-08 02:42:56Z Katura $
%

%ch={[1,2,3,4],[14 16 19]};
%newchpos=[5 2];

%- prepare newdata
newchlen = size(data,2)-length([ch{:}])+length(ch);
newdata=zeros(size(data,1),newchlen,size(data,3));
newhdata=hdata;
newhdata.flag = zeros(size(hdata.flag,1), size(hdata.flag,2), newchlen);
newhdata.Pos.D2.P = zeros(newchlen, 2);

tg= true(1,newchlen);
tg(newchpos)=false;

%-
tmp=data;
tmp(:,[ch{:}],:)=[];
newdata(:,tg,:)=tmp;
%-
tmp=hdata.flag;
tmp(:,:,[ch{:}])=[];
newhdata.flag(:,:,tg)=tmp;
%-
tmp=hdata.Pos.D2.P;
tmp([ch{:}],:)=[];
newhdata.Pos.D2.P(tg,:)=tmp;

%-
%% - check channel group
chgroup=zeros(1,size(data,2));
for k=1:length(hdata.Pos.Group.ChData)
	chgroup(hdata.Pos.Group.ChData{k})=k;
end

s={};
for k=1:length(ch)
	if length(unique(chgroup(ch{k})))>1
		tmp1=unique(tmp(ch{k}));ss='%d';
		for kk=2:length(tmp1),ss=['%d,' ss];end
		s{end+1}=sprintf(['Channel list %02d:different channel group [' ss ']\n'],k,tmp1);
	end
end
if ~isempty(s)
	errordlg(cat(2,'Incorrect channel setting found.',s,'Channel Data Averating was skipped.'),'Channel Data Averaging');
	return;
end
%% -- modify channel group(s)
a=1:size(data,2);
a([ch{:}])=[];
b=zeros(1,newchlen);
b(tg)=a;
newchgroup = zeros(1,newchlen);
newchgroup(tg)=chgroup(a);
for k=1:length(ch)
	newchgroup(newchpos(k))= unique(chgroup(ch{k}));
end
for k=1:max(newchgroup)
	newhdata.Pos.Group.ChData{k} = find(newchgroup==k);
end

%- Averaging
for k=1:length(ch);

	%% -- modify data
	tmp=data(:,ch{k},:);
	tmp=nan_fcn('mean',tmp,2);
	newdata(:,newchpos(k),:) = tmp;
	
	%% -- modify flag
	tmp=hdata.flag(:,:,ch{k});
	tmp=nan_fcn('mean',tmp,3);
	newhdata.flag(:,:,newchpos(k)) = tmp;
	
	%% -- modify related info
	tmp=hdata.Pos.D2.P(ch{k},:);
	tmp = mean(tmp,1);
	newhdata.Pos.D2.P(newchpos(k),:) = tmp;

end

data=newdata;
hdata=newhdata;

