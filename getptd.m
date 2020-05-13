function [data,tvec,ier] = getptd(shot,ptname,tmin,tmax,ical,debug);
 %
%  SYNTAX:  [data,tvec,ier] = getptd(shot,ptname,tmin,tmax,ical,debug)
%
%  PURPOSE:  Get pointname data from the shot database. This function is a 
%  shell which executes the mex (fortran) procedure getbigptdf.f which in turn
%  calls ptdata.
%
%  INPUT:
%    shot 	= shot number
%    ptname	= point name - must be in single quotes
%    tmin	= minimum time in seconds
%    tmax	= maximum time in seconds
%    ical	= optional calibration input (see ptdata documentation)
%    debug      = optional debugging flag (optional, default 0)
%		  1 = print shot number, ptname, and ical as data is read
%		  2 = for info used in debugging getbigptdf.f 
%
%  OUTPUT:
%    data	= data for point name defined by input
%    tvec	= time vector for data
%    ier	= error code (see documentation for ptdata)
%
%  RESTRICTIONS:  
%   (1) DO NOT do a cntrl-C when this function is running.  The ptdata
%   	routine loses track of where it is and subsequent calls to this
%   	function give you bogus results.

 
%  METHOD: Only reason for shell is to return only as much data as is obtained
%  from the shot file rather than huge array passed to ptdata by getbigptdf.
%
%  WRITTEN BY:  Mike Walker 	ON 	??/93
% 
%		     COPYRIGHT 1994 GENERAL ATOMICS 	
%			RESTRICTED RIGHTS NOTICE
% UNPUBLISHED-RIGHTS RESERVED UNDER THE COPYRIGHT LAWS OF THE UNITED STATES.
% 
% (a) This computer software is submitted with restricted rights under
%     Government Contract No. DE-AC03-89ER51114.  It may not be used,
%     reproduced, or disclosed by the Government except as provided in
%     paragraph (b) of this Notice or as otherwise expressly stated in the
%     contract.
% (b) This MIMO computer software shall be used exclusively in the
%     DIII-D Program and may be --
%    (1) Used or copied for use in or with the computer or computers for
%        which it was acquired, including use at any Government installation to 
%        which the DIII-D fusion reactor may be transferred;
%    (2) Used or copied for use in a backup computer if any computer for
%        which it was acquired is inoperative;
%    (3) Reproduced for safekeeping (archives) or backup purposes;
%    (4) Modified, adapted, or combined with other computer software,
%        provided that the modified, combined, or adapted portions of the
%        derivative software are made subject to the same restricted rights;
%    (5) Disclosed to and reproduced for use by support service Contractors
%        in accordance with subparagraphs (b)(1) through (4) of this clause,
%        provided the Government makes such disclosure or reproduction
%        subject to these restricted rights; and
%    (6) Used or copied for use in or transferred to a replacement computer.
% (c) Notwithstanding the foregoing, if this computer software is published
%     copyrighted computer software, it is licensed to the Government without
%     disclosure prohibitions, with the minimum rights set forth in paragraph
%     (b) of this clause.
% (d) Any other rights or limitations regarding the use, duplication, or
%     disclosure of this computer software are to be expressly stated in, or
%     incorporated in, the contract.
% (e) This Notice shall be marked on any reproduction of this computer
%     software, in whole, or in part.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @(#)getptd.m	1.8 08/05/13

% test for existence of optional arguments
if nargin < 6, debug=0;, end;
if nargin < 5, ical =1;, end;

if(tmin > tmax)
   wait('ERROR getptd: tmin must be less than or equal to tmax');
   data = []; tvec=[]; ier=1;
   return;
end

%test=exist('ical');
%if test ~= 1
%   ical = 1;
%end;
%test=exist('debug');
%if test ~= 1
%   debug = 0;
%end;

ptname = upper(ptname);		% needed by some low level ptdata routines
shot = double(shot);        % Cast to double for mex functions
if(strlen(ptname)<4)
   ier  = 0;
   [data,tvec,npts,ier] = getbigptd(shot,ptname,tmin,tmax,ical,debug);
elseif((strcmp('pcv',ptname(1:3)) | strcmp('PCV',ptname(1:3))) & ...
	~strcmp(ptname(4:4),'X') & ~strcmp(ptname(4:4),'HX') & ...
         ~strcmp(ptname(4:4),'x') & ~strcmp(ptname(4:4),'hx'));
   [data,tvec,npts,ier] = getbigptd(shot,ptname,tmin,tmax,ical,debug);
   if(ier>0)
      [N_choppers,PS_name,coil_name,chopper_name, pushpull,Idirection, ...
       chopper_index,PS_index,bus_code,ichop,err] = getpatch(shot,1);
      if(err==0)
         ii = str2num(ptname(4:4));
         if(~isempty(ii))	% must be a number to do the following
            if(strcmp(ptname(5:5),'b') | strcmp(ptname(5:5),'B'))
               ii = ii+9;
            end
            if(strcmp(chopper_name(ii,1:2),'RV'))
               data=[]; tvec=[];
               ier=1;
               fprintf('ERROR: no chopper on coil %s\n',ptname(4:5));
            else
               ptname1 = ['PCV' deblank(chopper_name(ii,1:4))];
               fprintf('substituting ptname %s for %s\n',ptname1,ptname);
               [data,tvec,npts,ier]=getbigptd(shot,ptname1,tmin,tmax,ical,debug);
            end
         else
            data=[]; tvec=[];
            ier=1;
            fprintf('ERROR: unable to get data for %s\n',ptname);
         end
      else
         data=[]; tvec=[];
         ier=1;
         fprintf('ERROR: unable to get voltage on coil %s\n',ptname(4:5));
      end
   end
else

    % If this is one of the new ECE ptnames, append the segment number
    % Allow for the segment number to be appended manually (in other words,
    % this won't run in you have a ptname like ECEVS01_0)
    if length(ptname) > 4 % Check the length before the ECEVS test ensure no out of bounds indexing
        if strcmp(ptname(1:5),'ECEVS') && length(ptname) < 8
            data = [];
            tvec = [];
            for i = 0:2
                ptname_seg = sprintf('%s_%d',ptname,i);
                [data_seg,tvec_seg,ier] = getptd(shot,ptname_seg,tmin,tmax,ical,debug);
                if ier > 0
                    data = []
                    tvec = []
                    return
                end
                data = [data; data_seg];
                tvec = [tvec; tvec_seg];              
            end % end for
            return
        end %end if strcmp....
    end %end if length...


   ier  = 0;
   [data,tvec,npts,ier] = getbigptd(shot,ptname,tmin,tmax,ical,debug);
end
if 0 % KLUGE - something wrong with pcs data acquisition for runsa:
temp_t = flipud(tvec);
idx = min(find(temp_t~=0));
if(idx>1)
   temp_d = flipud(data);
   temp_d = temp_d(idx:end);
   temp_t = temp_t(idx:end);
   data = flipud(temp_d);
   tvec = flipud(temp_t);
end
end

if(ier<=0) % call mex file
   data = data(1:npts);
   tvec = tvec(1:npts);
else
   data = []; tvec=[];
end
