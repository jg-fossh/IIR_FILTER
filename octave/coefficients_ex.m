close all;
clear all;
pkg load signal;
pkg load communications;

% Fs = 96000;

% f2 = 0.0015;
% f3 = 0.20625/2;
% hc = fir1(11, [f2 f3],'DC-0');
% freqz(hc)

% b=hc-min(hc);
% b=b/max(b);
% b=b*2^4;
% b=b-2^3;
% bf = fix(b);

% limit_value = max(bf);
% sign_index = zeros(size(bf'));
% if limit_value < abs(min(bf))
%   limit_value = abs(min(bf));
% endif
% limit_value

% x = 0:.1:1;
% A = [x; exp(x)];

% fileID = fopen('fir.txt','w');
% fprintf(fileID,'%X\n', typecast(int8(bf),'uint8'));
% fclose(fileID);

sf = 48000; sf2 = sf/2;
 data=[[1;zeros(sf-1,1)],sinetone(25,sf,1,1),sinetone(50,sf,1,1),sinetone(10000,sf,1,1)];
 [b,a]=butter ( 3, [62 / sf2, 5800 / sf2]);
 filtered = filter(b,a,data);

 clf
 subplot ( columns ( filtered ), 1, 1)
 plot(filtered(:,1),";Impulse response;")
 subplot ( columns ( filtered ), 1, 2 )
 plot(filtered(:,2),";25Hz response;")
 subplot ( columns ( filtered ), 1, 3 )
 plot(filtered(:,3),";50Hz response;")
 subplot ( columns ( filtered ), 1, 4 )
 plot(filtered(:,4),";100Hz response;")
