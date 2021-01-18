
function gridETDRS = fundProfile(retinaMap)

% create the fundus size image
[imageSizeY, imageSizeX] = size(retinaMap);
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% create the circle in the image
centerIm = round([imageSizeX imageSizeY]/2); %image center
centerX = centerIm(1);
centerY = centerIm(2);
% figure;imshow(retinaMap,[])
% hold on
% plot(centerX,centerY,'*r')
% *foveal area mask (1.5x1.5mm)*
diaDim = 1500; % real desired radius dimension, um
radiusFac = 3000/600; % conversion factor, um/px
radius = round((diaDim/radiusFac)/2);
circlePixels = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius.^2;
retinaMapInner = retinaMap.*circlePixels;
%figure; imshow(circlePixels,[])
%figure; imshow(retinaMapInner,[])
%figure; imshow([retinaMap retinaMapInner],[])

[rowsOfMask, colsOfMask] = find(circlePixels); % foveal coordinates
indOfMask = find(circlePixels); % foveal indexes
minValue = min(retinaMap(circlePixels));
indOfMin =  find(retinaMap(circlePixels) == minValue);
rowsOfMin = rowsOfMask(indOfMin);
colsOfMin = colsOfMask(indOfMin);

% foveal center point
fovCenterX = round(median(colsOfMin));
fovCenterY = round(median(rowsOfMin));
% figure;imshow(retinaMap,[])
% hold on
% plot(colsOfMin,rowsOfMin,'ob')
% plot(fovCenterX,fovCenterY,'.r')

disp('begin fundGrid')
gridETDRS = fundGrid(retinaMap, fovCenterX, fovCenterY);
disp('end fundGrid')
%retinaGrid = mat2gray(retinaMap);
%retinaGrid(gridETDRS) = 1;
%figure; imshow(retinaGrid,[])

end

