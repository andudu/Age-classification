%��pts��ʽ��filename�ļ��л�ùؼ�������꼯coor
function co=ptsread(filename)
%%%filename �ļ���
%%%ÿ���ļ����ݴӵ�4�п�ʼ
%%%��71�н���
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