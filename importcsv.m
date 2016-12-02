files= dir('alltmy3a/*.csv');
num_files = length(files);
Waitbar = waitbar(0,'Please wait...');
Length = num_files;

%initalise the structure
clear weather;
weather.DateMMDDYYYY = 0;
weather.TimeHHMM = 0;
weather.ETRWm2 = 0;
weather.ETRNWm2 = 0;
weather.GHIWm2 = 0;
%weather.GHIsource = 0;
%weather.GHIuncert = 0;
weather.DNIWm2 = 0;
%weather.DNIsource = 0;
weather.DNIuncert = 0;
weather.DHIWm2 = 0;
weather.DHIsource = 0;
weather.DHIuncert = 0;
weather.GHillumlx = 0;
weather.GHillumsource = 0;
weather.Globalillumuncert = 0;
weather.DNillumlx = 0;
weather.DNillumsource = 0;
weather.DNillumuncert = 0;
weather.DHillumlx = 0;
weather.DHillumsource = 0;
weather.DHillumuncert = 0;
weather.Zenithlumcdm2 = 0;
weather.Zenithlumsource = 0;
weather.Zenithlumuncert = 0;
weather.TotCldtenths = 0;
weather.TotCldsource = 0;
weather.TotClduncertcode = 0;
weather.OpqCldtenths = 0;
weather.OpqCldsource = 0;
weather.OpqClduncertcode = 0;
weather.DrybulbC = 0;
weather.Drybulbsource = 0;
weather.Drybulbuncertcode = 0;
weather.DewpointC = 0;
weather.Dewpointsource = 0;
weather.Dewpointuncertcode = 0;
weather.RHum = 0;
weather.RHumsource = 0;
weather.RHumuncertcode = 0;
weather.Pressurembar = 0;
weather.Pressuresource = 0;
weather.Pressureuncertcode = 0;
weather.Wdirdegrees = 0;
weather.Wdirsource = 0;
weather.Wdiruncertcode = 0;
weather.Wspdms = 0;
weather.Wspdsource = 0;
weather.Wspduncertcode = 0;
weather.Hvism = 0;
weather.Hvissource = 0;
weather.Hvisuncertcode = 0;
weather.CeilHgtm = 0;
weather.CeilHgtsource = 0;
weather.CeilHgtuncertcode = 0;
weather.Pwatcm = 0;
weather.Pwatsource = 0;
weather.Pwatuncertcode = 0;
weather.AODunitless = 0;
weather.AODsource = 0;
weather.AODuncertcode = 0;
weather.Albunitless = 0;
weather.Albsource = 0;
weather.Albuncertcode = 0;
weather.Lprecipdepthmm = 0;
weather.Lprecipquantityhr = 0;
weather.Lprecipsource = 0;
weather.Lprecipuncertcode = 0;
weather.PresWthMETARcode = 0;
weather.PresWthsource = 0;
weather.PresWthuncertcode = 0;
weather(num_files).DateMMDDYYYY=0;

clear location;    
location.SiteID = 0;
location.StationName = 0;
location.State = 0;
location.TimeZone = 0;
location.Latitude = 0;
location.Longitude = 0;
location.Elevation = 0;
location(num_files).SiteID = 0;


for i=1:num_files
    
    try 
        %% Initialize variables.
        filename = files(i).name;
        delimiter = ',';
        startRow = 3;
        formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
        fclose(fileID);

        raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
        for col=1:length(dataArray)-1
            raw(1:length(dataArray{col}),col) = dataArray{col};
        end
        numericData = NaN(size(dataArray{1},1),size(dataArray,2));

        for col=[3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28,29,31,32,34,35,37,38,40,41,43,44,46,47,49,50,52,53,55,56,58,59,61,62,64,65,66,68,69,71]
            % Converts strings in the input cell array to numbers. Replaced non-numeric
            % strings with NaN.
            rawData = dataArray{col};
            for row=1:size(rawData, 1);
                % Create a regular expression to detect and remove non-numeric prefixes and
                % suffixes.
                regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                try
                    result = regexp(rawData{row}, regexstr, 'names');
                    numbers = result.numbers;

                    % Detected commas in non-thousand locations.
                    invalidThousandsSeparator = false;
                    if any(numbers==',');
                        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                        if isempty(regexp(thousandsRegExp, ',', 'once'));
                            numbers = NaN;
                            invalidThousandsSeparator = true;
                        end
                    end
                    % Convert numeric strings to numbers.
                    if ~invalidThousandsSeparator;
                        numbers = textscan(strrep(numbers, ',', ''), '%f');
                        numericData(row, col) = numbers{1};
                        raw{row, col} = numbers{1};
                    end
                catch me
                end
            end
        end

        dateFormats = {'MM/dd/yyyy', 'HH:mm'};
        dateFormatIndex = 1;
        blankDates = cell(1,size(raw,2));
        anyBlankDates = false(size(raw,1),1);
        invalidDates = cell(1,size(raw,2));
        anyInvalidDates = false(size(raw,1),1);
        dates = cell(1,size(raw,2));
        for col=[1,2]% Convert the contents of columns with dates to MATLAB datetimes using date format string.
            try
                dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[1,2]}, 'InputFormat', dateFormats{col==[1,2]}); 
            catch
                try
                    % Handle dates surrounded by quotes
                    dataArray{col} = cellfun(@(x) x(2:end-1), dataArray{col}, 'UniformOutput', false);
                    dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[1,2]}, 'InputFormat', dateFormats{col==[1,2]}); %%#ok<SAGROW>
                catch
                    dates{col} = repmat(datetime('00:00','Format','HH:mm'), size(dataArray{col})); 
                end
            end

            dateFormatIndex = dateFormatIndex + 1;
            blankDates{col} = cellfun(@isempty, dataArray{col});
            anyBlankDates = blankDates{col} | anyBlankDates;
            invalidDates{col} = isnan(dates{col}.Hour) - blankDates{col};
            anyInvalidDates = invalidDates{col} | anyInvalidDates;
        end
        dd = dates{2};
        dd(anyInvalidDates) = datetime('00:00','Format','HH:mm');
        dates{2} = dd;
        dates = dates(:,[1,2]);
        blankDates = blankDates(:,[1,2]);
        invalidDates = invalidDates(:,[1,2]);

        %% Split data into numeric and cell columns.
        rawNumericColumns = raw(:, [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28,29,31,32,34,35,37,38,40,41,43,44,46,47,49,50,52,53,55,56,58,59,61,62,64,65,66,68,69,71]);
        rawCellColumns = raw(:, [27,30,33,36,39,42,45,48,51,54,57,60,63,67,70]);


        %% Replace non-numeric cells with NaN
        R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
        rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
        
        %% Create output variable
        %TYA = table;
        weather(i).DateMMDDYYYY = datenum(dates{:, 1});
        weather(i).TimeHHMM = datenum(dates{:, 2});
        weather(i).ETRWm2 = cell2mat(rawNumericColumns(:, 1));
        weather(i).ETRNWm2 = cell2mat(rawNumericColumns(:, 2));
        weather(i).GHIWm2 = cell2mat(rawNumericColumns(:, 3));
        %weather(i).GHIsource = cell2mat(rawNumericColumns(:, 4));
        %weather(i).GHIuncert = cell2mat(rawNumericColumns(:, 5));
        weather(i).DNIWm2 = cell2mat(rawNumericColumns(:, 6));
        %weather(i).DNIsource = cell2mat(rawNumericColumns(:, 7));
        %weather(i).DNIuncert = cell2mat(rawNumericColumns(:, 8));
        weather(i).DHIWm2 = cell2mat(rawNumericColumns(:, 9));
        %weather(i).DHIsource = cell2mat(rawNumericColumns(:, 10));
        %weather(i).DHIuncert = cell2mat(rawNumericColumns(:, 11));
        weather(i).GHillumlx = cell2mat(rawNumericColumns(:, 12));
        %weather(i).GHillumsource = cell2mat(rawNumericColumns(:, 13));
        %weather(i).Globalillumuncert = cell2mat(rawNumericColumns(:, 14));
        weather(i).DNillumlx = cell2mat(rawNumericColumns(:, 15));
        %weather(i).DNillumsource = cell2mat(rawNumericColumns(:, 16));
        %weather(i).DNillumuncert = cell2mat(rawNumericColumns(:, 17));
        weather(i).DHillumlx = cell2mat(rawNumericColumns(:, 18));
        %weather(i).DHillumsource = cell2mat(rawNumericColumns(:, 19));
        %weather(i).DHillumuncert = cell2mat(rawNumericColumns(:, 20));
        weather(i).Zenithlumcdm2 = cell2mat(rawNumericColumns(:, 21));
        %weather(i).Zenithlumsource = cell2mat(rawNumericColumns(:, 22));
        %weather(i).Zenithlumuncert = cell2mat(rawNumericColumns(:, 23));
        %weather(i).TotCldtenths = cell2mat(rawNumericColumns(:, 24));
        %weather(i).TotCldsource = rawCellColumns(:, 1);
        %weather(i).TotClduncertcode = cell2mat(rawNumericColumns(:, 25));
        %weather(i).OpqCldtenths = cell2mat(rawNumericColumns(:, 26));
        %weather(i).OpqCldsource = rawCellColumns(:, 2);
        %weather(i).OpqClduncertcode = cell2mat(rawNumericColumns(:, 27));
        weather(i).DrybulbC = cell2mat(rawNumericColumns(:, 28));
        %weather(i).Drybulbsource = rawCellColumns(:, 3);
        %weather(i).Drybulbuncertcode = cell2mat(rawNumericColumns(:, 29));
        %weather(i).DewpointC = cell2mat(rawNumericColumns(:, 30));
        %weather(i).Dewpointsource = rawCellColumns(:, 4);
        %weather(i).Dewpointuncertcode = cell2mat(rawNumericColumns(:, 31));
        %weather(i).RHum = cell2mat(rawNumericColumns(:, 32));
        %weather(i).RHumsource = rawCellColumns(:, 5);
        %weather(i).RHumuncertcode = cell2mat(rawNumericColumns(:, 33));
        %weather(i).Pressurembar = cell2mat(rawNumericColumns(:, 34));
        %weather(i).Pressuresource = rawCellColumns(:, 6);
        %weather(i).Pressureuncertcode = cell2mat(rawNumericColumns(:, 35));
        %weather(i).Wdirdegrees = cell2mat(rawNumericColumns(:, 36));
        %weather(i).Wdirsource = rawCellColumns(:, 7);
        %weather(i).Wdiruncertcode = cell2mat(rawNumericColumns(:, 37));
        %weather(i).Wspdms = cell2mat(rawNumericColumns(:, 38));
        %weather(i).Wspdsource = rawCellColumns(:, 8);
        %weather(i).Wspduncertcode = cell2mat(rawNumericColumns(:, 39));
        %weather(i).Hvism = cell2mat(rawNumericColumns(:, 40));
        %weather(i).Hvissource = rawCellColumns(:, 9);
        %weather(i).Hvisuncertcode = cell2mat(rawNumericColumns(:, 41));
        %weather(i).CeilHgtm = cell2mat(rawNumericColumns(:, 42));
        %weather(i).CeilHgtsource = rawCellColumns(:, 10);
        %weather(i).CeilHgtuncertcode = cell2mat(rawNumericColumns(:, 43));
        %weather(i).Pwatcm = cell2mat(rawNumericColumns(:, 44));
        %weather(i).Pwatsource = rawCellColumns(:, 11);
        %weather(i).Pwatuncertcode = cell2mat(rawNumericColumns(:, 45));
        %weather(i).AODunitless = cell2mat(rawNumericColumns(:, 46));
        %weather(i).AODsource = rawCellColumns(:, 12);
        %weather(i).AODuncertcode = cell2mat(rawNumericColumns(:, 47));
        weather(i).Albunitless = cell2mat(rawNumericColumns(:, 48));
        %weather(i).Albsource = rawCellColumns(:, 13);
        %weather(i).Albuncertcode = cell2mat(rawNumericColumns(:, 49));
        %weather(i).Lprecipdepthmm = cell2mat(rawNumericColumns(:, 50));
        %weather(i).Lprecipquantityhr = cell2mat(rawNumericColumns(:, 51));
        %weather(i).Lprecipsource = rawCellColumns(:, 14);
        %weather(i).Lprecipuncertcode = cell2mat(rawNumericColumns(:, 52));
        %weather(i).PresWthMETARcode = cell2mat(rawNumericColumns(:, 53));
        %weather(i).PresWthsource = rawCellColumns(:, 15);
        %weather(i).PresWthuncertcode = cell2mat(rawNumericColumns(:, 54));
        
        weather;
        name = weather(i).DateMMDDYYYY;
        N=10; %number of times repeating the date;
        weather(i).DateMMDDYYYY = name(repmat(1:size(name,1),N,1),:); %need to do this for the dates
        numrows=length(weather(i).DateMMDDYYYY);
        maxx = max(weather(i).DateMMDDYYYY);
        minn = min(weather(i).DateMMDDYYYY);
        Nrows = length(weather(i).TimeHHMM);
        %preallocate ect
        weather(i).TimeHHMM = interp1(1:Nrows,weather(i).TimeHHMM,1:numrows,'linear');
        weather(i).ETRWm2 = interp1(1:Nrows,weather(i).ETRWm2,1:numrows,'linear');
        weather(i).GHIWm2 = interp1(1:Nrows,weather(i).GHIWm2,1:numrows,'linear');
        weather(i).DNIWm2 = interp1(1:Nrows,weather(i).DNIWm2,1:numrows,'linear');
        weather(i).DHIWm2 = interp1(1:Nrows,weather(i).DHIWm2,1:numrows,'linear');
        weather(i).GHillumlx = interp1(1:Nrows,weather(i).GHillumlx,1:numrows,'linear');
        weather(i).Zenithlumcdm2 = interp1(1:Nrows,weather(i).Zenithlumcdm2,1:numrows,'linear');
        weather(i).DrybulbC = interp1(1:Nrows,weather(i).DrybulbC,1:numrows,'linear');
        weather(i).Albunitless = interp1(1:Nrows,weather(i).Albunitless,1:numrows,'linear');

        
        clearvars delimiter startRow formatSpec fileID dataArray ans;


    catch
        z = filename
    end
    filename = files(i).name;
    delimiter = ',';
    endRow = 1;
    formatSpec = '%f%q%q%f%f%f%f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'ReturnOnError', false);
    fclose(fileID);

    location(i).SiteID = dataArray{:, 1};
    location(i).StationName = dataArray{:, 2};
    location(i).State = dataArray{:, 3};
    location(i).TimeZone = dataArray{:, 4};
    location(i).Latitude = dataArray{:, 5};
    location(i).Longitude = dataArray{:, 6};
    location(i).Elevation = dataArray{:, 7};
    

                    %% Clear temporary variables
     clearvars filename delimiter startRow formatSpec fileID dataArray ans;


Perc=i/num_files;
waitbar(Perc,[sprintf('%0.1f',Perc*100) '%']);
end
close(h)

