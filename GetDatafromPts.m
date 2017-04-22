function [Sample,label] = GetDatafromPts(Imdir,Ptdir ) 

image_struct=dir(strcat(Imdir,'*.jpg'));
totallen=length(image_struct);
points_struct=dir(strcat(Ptdir,'*.pts'));

Sample=[];
label=[];

kpnum=68;
for i=1:totallen
   img=imread(strcat(Imdir,image_struct(i).name));
   age=str2num(image_struct(i).name(5:6));  
   s=size(img);
   if length(s)==3   
      img=rgb2gray(img);
   end
   coor=ptsread(strcat(Ptdir,points_struct(i).name));  
   kpset=[];
   for j=1:kpnum
      px=min(coor(j,2),s(1));
      py=min(coor(j,1),s(2));
      kp=img(px,py);    
      kpset=[kpset kp];
   end
   Sample=[Sample;kpset];
  label=[label;fix(age/20)+1];   
end
