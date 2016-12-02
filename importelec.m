files= dir('RESIDENTIAL_LOAD_DATA_E_PLUS_OUTPUT/BASE/*.csv');
num_files = length(files);
Length = num_files;

clear electricity
electricity.base(1).DateTime = 0;
electricity.base(1).ElectricityFacilitykWHourly = 0;
electricity.base(1).GasFacilitykWHourly = 0;
electricity.base(1).HeatingElectricitykWHourly = 0;
electricity.base(1).HeatingGaskWHourly = 0;
electricity.base(1).CoolingElectricitykWHourly = 0;
electricity.base(1).HVACFanFansElectricitykWHourly = 0;
electricity.base(1).ElectricityHVACkWHourly = 0;
electricity.base(1).FansElectricitykWHourly = 0;
electricity.base(1).GeneralInteriorLightsElectricitykWHourly = 0;
electricity.base(1).GeneralExteriorLightsElectricitykWHourly = 0;
electricity.base(1).ApplInteriorEquipmentElectricitykWHourly = 0;
electricity.base(1).MiscInteriorEquipmentElectricitykWHourly = 0;
electricity.base(1).WaterHeaterWaterSystemsGaskWHourly = 0;
electricity.base(num_files).DateTime = 0;

for i=1:1

%% Initialize variables.
    filename = files(i).name;
    delimiter = ',';
    startRow = 2;

    %% Read columns of data as strings:
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

    %% Open the text file.
    fileID = fopen(filename,'r');

    %% Read columns of data according to format string.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

    %% Close the text file.
    fclose(fileID);

    %% Convert the contents of columns containing numeric strings to numbers.
    % Replace non-numeric strings with NaN.
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));

    for col=[2,3,4,5,6,7,8,9,10,11,12,13,14]
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

    % Convert the contents of columns with dates to MATLAB datetimes using date
    % format string.
    try
        dates{1} = datetime(dataArray{1}, 'Format', 'MM/dd HH:mm:ss', 'InputFormat', 'MM/dd HH:mm:ss');
    catch
        try
            % Handle dates surrounded by quotes
            dataArray{1} = cellfun(@(x) x(2:end-1), dataArray{1}, 'UniformOutput', false);
            dates{1} = datetime(dataArray{1}, 'Format', 'MM/dd HH:mm:ss', 'InputFormat', 'MM/dd HH:mm:ss');
        catch
            dates{1} = repmat(datetime([NaN NaN NaN]), size(dataArray{1}));
        end
    end

    anyBlankDates = cellfun(@isempty, dataArray{1});
    anyinvalidDates = isnan(dates{1}.Hour);
    ddd = dates{1};
    for d=1:365
        DDD = 24*d;
        ddd(DDD,1) = ddd((DDD-1),1)+hours(1);
    end
    dates{1} = ddd;

    dates = dates(:,1);

    %% Split data into numeric and cell columns.
    rawNumericColumns = raw(:, [2,3,4,5,6,7,8,9,10,11,12,13,14]);

    %% Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
    rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

    %% Create output variable
    %base = table;
    electricity.base(i).DateTime = datenum(dates{:, 1});
    electricity.base(i).ElectricityFacilitykWHourly = cell2mat(rawNumericColumns(:, 1));
    electricity.base(i).GasFacilitykWHourly = cell2mat(rawNumericColumns(:, 2));
    electricity.base(i).HeatingElectricitykWHourly = cell2mat(rawNumericColumns(:, 3));
    electricity.base(i).HeatingGaskWHourly = cell2mat(rawNumericColumns(:, 4));
    electricity.base(i).CoolingElectricitykWHourly = cell2mat(rawNumericColumns(:, 5));
    electricity.base(i).HVACFanFansElectricitykWHourly = cell2mat(rawNumericColumns(:, 6));
    electricity.base(i).ElectricityHVACkWHourly = cell2mat(rawNumericColumns(:, 7));
    electricity.base(i).FansElectricitykWHourly = cell2mat(rawNumericColumns(:, 8));
    electricity.base(i).GeneralInteriorLightsElectricitykWHourly = cell2mat(rawNumericColumns(:, 9));
    electricity.base(i).GeneralExteriorLightsElectricitykWHourly = cell2mat(rawNumericColumns(:, 10));
    electricity.base(i).ApplInteriorEquipmentElectricitykWHourly = cell2mat(rawNumericColumns(:, 11));
    electricity.base(i).MiscInteriorEquipmentElectricitykWHourly = cell2mat(rawNumericColumns(:, 12));
    electricity.base(i).WaterHeaterWaterSystemsGaskWHourly = cell2mat(rawNumericColumns(:, 13));

    %% Clear temporary variables
    clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me dates blankDates anyBlankDates invalidDates anyInvalidDates rawNumericColumns R;
end



       