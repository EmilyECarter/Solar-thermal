function counter = fitfunction(x)
%add the path to the location the folder 'Cool Prop' is in
addpath('/Users/Emily/Code/Cool Prop')
vaules;
expander = x(1);
Aw = x(2);
Aw = Aw/1000;
A = x(3);
Ag = x(4);
Ag = Ag/1000;
pump = x(5);
pump = pump/10;
n = x(6);
n = n/100;
thstorage = x(7);
refsize = x(8);
tank_volume = x(9);
usecase = x(10);
statega = x(11);
anual_irr = x(12);
%TMY3index = galocation(galocation(:,3) ==anual_irr);
TMY3 = 7027303;
%TMY3 = galocation(TMY3index,2); %to get site ID
stateindex = statega;

Aref = (refsize.*360.*Uref)./COP; %convert to kj/6 minutes interval 
%refridergtors are measured against there output.


%nh1 is new h1 an is re-calculated at the end of every loop,

working_fluid = 'R245fa'; %working fluid
%nrow = size(weather);
%nrow=nrow(1,2);

%% load electricity data for the location
 
if usecase == 1
    files= dir('RESIDENTIAL_LOAD_DATA_E_PLUS_OUTPUT/LOW/*.csv');
elseif usecase ==2
    files= dir('RESIDENTIAL_LOAD_DATA_E_PLUS_OUTPUT/BASE/*.csv');
else
    files= dir('RESIDENTIAL_LOAD_DATA_E_PLUS_OUTPUT/HIGH/*.csv');
end
    

clear electricity

file = sprintf('%d.csv',TMY3);
indexsiteID = find(strcmp({files.name},file)==1);

% Initialize variables.
    filename = files(indexsiteID).name;
    delimiter = ',';
    startRow = 2;
    
    formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

    fileID = fopen(filename,'r');

    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

    fclose(fileID);

    % Convert the contents of columns containing numeric strings to numbers.
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
        try
            DDD = 24*d;
            ddd(DDD,1) = ddd((DDD-1),1)+hours(1);
        catch
        end
    end
    dates{1} = ddd;

    dates = dates(:,1);

    % Split data into numeric and cell columns.
    rawNumericColumns = raw(:, [2,3,4,5,6,7,8,9,10,11,12,13,14]);

    % Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
    rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

    % Create output variable
    %base = table;
    electricity.DateTime = datenum(dates{:, 1});
    electricity.ElectricityFacilitykWHourly = cell2mat(rawNumericColumns(:, 1));
    electricity.GasFacilitykWHourly = cell2mat(rawNumericColumns(:, 2));
    electricity.HeatingElectricitykWHourly = cell2mat(rawNumericColumns(:, 3));
    electricity.HeatingGaskWHourly = cell2mat(rawNumericColumns(:, 4));
    electricity.CoolingElectricitykWHourly = cell2mat(rawNumericColumns(:, 5));
    electricity.HVACFanFansElectricitykWHourly = cell2mat(rawNumericColumns(:, 6));
    electricity.ElectricityHVACkWHourly = cell2mat(rawNumericColumns(:, 7));
    electricity.FansElectricitykWHourly = cell2mat(rawNumericColumns(:, 8));
    electricity.GeneralInteriorLightsElectricitykWHourly = cell2mat(rawNumericColumns(:, 9));
    electricity.GeneralExteriorLightsElectricitykWHourly = cell2mat(rawNumericColumns(:, 10));
    electricity.ApplInteriorEquipmentElectricitykWHourly = cell2mat(rawNumericColumns(:, 11));
    electricity(1).MiscInteriorEquipmentElectricitykWHourly = cell2mat(rawNumericColumns(:, 12));
    electricity(1).WaterHeaterWaterSystemsGaskWHourly = cell2mat(rawNumericColumns(:, 13));

    % Clear temporary variables
    clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me dates blankDates anyBlankDates invalidDates anyInvalidDates rawNumericColumns R;


%% this is the code for each test case
try

jj = indexsiteID; %the ID of the TMY3 files, %change to num_files for all locations

%% capital cost calculations
hot_fluid = 6.*thstorage;
chpexp = 10000;
panelexp = 782465; % for 2016 start year
expander_cost = 0.0081.*expander+436.81; %vary expander
chiller_cost = 2672.4.*refsize.^(0.684);
heat_cost =  945777.*Aw+3568; %vary chparea
instalation_cost = -64.07.*log(panelexp) +1462.5 -31.77.*log(chpexp) +902+...
    290+956+ 231 +179;
A_cost = 65.759.*A-39.627.*A*n+96.299 ; %panel vary n and A
pump_cost = 411.72.*pump+77.145; % vary HP
capital_costs = expander_cost  + heat_cost + instalation_cost + ...
    A_cost + pump_cost + hot_fluid + chiller_cost; 

pump_work = pump.*0.00134.*360;%convert pump hoursepower to joules/s then to 300 seconds due to splitting into 6 mintue chunks

    % vary syear or start year

    if syear < 2020 %federal subsity changes
        fed_sub = 0.07; %(1-the federal subsity)*0.1 - the average tax rate
    elseif syear < 2021
        fed_sub = 0.074;
    elseif syear < 2022
        fed_sub = 0.078;
    elseif syear < 2023
        fed_sub = 0.082;
    else
        fed_sub = 0;
    end
    fed_sub = 1-fed_sub;
    state_sub = statesubsity(stateindex,3).*0.1.*A.*0.142; %avaerage area of 1kw array is 7m
    %proxy for state subsidy for area installtion, 0.1 is the average tax
    %rate
    state_sub = state_sub+ statesubsidy(stateindex, 5).*A.*0.142; %rebate is straight rebate not tax
    state_tax =  state_sub(stateindex,7).*0.05;%in some states renewables are exempt from sales tax, other have to pay average 5%
    capital_costs = capital_costs.*fed_sub -state_sub+state_tax;
    remaining_cost = capital_costs;

    %% calculate the data for the year
%loop each hour
    k=1; 
    for k = 1:nrow
        if k == 1

            t1 = weather(jj).DrybulbC(k)+273.15;
            if t1<273.06
                t1 = 274;
            end
            ttank = 315;
            h1=CoolProp.PropsSI('H','T',t1,'Q',0,working_fluid);
            hot_storage = 0;
            t_glc = weather(jj).DrybulbC(k)+273.15;
            counter = 0; % new location counter gets reset
        end

        houri = k/10; % again 10 is the number of slpits

        houri = floor(houri) +1;
        if houri > 8670
            houri = 8670;
        end
        total_elec = electricity(jj).ElectricityFacilitykWHourly(houri);
        if total_elec > 0
            elec_demand = 1;
        end

        %assume hot water rank heats up every hour
        hwaterhour = electricity(jj).WaterHeaterWaterSystemsGaskWHourly(houri+1);
        ttankdiff = hwaterhour./(elec_heat_eff.*tank_volume.*cp_water);%heat loss to tank through use.
        ttank = ttank-ttankdiff;


        lat = location(jj).Latitude;
        timezone = location(jj).TimeZone;
        t_outside = weather(jj).DrybulbC(k);
        t_outside = t_outside +273.15; %convert to kelvin
        LMST = 15.*timezone;
        datetim = weather(jj).TimeHHMM(k);
        time = datetime(datetim(1,1),'ConvertFrom','datenum');
        y = time.Year;
        B= (360/365)*(weather(jj).DateMMDDYYYY(k)-datenum(datetime(y,01,01)) -81);
        EoT = 9.87.*sind(2.*B)-7.53*cosd(B)-1.5.*sind(B);
        TC = 4.*(location(jj).Longitude-LMST)+EoT;
        LST = time.Hour+TC/60;
        HRA = 15.*(LST-12); %hour angle
        dec = 23.45.*sind(B); %declination angle
        E = asind(abs(sind(dec).*sind(lat)+cosd(dec).*cosd(lat).*cosd(HRA))); %elevation angle
        Az = acosd((sind(dec).*cosd(lat)-cosd(dec).*sind(lat).*cosd(HRA))/cosd(E)); %Azenith angle
        zenith = 90-Az;


        beta = lat; %angle of incidence of the panel to the horizontal inclination tilt
        alpha = 300;

        incident = acosd(sind(E).*cosd(beta)+cosd(E).*sin(beta).*cos(alpha-Az));

        if incident < 0 
            mode = 0;
        elseif incident >70
            mode = 0;      

        %elseif ideal-ttank < 5
            %mode = 0;

        elseif elec_demand >0  
            mode=1;
        end

        if isnan(weather(jj).DNIWm2(k));
            mode = 0;
        end
        if hot_storage>h_change %override if heat still stored up.
            mode = 1;
        end

        %% 
        if mode > 0;

            % start with saturated liquid working fluid at 1
            p1 = arrayfun(@(x) CoolProp.PropsSI('P','T',x,'Q',0,working_fluid),t1);
            %h1 = CoolProp.PropsSI('H','T',t1,'Q',1,working_fluid);

            %the working fluid gets pumped to the pannel where the pressure rises
            %calculate temperature of the fluid

            h2 = h1 + pump_work;
            %h2 has to be molar
            state = CoolProp.AbstractState.factory('HEOS', working_fluid);
            %temporay p value
            p2=2.*p1;
            arrayfun(@(x) state.update(CoolProp.PQ_INPUTS,(x),0),p2);
            t2 = state.T;
            s2 = state.smass;

            % it is heated to vapour usindg heat from pannel
            %angle*adjustment factor for the sun
            %the other one for time of year
             %Collector efficency =Q/AI

             %a meaure of how the solar collector performs with different angles
             %of incident.
             if incident < 10;
                 K_trans = 1; % no loss when sun is directly above the panel
                 K_long = 1;
             end
            angles = [10, 20, 30, 40, 50, 60, 70];
            x = collector(1, 1:7);
            values = [10:5:70];
            effT = interp1(angles, x, values);
            effL = interp1(angles, collector(2,1:7), values);

            %calculate the efficency of the collector based of the location (angle) of the
            %sun and how it affects the geometry of the solar collector
            %l is the longatudinal and the translational corection so evacuted tube
            %collectors can be used.

            langle = abs(atan(tan(zenith).*cosd(HRA - alpha))-beta);
            tangle = abs(atan((sind(zenith).*sind(HRA-alpha)/cosd(incident))));

            %find the closet vaule in the tables generated to look up the K
            dif = abs(values-langle);
            match = dif == min(dif);
            %index = find(values == match)
            K_long = effL(match);
            %K_long = sprintf('%s*',K_long{1});
            %K_long = sscanf(K_long, '%f*');

            dif2 = abs(values-tangle);
            match2 = dif2 == min(dif2);
            %index2 = find(values == match2)
            K_trans = effT(match2);
            %K_trans = sprintf('%s*',K_trans{1});
            %K_trans = sscanf(K_trans, '%f*');

            correction = K_long.*K_trans;

             %heat transfer co-efficient=Q/deltaT
              %solar irradance for the hour Wh/m2

             I=weather(jj).DNIWm2(k)*cosd(incident) +... %Wh/m2
                 weather(jj).DHIWm2(k)*((1+cosd(beta))/2)+...
             weather(jj).Albunitless(k)*weather(jj).GHIWm2(k)*((1-cosd(beta))/2);
             heat_added = n*A*I*3600*correction; %J

             hot_storage = hot_storage+ heat_added;
             h_change = -arrayfun(@(x) CoolProp.PropsSI('H', 'Q', 0,'T', x, working_fluid),t2)+...
                     arrayfun(@(x) CoolProp.PropsSI('H', 'Q', 1,'T', x, working_fluid),t2);
             if hot_storage > h_change
                 t_glc = thstorage; %temp of hot storage
                 t_glc = hot_storage/(m_glc.*cp_glc.*timeheat1)+t_glc;
                  %heat exchange with the working fluid
                 cp = arrayfun(@(x,y) CoolProp.PropsSI('Cpmass', 'T',x,'S',y,working_fluid),t2,s2);

                 C_glc = m_glc.*cp_glc;
                Cr = cp.*m;
                if C_glc<Cr
                    Cstar=C_glc/Cr;
                    Ntuh = Ug.*Ag/C_glc;
                else
                    Cstar=Cr/C_glc;
                    Ntuh = Ug.*Ag/Cr;
                end

                %q_maxh1 = cp*m*(t_glc-t2)*timeheat1;

                p2 = arrayfun(@(x,y) CoolProp.PropsSI('P', 'T', x, 'S',y, working_fluid),t2,s2);
                %the vapour is superheated
                tsat1 = arrayfun(@(x) CoolProp.PropsSI('T', 'P', x, 'Q',1, working_fluid),p2);
                q1 = m.*cp.*(tsat1-t2).*timeheat1;
                %calculate the temperature of the hot water of the first 'heat
                %exchanger'
                t_glc = t_glc - q1/(m_glc.*cp_glc.*timeheat1);
                %epsh1+epsh2 = (q1+q2)/q_maxh1

                if t_glc > tstag
                    t_glc = tstag;
                end

                syms y
                eqn2 = y == (1+exp(log(1+log(1-y*Cstar)/Cstar)*(1+Cstar)))/(1+Cstar);
                xx = vpasolve(eqn2,y, [0,1]);
                epsh1 = char(xx);
                epsh1 = str2double(epsh1);

                Ntuh1 = abs(log(1+log(1-epsh1*Cstar)/Cstar));
                Ntuh2 = abs(Ntuh - Ntuh1);


                             %add in heat added average temperature
                 %assume all water is liquid


                %now calculate the second 'heat exchanger' cooling and phase change
                %as Cstar = 0
                %assume the heat capcaity of water remains constant accross
                %temperature difference
                epsh2 = 1-exp(-Ntuh2); 
                q2 = epsh2.*C_glc.*(t_glc-tsat1).*timeheat1;
                hb = (q2)/(cp);%enthalphy of the working fluid convert to temp


                boil_out = t_glc -(q2)/(m_glc.*cp_glc.*timeheat1); %temp_out glc
                tb = hb/cp+tsat1;                   
                t3 = tb;
                hot_storage = hot_storage - q2 -q1-h_change; 
                h3 = h2+h_change+q1+q2;
                thstorage = (t_glc.*(thstorage-m_glc.*timeheat1) +... %account for storage
                    boil_out.*m_glc.*timeheat1)/thstorage;
             else
                continue

             end


             %calculate entropy
             Cv = arrayfun(@(x,y) CoolProp.PropsSI('Cvmass','T',x,'S',y,working_fluid),t2,s2);
             ds = Cv.*log(t3/t2);
             s_change = -arrayfun(@(x) CoolProp.PropsSI('S', 'Q', 0,'T', x, working_fluid),t2  )+...
                     arrayfun(@(x) CoolProp.PropsSI('S', 'Q', 1,'T', x, working_fluid),t2);
             s3 = ds + s2+s_change;
             %set(w, 'T',t3,'H',h3);
             p3 = arrayfun(@(x,y) CoolProp.PropsSI('P','T',x,'S',y,working_fluid),t3,s3);
             %hot storage


            % Produce work in the turbine
            s4 = s3;
            %temp change 3-4

            sf = arrayfun(@(x) CoolProp.PropsSI('S', 'Q', 0,'P', x, working_fluid),p3);
            sg = arrayfun(@(x) CoolProp.PropsSI('S', 'Q', 1,'P', x, working_fluid),p3);
            %enthapy of vaporization
            sfg = sg - sf;
            %calculate the fraction from the specific entrophys
            x4s = (s4 - sf)./sfg;
            if x4s >1
                x4s = 1;
            end
            %to calculate the enthaply of ideal system
            hg = arrayfun(@(x) CoolProp.PropsSI('H', 'Q', 1,'P', x, working_fluid),p3);
            hf = arrayfun(@(x) CoolProp.PropsSI('H', 'Q', 0,'P', x, working_fluid),p3);
            hfg = hg-hf;
            h4 = hf + x4s.*hfg;
            %actual enthaply
            work=m.*(h4-h3);
            net_work = work - pump_work;
            t4 = arrayfun(@(x,y) CoolProp.PropsSI('T', 'H', x,'S', y, working_fluid),h4,s4);

            %calculate the heat required for heating and cooling

            Q_out = tank_area.*(ttank-t_outside)/R_tank;
            %backcalculate to get new temp
            ttank = Q_out/tank_area+t_outside; %heat loss through radation

            % theoritical amaount of heat needed for hot water
            %Q_hot = tank_volume*cp_water*(ttank-ideal); %assume water has a density og 1g/1mL

            cp = arrayfun(@(x,y) CoolProp.PropsSI('Cpmass','S',x,'T',y,working_fluid),s4,t4);
            %treat the first heat exchanger with the hot water tank as two heat
            %exchangers, one for temperature reduction and one for condensation
            %cross flow sindgle pass
            Cw = m_water.*cp_water;
            Cr = cp.*m;
            if Cw>Cr
                Cstar=Cr./Cw;
                Ntu = (U.*Aw)./Cr;
            else
                Cstar=Cw./Cr;
                Ntu = (U.*Aw)./Cw;
            end

            %the working fluid having a lower heat capacity and mass flow rate
            %will always be lower than the Cw of the hot water, so we use the
            %vaules for the working fluid
            %q_max1 = cp*m*(t4-ttank)*timeh1;
            p4 = arrayfun(@(x,y) CoolProp.PropsSI('P', 'T', x, 'S',y, working_fluid),t4,s4);
            tsat = arrayfun(@(x) CoolProp.PropsSI('T', 'P', x, 'Q',1, working_fluid),p4);

            if tsat<t4
                q1 = m.*cp.*(t4-tsat).*timeh1;

                %calculate the temperature of the hot water of the first 'heat
                %exchanger'
                ttank = ttank - q1./(m_water.*cp_water.*timeheat1);
                %epsh1+epsh2 = (q1+q2)/q_maxh1

                syms yy
                eqn1 = yy == (1+exp(log(1+log(1-yy.*Cstar)/Cstar).*(1+Cstar)))./(1+Cstar);
                xx = vpasolve(eqn1,yy, [0,1]);
                eps1 = char(xx);
                eps1 = str2double(eps1);

                Ntu1 = abs(log(1+log(1-eps1.*Cstar)./Cstar));
                Ntu2 = abs(Ntu - Ntu1);
                quality = 1;
            else
                Ntu2 = Ntu;
                q1 = 0;
                quality = x4s;

            end
            h_condensation = arrayfun(@(x,y) CoolProp.PropsSI('H', 'T', x, 'Q',y, working_fluid), tsat,quality)-...
                arrayfun(@(x) CoolProp.PropsSI('H', 'T', x, 'Q',0, working_fluid),tsat);
            eps2 = 1-exp(-Ntu2); 
            q2 = eps2.*Cw.*(ideal-ttank).*timeh1;%heat gained by the water
            hworking = h_condensation - q1 -q2; %enthalphy of working fluid
            if hworking <0
                hc = h4-h_condensation;
                qtransfer = hworking;
            else
                hc = h4 -q1 - q2;
                qtransfer = 0;
            end
            tc = t4- (q1+q2)/(m*cp) ;

            qhot = q1 + q2;



            %now for the absorbtion cooling, the working fluid interacts with 
            %the generator of the cooling in a heat exchanger         
            Cr = arrayfun(@(x) CoolProp.PropsSI('Cpmass','T', x, 'Q', 0, working_fluid),tc) .*m;
            if Cw>Cr
                Cc=Cr;
                NTU = Uref.*Aref./Cw;
            else
                Cc=Cw;
                NTU = Uref.*Aref./Cr;
            end      

            q_max = Cc.*(tc-298).*timeref;
            q_max = q_max + qtransfer;
            epsref = 1-exp(NTU);
            %effiecency of heat transfer
            q_ref = epsref.*q_max;
            %the coefficent of performance for an absorbtion chiller is Qe/Qg
            Q_cool=q_ref.*COP;
            newh1 = hc+m.*q_ref;
            h1 = newh1;
            newt1 = q_ref./(m.*timeref.*Cc)+tc;
            t1 = newt1;

            total_gas = electricity(jj).GasFacilitykWHourly(houri);
            cooling = electricity(jj).CoolingElectricitykWHourly(houri);
            hwater = electricity(jj).WaterHeaterWaterSystemsGaskWHourly(houri);
            saveh = hwater - abs(qhot).*2.778-7; %convert J tokwh
            savee = abs(net_work).*turbine_ineff.*2.778e-7; %you can sell electricity back to the grid
            savec = cooling - (abs(Q_cool)./COPref).*2.778e-7; %the amount of energy it would take to 
            %cool the same amount

            if saveh<0
                saveh = hwater;
            else
                saveh = abs(qhot); % you can't sell or profit for excess heating/cooling
            end
            if savec <0
                savec = cooling;
            else
                savec = abs(Q_cool);
            end


            results=[qhot,net_work,Q_cool, saveh,savee, savec, k];
            filename  = sprintf('thesisuse%d.csv',jj);
            dlmwrite(filename,results,'-append')

        else
            Q_out = tank_area.*(ttank-t_outside)./R_tank;        
            ttank = Q_out./tank_area+t_outside;
            %assume working fluid sufficently insulated not to decrease in
            %temperature over the hour.

        end
        Q_out = tank_area.*(ttank-t_outside)./R_tank;        
        ttank = Q_out./tank_area+t_outside;
        if hot_storage < h_change
            continue
        end



    %k=k+1;    
    end


            %% 
            %calculate cost savings
    while remaining_cost > 0;
        counter = counter +1;
        if counter >20
            counter = 100000;
            break
        end

        filename  = sprintf('thesisuse%d.csv',jj);
        load(filename);
        results = sum(filename,1);
        saveh = abs(results(1,4));
        savee = abs(results(1,5));
        savec = abs(results(1,6));


        yearindex = counter+2;
        state = location(jj).State;
        elec_aray = table2array(electricityprice);
        cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
        ece = electricityprice(:,1);
        stateindex = cellfun(cellfind(state),ece);
        elec_pric = electricityprice(stateindex, :);
        elec_price = electricityprice(stateindex,yearindex);
        gasp = gasprice(:,1);
        stateindex = cellfun(cellfind(state),gasp);
        gas_pric = electricityprice(stateindex, g:);
        gas_price = gasprice(stateindex,yearindex);
        yearhsave = saveh.*cell2mat(gas_price)*elec_heat_eff;
        if cell2mat(statesubsidy(stateindex,6))>0
            if cell2mat(statesubsity(stateindex,6))>cell2mat(elec_price)
                yearesave = savee.*cell2mat(statesubsity(stateindex,6));
            else %some states pay a premium for renewable electricity generated.
                yearesave = savee.*cell2mat(elec_price);
            end
        else
            yearesave = savee.*cell2mat(elec_price);
        end
        yearcsave = savec.*cell2mat(elec_price);
        remaining_cost = remaining_cost -  yearhsave - yearesave - yearcsave;
        maintaince_cost = 0.03*capital_costs;
        remaining_cost = maintaince_cost + remaining_cost;

    end
    if counter >20 %assume to long, data is no longer valid ect. 
        counter = 10000;
    end

            output(i,1,j) = t1;
            output(i,2,j) =t2;
            output(i,3,j) = t3;
            output(i,4,j) = t4;
            output(i,5,j) = net_work;
            output(i,6,j) = q_hot;
            output(i,7,j) = q_ref; %how much energy is used
            output(i,8,j) = t_outside;%outside temp
            output(i,9,j) = i;%time
            output(i,10,j) = hotw_outt; %temperature hot water tank
            output(i,11,j) = Q_cool; %q_cool is our actual output in cooling
            output(i,12,j) = ttank;
            output(i,13,j) = hot_storage;
            file = sprintf('thesis%d.csv',j);
            csvwrite(file,output(:,:,j));

    output = [];
    output(1) = counter; %in years
    output(14) =jj;
    output(2) = A;
    output(3) = pump;
    output(4) = expander;
    output(5) = n;
    output(6) = thstorage;
    output(7) = tank_volume;
    output(8) = Ag;
    output(9) = Aw;%hot water exchange
    output(10) = UAref; %chiller
    output(11) = usecase;
    output(12) = stateID;
    output(13) = anual_irr;
    filename  = sprintf('thesisconditions.csv');
    dlmwrite(filename,'-append')



catch
    counter = 10000;
end
%Perc=jj/num_files;
%waitbar(Perc,[sprintf('%0.1f',Perc*100) '%']);    
end

