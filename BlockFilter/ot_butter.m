function [b,a]=ot_butter(hpf,lpf,smp,dim,typ)
%   input:
%           data: data matrix
%           hpf: [vector]:high-pass filter(cutting low frequency) [Hz]:9999=>no hpf
%           lpf: [vector]:low-pass filter(cutting high frequency) [Hz]:9999=>no lpf
%           smp: sampling frequency [Hz]
%           dim: dimension of filttering
%           typ: 'lpf' of 'hpf' or 'bpf' or 'bsf'
%   output:
%           b,a: coefficients of designed filter
%
%
% May 03, 2003, Maki


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Check highpass value
hpf=hpf*2/smp;
lpf=lpf*2/smp;

% Argument Check
typ2=typ;
if isempty(hpf) || hpf<=0 ,typ2='lpf';hpf=[];end
if isempty(lpf) || lpf>=1 ,typ2='hpf';lpf=[];end

delta=0.0001;
if ~strcmpi(typ2,typ) || strcmpi(typ2,'hpf'),
    switch typ,
        case 'lpf',
            lpf = 1-delta;
            warning('Input Value of ot_butter is out of range');
        case 'hpf',
            if isempty(hpf),
                hpf = delta*10;
                warning('Input Value of ot_butter is out of range');
            end
        case 'bsf';
            if isempty(hpf),hpf=delta;end
            if isempty(lpf),lpf=1-delta;end
            warning('Input Value of ot_butter is out of range');
        case 'bpf',
            if isempty(hpf) && isempty(lpf),
                hpf=delta;
                lpf=1-delta;
                warning('Input Value of ot_butter is out of range');
            else
                warning(['Butterworth Type : Change ' typ ' to ' typ2]);
                typ=typ2;
            end
    end % Switch
end

switch typ,
    case {'lpf'},[b,a]=butter(dim,lpf);
    case {'hpf'},[b,a]=butter(dim,hpf,'high');
    case {'bpf'},[b,a]=butter(dim,[hpf,lpf]);
    case {'bsf'},[b,a]=butter(dim,[hpf,lpf],'stop');
    otherwise
        errordlg('Program Error : Type of ot_butter is lpf or hpf or bpf or bsf');
end


% === Grep Result 27-Dec-2004 ===

% BlockFilter/block_controller.m
%    :202:        [b,a]=ot_butter(hpf,lpf,1000/datapara(1),5,filttyp);%Use 5 degree
%    :804:        [b,a]=ot_butter(hpf,lpf,10,5,'bpf');%Use 5 degree
%
% preprocessor/plot_prepro.m
%    :254:        [b,a]=ot_butter(hpf,lpf,1000/datapara(1),5,filttyp);%Use 5 degree
% viewer/plot_stat1.m
%    :245:        [b,a]=ot_butter(hpf,lpf,1000/datapara(1),5,filttyp);%Use 5 degree
% viewer/plot_stat2.m
%    :255:        [b,a]=ot_butter(hpf,lpf,1000/datapara(1),5,filttyp);%Use 5 degree
% viewer/plot_view2.m
%    :252:        [b,a]=ot_butter(hpf,lpf,1000/datapara(1),5,filttyp);%Use 5 degree
%
