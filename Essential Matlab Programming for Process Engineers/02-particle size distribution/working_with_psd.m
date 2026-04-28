clear all

% read sample particle size distribution
A=dlmread('psd.csv',',',2,0);

% split array in variables and create structure variable
psd.x=A(:,1);
psd.q3=A(:,2);

% calculate the sum distribution from data points

% luckily, the interval width is constant :-)
psd.dx=psd.x(2)-psd.x(1);

% Calculate cumulative sum of Q3
psd.Q3=cumsum(psd.q3*psd.dx);

% unfortunately, Q3 does not sum up to 1, may be rounding errors etc. Let's
% rescale it!
psd.Q3=psd.Q3/max(psd.Q3);
% since Q3 relates to the upper particle size limit and not the center, we
% need to recalculate this
psd.x_upper=psd.x+0.5*psd.dx;

% now let's do a first plot
% plot particle size distribution
H=plotyy(psd.x,psd.q3,psd.x_upper,psd.Q3);
xlabel 'particle diameter / µm';
ylabel 'density distribution / 1/µm';
ylabel(H(2),'cumulative sum / -');
grid on

% so far so good. Now let us calculate d10, d16, d50, d84 and d90
psd.d10=interp1(psd.Q3,psd.x_upper,0.1);
psd.d16=interp1(psd.Q3,psd.x_upper,0.16);
psd.d50=interp1(psd.Q3,psd.x_upper,0.5);
psd.d84=interp1(psd.Q3,psd.x_upper,0.84);
psd.d90=interp1(psd.Q3,psd.x_upper,0.90);

% some statistical values:

% calculate geometric standard deviation:
psd.sigma1=psd.d50/psd.d16;
psd.sigma2=psd.d84/psd.d50;

% calculate span value
psd.span=(psd.d90-psd.d10)/psd.d50;

% put some documentation into the file
psd.doc='Particle size distribution of sample SXX-966. This file was generated from psd.csv (received from Dr. Evil on 09/07/2020 by mail). Did analysis with working_with_psd.m'; 


% let's write data as json
json=jsonencode(psd);

% open file
fid=fopen('PSD.json','w');
fwrite(fid,json);
fclose(fid);

% To do: Email this file back to Dr. Evil