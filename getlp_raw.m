function [t,x]=getlp_raw(shot,ptname,tmin,tmax,offset)
% tic
t=[];
x=[];
if ~strfind(upper(ptname),'TPLANG'); return;end
if nargin<3;tmin=-2;end
if nargin<4;tmax=10;end
if nargin < 5 ; offset=0;end
if tmin>tmax;a=tmin;tmin=tmax;tmax=a;end
I0=fix(tmin/2);
I1=ceil(tmax/2);
if I1 >4; I1=4;end


for i=I0:I1
[x0,t0,c]=getptd(shot,strcat(ptname,'_',num2str(i)),tmin,tmax,1,0);
t=[t;t0];
x=[x;x0];
end

if offset ==1
    [x0,t0,c]=getptd(shot,strcat(ptname,'_4'),7.8,8.,1,0);
  
    x=x-mean(x0);
end
% toc


