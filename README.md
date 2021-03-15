# EEC-201 Final Project : Team Omega
Authors: Igor Sheremet and Jonathan Tivald
Date: March 2021

# Speech Data Files
Down load the ZIP file of the speech database from canvas. After unzipping the file, you will 11 speech files, named: S1.WAV, S2.WAV, …; each is labeled after the ID of the speaker. These files were recorded in WAV format. Our goal is to train a voice model (e.g., a VQ codebook in the MFCC vector space) for each speaker using the corresponding sound file. After this training step, the system would have knowledge of the voice characteristic of each (known) speaker. Next, in the testing phase, you should add noises to distort the existing training signals to generate a test set. The amount of noises would vary to test the robustness of your system.

## Test 1
Play each sound file in the TRAIN folder. Can you distinguish the voices of the 11 speakers in the database? Next play each sound in the TEST folder in a random order without looking at the groundtruth and try to identify the speaker manually. Record what is your (human performance) recognition rate. Use this result as a later benchmark.

Human Performance

| TEST Audio | Jonathan | Igor |
| --- | --- | --- |
| s1 | s1 | s |
| s2 | s2 | s |
| s3 | s3 | s |
| s4 | s4 | s |
| s5 | s5 | s |
| s6 | s6 | s |
| s7 | s7 | s |
| s8 | s8 | s |

# Speech Processing

## Test 2
The training data file s1.wav was played in MATLAB using 'sound'. The sample rate of the signal is 12.5 kHz, which means 256 samples contain 20.48 ms of the signals. The signal time-domain plot is bellow:

![time-domain plot](img/test_2_1.png?raw=true)

The STFT was then calculated in MATLAB and was used to generate the spectrograms. First a frame size of 128 samples was used:

![N=128 stft](img/test_2_2.png?raw=true)

Then a frame size of 256 was used:

![N=256 stft](img/test_2_3.png?raw=true)

Lastly, a frame size of 512 samples was used:

![N=512 stft](img/test_2_4.png?raw=true)

In the spectrograms, the region that contains the most energy is between 200 ms and 750 ms.

## Test 3
We used a 40 bank mel-spaced filter bank. The filter bank responses were plotted in MATLAB:

![mel-spaced filter bank](img/test_3_1.png?raw=true)

The spectrogram for the training signal s1.wav was then plotted. Note that the part of the signal that contains the word was isolated:

![signal spectrogram](img/test_3_2.png?raw=true)

The spectrum was then filtered with the mel-spaced filter bank and the output spectrum was plotted:

![mel-spaced filter bank output](img/test_3_3.png?raw=true)

After the signal is passed through the filter-bank, each bank contains the energy of the spectrum in the range of the filter bank. This reduces the amount of coefficients, and the new coefficients contain parts of the spectrum that are most important.

## Test 4
The cepstrum of the filter bank output was then calculated:

![mel-spaced filter bank output](img/test_4_1.png?raw=true)

A selected range of the cepstrum was then selected and normalized to determine the MFCC values.

![mfcc output](img/test_4_2.png?raw=true)

# Vector Quantization
Now apply VQ-based pattern recognition technique to build speaker reference models from those vectors in the training set before identifying any sequences of acoustic vectors from unmarked speakers in the test set.

## Test 5
To check whether the program is working, inspect the acoustic space (MFCC vectors) in any two dimensions in a 2D plane to observe the results from different speakers. Are they in clusters?

Now write a function that trains a VQ codebook using the LGB algorithm.

## Test 6
Plot the resulting VQ codewords using the same two dimensions over the plot of in TEST 5. You should get a figure like Figure 4.

![Figure 4](img/VQ_codebook.png?raw=true)

# Full Test and Demonstration
Using the programs to train and test speaker recognition on the data sets.

## Test 7
Record the results. What is recognition rate our system can perform? Compare this with human performance. Experiment and find the reason if high error rate persists. Record more voices of yourself and your teammates/friend. Each new speaker can provide one speech file for training and one for testing. **Record the results.**

## Test 8
Use notch filters on the voice signals to generate another test set. Test your system on the accuracy after voice signals have passed different notch filters that may have suppressed distinct features of the original voice signal. Report the robustness of your system.

## Test 9
Test the system with other speech files you may find online. E.g. https://lionbridge.ai/datasets/best-speech-recognition-datasets-for-machine-learning/