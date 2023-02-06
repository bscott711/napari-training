%In this computational exploration we will calculate the stiffness of an
%optical trap by measuring the fluctuations in the position of a trapped
%bead around the center of the well.

%Let's start by looking at the first frame of the movie of the trapped bead
Bead = imread('Trap001.tif');
imshow(Bead,[])

%As we have done aleady in previous computational explorations, let's
%convert this to an image where the dimmest pixel has a value of 0 and the
%brightest one has a value of 1. This is done with the function "mat2gray".
BeadNorm = mat2gray(Bead);

%Let's try to find a threshold that can segment the bead correctly
Threshold = 0.5;
BeadThresh = BeadNorm < Threshold;
imshow(BeadThresh)

%This threshold seems to work relatively well. Now, we want to find the
%position of its centroid. We will use this to track the bead over time.
BeadLabel=bwlabel(BeadThresh);

%Notice that we found more than one area
max(max(BeadLabel))
imshow(BeadLabel==1)
imshow(BeadLabel==2)

%We will assume that the largest area corresponds to the actual bead we
%want to find. Now, obtain the area and centroid using "regionprops". This
%command looks for regions that are not connected in a binary image and
%calculated certain properties corresponding to each region. In this case,
%we will ask it to compute the centroid of each region and its area.
BeadProps=regionprops(BeadLabel,'Centroid','Area');

%The output of "regionprops" is a structure array. This is a very flexible
%data structure in Matlab. Notice that our structure array has two
%elements, each corresponding to one of the detected regions.
BeadProps(1)
BeadProps(2)
%Each element of this structure array has two fields. First, the area,
%which consists of a single scalar. Second, the centroid posision, which is
%a vector with two elements indicating the coordinates of the centroid.

%In order to compare the area of the regions we want to be able to look at
%them side by side. This can be done with the following command
Areas=[BeadProps.Area];
%Notice that we just grabbed each element of the BeadProps structure array,
%and put the area stored into a vector.

%Now, let's find the region with the maximum area. The first output of the
%"max" function gives the actual maximal value and the second output gives
%the element number that the maximum corresponds to
[MaxValue,BeadIndex]=max(Areas);
%As a result, we now know the centroid of our bead
BeadProps(BeadIndex).Centroid


%We just found the centroid of the bead! Finally, we can do this for all
%the snapshots we have. We'll make a for-loop to load and process all
%frames

%First, get a list of the files. The frames are taken at a rate
%of 50 frames/second.
D=dir('*.tif');

for i=1:length(D)
    Bead=imread(D(i).name);
    BeadNorm=mat2gray(Bead);
    BeadThresh = BeadNorm < Threshold;
    BeadLabel=bwlabel(BeadThresh);
    BeadProps=regionprops(BeadLabel,'Centroid','Area');
    Areas=[BeadProps.Area];
    [MaxValue,BeadIndex]=max(Areas);
    Centroid(i,:)=BeadProps(BeadIndex).Centroid;
end

%Now, the first column of "Centroid" has the x positions and the second
%column has the y positions
plot(Centroid(:,1),Centroid(:,2),'-k')

%We want to measure the deviations of the position with respect to the
%mean. We start then by calculating the mean.
MeanCentroid=mean(Centroid);

%We calculate now the mean square displacement in each coordinate
MSDx=mean((Centroid(:,1)-MeanCentroid(1)).^2);
MSDy=mean((Centroid(:,2)-MeanCentroid(2)).^2);

%These mean square displacements are given in units of pixel^2. In order to
%conver this to microns we make use of the fact that, for this particular
%setup, 100um correspond to 1028 pixels:
MSDxum=MSDx*(100/1028)^2;
MSDyum=MSDy*(100/1028)^2;

%Finally, we calculate the stiffness of the trap in each axis by dividing
%kT by the mean square displacement. At room temperature kT = 4E-3 um pN
kx=4E-3/MSDxum
ky=4E-3/MSDyum



