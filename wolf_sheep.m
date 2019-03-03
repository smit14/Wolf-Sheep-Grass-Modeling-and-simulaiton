n = 100;
gsheep = zeros(n,n);          % grid for sheeps
ggrass = zeros(n,n,2);          % grid for grass
gwolf = zeros(n,n);

sheeps= zeros(10*n*n,4);        % array for sheeps
wolves = zeros(10*n*n,4);       % array for wolves

nwolf = 2;      %initial percentage of wolves
nsheep = 10;    %initial percentage of sheep
ngrass = 30;    %initial percentage of grass
ewolf = 100;    %initial energy of wolf
esheep = 80;    %initial energy of sheep   
lwolf = 1;      %loss of energy after a move for wolf
lsheep = 1;     %loss of energy after a move for sheep
gainwolf = 12;      %gain of wolf after eating sheep
gainsheep = 4;     %gain of sheep after eating grass
rwolf = 3;      %reproduction rate of wolf
rsheep = 4;     %reproduction rate of sheep
rtgrass = 23;   %regrowth time for grass

counts = 1;     %array count for sheep
countw = 1;     %array count for wolf

itr = 5000;     %number of iterations
cntsheeps = zeros(itr,1);
cntwolves = zeros(itr,1);
cntgrass = zeros(itr,1);
for i=1:n
    for j=1:n
        r = rand();
        if r<=nwolf*.01
            gwolf(i,j) = countw;
            wolves(countw,1) = ewolf;       %initial energy of wolf
            wolves(countw,2) = 1;           %1 = wolf is alive ; 0 = wolf is dead
            wolves(countw,3) = i;           %x position of wolf
            wolves(countw,4) = j;           %y position of wolf
            countw=countw+1;
        elseif r<=(nwolf+nsheep)*.01
            gsheep(i,j) = counts;             %number of sheeps at a point                   
            sheeps(counts,1) = esheep;          %energy of sheep
            sheeps(counts,2) = 1;               %1 = sheep is alive ; 0= sheep is dead
            sheeps(counts,3) = i;               % x position of sheep
            sheeps(counts,4) = j;               % y position of sheep
            counts = counts + 1;
        end;
        r = rand();
        if r<= ngrass*.01
            ggrass(i,j,1) = 1;                  % 1 = grass; 0 = no grass;
        else
            ggrass(i,j,2) = rtgrass;            % time remaining for regrowth of grass;
        end;
    end;
end

img = getimage(gsheep,gwolf,ggrass(:,:,1));
imshow(img,'InitialMagnification',4000);
pause(2);


for it = 1:itr
    %%--------------------------------- sheep ---------------------------------
     
    
    tcounts = counts;

    for i=1:counts
        if sheeps(i,2)==1
            sheeps(i,1) = sheeps(i,1)-lsheep;    %enegry
            % -------------------------- death ----------------------------------

            if sheeps(i,1) <= 0
                sheeps(i,2) = 0;
                gsheep(sheeps(i,3),sheeps(i,4)) = 0;            

            %--------------------------- move ---------------------------------
            else  
              
                x = sheeps(i,3);
                y = sheeps(i,4);
                [b,nx,ny] = getlocation1(x,y,n,gsheep);             %new location
                if b==0                                     % space is available to move
                    sheeps(i,3) = nx;
                    sheeps(i,4) = ny;
                    gsheep(x,y) = 0;                
                    gsheep(nx,ny) = i;
                
                %-------------------------- eat -------------------------------

                    if ggrass(nx,ny,1) == 1
                        sheeps(i,1) = sheeps(i,1) + gainsheep;
                        ggrass(nx,ny,1) = 0;
                        ggrass(nx,ny,2) = rtgrass;
                    end

                %------------------------- reproduce --------------------------

                    r = rand();
                    [bb,nnx,nny] = getlocation1(nx,ny,n,gsheep);
                    if r < rsheep*.01 && bb==0
                        eng = sheeps(i,1)/2;
                        sheeps(i,1) = eng;
                        tcounts = tcounts+1;
                        sheeps(tcounts,1) = eng;
                        sheeps(tcounts,2) = 1;
                        sheeps(tcounts,3) = nnx;
                        sheeps(tcounts,4) = nny;
                       
                        gsheep(nnx,nny) = tcounts;
                       
                    end
                end
            end
        end
        
    end
    counts = tcounts;
    
    
    %---------------------------- grass -----------------------------------
    
    for i=1:n
        for j=1:n
            if ggrass(i,j,2)>0
                ggrass(i,j,2) = ggrass(i,j,2) - 1;
            end
            if ggrass(i,j,1)==0 && ggrass(i,j,2)==0
                ggrass(i,j,1)=1;
                ggrass(i,j,2) = rtgrass;
            end
        end
    end
   
%     subplot(1,2,1)
%     imshow(logicalimage(gsheep),'InitialMagnification',4000);
%     pause(.5);
%     subplot(1,2,2)
%    imshow(logicalimage(ggrass(:,:,1)),'InitialMagnification',4000);
    % pause(.01);
    
    
    %%------------------------- wolf ------------------------------------------

    tcountw = countw;
    for i=1:countw
        if wolves(i,2) ==1
            %------------------------- death ----------------------------------
            wolves(i,1) = wolves(i,1) - lwolf;
            if wolves(i,1) <= 0
                wolves(i,2) = 0;
                gwolf(wolves(i,3),wolves(i,4))=0;
            else
            %------------------------ move ------------------------------------
                x = wolves(i,3);
                y = wolves(i,4);
                %[b,nx,ny] = getlocation1(x,y,n,gwolf);
                [bb,nx,ny]=newlocation(x,y,n,gwolf,gsheep);
                if b==0
                    
                    gwolf(x,y) = 0;
                    gwolf(nx,ny) = 1;
                    wolves(i,3) = nx;
                    wolves(i,4) = ny;
                %------------------------ eat -------------------------------------    
                    if gsheep(nx,ny)>0
                       isheep = gsheep(nx,ny);
                       sheeps(isheep,2) = 0;
                       gsheep(nx,ny) = 0;
                       wolves(i,1) = wolves(i,1) + gainwolf;
                    end

                %------------------------ reproduce -------------------------------    

                    r = rand();
                    [bb,nnx,nny] = getlocation1(nx,ny,n,gwolf);
                    
                    if r<= rwolf*.01 && bb==0
                        eng = wolves(i,1)/2;
                        wolves(i,1) = eng;
                        tcountw = tcountw +1;
                        wolves(tcountw,1) = eng;
                        wolves(tcountw,2) = 1;
                        gwolf(nnx,nny) = 1;
                        wolves(tcountw,3) = nnx;
                        wolves(tcountw,4) = nny;
                    end
                end
            end
        end
    end
    countw = tcountw;       
%    figure(1);
%     subplot(1,2,1);
%     imshow(logicalimage(gsheep),'InitialMagnification',4000);  
% %     
%      subplot(1,2,2);
%     imshow(logicalimage(gwolf),'InitialMagnification',4000);
img = getimage(gsheep,gwolf,ggrass(:,:,1));
%figure(2);
imshow(img,'InitialMagnification',4000);
    cntwolves(it) = sum(wolves(:,2));
    cntsheeps(it) = sum(sheeps(:,2));
    a = ggrass(:,:,1);
    cntgrass(it) = sum(a(:));
end;

figure(3);
plot(cntwolves);
hold on;
plot(cntsheeps);
hold on;
plot(cntgrass);
legend('wloves','sheeps','grass');

