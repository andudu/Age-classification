%获得由所有图像的关键点的一维形式组成的Sample，以及年龄段标志对应的lable集
function [Sample,label] = GetDatafromPts(Imdir,Ptdir ) 

image_struct=dir(strcat(Imdir,'*.jpg'));
totallen=length(image_struct);
points_struct=dir(strcat(Ptdir,'*.pts'));

%获取所有图片关键点集合coorset,totallen*kpnum
Sample=[];
label=[];

kpnum=68;
for i=1:totallen
   img=imread(strcat(Imdir,image_struct(i).name));
   age=str2num(image_struct(i).name(5:6));  %获取图片对应年龄
   s=size(img);
   if length(s)==3   %判断图像是否为彩色图像，彩色图像大小为图像行，列和每个像素点的RGB大小
      img=rgb2gray(img);
   end
   coor=ptsread(strcat(Ptdir,points_struct(i).name));  %调用ptsread函数获得关键点的坐标集coor
   kpset=[];
   for j=1:kpnum
      px=min(coor(j,2),s(1));
      py=min(coor(j,1),s(2));
      kp=img(px,py);     %根据关键点坐标从img中获得关键点像素灰度值
      kpset=[kpset kp];
   end
   Sample=[Sample;kpset];
  label=[label;fix(age/20)+1];   %将年龄转化成标志
end
