%���������ͼ��Ĺؼ����һά��ʽ��ɵ�Sample���Լ�����α�־��Ӧ��lable��
function [Sample,label] = GetDatafromPts(Imdir,Ptdir ) 

image_struct=dir(strcat(Imdir,'*.jpg'));
totallen=length(image_struct);
points_struct=dir(strcat(Ptdir,'*.pts'));

%��ȡ����ͼƬ�ؼ��㼯��coorset,totallen*kpnum
Sample=[];
label=[];

kpnum=68;
for i=1:totallen
   img=imread(strcat(Imdir,image_struct(i).name));
   age=str2num(image_struct(i).name(5:6));  %��ȡͼƬ��Ӧ����
   s=size(img);
   if length(s)==3   %�ж�ͼ���Ƿ�Ϊ��ɫͼ�񣬲�ɫͼ���СΪͼ���У��к�ÿ�����ص��RGB��С
      img=rgb2gray(img);
   end
   coor=ptsread(strcat(Ptdir,points_struct(i).name));  %����ptsread������ùؼ�������꼯coor
   kpset=[];
   for j=1:kpnum
      px=min(coor(j,2),s(1));
      py=min(coor(j,1),s(2));
      kp=img(px,py);     %���ݹؼ��������img�л�ùؼ������ػҶ�ֵ
      kpset=[kpset kp];
   end
   Sample=[Sample;kpset];
  label=[label;fix(age/20)+1];   %������ת���ɱ�־
end
