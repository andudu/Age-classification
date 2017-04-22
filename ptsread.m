
function co=ptsread(filename)
co=[];
fid=fopen(filename);
for i=1:71
     tline = fgetl(fid);
    if i>3
      p=round(str2num(tline));
      co=[co;p];
    end
end
fclose(fid);