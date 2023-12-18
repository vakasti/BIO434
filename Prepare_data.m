%function readwritescorNew(filename,visid)

clear all; close all;

Folderpath='E:\COURSE_DATA\';
%functions
addpath('F:\BIO434\functions\');
%eeglab
addpath ('C:\Users\vakas\GitHub\eeglab\')
eeglab
close

%%
directory = uigetdir(Folderpath,'select Folder containing .raw files');
cd(directory)
[file_name] = uigetfile('*.raw', 'Select the first .raw file');
filename=file_name;

numfile=input('HOW MANY .RAW FILES DO YOU WANT TO PROCESS? ');

datapath=[directory,'\'];

chanlocs = readlocs('test128.loc');
srate_down=128;

for i=1:numfile    
    if i<10
        numfilstr=['0' num2str(i)];
    else
        numfilstr=num2str(i);
    end
    
    filenameraw=[datapath,filename];
    fid = fopen(filenameraw,'rb','b')
    [segInfo, dataFormat, header_array, EventCodes,Samp_Rate, NChan, scale, NSamp, NEvent] = readRAWFileHeader(fid);
    fclose(fid);
    newsamp = NSamp;
    fsraw=Samp_Rate;


    datacut = zeros(128,90*60*fsraw);
    parfor ch = 1:128
        datax = loadEGIBigRaw(filenameraw,ch);
        % Cut to first 90 min
        datacut(ch,:) = datax(:,1:90*60*fsraw);
    end
           
    EEG90 = makeEEG(datacut, fsraw, chanlocs);

    %% Filters
    % design the Low-Pass Filter

    % FIR filter 35 Hz - kaiser (attenuated 50 Hz perfectly)
    srateFilt    = fsraw;
    passFrq      = 30;
    stopFrq      = 49.75;
    passRipple   = 0.02;
    stopAtten    = 60;
    LoPassFilt   = designfilt('lowpassfir','PassbandFrequency',passFrq,'StopbandFrequency',stopFrq,'PassbandRipple',passRipple,'StopbandAttenuation',stopAtten, 'SampleRate',srateFilt, 'DesignMethod','kaiser','MinOrder','Even');
    lpfiltkern = LoPassFilt.Coefficients;

    % design the High-Pass Filter

    % FIR filter 0.5 Hz - kaiser (removes low frequency artifacts and DC offset when combined with the EGI filter)
    srateFilt  = srate_down;
    passFrq    = 0.5;
    stopFrq    = 0.25;
    passRipple = 0.05;
    stopAtten  = 30;
    HiPassFilt = designfilt('highpassfir','PassbandFrequency',passFrq,'StopbandFrequency',stopFrq,'StopbandAttenuation',stopAtten,'PassbandRipple',passRipple,'SampleRate',srateFilt,'DesignMethod','kaiser','MinOrder','Even');
    hpfiltkern = HiPassFilt.Coefficients;

    %% Apply filters and downsampling
    % low-pass filter
    fprintf('** Low-pass filter starts attenuating signal at %.2f Hz and reaches maximum attenuation of %d dB at %.2f Hz\n', LoPassFilt.PassbandFrequency, LoPassFilt.StopbandAttenuation, LoPassFilt.StopbandFrequency)
    EEG90 = firfilt(EEG90, lpfiltkern); 
    
    % Down sample
    EEG90 = pop_resample(EEG90, srate_down);

    % high-pass filter
    fprintf('** High-pass filter starts attenuating signal at %.2f Hz and reaches maximum attenuation of %d dB at %.2f Hz\n', HiPassFilt.PassbandFrequency, HiPassFilt.StopbandAttenuation, HiPassFilt.StopbandFrequency)
    EEG90 = firfilt(EEG90, hpfiltkern);

        
    %% Save the data
    clear segInfo dataFormat header_array EventCodes Samp_Rate NChan scale NSamp NEvent 
    save(['A_Preprocessed_90min_',filename(1:end-4), '.mat'],'EEG90','-v7.3')
    %clear EEG EEG90
    disp('Done Saving!...')
    %clc
end

