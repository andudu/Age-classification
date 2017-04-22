%���������ͼ���һά��ʽ��ɵ�Sample���Լ�ͼ������α�־��Ӧ��lable��
function [Sample,label] = GetDatafromImg(Imdir,setSize ) 
image_struct=dir(strcat(Imdir,'*.jpg'));
totallen=length(image_struct);
Sample=[];
label=[];
 for i=1:totallen
        img=imread(strcat(Imdir,image_struct(i).name));
         if length(size(img))==3   %�ж�ͼ���Ƿ�Ϊ��ɫͼ�񣬲�ɫͼ���СΪͼ���У��к�ÿ�����ص��RGB��С
                 img=rgb2gray(img);
         end
         img2=imresize(img,setSize);
         img1 = reshape(img2',setSize(1)*setSize(2),1);%���д洢�����������£���������
         Sample=[Sample;img1'];%ÿ��ͼƬ��һ�м���Sample��
        age=str2num(image_struct(i).name(5:6));
        label=[label;fix(age/20)+1];   %������ת���ɱ�־   
 end 