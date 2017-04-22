function [Sample,label] = GetDatafromImg(Imdir,setSize ) 
image_struct=dir(strcat(Imdir,'*.jpg'));
totallen=length(image_struct);
Sample=[];
label=[];
 for i=1:totallen
        img=imread(strcat(Imdir,image_struct(i).name));
         if length(size(img))==3   
                 img=rgb2gray(img);
         end
         img2=imresize(img,setSize);
         img1 = reshape(img2',setSize(1)*setSize(2),1);
         Sample=[Sample;img1'];
        age=str2num(image_struct(i).name(5:6));
        label=[label;fix(age/20)+1];   
 end 