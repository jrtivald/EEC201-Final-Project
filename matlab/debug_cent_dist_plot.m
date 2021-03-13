% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Debug centroids and distortion plots
%
% Description: This functions will generate centroid and distortion plots
% over different iterations.  Used for debugging VQ algorithm.
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 3/5/2021

function status = debug_cent_dist_plot(figure_name, mfcc, centroids, dist_idx, distortion_check, epsilon)

    % plot codebooks
    figure('Name',figure_name)

    %plot centroids over time
    data_clr = lines(size(centroids,1));
    
    for i = 1:size(centroids,2)/2
        subplot(1,size(centroids,2)/2+1,i)
        for j = 1:size(centroids,1)
            scatter(centroids(j,i),centroids(j,i+1),[],data_clr(j,:),'filled')
            hold on
            scatter(mfcc(1,(dist_idx(i,:)==j)),mfcc(2,(dist_idx(i,:)==j)),[],data_clr(j,:))
        end
        title(strcat('Centroid Convergence: ',num2str(i)))
    end
    
    %plot distortion check over time
    subplot(1,size(centroids,2)/2+1,size(centroids,2)/2+1)
    plot(distortion_check)
    hold on
    tmp = repmat(epsilon,1,length(distortion_check));
    plot(tmp,'r--')
    title('Distortion check with epsilon')
    
    %return a status flag
    status = 1;
end