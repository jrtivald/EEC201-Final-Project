% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Plot Different Speakers
%
% Description: This functions will plot different speakers with all of their
%               associated data color coated along with other speakers in the
%               same feature space.
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 3/5/2021

function status = plot_diff_spkrs(mfcc, codebook_mfcc, codebook_figs, spkrs_plt)

    % Read in the codebook centroids to plot
    load('codebook.mat','centroids');

    % plot codebooks
    figure('Name','Multiple Speakers')

    % Loop through defined figures
    for i = 1:size(codebook_figs,1)

        subplot(2,ceil(size(codebook_figs,1)/2),i)

        % Generate color palette
        data_clr = lines(size(spkrs_plt,2));

        if length(find(codebook_figs(i,:))) == 2

            % 2-D graph

            % Loop through defined speakers
            for j = 1:size(spkrs_plt,2)

                % Make life easier, save temp matrix of centroids
                cent_mat = centroids{1,spkrs_plt(1,j)};
                mfcc_mat = mfcc{1,spkrs_plt(1,j)};

                % Because centroids can have any MFCCs for dimensions,
                % need to determine which index corresponds to which MFCC
                cent_idx_x = find(codebook_mfcc==codebook_figs(i,1));
                cent_idx_y = find(codebook_mfcc==codebook_figs(i,2));


                scatter(cent_mat(:,cent_idx_x),...
                        cent_mat(:,cent_idx_y),...
                        [],data_clr(j,:),'filled',...
                        'DisplayName',strcat('spkr',num2str(spkrs_plt(1,j))))

                hold on

                scatter(mfcc_mat(codebook_figs(i,1),:),...
                        mfcc_mat(codebook_figs(i,2),:),...
                        [],data_clr(j,:),'HandleVisibility','off')

                title(strcat('Feature Space',num2str(i)))
                legend
                xlabel(strcat('MFCC',num2str(codebook_figs(i,1))))
                ylabel(strcat('MFCC',num2str(codebook_figs(i,2))))
            end
        else

            % 3-D graph

            % Loop through defined speakers
            for j = 1:size(spkrs_plt,2)

                % Make life easier, save temp matrix of centroids
                cent_mat = centroids{1,spkrs_plt(1,j)};
                mfcc_mat = mfcc{1,spkrs_plt(1,j)};
                
                % Because centroids can have any MFCCs for dimensions,
                % need to determine which index corresponds to which MFCC
                cent_idx_x = find(codebook_mfcc==codebook_figs(i,1));
                cent_idx_y = find(codebook_mfcc==codebook_figs(i,2));
                cent_idx_z = find(codebook_mfcc==codebook_figs(i,3));

                
                scatter3(cent_mat(:,cent_idx_x),...
                        cent_mat(:,cent_idx_y),...
                        cent_mat(:,cent_idx_z),...
                        [],data_clr(j,:),'filled',...
                        'DisplayName',strcat('spkr',num2str(spkrs_plt(1,j))))

                hold on

                scatter3(mfcc_mat(codebook_figs(i,1),:),...
                        mfcc_mat(codebook_figs(i,2),:),...
                        mfcc_mat(codebook_figs(i,3),:),...
                        [],data_clr(j,:),'HandleVisibility','off')

                title(strcat('Feature Space',num2str(i)))
                legend
                xlabel(strcat('MFCC',num2str(codebook_figs(i,1))))
                ylabel(strcat('MFCC',num2str(codebook_figs(i,2))))
                zlabel(strcat('MFCC',num2str(codebook_figs(i,3))))
            end
        end
    end

    %return a status flag
    status = 1;
end