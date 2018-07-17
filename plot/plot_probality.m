
figure(1)
hold on
y1 = [0.1154 , 0.89, 0 ,0 ; 
      0, 0, 1 , 0 ; 
      0 ,0. 0.07 , 0.93 ;
    0.42 , 0.38 , 0.19, 0];

y2 = [0.01, 0.94, 0.04, 0 ;
       0, 0.03, 0.94, 0.02;
       0.03,0.05, 0.07,0.83;
       0.59,  0.36 , 0.046 , 0] ;
       
x = [0.5:3.5] ; 
figure(1)
hold on
stem(x-0.1, y1 (1,:),'filled','r');
stem(x+0.1, y2 (1,:),'filled','b');


figure(2)
hold on
stem(x-0.1, y1 (2,:),'filled','r');
stem(x+0.1, y2 (2,:),'filled','b');

figure(3)
hold on
stem(x-0.1, y1 (2,:),'filled','r');
stem(x+0.1, y2 (2,:),'filled','b');

figure(4)
hold on
stem(x-0.1, y1 (4,:),'filled','r');
stem(x+0.1, y2 (4,:),'filled','b');


axis([0.9 4.1 -0.1 1.1 ]);