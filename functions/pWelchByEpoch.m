function [ffttot,frange] = pWelchByEpoch(data,fs,lepoch,lwelch,overlap,trim,epochsmear)
% Performs a pwelch spectral power calculation on a fixed epoch within a
% large recording (i.e. sleep EEG) using a hanning window.  Epoch length,
% welch overlap, epoch smear  and trim can be set
%
%
% Syntax:  [ffttot,frange] = pWelchByEpoch(data,fs,lepoch,lwelch,overlap,trim,epochoverlap)
%
% Inputs:
%    data           - timeseries in form [datapoints x channels], containing
%                     use filtered/preprocessed data (e.g. 0.5-40Hz filter)
%    fs             -  sampling rate
% Options:
%   lepoch [20]     - epoch length, default 20 s
%   lwelch [4]      - length of welch windows ,default 4s
%   overlap []      - overlap of pwelch windows in samples, defaults to 50% if left empty
%   trim [full] 	-  how many frequency bins to return, defaults to 50% of
%                      the two sided fft. to get a specific max frequncy use
%                      [val idx]=min(abs(0:1/lwelch:fs*lwelch/2)-freq));
%   epochoverlap [0]- set to 1 to also look into neighboring epoch. adds
%                     two welch windows at the beginning and end that overlap with other
%                       epochs
%
%
% Outputs:
%    ffttot - Spectral power values for  chan x freqbins x epoch
%    frange - Is in the form 0:1/lwelch:trim
%
%
% Other m-files required: none
% Toolboxes required: pwelch
% MAT-files required: none
%

% Authors: Walter Karlen, Caroline Lustenberger
% Date of creation: 2020-03-20
% Version: v1.1 2020-03-26
% Validation date/version:
% Validated by:
% Copyright: (c) 2019-2020. ETH Zurich, Mobile Health Systems Lab. 
%             All rights reserved. Check licence details at the bottom
%                of file.


%set defaults
if nargin<3 || isempty(lepoch)
    lepoch=20; %20 s windows
end
if nargin<4 || isempty(lwelch)
    lwelch=4;  %
end
if nargin<5
    overlap=[];  % 50% overlap creates approx equal weight for all
end
if nargin<6 || isempty(trim)
    trim=round(fs*lwelch/2);  % half the freq range
end

if nargin<7 || isempty(epochsmear)
    epochsmear=0;  % half the freq range
end

% Calculate size of data, number of channels andepochs
newnewsamp=size(data,1);
nch=size(data,2);
numepo=floor(newnewsamp/fs/lepoch); % calculate number of epochs to match with scoring file




%% spectral analysis
fftblock=zeros(nch,trim,numepo); % initalize variable

for channel=1:nch % loop through each channel
    %         disp(num2str(channel));
    
    if epochsmear %prepare matrix for pwelch by epoch
        v=buffer([zeros(lepoch*fs-lwelch*fs/2,1); data(1:end,channel)],lepoch*fs+lwelch*fs,lwelch*fs); % do also  pwelch of epoch edges (uses data of surrounding epochs)
        v=v(:,2:end);
    else
        NonCompleteEpochSize = mod(length(data(:,channel)),lepoch*fs);
        v=reshape(data(1:end-NonCompleteEpochSize,channel),lepoch*fs,[]); 
    end
    [ffte,frequbins]=pwelch(v,hanning(lwelch*fs),overlap,lwelch*fs,fs);
    fftblock(channel,:,:)=ffte(1:trim,:);

end
frange=frequbins(1:trim);
ffttot=fftblock;

%------------- END OF CODE --------------

%%%% ---------------------------- LICENCE ---------------------------------%%%%   
%    (c) 2019-2020. ETH Zurich. Mobile Health Systems Lab, All rights reserved.
%
%  * Redistribution in source and binary forms, with or without modification, 
%    are not permitted without previous written approval of the copyright owner.
%
%  * Modifications of source code for use must retain the above copyright 
%    notice, this list of conditions and the following disclaimer.
%
%    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS   
%    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
%    TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
%    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
%    BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
%    THE POSSIBILITY OF SUCH DAMAGE.