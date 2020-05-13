function [t,y]=getdata(shot,pointname,tmin,tmax,tree)

 if strfind(upper(pointname),'TPLANG')
     [t,y]=getlp_raw(shot,pointname,tmin,tmax);
     
 return;
 end

if (~exist('tmin',  'var') | isempty(tmin)  ), tmin= []; end

if (~exist('tmax',  'var') | isempty(tmax)  ), tmax= []; end

if (~exist('tree',  'var') | isempty(tree)  ), tree='D3D'; end

mdsconnect('atlas');
mdsopen(tree,shot);
t=mdsvalue(strcat('dim_of(\',pointname,')'));
y=mdsvalue(strcat('\',pointname));
if ~isnumeric(t(1))
   t=mdsvalue(strcat('dim_of(',pointname,')'));
    y=mdsvalue(strcat('',pointname));
end

if ~isnumeric(t(1)) | isempty(t)
    [y,t]=getptd(shot,pointname,tmin,tmax);
end
if isempty(t)
    [y,t]=getptd(shot,[pointname,'_1'],-10,10);
    if length(t) > 100 
        t=[];
        y=[];
        for i=0:100
            if ~isempty(t)
                if t(end)+t(end)-t(end-1) > tmax; continue;end
            end
            [x0,t0,c]=getptd(shot,strcat(pointname,'_',num2str(i)),tmin,tmax,1,0);
            t=[t;t0];
            y=[y;x0];
            
        end
    end
end
if isempty(t); return;end
if isnumeric(t(1))
    
    
    if ~isempty(tmin)
        if tmin <10 & max(t) >100
            t=t/1000;
        end
    
    end
    
    if isempty(tmin)
        tmin=min(t);
    end
    
    if isempty(tmax) 
       tmax=max(t);
    end
    index=find(t >= tmin & t <= tmax);
    t=t(index);
    y=y(index,:);
else
    t=[];
    y=[];
end

mdsclose();
mdsdisconnect();



