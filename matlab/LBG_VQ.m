% EEC-201, Winter Quarter 2021, Final Project
%
% Title: LBG K-Clustering algorithm
%
% Description: This functions will train a LBG K-Clustering algorithm which
%              will also be used to identify different speakers
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 3/5/2021

function certainty = LBG_VQ(mfcc, feature_cnt, epsilon, m_cnt, ftr_space_range, train_en)

    % if training mode is enabled, start with initilzed codebook
    if train_en == 1

        % Start with initialized centroids
        mid_ftr_range = (max(ftr_space_range)+min(ftr_space_range))/2;
        centroid_init = [mid_ftr_range mid_ftr_range];
        centroids = cell(feature_cnt-1,size(mfcc,2));
        centroids(:,:) = {centroid_init};
        m = 1;

        % Loop through all the different speakers
        for i = 1:size(mfcc,2)

            % Loop through feature pairs building feature spaces
            for j = 1:feature_cnt-1

                % Reset m
                m = 1;
                
                % Continue until desired centroid count achieved.
                while m < m_cnt

                    %split centroid
                    centroids{j,i} = split_centroids(centroids{j,i}, epsilon);
                    m = 2*m;

                    % Cluster Vectors
                    [min_distort, min_distort_idx] = vector_cluster(mfcc{1,i}(j:j+1,1:71),centroids{j,i});
                    distortion = sum(min_distort)/length(min_distort);

                    % Initialize some loop parameters
                    init_flag = 1;
                    distortion_prime = distortion;

                    % Continue until distortion is less than epsilon threshold
                    while (distortion_prime-distortion)/distortion >= epsilon || init_flag == 1

                        % clear initial run flag
                        init_flag = 0;
                        
                        % Update Distortion
                        distortion_prime = distortion;

                        % Find Centroids
                        centroids{j,i} = find_centroids(mfcc{1,i}(j:j+1,1:71), centroids{j,i}, min_distort_idx);

                        % Cluster Vectors
                        [min_distort, min_distort_idx] = vector_cluster(mfcc{1,i}(j:j+1,1:71),centroids{j,i});
                        distortion = sum(min_distort)/length(min_distort);

                    end
                end
            end
        end

        % plot codebooks
        plot_speaker = 1;
        figure('Name','Speaker 1 Codebooks')
        for i = 1:feature_cnt-1
            subplot(2,ceil((feature_cnt-1)/2),i)
            scatter(mfcc{1,plot_speaker}(i,1:71),mfcc{1,plot_speaker}(i+1,1:71))
            hold on
            scatter(centroids{i,plot_speaker}(:,1),centroids{i,plot_speaker}(:,2),[],'filled')
            title(strcat('Codebook',num2str(i)))
            xlabel(strcat('MFCC',num2str(i)))
            ylabel(strcat('MFCC',num2str(i+1)))
        end
        
        % Save codebooks
        save('codebook.mat','centroids');

    else
        % Read in the codebook centroids
        load('codebook.mat','centroids');
    end
    
    certainty = 0;
end

%% split_centroids()
function new_centroids = split_centroids(current_centroids, epsilon)

    new_centroids = [];

    % Test if input is cell array
    if iscell(current_centroids) == 1
        % Iterate through all the centroids and split
        for i = 1:size(current_centroids{1},1)
            new_centroids = [new_centroids(:,:);...
                            [current_centroids{1}(i,1)+epsilon current_centroids{1}(i,2)+epsilon];...
                            [current_centroids{1}(i,1)-epsilon current_centroids{1}(i,2)-epsilon]];
        end
    else
        for i = 1:size(current_centroids,1)
            new_centroids = [new_centroids(:,:);...
                            [current_centroids(i,1)+epsilon current_centroids(i,2)+epsilon];...
                            [current_centroids(i,1)-epsilon current_centroids(i,2)-epsilon]];
        end
    end

end

%% vector_cluster()
function [min_disteu, min_disteu_idx] = vector_cluster(mfcc, centroids)

    % Find euclidian distnace from all centroids
    e_dis = disteu(mfcc, centroids(:,:)');
    e_dis = e_dis';

    % Find nearest centroid (and corresponding distortion) for each data point
    [min_disteu, min_disteu_idx] = min(e_dis,[],1);

end

%% find_centroids()
function new_centroids = find_centroids(mfcc, centroids, min_disteu_idx)

    % initialize new centroids array with 0s
    new_centroids = zeros(size(centroids(:,:),1),2);

    % Loop through all mfccs
    for i = 1:length(min_disteu_idx)

        % Accumulate and average to find new centroids
        new_centroids(min_disteu_idx(i),:) = (new_centroids(min_disteu_idx(i),:) + mfcc(:,i)')/2;

    end

end