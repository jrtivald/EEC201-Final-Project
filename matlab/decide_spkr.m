% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Decide which speaker
%
% Description: Determines which speaker matched the test file.
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 3/5/2021

function status = decide_spkr(dist_mat, confidence_thresh, data_label)

    predict_speaker_number = zeros(1,size(dist_mat,1));
    dist_norm = zeros(size(dist_mat));

    % Normalize and predict speaker
    for i = 1:size(dist_mat,1)

        % First normalize the distortions
        dist_norm(i,:) = abs(dist_mat(i,:) - mean(dist_mat(i,:)));
        dist_norm(i,:) = dist_norm(i,:)/max(dist_norm(i,:));

        % Determine index of largest deviation from mean (predicted speaker)
        [tmp, predict_spkr] = max(dist_norm(i,:));

        % Determine if we are confident in this prediction
        % Look at next closest speaker to max
        next_spkr = sort(dist_norm(i,:),'descend');
        next_spkr = next_spkr(2);

        % Store speaker prediction
        if next_spkr < confidence_thresh
            predict_speaker_number(i) = predict_spkr;
        else
            predict_speaker_number(i) = 0;
        end

    end
    
    % Plot distortions
    figure('Name',data_label)

    for i = 1:size(dist_mat,1)
        scatter((1:size(dist_norm,2)),repmat(i,1,size(dist_norm,2)),repmat(500,1,size(dist_norm,2)),dist_norm(i,:),'filled','s');
        hold on
    end
    title(data_label)
    xlabel('Predicted Speaker')
    ylabel('Test File')
    colorbar

    % Output predicted speakers
    disp(data_label)
    for i = 1:size(dist_mat,1)
        fprintf('Test speaker %i is train speaker %i\n',i,predict_speaker_number(i));
    end

    % return a status flag
    status = 1;
end