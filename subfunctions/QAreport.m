
function QAreport(volumeStruc, fovCenterX, fovCenterY, BMf, RVIf, gridETDRS, retinaMap, scanInfo, rt_Profile, rv_Profile, path)

if ~exist(fullfile(path,'QA report'), 'dir')
    mkdir(fullfile(path,'QA report'));
end
folder = fullfile(path,'QA report');

set(0,'DefaultFigureVisible','off');

% chartColors1.c1 = rgb('AliceBlue');
chartColors1.c2 = rgb('RoyalBlue'); 
% chartColors2.c1 = rgb('MistyRose');
chartColors2.c2 = rgb('HotPink'); 

figure;
imshow(volumeStruc(:,:,fovCenterY),[])
hold on
plot(BMf(fovCenterY,:),'color',rgb('RoyalBlue'),'LineWidth',2)
plot(RVIf(fovCenterY,:),'color',rgb('HotPink'),'LineWidth',2)
axis on
ylim([0 size(retinaMap,1)])
xlim([0 size(retinaMap,1)])
set(gca,'XTick',[0 150 300 450 600]); %This are going to be the only values affected.
set(gca,'XTickLabel',[0 750 1500 2250 3000]); %This is what it's going to appear in those places.
set(gca,'YTick',[0 150 300 450 600]); %This are going to be the only values affected.
set(gca,'YTickLabel',[0 750 1500 2250 3000]); %This is what it's going to appear in those places.
xlabel('Fast Scan [\mum]','FontSize',10)
ylabel('A Scan [\mum]','FontSize',10)
legend('BM', 'RVI','Location','southeast')
set(gcf, 'Position',  [20, 100, 700, 500])
filename1 = 'QA_Bscan';
saveas(gcf, fullfile(folder, filename1),'png')
      
radiusFac = 3000/600;
[gridY, gridX] = find(gridETDRS);
f1 = figure;
ax1 = subplot(2,2,1);
imagesc(retinaMap*radiusFac)    

set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'xtick',[])
set(gca,'ytick',[])

colors_p = [linspace(chartColors2.c2(1),chartColors1.c2(1),3)', ...
    linspace(chartColors2.c2(2),chartColors1.c2(2),3)', ...
    linspace(chartColors2.c2(3),chartColors1.c2(3),3)'];
% c = hot(10); % used to determine color triplets
% J = customcolormap([0 0.5 1], [1 1 1; 1 1 0; 1 0 0]);  
J = customcolormap([0 0.5 1], colors_p);    
colormap(J);
caxis([200 400])  % set colormap range
c = colorbar;
c.Color = 'w'; % make colormap text white

hold on
plot(gridX,gridY,'.w')
if contains(scanInfo{1}, 'OD')
    text(fovCenterX,fovCenterY,'1', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX,fovCenterY-190,'2', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX+190,fovCenterY,'3', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX,fovCenterY+190,'4', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX-190,fovCenterY,'5', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX-250,fovCenterY-250,'OD', 'Color', 'k', 'FontSize', 14, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
else
    text(fovCenterX,fovCenterY,'1', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX,fovCenterY-190,'2', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX+190,fovCenterY,'5', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX,fovCenterY+190,'4', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX-190,fovCenterY,'3', 'Color', 'k', 'FontSize', 16, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
    text(fovCenterX-250,fovCenterY-250,'OS', 'Color', 'k', 'FontSize', 14, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
end
ax2 = subplot(2,2,2);
imagesc(retinaMap*radiusFac)
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'xtick',[])
set(gca,'ytick',[])

colormap(J);
caxis([200 400])
c = colorbar;
c.Color = 'w'; % make colormap text white

hold on
plot(gridX,gridY,'.w')
txtCT1 = num2str(rt_Profile(2),3);
text(fovCenterX-2,fovCenterY-20,txtCT1, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
txtCV1 = num2str(rv_Profile(2),'%.2f');
text(fovCenterX-2,fovCenterY+20,txtCV1, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
txtCT2 = num2str(rt_Profile(3),3);
text(fovCenterX-2,fovCenterY-20-190,txtCT2, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
txtCV2 = num2str(rv_Profile(3),'%.2f');
text(fovCenterX-2,fovCenterY+20-190,txtCV2, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
txtCT3 = num2str(rt_Profile(4),3);
text(fovCenterX-2+190,fovCenterY-20,txtCT3, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
txtCV3 = num2str(rv_Profile(4),'%.2f');
text(fovCenterX-2+190,fovCenterY+20,txtCV3, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
txtCT4 = num2str(rt_Profile(5),3);
text(fovCenterX-2,fovCenterY-20+190,txtCT4, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
txtCV4 = num2str(rv_Profile(5),'%.2f');
text(fovCenterX-2,fovCenterY+20+190,txtCV4, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
txtCT5 = num2str(rt_Profile(6),3);
text(fovCenterX-2-190,fovCenterY-20,txtCT5, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
txtCV5 = num2str(rv_Profile(6),'%.2f');
text(fovCenterX-2-190,fovCenterY+20,txtCV5, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')

% txtCT6 = num2str(rt_Profile(7),3);
% text(fovCenterX-2,fovCenterY-20-550,txtCT6, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
% txtCV6 = num2str(rv_Profile(7),'%.2f');
% text(fovCenterX-2,fovCenterY+20-550,txtCV6, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
% txtCT7 = num2str(rt_Profile(8),3);
% text(fovCenterX-2+550,fovCenterY-20,txtCT7, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
% txtCV7 = num2str(rv_Profile(8),'%.2f');
% text(fovCenterX-2+550,fovCenterY+20,txtCV7, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
% txtCT8 = num2str(rt_Profile(9),3);
% text(fovCenterX-2,fovCenterY-20+550,txtCT8, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
% txtCV8 = num2str(rv_Profile(9),'%.2f');
% text(fovCenterX-2,fovCenterY+20+550,txtCV8, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
% txtCT9 = num2str(rt_Profile(10),3);
% text(fovCenterX-2-550,fovCenterY-20,txtCT9, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
% txtCV9 = num2str(rv_Profile(10),'%.2f');
% text(fovCenterX-2-550,fovCenterY+20,txtCV9, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
txtCT0 = num2str(rt_Profile(1),3);
text(fovCenterX-2-240,fovCenterY-20-240,'CT [\mum]', 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
text(fovCenterX-2-240,fovCenterY+20-240,txtCT0, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
txtCV0 = num2str(rv_Profile(1),'%.2f');
text(fovCenterX-2+240,fovCenterY-20-240,'Vol [mm^{3}]', 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold','HorizontalAlignment', 'Center')
text(fovCenterX-2+240,fovCenterY+20-240,txtCV0, 'Color', 'k', 'FontSize', 8, 'FontWeight', 'normal','HorizontalAlignment', 'Center')
ax3 = subplot(2,2,3);
retinaMap2 = flip(retinaMap, 1);
surf(retinaMap2*radiusFac,'EdgeColor','none');

colormap(J);
caxis([200 400])
c = colorbar;
c.Color = 'w'; % make colormap text white

xlim([0 size(retinaMap,1)])
ylim([0 size(retinaMap,1)])
set(gca,'XTick',[0 150 300 450 600]); %This are going to be the only values affected.
set(gca,'XTickLabel',[0 0.75 1.5 2.25 3.0]); %This is what it's going to appear in those places.
set(gca,'YTick',[0 150 300 450 600]); %This are going to be the only values affected.
set(gca,'YTickLabel',[0 0.75 1.5 2.25 3.0]); %This is what it's going to appear in those places.
xlabel('Slow Scan [mm]','FontSize',10)
ylabel('Fast Scan [mm]','FontSize',10)
zlabel('Thickness [\mum]','FontSize',10)
view(330,75)
darkBackground(f1,[0 0 0],[1 1 1])
% ax4 = subplot(2,2,4);
% choroidMap2 = flip(retinaMap, 1);
% surf(choroidMap2*radiusFac,'EdgeColor','none');
% colormap jet
% xlim([0 size(retinaMap,1)])
% ylim([0 size(retinaMap,1)])
% set(gca,'XTick',[0 150 300 450 600]); %This are going to be the only values affected.
% set(gca,'XTickLabel',[0 0.75 1.5 2.25 3.0]); %This is what it's going to appear in those places.
% set(gca,'YTick',[0 150 300 450 600]); %This are going to be the only values affected.
% set(gca,'YTickLabel',[0 0.75 1.5 2.25 3.0]); %This is what it's going to appear in those places.
% xlabel('Slow Scan [mm]','FontSize',10)
% ylabel('Fast Scan [mm]','FontSize',10)
% zlabel('Thickness [\mum]','FontSize',10)
% view(330,75)
set(gcf, 'Position',  [800, 900, 1170, 917])
filename2 = 'QA_maps';
saveas(gcf, fullfile(folder, filename2),'png')

set(0,'DefaultFigureVisible','on');

end 