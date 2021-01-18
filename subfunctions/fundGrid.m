
function gridETDRS = fundGrid(fundIm, centerXIm, centerYIm)

% figure;imshow(fundIm,[])
% hold on
% plot(centerXIm,centerYIm,'.r')

% fundus image properties ~6x6mm
resFund = 3000/600; % fundus resolution um/px
fundFrame = zeros(size(imresize(fundIm,2)));
fundDimX = size(fundFrame,2); % actual fundus X dimension in um 
fundDimY = size(fundFrame,1); % actual fundus Y dimension in um 
% disp(num2str(fundDimY,'%.2f'))

% *steps*

% (1) foveal location is automatically detected using layers thickness;
% will initially search the lowest thickness in a 1.5x1.5mm circular area, 
% (assuming fundus image is centered at fovea) 
% (2) annular circles are made by assigning 1s to an inner circle, thereby 
% creating an annular mask
% (3) annular quadrants are made by assigning 1s to all areas left or 
% right, top or bottom of the desired quadrants
% (4) angled annular quadrants are made by rotating the mask around the 
% foveal center point 
% (5) a 3D angled annular quadrant mask is obtained by duplicating the 
% initial 2D mask in the axial direction

% ***(OD numenclature-based) ETDRS regions algorithm***

% Create a logical image of a circle with specified diameter, center, and 
% fundus image size

% create the fundus size image ~6x6mm (in px)
imageSizeX = round(fundDimX);
imageSizeY = round(fundDimY);
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
centerX = round(centerXIm + round((imageSizeX-round(size(fundIm,2)))/2));
centerY = round(centerYIm + round((imageSizeY-round(size(fundIm,1)))/2));

% % create the circle in the image
% diaDim = 6000; % real desired diameter dimension in um 
radiusFac = 1/resFund; % conversion factor
% radius = round((diaDim*radiusFac)/2);

% *ETDRS 6-9 —  outer annular area mask (6x6mm)*
diaDim2 = 3000; % real desired radius dimension in um 
radius2 = round((diaDim2*radiusFac)/2);
circlePixels2 = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius2.^2;

% *ETDRS 1-5 —  full inner area mask (3x3mm)*
%fundIm5 = fundIm2.*circlePixels2;
%figure; imshow(circlePixels2,[])
%figure; imshow([fundIm2 fundIm5],[])

% *ETDRS 2-5 —  inner annular area mask (3x3mm)*
diaDim3 = 1000; % real desired diameter dimension in um 
radius3 = round((diaDim3*radiusFac)/2);
circlePixels4 = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius3.^2;

% *ETDRS 1 —  full center area mask (1x1mm)*
%fundIm7 = fundIm.*circlePixels4;
%figure; imshow(circlePixels4,[])
%figure; imshow([fundIm2 fundIm7],[])

% ***(OD numenclature-based) ETDRS grid algorithm***

% *steps*
% (1)obtain three 3-px wide annular circles
% (2) obtain two 3-px wide segments 
% (3) mask centre of mask with ETDRS region 1

circlesThickness = 40;

% *ETDRS inner circle (3x3mm)*
diaDim4 = 3000-circlesThickness; % real desired diameter dimension in um, 30px thick line
radius5 = round((diaDim4*radiusFac)/2);
circlePixels8 = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius5.^2;
circlePixels9 = circlePixels2;
circlePixels9(circlePixels8) = 0;
% circlePixels7(circlePixels9) = 1;
% *ETDRS center circle (1x1mm)*
diaDim5 = 1000-circlesThickness; % real desired diameter dimension in um, 30px thick line
radius6 = round((diaDim5*radiusFac)/2);
circlePixels10 = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius6.^2;
circlePixels11 = circlePixels4;
circlePixels11(circlePixels10) = 0;
circlePixels9(circlePixels11) = 1;
% *ETDRS outer vertical & horizontal line (6x6mm)*
linesIm = zeros(size(fundFrame));
% linesIm(max(centerX-radius,1):min(centerX+radius, size(fundFrame,2)),centerY-2:centerY+2) = 1;
% linesIm(centerX-2:centerX+2,max(centerY-radius,1):min(centerY+radius, size(fundFrame,1))) = 1;
linesThickness = 2;
linesIm(max(centerY-radius2,1):min(centerY+radius2, size(fundFrame,2)),centerX-linesThickness:centerX+linesThickness) = 1;
linesIm(centerY-linesThickness:centerY+linesThickness,max(centerX-radius2,1):min(centerX+radius2, size(fundFrame,1))) = 1;
linesIm = logical(linesIm);
circlePixels9(linesIm) = 1;
circlePixels9(circlePixels10) = 0;
circlePixels9 = rotateAround(circlePixels9, centerY, centerX, 45);
%fundGrid2 = fundIm;
%fundGrid2(circlePixels7) = 255;
%figure; imshow(circlePixels7,[])
%figure; imshow(fundGrid2,[])

% cropping is based on actual center of the image, not fundus center
imageCenter = round([imageSizeX imageSizeY]/2); %actual image center
imageCenterX = imageCenter(1);
imageCenterY = imageCenter(2);
startX = imageCenterX-round(size(fundIm,2)/2);
endX = startX+size(fundIm,2)-1;
startY = imageCenterY-round(size(fundIm,1)/2);
endY = startY+size(fundIm,1)-1;

gridETDRS = circlePixels9(startY:endY, startX:endX);    
% figure; imshow(gridETDRS,[])
% hold on
% plot(centerXIm,centerYIm,'.r')

end
