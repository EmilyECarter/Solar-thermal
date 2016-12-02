%spmd
    m_glc = 0.1;%kg
    cp_glc = 2450;%J/kg
    t_glc = 310;
    timeheat1 = 360; %s because the iteration is run every 6 minutes
    Ug = 1000;%W/m2
    %Ag = 1;%m2


    work_fluid = 'Water'; %can set
    m = 1; %m2/hour %mass flow rate of working fluid

    %htc = 5; %heat transfer co-effcient 
    %sa= 4.5; %m^2 surface area of the hot heat exchanger.
    %ohtc= 1000; %overall heat transfer coefficent W/m^2.K
    pump_ineff = 0.9;
    pump_work = 5;% work done by thed pump, sized for the system
    turbine_ineff = 0.9;
    mhot = 70; %mass of hot thing
    m_water = 0.15;
    syear = 2016;

    load('weather.mat');
    load('location.mat');
    load('electricity.mat');
    load('electricityprice.mat');
    load('gasprice');
    load('statesubsidy.mat');
    %load('locationID.mat');


    tank_area = 0.5;
    tank_volume = 10; %L
            mass_flow_ref = 0.2; %^absorbtion chiller
            eff_ref = 0.4; %absorbtion chiller
    U = 800; % heat transfer coefficent and area of the hot water heat exchanger
    cp_water = 4180; %heat capacity of the hot water tank
    %units!!!!!

    tstag = 540; %K
    t1 = 310; % intial temp-fix with data
    ttank=325;
    timeh1 = 1;%hour time in first heat exchanger
    h1=330000;%Joules/kg
    mode =1;
    ideal = 325; %ideal temp
    R_tank = 6;
    COP = 0.7; %for the absorbtion cooler
    COPref = 3; %typical COP for electric air-con
    Uref = 4.53;
    timeref = 360; %s because the itteration is run every 6 minutes
    hot_storage = 0;

    %solar absorber
    %n = 0.45; % solar efficency of the pannel, this just the pannel 
    %A = 1; %m^2 appature area of collector
    a = [1.00, 0.99, 0.98,0.95, 0.91,0.84,0.7];
    b = [1.00, 0.99, 0.98,0.95, 0.91,0.84,0.7];
    collector = [a;b];


    %from weather data
    %asll in degrees
        %alpha = 70; %angle of pannel measured from the north orentitation
       % beta=34;%angle of incidence of the panel to the horizontal inclination

       counter = 0;
       jj = 1;
       k = 1;
       nrow = 87600;
       h_change = 1000000;
       elec_heat_eff = 0.3;
       
       allstateindex = gasprice(2:52,1);
       
       %match each location to the siteID
       %for i=1:2046 %the number of station in TMY3 
           %galocation(i,1) = location(i).State;
           %galocation(i,4) = find(strcmp({allstateindex},location(i).State)==1);
           %galocation(i,2) = location(i).SiteID;
           %galocation(i,3) = sum(weather(i).ETRWm2);
           %then save each as .mat
      % end
       
       %load('galocation.mat');
       
 
%end



