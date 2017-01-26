%% H/V-TEST v. 1.0_alpha
% Matteo Albano(1) (matteo.albano@ingv.it)
% Vito Romaniello(1)
% (1)Istituto Nazionale di Geofisica e Vulcanologia
%
% Tool for the verification of the reliability and 
% clarity of the H/V peak according to the SESAME criteria.
% <http://sesame.geopsy.org/Papers/HV_User_Guidelines.pdf>
% This tool automatically reads the parameters needed for the verification 
% from the output files of the H/V toolbox (.hv and .log) of the GEOPSY
% software <http://www.geopsy.org/>.
% This version allows to verify H/V curves calculated with fixed or
% variable windows length.

%% Load input files
%******************************************************************
clear all
noise ='HV_TEST.hv';% .hv output file from H/V toolbox (GEOPSY software)
log = 'HV_TEST.log';% .log output file from H/V toolbox (GEOPSY software)

%% AUTOMATIC SELECTION OF THE REQUIRED PARAMETERS
%******************************************************************
%nw mumber of windows selected for the average H/V curve
nw = dlmread(noise,' ',[1 5 1 5]); 
%Iw window length
fid_diff = fopen(log);
ii=0;
while ~feof(fid_diff)
ii=ii+1;    
tline_diff = fgetl(fid_diff);   
   aa_diff=strfind(tline_diff,'# Start time');
   if(aa_diff==1)
      indice=ii;
   end
end
fclose(fid_diff);
Iw = dlmread(log,'\t',[indice 2 indice+nw-1 2]);
%f0 = H/V peak frequency
f0 = dlmread(noise,'\t',[2 1 2 1]);
%A0 = H/V peak amplitude
A0 = dlmread(noise,'\t',[5 1 5 1]);
%sf = standard deviation for f0
f1 = dlmread(noise,'\t',[4 2 4 2]);
sf = f0-f1;
%nc = number of significant cycles
nc = Iw*nw*f0;
% = tabular data
tab = dlmread(noise,'\t',7,0);
% = amplitude standard deviation
si=size(tab);
for i = 1:si(1)
    tab(i,5)= tab(i,4)./tab(i,2);
end

%% Verification of the SESAME criteria
%******************************************************************
%Criteria for reliable H/V curve
%******************************************************************
% 1) f0>10/Iw
%******************************************************************
if f0 > 10./Iw
    disp('V1 OK')
else
    disp('V1 NO, at least one window does not meet the chriterion')
end
%******************************************************************
% 2) nc(f0)>200
%******************************************************************
if nc > 200
    disp('V2 OK')
else
    disp('V2 NO, at least one window does not meet the chriterion')
end
%******************************************************************
% 3) s
%******************************************************************
flag=0;
if f0 >= 0.5
    for j = 1:si(1)
        if tab(j,1)> 0.5*f0 && tab(j,1)< 2*f0 && tab(j,5)>2
          flag=1;
        end
    end
else
    for j = 1:si(1)
        if tab(j,1)> 0.5*f0 && tab(j,1)< 2*f0 && tab(j,5)>3
          flag=1;
        end
    end
end

if flag == 0;
    disp('V3 OK')
else
    disp('V3 NO')
end
%******************************************************************
%Criteria for a clear H/V peak
%******************************************************************
% 4) 
%******************************************************************
flag = 0;
    for j = 1:si(1)
        if tab(j,1)> f0/4 && tab(j,1)< f0 && tab(j,2)<A0/2
            flag = 1;
        end
    end
    
if flag == 1;
    disp('V4 OK')
else
    disp('V4 NO')
end
%******************************************************************
% 5)
%******************************************************************
flag = 0;
    for j = 1:si(1)
        if tab(j,1)> f0 && tab(j,1)< 4*f0 && tab(j,2)<A0/2
            flag = 1;
        end
    end
    
if flag == 1;
    disp('V5 OK')
else
    disp('V5 NO')
end
%******************************************************************
% 6)
%******************************************************************
if A0 >2
    disp ('V6 OK')
else
    disp ('V6 NO')
end
%******************************************************************
% 7)
%******************************************************************
f0a = f0+0.05*f0;
f0b = f0-0.05*f0;
[M,I]=max(tab);
if tab(I(3),1)> f0b && tab(I(3),1) < f0a && tab(I(4),1)> f0b && tab(I(4),1) < f0a
    disp ('V7 OK')
else
    disp ('V7 NO')
end
%******************************************************************
% 8)
%******************************************************************
if f0 < 0.2
    ef0 = 0.25*f0;
elseif f0 < 0.5
    ef0 = 0.20*f0;
elseif f0 < 1.0
    ef0 = 0.15*f0;
elseif f0 < 2.0
    ef0 = 0.10*f0;
else 
    ef0 = 0.05*f0;
end

if sf < ef0
    disp('V8 OK')
else
    disp('V8 NO')
end

%******************************************************************
% 9)
%******************************************************************

if f0 < 0.2
    tetaf0 = 3.0;
elseif f0 < 0.5
    tetaf0 = 2.5;
elseif f0 < 1.0
    tetaf0 = 2.0;
elseif f0 < 2.0
    tetaf0 = 1.78;
else 
    tetaf0 = 1.58;
end

if tab(I(2),5)<tetaf0
    disp('V9 OK')
else
    disp('V9 NO')
end

%% PLOT H/V curve and results
%******************************************************************

vet = [0 max(tab(:,4))+1];
vet1= [f0/4 f0*4];
freq0 = [f0 f0];
freqa = [f0a f0a];
freqb = [f0b f0b];
freqc = [f0/4,f0/4];
freqd = [f0*4,f0*4];
ampl = [A0/2,A0/2];
hold on
plot (tab(:,1),tab(:,2),'k','LineWidth',1)
plot (tab(:,1),tab(:,3),':k','LineWidth',1)
plot (tab(:,1),tab(:,4),':k','LineWidth',1)
plot (freq0,vet,'r','LineWidth',1)
plot (freqa,vet,':b','LineWidth',1)
plot (freqb,vet,':b','LineWidth',1)
plot (freqc,vet,':g','LineWidth',1)
plot (freqd,vet,':g','LineWidth',1)
plot (vet1, ampl,':r','LineWidth',1)
ylabel('Amplitude H/V','Fontsize',8)
xlabel('Frequency [Hz]','Fontsize',8)
ax = gca;
ax.Box = 'on';
ax.XScale = 'log';
