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

function [dist_vec, spkr_num] = LBG_VQ(mfcc, codebooks, epsilon, m_cnt, ftr_space_range, train_en)

    % if training mode is enabled, start with initilzed codebook
    if train_en == 1

        % Start with initialized centroids
        mid_ftr_range = (max(ftr_space_range)+min(ftr_space_range))/2;
        centroids = cell(size(codebooks,1),size(mfcc,2));
        min_distort_idx = cell(size(codebooks,1),size(mfcc,2));

        % Loop through all the different speakers
        for i = 1:size(mfcc,2)

            % Loop through feature groups set by user via 'codebooks'
            for j = 1:size(codebooks,1)

                % Reset m
                m = 1;
                
                % Build codebook matrix from mfcc
                if length(find(codebooks(j,:))) == 2
                    % if 2-D
                    tmp_mfcc = [mfcc{1,i}(codebooks(j,1),:);...
                                mfcc{1,i}(codebooks(j,2),:)];
                    
                    centroids{j,i} = {[mid_ftr_range mid_ftr_range]};
                else
                    % If not 2-D, then 3-D
                    tmp_mfcc = [mfcc{1,i}(codebooks(j,1),:);...
                                mfcc{1,i}(codebooks(j,2),:);...
                                mfcc{1,i}(codebooks(j,3),:)];
                    
                    centroids{j,i} = {[mid_ftr_range mid_ftr_range mid_ftr_range]};
                end

                % Continue until desired centroid count achieved.
                while m < m_cnt

                    %split centroid
                    centroids{j,i} = split_centroids(centroids{j,i}, epsilon);
                    m = 2*m;

                    % Cluster Vectors
                    [min_distort, min_distort_idx{j,i}] = vector_cluster(tmp_mfcc,centroids{j,i});
                    distortion = sum(min_distort)/length(min_distort);

                    % Initialize some loop parameters
                    init_flag = 1;
                    distortion_prime = distortion;
                    
                    % Continue until distortion is less than epsilon threshold
                    while abs(distortion_prime-distortion)/distortion >= epsilon || init_flag == 1

                        % clear initial run flag
                        init_flag = 0;
                        
                        % Update Distortion
                        distortion_prime = distortion;
                        
                        % Find Centroids
                        centroids{j,i} = find_centroids(tmp_mfcc, centroids{j,i}, min_distort_idx{j,i});
                        
                        % Cluster Vectors
                        [min_distort, min_distort_idx{j,i}] = vector_cluster(tmp_mfcc,centroids{j,i});
                        distortion = sum(min_distort)/length(min_distort);
                        
                    end
                end
            end
        end
        
        % Save codebooks
        save('codebook.mat','centroids','min_distort_idx');
        
        % No return when training
        spkr_dist = NaN;
        spkr_num = NaN;
        dist_vec = NaN;
        
    else
        
        % Read in the codebook centroids
        load('codebook.mat','centroids');
        
        % initialize distortion matrix
        dist_mat = zeros(size(codebooks,1),size(centroids,2));
            
        % Loop through feature groups set by user via 'codebooks'
        for j = 1:size(codebooks,1)
            
            % Build codebook matrix from mfcc
            if length(find(codebooks(j,:))) == 2
                %if 2-D
                tmp_mfcc = [mfcc(codebooks(j,1),:);...
                            mfcc(codebooks(j,2),:)];
            else
                % If not 2-D, then 3-D
                tmp_mfcc = [mfcc(codebooks(j,1),:);...
                            mfcc(codebooks(j,2),:);...
                            mfcc(codebooks(j,3),:)];
            end
                
            % Loop through all sets of speaker centroids
            for i = 1:size(centroids,2)
                
                % Calculate the minimum distortion
                [min_distort, min_distort_idx] = vector_cluster(tmp_mfcc,centroids{j,i});
                dist_mat(j,i) = sum(min_distort)/length(min_distort);
                
            end
        end
        
        %Sum up all the distortion
        dist_vec = sum(dist_mat,1);
        
    end
    
    %Determine the speaker
    [spkr_dist, spkr_num] = min(dist_vec);

end

%% split_centroids()
function new_centroids = split_centroids(current_centroids, epsilon)

    new_centroids = [];

    %If cell, convert to stored array
    if iscell(current_centroids) == 1
        current_centroids = current_centroids{1}(:,:);
    end

    % Iterate through all the centroids and split
    for i = 1:size(current_centroids,1)
        %check if 2-D
        if size(current_centroids,2) == 2
            new_centroids = [new_centroids(:,:);...
                            [current_centroids(i,1)+epsilon current_centroids(i,2)+epsilon];...
                            [current_centroids(i,1)-epsilon current_centroids(i,2)-epsilon]];
        else
            new_centroids = [new_centroids(:,:);...
                            [current_centroids(i,1)+epsilon current_centroids(i,2)+epsilon current_centroids(i,3)+epsilon];...
                            [current_centroids(i,1)-epsilon current_centroids(i,2)-epsilon current_centroids(i,3)-epsilon]];
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
    if size(centroids,2) == 2
        new_centroids = zeros(size(centroids,1),2);
    else
        new_centroids = zeros(size(centroids,1),3);
    end

    % Loop through all mfccs
    for i = 1:size(centroids,1)

        % Find length of data assigned to centroid
        data_len = length(find((min_disteu_idx==i)));
        
        % Find sum of data assigned to centroid
        data_sum = sum(mfcc(:,(min_disteu_idx==i)),2);
        
        % Accumulate and average to find new centroids
        new_centroids(i,:) = (data_sum/data_len)';

    end

end