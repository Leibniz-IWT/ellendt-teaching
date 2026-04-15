function [ data ] = readjson( filename )
%Reads JSON file
fid = fopen(filename);
data=jsondecode(char(fread(fid,inf)'));
fclose(fid);
end

