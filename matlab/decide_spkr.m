% EEC-201, Winter Quarter 2021, Final Project
%
% Title: Decide which speaker
%
% Description: Determines which speaker matched the test file.
%
% Authors: Igor Sheremet and Jonathan Tivald
%
% Date: 3/5/2021

function decide_spkr(dist_mat, thresh, data_label)

    % initialize
    prediction = zeros(size(dist_mat));
    predict_speaker_number = zeros(1,size(dist_mat,1));

    for i = 1:size(dist_mat,1)
        
        % convert distortion to a prediction where 0 is least likley to be 
        % the speaker and and 1 is most likeley to be speaker
        prediction(i,:) = 1 - dist_mat(i,:)/norm(dist_mat(i,:),'inf');
        
        % Determine index of the predicted speaker
        [~, predict_spkr] = max(prediction(i,:));     
        
        % determine if prediction if over the threshold
        if prediction(i,predict_spkr) >= thresh
            predict_speaker_number(i) = predict_spkr;
        else
            predict_speaker_number(i) = 0;
        end

    end
    
    % Plot predictions
    figure('Name',data_label)
    imagesc(prediction);  
    yticks(1:size(prediction,1))
    xticks(1:size(prediction,2))
    axis xy
    title(data_label)
    xlabel('Predicted Speaker')
    ylabel('Test File')
    colorbar

    % Output predicted speakers
    fprintf('\n%s:\n',data_label)
    for i = 1:size(dist_mat,1)
        if predict_speaker_number(i) == 0
            fprintf('Speaker %i is not recognized\n',i)
        else
            fprintf('Speaker %i is train speaker %i\n',i,...
                predict_speaker_number(i));
        end
    end
    
end