
Imdir='./dataset/Images/';  
Ptdir='./dataset/points/';   

[allSample,alllabel]=GetDatafromPts(Imdir,Ptdir);
allSample=double(allSample);
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

        x=trainSample;
        [m,n] = size(x);
         S = zeros(m,n);
        for i = 1:m
             mea = mean( x(i,:) );
             va = var(x(i,:) );
             S(i,:) = ( x(i,:)-mea )/va;
        end

        y=test;
        [m,n] = size(y);
        T = zeros(m,n);
        for i = 1:m
            mea = mean( y(i,:) );
            va = var(y(i,:) );
            T(i,:) = ( y(i,:)-mea )/va;
        end
        
       traindata = S;
       testdata = T;
       
       model = svmtrain(trainlabel,traindata,'-s 0 -t 2 -c 2.5 -g 3.8');
      
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
