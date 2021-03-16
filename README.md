<p align="center">
  <img src="img/team_omega.png" width="1000" title="Github Logo">
</p>

# EEC-201 Final Project : Team Omega
Authors: Igor Sheremet and Jonathan Tivald

Date: March 2021

# Project Overview

This project implements what is known as the Linde Buzo Gray (LBG) Vector Quantization (VQ) method [1], which falls under the general umbrella of k-clustering, to learn and recognize human speech. The algorithm may read in training data (*.wav audio files) to generate "codebooks" (combination of "codewords") which characterize each training files Mel-Frequency Cepstral Coefficients (MFCC).  The Algorithm may then read in test data generated from the same speaker to identify which speaker the test data belongs to based on the learned "codebook."

# How to run the speech recognition program

## Running Speaker Recognition
Simply clone this repository, set ~EEC201-FINAL_PROJECT/matlab/ as your Matlab's working directory, and type "speaker_recognition" into the command line. Or open speaker_recognition.m and click "run."

## Parameter Modification
Below are some user defined parameters that may be found at the top of speaker_recognition.m (around line 28) which allows the user to easily make critical changes to the speaker recognition algorithm.

### MFCC Paramters
| Variable | Description |
| --- | --- |
| FRAME_SIZE_MS     | Size of each data frame in miliseconds |
| FRAME_OVERLAP_MS  | Overlap of each data frame in miliseconds |
| FFT_NUM_POINTS    | Length of FFT for calculating MFCCs |
| MEL_NUM_BANKS     | Number of Mel-Frequency filter banks |
| CEPS_START_BANK   | First filter bank to calculate cpestrum of (usually used to remove DC filter bank) |
| CEPS_NUM_BANKS    | Number of filter banks to calculate cepstrum of |

### LBG-VQ Paramters
| Variable | Description |
| --- | --- |
| LBG_VQ_EPSILON        | Threshold to determine acceptably small distortion change |
| LBG_VQ_M              | 1xS vector specifying centroid count for each speaker, where S is total count of speakers |
| SPKR_CENTROIDS        | Speaker, denoted by integer value, to plot converged centroids with corresponding clustered data |
| SPKR_PLT              | 1xS vector specifying which speakers to plot for comparing centroid and data in feature spaces specified by CODEBOOK_FIGS, where S may be integer values specifying 1 up to all speakers |
| CODEBOOK_MFCC         | 1xS vector specifing which MFCCs will be part of every speaker's codebook, where S may be integer values specifying 1 to all MFCCs |
| CODEBOOK_FIGS         | 2-D array specifying which feature spaces to plot. Each row is either a 1X2 vector (2-D plot) or 1x3 vector (3-D plot) containing integer values corresponding to the MFCC to plot |

# Project Tasks

## Speech Data Files

### Test 1

The test sounds were played, and each project attempted to match the test speaker with the training speaker. The results are summarized in the table below

| TEST Audio | Jonathan | Igor |
| --- | --- | --- |
| s1 | s1 | s1 |
| s2 | s2 | s2 |
| s3 | s3 | s3 |
| s4 | s4 | s4 |
| s5 | s5 | s5 |
| s6 | s6 | s6 |
| s7 | s7 | s7 |
| s8 | s8 | s8 |

## Speech Processing

### Test 2
The training data file s1.wav was played in MATLAB using 'sound'. The sample rate of the signal is 12.5 kHz, which means 256 samples contain 20.48 ms of the signals. The signal time-domain plot is bellow:

![time-domain plot](img/test_2_1.png?raw=true)

The STFT was then calculated in MATLAB and was used to generate the spectrograms. First a frame size of 128 samples was used:

![N=128 stft](img/test_2_2.png?raw=true)

Then a frame size of 256 was used:

![N=256 stft](img/test_2_3.png?raw=true)

Lastly, a frame size of 512 samples was used:

![N=512 stft](img/test_2_4.png?raw=true)

In the spectrograms, the region that contains the most energy is between 200 ms and 750 ms.

### Test 3
We used a 40 bank mel-spaced filter bank. The filter bank responses were plotted in MATLAB:

![mel-spaced filter bank](img/test_3_1.png?raw=true)

The spectrogram for the training signal s1.wav was then plotted. Note that the part of the signal that contains the word was isolated:

![signal spectrogram](img/test_3_2.png?raw=true)

The spectrum was then filtered with the mel-spaced filter bank and the output spectrum was plotted:

![mel-spaced filter bank output](img/test_3_3.png?raw=true)

After the signal is passed through the filter-bank, each bank contains the energy of the spectrum in the range of the filter bank. This reduces the amount of coefficients, and the new coefficients contain parts of the spectrum that are most important.

### Test 4
The cepstrum of the filter bank output was then calculated:

![mel-spaced filter bank output](img/test_4_1.png?raw=true)

A selected range of the cepstrum was then selected and normalized to determine the MFCC values.

![mfcc output](img/test_4_2.png?raw=true)

## Vector Quantization
Now apply VQ-based pattern recognition technique to build speaker reference models from those vectors in the training set before identifying any sequences of acoustic vectors from unmarked speakers in the test set.

### Test 5
After calculating the MFCCs for each training file, we then plotted the framed time data over the duration of our signal choosing two or three MFCCs as our X, Y, and Z axis.  Below you will see speakers 1 and 4 plotted with MFCCs 3 and 11, and again with MFCCs 3, 8 and 11.

<p align="center">
    <img src="img/speaker_compare_no_cent.png" width = "383" height = "220" alt = "Speaker 4 Data 2-D" />
    <img src="img/speaker_compare_no_cent_3d.png" width = "383" height = "220" alt = "Speaker 4 Data 3-D" />
</p>

### Test 6
Next we LBG-VQ method to encode our training files via a method generally referred to as k-clustering.  The main idea behind k-clustering is to generate a "codebook" of "codewords" per each speaker we want to identify. For this project, a "codebook" will be an array of centroids, and a "codeword" will be a centroid.  Each centroid will be determined through the iterative LBG-VQ algorithm which essentially does the following steps each iteration:
- Cluster closest data points to each centroid by finding the minimum Euclidian distance.
- Update each centroid by averaging each dimension of the data points clustered to each centroid.
- Repeat the cluster and update process until a desired distortion change reaches a user defined threshold.
- Split all centroids and repeat all steps until desired amount of centroids and distortion change is reached.

NOTE: The last step is not the only way to add additional centroids, but the method we chose for this project.

Below you will see the centroids which the method above converged on for speaker 4's data points. The color coding identifies which data points are clustered with whith which centroids after the final cnetroids have been determined.

<p align="center">
    <img src="img/speaker4_centroid.png" width = "383" height = "220" alt = "Speaker 4 Centroids 2-D" />
    <img src="img/speaker4_centroid_3d.png" width = "383" height = "220" alt = "Speaker 4 Centroids 3-D" />
</p>

Finally we may look at the data points of the two different speakers with the determined centroids of each speaker.

<p align="center">
    <img src="img/speaker_compare.png" width = "383" height = "220" alt = "Compare Speakers 2-D" />
    <img src="img/speaker_compare_3d.png" width = "383" height = "220" alt = "Compare Speakers 3-D" />
</p>

## Full Test and Demonstration
Using the programs to train and test speaker recognition on the data sets.

### Test 7
Record the results. What is recognition rate our system can perform? Compare this with human performance. Experiment and find the reason if high error rate persists. Record more voices of yourself and your teammates/friend. Each new speaker can provide one speech file for training and one for testing. **Record the results.**

### Test 8
Use notch filters on the voice signals to generate another test set. Test your system on the accuracy after voice signals have passed different notch filters that may have suppressed distinct features of the original voice signal. Report the robustness of your system.

### Test 9
Test the system with other speech files you may find online. E.g. https://lionbridge.ai/datasets/best-speech-recognition-datasets-for-machine-learning/

# References
[1] Y. Linde, A. Buzo & R. Gray, “An algorithm for vector quantizer design”, IEEE Transactions on Communications, Vol.28, pp.84-95, 1980.