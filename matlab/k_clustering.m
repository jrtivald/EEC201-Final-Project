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

function certainty = LBG_clustering(mfcc, feature_cnt, epsilon, m_cnt, train_en)

    % if training mode is enabled, start with initilzed codebook
    if train_en
        %Start with initialized centroids
        centroid_init = [0.5 0.5];
        centroids = cell(1,feature_cnt-1);
        centroids(:) = {centroid_init};
    else
        %Read in the codebook centroids
        load('codebook.m',centroids)
    end


    % Loop through feature pairs
    for i = 1:feature_cnt-1

        % Continue until desired centroid count achieved.
        while m < m_cnt

            %split centroid
            centroids{i} = centroid_split(centroids{i}, epsilon);

            % Continue until distortion is less than epsilon threshold
            while (distortion_der-distortion)/distortion >= epsilon

                % Cluster Vectors
                % Currently setup to accept row vectors of data, but can be chagned.
                cluster_logic = vector_cluster(mfcc(i:i+1,:),centroids{i});

                % Update Centroids

                % Compute Distortion


            end
        end
    end    

    % if training mode is enabled, save computed codebooks
    if train_en
        save('codebook.m',centroids)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% centroid_split()
function new_centroids = centroid_split(current_centroids, epsilon)

    new_centroids = {[]};

    %Iterate through all the centroids and split
    for i = 1:length(current_centroids)
        new_centroids = {[new_centroids{1}(:,:);...
                          [current_centroids{1}(i,1)+epsilon current_centroids{1}(i,2)+epsilon];...
                          [current_centroids{1}(i,1)-epsilon current_centroids{1}(i,2)-epsilon]]};
    end

end

% vector_cluster()
function nearest_centroid = vector_cluster(mfcc, centroids)

    % initialize logic array
    nearest_centroid = zeros(size(mfcc,1), size(centroids{1}(:,:),1));

    % expand matricies

    % here we should use the disteu.m file provided by Prof Ding, but that function
    % seems to sum up the distances over all the time frames, which I think implies
    % that all of the whole data vector should be clustered to 1 centroid, which is
    % different from the video I sent you on Youtube.  That video clustered each
    % individual datapoint with the closest centroid, not the entire data vector.

    % Return logic matrix
    % I wanted to return a matrix of logic vecotrs that will indicate which data points
    % are clustered with each centroid. so the matrix would be NxM where N is the centroid
    % count and M is length of our MFCC vecotrs (ie. number of time domain frames).
    % That way when we update the centroid location, we can just do code like the following:
    %
    % controid(3,1) = average(mfcc(7,logic_matrix(3,:))
    % controid(3,2) = average(mfcc(8,logic_matrix(3,:))
    %
    % Which should update the location of the 3rd centroid in the codebook 
    % for MFCC-7 by MFCC-8
end