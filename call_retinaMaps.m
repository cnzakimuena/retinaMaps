
function call_retinaMaps()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name - retinaMaps
% Creation Date - 17th January 2021
% Author - Charles Belanger Nzakimuena
% Website - https://www.ibis-space.com/
%
% Description - 
%   Thickness map generation indicating retinal space thickness.  Retinal 
%   thickness and volume values corresponding to ETDRS subfieds are 
%   provided in table format.
%
% Example -
%		call_retinaMaps()
%
% License - MIT
%
% Change History -
%                   17th January 2021 - Creation by Charles Belanger Nzakimuena
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('./subfunctions'))

%% list names of folders inside the patients folder

currentFolder = pwd;
patientsFolder = fullfile(currentFolder, 'processed');
myDir = dir(patientsFolder);
dirFlags = [myDir.isdir] & ~strcmp({myDir.name},'.') & ~strcmp({myDir.name},'..');
nameFolds = myDir(dirFlags);

%% for each 3x3 subfolder, turn segmented data into network graph

% get table row count
rowCount = 0;
for g = 1:numel(nameFolds)
    folder2 = fullfile(patientsFolder, nameFolds(g).name);
    patientDir2 = dir(fullfile(folder2, 'Results'));
    dirFlags2 = [patientDir2.isdir] & ~strcmp({patientDir2.name},'.') & ~strcmp({patientDir2.name},'..');
    subFolders2 = patientDir2(dirFlags2);
    rowCount = rowCount + numel(subFolders2);
end

col = zeros(rowCount,1);
colc = cell(rowCount,1);
rtTable = table(colc,col,col,col,col,col,col,...
    'VariableNames',{'id' 'centerThickness' 'region1' 'region2' 'region3' 'region4'...
    'region5'});
rvTable = table(colc,col,col,col,col,col,col,...
    'VariableNames',{'id' 'totalVolume' 'region1' 'region2' 'region3' 'region4'...
    'region5'});

tableRow = 0;
for i = 1:numel(nameFolds)
    
    % assemble patient folder string
    folder = fullfile(patientsFolder, nameFolds(i).name);
    
    % add line to LOG
    disp(logit(folder, ['Initiating retinaMaps; ' nameFolds(i).name ' folder']))
    
    patientDir = dir(fullfile(folder, 'Results'));
    dirFlags = [patientDir.isdir] & ~strcmp({patientDir.name},'.') & ~strcmp({patientDir.name},'..');
    subFolders = patientDir(dirFlags);
    
    for k = 1:numel(subFolders)
        
        nameFold = subFolders(k).name;
        scanType = nameFold(1:2);
        addpath(genpath('./drusenFunctions'))
        
        if strcmp(scanType, '3m')
            
            load(fullfile(folder,'Results', nameFold,'segmentation.mat'));
            load(fullfile(folder,'Results', nameFold,'scanInfo.mat'));
            load(fullfile(folder,'Results', nameFold,'ETDRS_grid','2DregionsETDRS.mat'));
            sizeRed = scanTag{2};
            radiusFac = 1/sizeRed*3000/1536; % conversion factor, um/px
            
            disp('begin dimAdjustAll')
            [vol_flow,vol_struc,BM,RVI] = dimAdjustAll(volumeFlow,volumeStruc,lBM,RVIf,sizeRed);
            disp('end dimAdjustAll')
            % figure;imshow3D(vol_struc,[],'plot',cat(3,RVI, BM),'LineWidth',2)
            
            % volumeFlow orientation change to en-face direction
            enFace_Flow = zeros(size(vol_flow, 2), size(vol_flow, 3), size(vol_flow, 1));
            for ff = 1:size(vol_flow,1)
                disp(num2str(ff))
                enFace_im2 = mat2gray(reshape(vol_flow(ff,:,:), [size(vol_flow, 2), size(vol_flow, 3)]));
                enFace_Flow(:,:,ff) = enFace_im2;
            end
            % clearvars vol_flow
            
            % check data orientation integrity
            maxFlow = zeros(size(enFace_Flow, 1),size(enFace_Flow, 2));
            for h = 1:size(enFace_Flow, 1)
                disp(num2str(h))
                for hh = 1:size(enFace_Flow, 2)
                    maxFlow(h,hh) = max(enFace_Flow(h,hh,:));
                end
            end
            % clearvars enFace_Flow
            % rotation for consistency with fundus image orientation
            maxFlow = imrotate(maxFlow,-90);
            %                 currDimB = size(vol_struc, 2);
            %                 newDimV = 1536; % from 300
            %                 maxFlow =  imresize(maxFlow, [newDimV currDimB]);
            % figure;imshow(maxFlow,[])
            
            retinaMap = BM-RVI;
            % horizontal flip for consistency with fundus image orientation
            retinaMap = flip(retinaMap, 2);
            
            %retinal thickness, rt
            rtFP = retinaMap(fovCenterX, fovCenterY)*radiusFac; % at foveal point, mm
            avg_rtGR = zeros(1, size(regionsETDRS, 3));
            for h = 1:size(regionsETDRS, 3)
                curr_mean = (mean(retinaMap(logical(regionsETDRS(:,:,h))))*radiusFac);
                avg_rtGR(:, h) = curr_mean; % at given grid region, mm
            end
            rtProfile = [rtFP avg_rtGR]; % mm
            %retinal volume, rv
            voxFac = radiusFac^3; % conversion factor, um^3/vx
            volFac = (1/1000)^3; % conversion factor, mm^3/um^3
            rvT = sum(sum(retinaMap))*voxFac*volFac; % total, mm^3
            rvGR = zeros(1, size(regionsETDRS, 3));
            for h = 1:size(regionsETDRS, 3)
                curr_sum = sum(sum(retinaMap(logical(regionsETDRS(:,:,h)))))*voxFac*volFac;
                rvGR(:, h) = curr_sum; % at given grid region, mm^3
            end
            rvProfile = [rvT rvGR]; % mm^3
            
            resultsFolder = fullfile(folder, 'Results', nameFold);

            % *ETDRS data extraction*
            disp('begin fundProfile')
            gridETDRS = fundProfile(retinaMap);
            disp('end fundProfile')
            
            % *Quality assurance*
            disp('begin QAreport')
            QAreport(vol_struc, fovCenterX, fovCenterY, BM, RVI, gridETDRS, retinaMap, scanTag, rtProfile, rvProfile, resultsFolder)
            disp('end QAreport')
%             QAreport2(vol_struc, fovCenterX, fovCenterY, BM, RVI, gridETDRS, scanTag, resultsFolder)

            %             numcols2 = round(size(maxMask, 1)*1536/300*sizeRed);
            %             numrows2 = round(size(maxMask, 2)*sizeRed);
            %             maxMask_BW = imbinarize(imresize(maxMask,[numrows2 numcols2]));
            normImage = mat2gray(retinaMap);
            imwrite(normImage,fullfile([folder,'\Results\', nameFold, '\retinaMap' '.png']));
            %figure;imshow(maxMask_BW,[])
            
            % For left eye, ETDRS regions must be modified from OD nomenclature
            % to OS nomenclature
            if contains(nameFold, '_OS_')
                rtRegion3 = rtProfile(6);
                rtRegion5 = rtProfile(4);
                rtProfile(4) = rtRegion3;
                rtProfile(6) = rtRegion5;
                
                rvRegion3 = rvProfile(6);
                rvRegion5 = rvProfile(4);
                rvProfile(4) = rvRegion3;
                rvProfile(6) = rvRegion5;
                
            end
            
            tableRow = tableRow + 1;
            
            rtTable{tableRow,'id'} = {nameFold};
            rtTable{tableRow,'centerThickness'} = rtProfile(1);
            rtTable{tableRow,'region1'}  = rtProfile(2);
            rtTable{tableRow,'region2'} = rtProfile(3);
            rtTable{tableRow,'region3'} = rtProfile(4);
            rtTable{tableRow,'region4'} = rtProfile(5);
            rtTable{tableRow,'region5'} = rtProfile(6);
            
            rvTable{tableRow,'id'} = {nameFold};
            rvTable{tableRow,'totalVolume'} = rvProfile(1);
            rvTable{tableRow,'region1'}  = rvProfile(2);
            rvTable{tableRow,'region2'} = rvProfile(3);
            rvTable{tableRow,'region3'} = rvProfile(4);
            rvTable{tableRow,'region4'} = rvProfile(5);
            rvTable{tableRow,'region5'} = rvProfile(6);
            
        end
    end
    
end

fileName1 = fullfile(patientsFolder,'rtTable.xls');
fileName2 = fullfile(patientsFolder,'rvTable.xls');
writetable(rtTable,fileName1)
writetable(rvTable,fileName2)

disp(logit(patientsFolder,'Done retinaMaps'))

            
            