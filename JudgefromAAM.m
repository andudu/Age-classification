addpath functions
where = '.';
folder = 'Images';
what = 'jpg';
AAM.num_of_points = 68;
image_list = dir([where '/' folder '/*.' what]);
pts_files = dir([where '/' folder '/*.pts']);
num_of_samples = length(image_list);
AAM.shape.max_n = 30;
num_of_scales = 1;
ii=1;
AAM.texture{1}.max_m = 220;
Imdir='./Images/';
image_struct=dir(strcat(Imdir,'*.jpg'));
alllabel=[];
for ll=1:length(image_struct)
     age=str2num(image_struct(ll).name(5:6));
     alllabel=[alllabel;fix(age/20)+1]; 
end
shapes = zeros(AAM.num_of_points, 2, num_of_samples);
for i=1:length(image_list)
shape_path = [where '/' folder '/' pts_files(i).name];
n_vertices = AAM.num_of_points;
% read_shape pts
fid = fopen(shape_path);
tline = fgetl(fid);
start = 1;
while ~strcmp(tline, '{')
    start = start + 1;
    tline = fgetl(fid);
end
fclose(fid);
% read shape
shape =  dlmread(shape_path, ' ', [start 0 start+n_vertices-1 1]);
    shapes(:,:,i) = (shape);
end
% align all shapes to the mean shape
% shapes_normal : aligned shapes
% Translate each shape to the origin
shapes_normal = shapes - repmat(mean(shapes, 1), size(shapes, 1), 1);
mean_shape = mean(shapes_normal, 3);

iteration = 0;
max_iteration = 100;

while (iteration<=max_iteration)
    % Align all shapes with current mean shape
    for i=1:size(shapes,3)
        [~, shapes_normal(:,:,i)] = procrustes(mean_shape, shapes_normal(:,:,i));
    end    
    % Update mean shape
    mean_shape_new = mean(shapes_normal, 3);
    [~, mean_shape_new] = procrustes(mean_shape, mean_shape_new);
    mean_shape = mean_shape_new;
    
    iteration = iteration + 1;
end
AAM.shape.s0 = mean(shapes_normal, 3);
% Create the shape model
shapes_normal = reshape(shapes_normal, [], num_of_samples);
rep_s0 = repmat(AAM.shape.s0(:), 1, num_of_samples);
% apply PCA on similarity free shapes
S =  myPCA(shapes_normal - rep_s0, AAM.shape.max_n);
play=S'*(shapes_normal - rep_s0);

% Create the coordinate frame of the AAM
triangles = delaunay(AAM.shape.s0(:,1), AAM.shape.s0(:,2));

 AAM.coord_frame{ii}.triangles  = triangles;


% create base shape and base texture, and masks for each resolution
sc = 2.^(AAM.scales-1);
for ii = 1:length(sc)
    s0_sc = AAM.shape.s0/sc(ii);
% Create base shape
    mini = min(s0_sc(:, 1));
    minj = min(s0_sc(:, 2));
    maxi = max(s0_sc(:, 1));
    maxj = max(s0_sc(:, 2));
    
    AAM.coord_frame{ii}.base_shape = s0_sc - repmat([mini - 2, minj -  2], [AAM.num_of_points, 1]);
    AAM.coord_frame{ii}.resolution  = [ceil(maxj - minj + 3) ceil(maxi - mini + 3)];
    
    vertices = AAM.coord_frame{ii}.base_shape;
    triangles = AAM.coord_frame{ii}.triangles;
    resolution = AAM.coord_frame{ii}.resolution;
    % base_texture to warp image
    base_texture = zeros(resolution(1), resolution(2));

    for i=1:size(triangles,1)
        % vertices for each triangle
        X = vertices(triangles(i,:),1);
        Y = vertices(triangles(i,:),2);
        % mask for each traingle
        mask = poly2mask(X,Y,resolution(1), resolution(2)) .* i;
        % the complete base texture
        base_texture = max(base_texture, mask);
    end
       AAM.coord_frame{ii}.base_texture = base_texture;
    % Masking: 
    % When we warp the images to the mean shape below, we may want to mask out 1
    % boundary pixel.
    mask = AAM.coord_frame{ii}.base_texture; 
    mask(mask>0) = 1; 
    mask = double(mask);
    mask = imerode(mask, strel('square',3));
    AAM.coord_frame{ii}.mask = mask;
    AAM.coord_frame{ii}.ind_in = find(mask == 1);
    AAM.coord_frame{ii}.ind_out = find(mask == 0);
   
end    

% D. Read images and get shape-free textures textures
textures = cell(1, num_of_scales);

    textures{ii} = zeros(length(AAM.coord_frame{ii}.ind_in), num_of_samples);

zeros(num_of_scales, length(image_list));
count = 0;
for jj = 1:length(image_list)
    I = imread([where '/' folder '/' image_list(jj).name]);
    if size(I, 3) == 3
        I = double(rgb2gray(I));
    else
        I = double((I));
    end
 
    current_shape(:, 1) = shapes(:, 1, jj);
    current_shape(:, 2) = shapes(:, 2, jj);
    
    count = count + 1;
    
        try
            Iw = warp_image(AAM.coord_frame{ii}, current_shape, I);
            % mask out 1 boundary pixel
            Iw(AAM.coord_frame{ii}.ind_out) = 0;
            Iw(AAM.coord_frame{ii}.ind_out) = [];
            % check if warped data is fine
            temp = sum(isnan(Iw));
            % all images should be also in the range [0, 255]
            if ((temp == 0) && max(Iw) < 256)
                textures{ii}(:, count) = Iw;
            else
                textures{ii}(:, count) = zeros(size(Iw));
            end
            
        catch me
            aa = 1;
        end
   
end

% E. Create the texture model

    A0 = mean(textures{ii}, 2);
    textures{ii} = textures{ii} - repmat(A0, 1, size(textures{ii}, 2));
    AAM.texture{ii}.A0 = A0;
    AAM.texture{ii}.A  = myPCA(textures{ii}, AAM.texture{ii}.max_m);

    play2=(AAM.texture{ii}.A)'*textures{ii};
   
eigv_shape = eig(AAM.shape.S' * AAM.shape.S);
eigv_texture = eig(AAM.texture{1}.A' * AAM.texture{1}.A);

ratio = sum(eigv_shape) / sum(eigv_texture);

Ws = ratio * eye(size(play, 1));

final_b = [Ws * play; play2];
allSample = final_b';


Samplelen=size(allSample);
num=200; 

 for t=1:3
   trainnum=t*num;  
   for s=1:5
       Sample=[];   
       label=[];
       trainSample=[];  
       testSample=[];   
       trainlabel=[];   
       testlabel=[];    
       r=rand(1,Samplelen(1));
       [ignore,p]=sort(r);
       for i=1:Samplelen(1)
          Sample=[Sample;allSample(p(i),:)];   
          label=[label;alllabel(p(i))];        
       end
      

      for i=1:Samplelen(1)
            if i<=trainnum               
         	  trainSample=[trainSample;Sample(i,:)];  
              trainlabel=[trainlabel;label(i)];
            else
              testSample=[testSample;Sample(i,:)];
              testlabel=[testlabel;label(i)];
            end
      end
      
     [trainSet,base]=pca(trainSample); 

     test=[];
     test_label=[];
     testnum=200;  
     testSamplelen=size(testSample);
     r=rand(1,testSamplelen(1));
     [ignore,p]=sort(r);
     for i=1:testnum
        test=[test;testSample(p(i),:)];
        test_label=[test_label;testlabel(p(i))];
     end

      testSet=double(test)*base;

     x=trainSet;
     [m,n] = size(x);
     S = zeros(m,n);
     for i = 1:m
        mea = mean( x(i,:) );
        va = var(double(x(i,:)));
        S(i,:) = ( x(i,:)-mea )/va;
     end

     y=testSet;
     [m,n] = size(y);
     T = zeros(m,n);
     for i = 1:m
        mea = mean( y(i,:) );
        va = var(double( y(i,:)));
        T(i,:) = ( y(i,:)-mea )/va;
     end

     traindata = S;
     testdata = T;

     model = svmtrain(trainlabel,traindata,'-s 0 -t 2 -c 1.2 -g 2.8');

     Parameters=model.Parameters;
     Label = model.Label;
     nr_class = model.nr_class;
     totalSV = model.totalSV;
     nSV = model.nSV;
    
     [ptrain,acctrain,~] = svmpredict(test_label,testdata,model); 
     acc(s)=acctrain(1);
      end
       accuracy(t)=mean(acc);
  end
  accuracy

