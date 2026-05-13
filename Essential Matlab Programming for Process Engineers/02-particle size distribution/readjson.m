function data = readjson(filename)
%READJSON  Read a JSON file and decode it into a MATLAB struct or array.
%
%   data = readjson(filename)
%
%   This is a thin wrapper around jsondecode / fileread that keeps calling
%   code clean.  For large files, fileread is preferred over fread because
%   it avoids the char-array transpose.
%
%   Input
%     filename  --  path to a .json file (string or char array)
%
%   Output
%     data      --  MATLAB struct / array decoded from the JSON content
%
%   Example
%     psd = readjson('PSD.json');
%     disp(psd.d50)
%
%   Author:  Prof. Nils Ellendt, Leibniz-IWT, University of Bremen
%   Course:  Essential MATLAB Programming for Process Engineers

data = jsondecode(fileread(filename));
end
