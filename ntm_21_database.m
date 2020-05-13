
% Run this files in the command window prior to open matlab
% module load mdsplus/6.1.84
% module load matlab
% module load toksys

% Run this commands only once
% toksys_startup; d3d_startup

% DO NOT START THIS FILE WITH clear

mdsconnect('atlas');

% Select the range of shots to analyze
% shot1 = 141325:141334; % 5 Test shots with tearing mode
shot1 = getShots2019(); 
shot1 = shot1(:,1);

% Minimum and maximum time
t11=1;t12=7;

% Preallocate ntm_data
ntm_data = [];

% Start the analysis
kflag=0;
for i1=1:length(shot1)
    
    shot1(i1)
    try;
    [tam,bam]=getdata(shot1(i1),'n1rms',t11,t12); %n1rms
   
    mdsconnect('atlas');
    mdsopen('D3D',shot1(i1));
    h98=mdsvalue('\h_thh98y2');
    th98=mdsvalue(['dim_of(','\h_thh98y2',')'])/1000;
    taue=mdsvalue('\taue');
    ttaue=mdsvalue(['dim_of(','\taue',')'])/1000;
    
    mdsconnect('atlas');
    mdsopen('efit01',shot1(i1));
    q95=mdsvalue('\q95');
    tq95=mdsvalue(['dim_of(','\q95',')'])/1000;
    
    betap=mdsvalue('\betap');
    tbetap=mdsvalue(['dim_of(','\betap',')'])/1000;
    
    betan=mdsvalue('\betan');
    tbeta=mdsvalue(['dim_of(','\betan',')'])/1000;
    
    wmhd=mdsvalue('\wmhd');
    twmhd=mdsvalue(['dim_of(','\wmhd',')'])/1000;
    
    bam0=smooth(bam,20);
    shot1(i1)
    bmax=max(bam0);
    if (bmax>12 & h98(1)~='J' & taue(1)~='J' & q95(1)~='J' & betap(1)~='J' & betan(1)~='J')% to check there is large n=1 tearing mode and have data for h98 and taue
        h98=smooth(h98,5);
        taue=smooth(taue,5);
        mdsconnect('atlas');
        [tip,ip]=getdata(shot1(i1),'ip',t11,t12);%ip
        ip=smooth(ip,10)*1.e-6;
        [tbt,bt]=getdata(shot1(i1),'bt',t11,t12);%bt
        
        [tli,li]=getdata(shot1(i1),'li',t11,t12,'efit01');%ip
%         [tbetap,betap]=getdata(shot1(i1),'betap',t11,t12,'efit01');%ip
%         betap=smooth(betap,5);
        
        mdsconnect('atlas');
        mdsopen('efit01',shot1(i1));
        betap=smooth(betap,5);
        ne=mdsvalue('\density')*1.e-13;
        tne=mdsvalue(['dim_of(','\density',')'])/1000;
        if (max(ne)<1)
            tne=tq95;ne(1:length(tne))=4;
        else
            ne=smooth(ne,5);
        end
%        ip=mdsvalue('\ip');
%        tip=mdsvalue(['dim_of(','\ip',')'])/1000;
        betan=smooth(betan,5);
        wmhd=smooth(wmhd,5);
        
        % constraint by n2rms:        
        kmax=find(bam0==bmax);tmax=tam(kmax);%to find the max value of b1rms and the corresponding time
        ktmin=find(bam0<=0.05*bmax);konset=max(ktmin(find(ktmin<kmax))); % to find the onset time
        kmin1=find(bam0(konset:kmax)<0.05*bmax);kmin10=konset+max(kmin1)-1;
        kmin2=find(bam0(konset:kmax)>0.15*bmax & bam0(konset:kmax)<0.2*bmax);kmin20=konset+max(kmin2)-1;
        
        % h98 factor
     if (konset)
        tam(konset);
        k98=max(find(th98<=tam(konset)-0.05));t98=th98(k98);h98_onset=h98(k98);
        kbeta=max(find(tbeta<=tam(konset)-0.05));tbe=tbeta(kbeta);betan_onset=betan(kbeta);
        k95=max(find(tq95<=tam(konset)));t95=tq95(k95);q95_onset=q95(k95);
        kwmhd=max(find(twmhd<=tam(konset)));twm=twmhd(kwmhd);wmhd_onset=wmhd(kwmhd);
        ktau=max(find(ttaue<=tam(konset)));tta=ttaue(ktau);taue_onset=taue(ktau);
        ktne=max(find(tne<=tam(konset)));ttne=tne(ktne);ne_onset=ne(ktne);
        ktip=max(find(tip<=tam(konset)));ttip=tip(ktip);ip_onset=ip(ktip);
        ktbt=max(find(tbt<=tam(konset)));ttbt=tbt(ktbt);bt_onset=bt(ktbt);
        ktli=max(find(tli<=tam(konset)));ttli=tli(ktli);li_onset=li(ktli);
        ktbetap=max(find(tbetap<=tam(konset)));ttbetap=tbetap(ktbetap);betap_onset=betap(ktbetap);
        
        if (tam(kmin20)-tam(kmin10)<=0.01)
            bmax=max(bam0(1:konset));
            kmax=find(bam0(1:konset)==bmax);tmax=tam(kmax);
            ktmin=find(bam0(1:konset)<=0.05*bmax);konset=max(ktmin(find(ktmin<kmax))); % to find the onset time
        else
        end
        
        % If tearing mode exist, write down the data into ntm_data
        q95_min=min(q95);
        if((tam(kmax)-tam(konset))>=0.05 & bmax>12 & h98_onset>=0.7 & q95_onset<q95_min*1.5)% H mode: H98 >0.7, mode continues nore than 50 ms and strong ampltude
            %disp('Hello')
            kflag=kflag+1;
            ntm_data(kflag,1)=shot1(i1);
            ntm_data(kflag,2)=tam(konset);
            ntm_data(kflag,3)=ip_onset;
            ntm_data(kflag,4)=bt_onset;
            ntm_data(kflag,5)=ne_onset;
            ntm_data(kflag,6)=q95_onset;
            ntm_data(kflag,7)=betan_onset;
            ntm_data(kflag,8)=h98_onset;
            ntm_data(kflag,9)=taue_onset;
            ntm_data(kflag,10)=wmhd_onset;
            ntm_data(kflag,11)=li_onset;
            ntm_data(kflag,12)=betap_onset;
            
%             figure;set(gcf,'units','centimeter','position',[2 4 12 9]);
%             hold on;
%             plot(tam,bam,tam,bam0,'linewidth',2)
%             plot(tmax,bmax,'sk','markersize',12,'markerfacecolor','k')
%             plot(tam(konset),bam0(konset),'sk','markersize',12,'markerfacecolor','k','linewidth',2)
%             set(gca,'fontsize',16,'linewidth',1.5,'xlim',[t11,t12],'box','on');
%             set(gca,'xminortick','on','yminortick','on','ticklength',[0.025 0.025]);
%             ylabel('B_{n=1}','fontsize',20,'fontweight','bold');
%             xlabel('Time (s)','fontsize',20,'fontweight','bold');
%             set(gca,'units','centimeter','position',[2 1.7 9.8 7])
%             text(1.3,bam(kmax),num2str(shot1(i1)))
%             saveas(gcf,[num2str(shot1(i1)),'_ntm_21.tif']);
%             close figure 1;    
        
        else
        end
        
     else
     end
        
    else
    end
    end
end

% Write ntm_data heading into a text file
fid=fopen('tm_2019.txt','wt');
fprintf(fid,'%7.4s','Shot');
fprintf(fid,'%21.13s','onset_time(s)');
fprintf(fid,'%11.6s','Ip(MA)');
fprintf(fid,'%16.5s','Bt(T)');
fprintf(fid,'%19.10s','ne(10**19)');
fprintf(fid,'%12.3s','q95');
fprintf(fid,'%18.6s','beta_N');
fprintf(fid,'%14.4s','H_98');
fprintf(fid,'%18.8s','tau_E(s)');
fprintf(fid,'%17.8s','W_mhd(J)');
fprintf(fid,'%11.2s','li');
fprintf(fid,'%17.6s\n','beta_p');

% Write ntm_data data into a text file
[row,col]=size(ntm_data);
for i=1:row
   for j=1:col
      if(j==col)
         fprintf(fid,'%4.4g\n',ntm_data(i,j));
      else
         fprintf(fid,'%8.6g\t',ntm_data(i,j));
      end
   end
end