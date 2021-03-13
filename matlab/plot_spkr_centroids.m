% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Plot Speaker Centroids
%
% Description: This functions will plot a speakers contriods in their codebook
%               with color coated data clustered to each centroid for debugging.
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 3/5/2021

function status = plot_spkr_centroids(mfcc, codebook_mfcc, codebook_figs, spkr_plt)

    % Read in the codebook centroids to plot
    load('codebook.mat','centroids','min_distort_idx');

    % plot codebooks
    figure('Name',strcat('Speaker ',num2str(spkr_plt)))

    % Loop through defined figures
    for i = 1:size(codebook_figs,1)

        subplot(2,ceil(size(codebook_figs,1)/2),i)

        % Make life easier, save temp matrix of centroids and
        % Min distortion index from cell array
        cent_mat = centroids{1,spkr_plt};
        min_dist_vec = min_distort_idx{1,spkr_plt};
        mfcc_mat = mfcc{1,spkr_plt};

        % Generate color palette
        data_clr = lines(size(cent_mat,1));

        if length(find(codebook_figs(i,:))) == 2

            % 2-D graph

            % Because centroids can have any MFCCs for dimensions,
            % need to determine which index corresponds to which MFCC
            cent_idx_x = find(codebook_mfcc==codebook_figs(i,1));
            cent_idx_y = find(codebook_mfcc==codebook_figs(i,2));

            % Plot centroid and associated MFCCs with matching colors
            for j = 1:size(cent_mat,1)

                scatter(cent_mat(j,cent_idx_x),...
                        cent_mat(j,cent_idx_y),...
                        [],data_clr(j,:),'filled',...
                        'DisplayName',strcat('centroid',num2str(j)))

                hold on

                scatter(mfcc_mat(codebook_figs(i,1),min_dist_vec==j),...
                        mfcc_mat(codebook_figs(i,2),min_dist_vec==j),...
                        [],data_clr(j,:),'HandleVisibility','off')
            end

            title(strcat('Feature Space',num2str(i)))
            legend
            xlabel(strcat('MFCC',num2str(codebook_figs(i,1))))
            ylabel(strcat('MFCC',num2str(codebook_figs(i,2))))
        else

            % 3-D graph

            % Because centroids can have any MFCCs for dimensions,
            % need to determine which index corresponds to which MFCC
            cent_idx_x = find(codebook_mfcc==codebook_figs(i,1));
            cent_idx_y = find(codebook_mfcc==codebook_figs(i,2));
            cent_idx_z = find(codebook_mfcc==codebook_figs(i,3));

            % Plot centroid and associated MFCCs with matching colors
            for j = 1:size(cent_mat,1)
                
                scatter3(cent_mat(j,cent_idx_x),...
                        cent_mat(j,cent_idx_y),...
                        cent_mat(j,cent_idx_z),...
                        [],data_clr(j,:),'filled',...
                        'DisplayName',strcat('centroid',num2str(j)))

                hold on

                scatter3(mfcc_mat(codebook_figs(i,1),min_dist_vec==j),...
                        mfcc_mat(codebook_figs(i,2),min_dist_vec==j),...
                        mfcc_mat(codebook_figs(i,3),min_dist_vec==j),...
                        [],data_clr(j,:),'HandleVisibility','off')
            end

            title(strcat('Feature Space',num2str(i)))
            legend
            xlabel(strcat('MFCC',num2str(codebook_figs(i,1))))
            ylabel(strcat('MFCC',num2str(codebook_figs(i,2))))
            zlabel(strcat('MFCC',num2str(codebook_figs(i,3))))
        end
    end

    %return a status flag
    status = 1;
end