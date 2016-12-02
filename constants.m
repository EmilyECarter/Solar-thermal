
work_fluid = 'Water'; %can set
m = 0.5; %mass flow rate of working fluid

htc = 5; %heat transfer co-effcient 
sa= 4.5; %m^2 surface area of the hot heat exchanger.
ohtc= 1000; %overall heat transfer coefficent W/m^2.K
pump_ineff = 0.9;
pump_work = 5;% work done by thed pump, sized for the system
turbine_ineff = 0.9;
mhot = 70; %mass of hot thing
m_water = 0.025;


tank_area = 5;
        mass_flow_ref = 0.2; %^absorbtion chiller
        eff_ref = 0.4; %absorbtion chiller
UA = 800; % heat transfer coefficent and area of the hot water heat exchanger
cp_water = 4180; %heat capacity of the hot water tank

elec_demand = 1; %fix with time

t1 = 400; % intial temp-fix with data
ttank=315;
h1=1000;
mode =1;
ideal = 325; %ideal temp
t_outside =300;
R_tank = 6;

%solar absorber
n = 0.9; % solar efficency of the pannel, this just the pannel 
A = 3; %m^2 appature area of collector
m = 1; %mass flow rate of the system
a = [1.00, 0.99, 0.98,0.95, 0.91,0.84,0.7];
b = [1.00, 0.99, 0.98,0.95, 0.91,0.84,0.7];
collector = [a;b];


%from weather data
    alpha = 0.9;
    beta=0.7;
    aa_angle = 1.7;
    solar_azimuth = 0.6;
    inclination =1.8;
    angle_of_orentation = 0.3;
    hour_angle = 0.6;
    zenith = 0.7;
    data = [1500:10:1700];
    
   %heat exchanger
   hot_eff = 0.88;
    




