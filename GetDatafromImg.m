%获得由所有图像的一维形式组成的Sample，以及图像年龄段标志对应的lable集
function [Sample,label] = GetDatafromImg(Imdir,setSize ) 
image_struct=dir(strcat(Imdir,'*.jpg'));
totallen=length(image_struct);
Sample=[];
label=[];
 for i=1:totallen
        img=imread(strcat(Imdir,image_struct(i).name));
         if length(size(img))==3   %判断图像是否为彩色图像，彩色图像大小为图像行，列和每个像素点的RGB大小
                 img=rgb2gray(img);
         end
         img2=imresize(img,setSize);
         img1 = reshape(img2',setSize(1)*setSize(2),1);%按行存储，即从上往下，从左往右
         Sample=[Sample;img1'];%每张图片按一行加入Sample中
        age=str2num(image_struct(i).name(5:6));
        label=[label;fix(age/20)+1];   %将年龄转化成标志   
 end 