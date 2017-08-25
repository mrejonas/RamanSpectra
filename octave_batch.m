%Usage: z=Goldindec(A,p,peak_ratio,eps,b_path);
%A is a vector with two columns, in which the first column is Raman wave number, while the second column is Raman intensity.
%p is the polynomial prder.
%peak_ratio is the ratio of peaks.
%eps is the parameter �� to terminate the iteration and users can specify this value.
%b_path is the output path of the final fitted baseline.
%z is the fitted baseline.

addpath ~/. % Change to the path of where Goldindec is
pkg load io

% Change this 'sample_test/' directory to point to the directory where files are
% Running this script on Windows-based Octave may encounter some problems with
% things like spaces or hyphens("-") in names
% Caveats:
% -> Directories:
%     - escape the "\" with another "\", eg. "\\"
%     - try to use underscores ("_") instead of hyphens or spaces
% -> Files:
%     - do not start filenames with numbers; if you need the date, put it
%       somewhere internal to the filename, not the start
%     - no spaces, hyphens or special characters in filenames

files = readdir('sample_test/')
workdir = 'sample_test/'

% Change this extension to reflect your file extension
extension = "\.txt"
for idx = 1:numel(files)
%  if(regexp(files{idx}, "\.txt$"))
  if(regexp(files{idx}, extension))
    %disp(files{idx})
    readfile = strjoin({workdir, files{idx}},"")
    project = dlmread(readfile) %add the mineral Albite from its path
%    outname = strrep(files{idx},".txt","")
    outname = strrep(files{idx},extension,"")
    Goldindec(project,4,0.5,0.0001,'/home/mario/Development/Proteomics/RamanSpectra/sample_test/',outname); %z is the baseline of Raw Raman data of Albite
  endif
end
