%从pts格式的filename文件中获得关键点的坐标集coor
function co=ptsread(filename)
%%%filename 文件名
%%%每个文件数据从第4行开始
%%%到71行结束
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