function payback = fit(htc,sa);




    
addpath('/Users/Emily/Code/Cool Prop')
%add the path to the location the folder 'Cool Prop' is in

%nh1 is new h1 an is re-calculated at the end of every loop,

results = [];
try

    for i = 1:20;

        cosx = sin(alpha)*cos(beta)+cos(alpha)*sin(beta)*cos(aa_angle-solar_azimuth);
        incident = acosd(cosx);
        if incident < 10 
            mode = 0;
        elseif incident >70
            mode = 0;      

        elseif ideal-ttank < 5
            mode = 0;

        elseif elec_demand >0  
            mode=1;
        end

        if mode > 0;

            % start with saturated liquid working fluid at 1
            p1 = arrayfun(@(x) CoolProp.PropsSI('P','T',x,'Q',1,working_fluid), t1);
            %h1 = CoolProp.PropsSI('H','T',t1,'Q',1,working_fluid);

            %the working fluid gets pumped to the pannel where the pressure rises
            %calculate temperature of the fluid

            h2 = h1 + pump_work;
            %temporay p value fix this later
            s2 = arrayfun(@(x) CoolProp.PropsSI('S', 'Q',1, 'P', x ,working_fluid), p1);
            t2 = arrayfun(@(x) CoolProp.PropsSI('T', 'Q',1, 'P', x ,working_fluid), p1);


            % it is heated to vapour using heat from pannel
            %angle*adjustment factor for the sun
            %the other one for time of year
             %Collector efficency =Q/AI

             %a meaure of how the solar collector performs with different angles
             %of incident.
            angles = [10, 20, 30, 40, 50, 60, 70];
            x = collector(1, 1:7);
            values = [10:5:70];
            effT = interp1(angles, x, values);
            effL = interp1(angles, collector(2,1:7), values);

            %calculate the efficency of the collector based of the location (angle) of the
            %sun and how it affects the geometry of the solar collector
            %l is the longatudinal and the translational corection so evacuted tube
            %collectors can be used.
            cos_indcidence = sin(alpha)*cos(beta)+cos(alpha)*sin(beta)*cos(aa_angle-solar_azimuth);
            langle = abs(atan(tan(zenith)*cos(hour_angle - angle_of_orentation))-inclination);
            tangle = abs(atan((sin(zenith)*sin(hour_angle-angle_of_orentation)/cos_indcidence)));

            %find the closet vaule in the tables generated to look up the K
            dif = abs(values-langle);
            match = dif == min(dif);
            index = find(values == match);
            K_long = effL(index);

            dif2 = abs(values-tangle);
            match2 = dif2 == min(dif2);
            index2 = find(values == match2);
            K_trans = effT(index2);

             %heat transfer co-efficient=Q/deltaT
             I=data(i); %solar irradance for the hour
             heat_added = n.*A.*I;
             h3 = heat_added./ +h2;
             t3 = htc./heat_added + t2;
             %calculate entropy
             ds = heat_added./t3;
             s3 = ds + s2;
             %set(w, 'T',t3,'H',h3);

            % Produce work in the turbine
            s4 = s3;
            t4=t1;
            sf = arrayfun(@(x) CoolProp.PropsSI('S', 'Q', 1,'T', x, working_fluid), t4);
            sg = arrayfun(@(x) CoolProp.PropsSI('S', 'Q', 0,'T', x, working_fluid), t4);
            %enthapy of vaporization
            sfg = sg - arrayfun(@(x) CoolProp.PropsSI('S', 'Q', 1,'T', x, working_fluid), t4);
            %calculate the fraction from the specific entrophys
            x4s = (s4 - sf)./sfg;
            %to calculate the enthaply of ideal system
            hg = arrayfun(@(x) CoolProp.PropsSI('H', 'Q', 0,'T', x, working_fluid), t4);
            h4s = hg + x4s.*(hg - arrayfun(@(x) CoolProp.PropsSI('H', 'Q', 1,'T', x, working_fluid), t4));
            %actual enthaply
            h4 = h3-turbine_ineff*(h3-h4s);
            work=m*(h4-h3).*turbine_ineff;
            net_work = work - pump_work;

            %calculate the heat required for heating and cooling

            Q_out = tank_area.*(ttank-t_outside)/R_tank;
            %backcalculate to get new temp
            ttank = Q_out./tank_area+t_outside;
            results(i,1) = ideal-ttank;

            if numel(s4)<numel(t4);
                t4 = repmat(t4,numel(s4));
            end
            if numel(t4)<numel(s4);
                t4 = repmat(s4,numel(t4));
            end
            cp = arrayfun(@(x,y) CoolProp.PropsSI('Cpmass','S',x,'T',y,working_fluid),s4,t4);
            %treat the first heat exchanger with the hot water tank as two heat
            %exchangers, one for temperature reduction and one for condensation
            %cross flow single pass
            Cw = m_water.*cp_water;
            Cr = cp.*m;
            Cstar=Cw./Cr;
            Ntu = UA./Cr;

            %the working fluid having a lower heat capacity and mass flow rate
            %will always be lower than the Cw of the hot water, so we use the
            %vaules for the working fluid
            q_max1 = cp.*m.*(t4-ttank);

            p4 = (h4-arrayfun(@(x,y) CoolProp.PropsSI('P', 'T', x, 'S',y, working_fluid),t4,s4));
            %the vapour is superheated
            tsat = arrayfun(@(x) CoolProp.PropsSI('T', 'P', x, 'Q',1, working_fluid),p4);
            q1 = m.*cp.*(t4-tsat);
            %calculate the temperature of the hot water of the first 'heat
            %exchanger'
            tw = ttank - q1./(m_water.*cp_water);

            eps1 = abs(q1./q_max1);
            Ntu1 = -log(1+log(1-eps1.*Cstar)./Cstar);
            Ntu2 = Ntu - Ntu1;

            %now calculate the second 'heat exchanger' cooling and phase change
            %Cstar = 0
            %assume the heat capcaity of water remains constant accross
            %slight temperature difference
            eps2 = 1-exp(Ntu2); 
            q2 = eps2.*Cw.*(tsat-tw);
            hc = arrayfun(@(x) CoolProp.PropsSI('H', 'T', x, 'Q',1, working_fluid), tsat) - q2./m;
            hotw_outt = tw-q2/(m_water*cp_water);
            tc = tsat - cp_water./(arrayfun(@(x) CoolProp.PropsSI('H', 'T', x, 'Q',1, working_fluid), tsat)-hc);
            results(i,2) = hotw_outt; %temperature of hot water tank

            %now for the absorbtion cooling, the working fluid interacts with 
            %the generator of the cooling in a heat exchanger         
            Cr = arrayfun(@(x) CoolProp.PropsSI('Cpmass','T', x, 'Q', 0, working_fluid),tc) *m;
            if Cw>Cr
                Cc=Cr;
            else
                Cc=Cw;
            end      

            q_max = Cc.*(tc-298);
            %effiecency of heat transfer
            q_ref = eff_ref.*q_max;
            %the coefficent of performance for an absorbtion chiller is Qe/Qg
            Q_cool=q_ref./COP;
            results(i,3) = Q_cool;
            newh1 = hc-m.*q_ref;
            h1 = newh1;
            newt1 = tc - q_ref./Cc;
            t1 = newt1;

        else
            Q_out = tank_area.*(ttank-t_outside)./R_tank;        
            ttank = Q_out./tank_area+t_outside;
            %assume working fluid sufficently insulated not to decrease in
            %temperature over the hour.
        end
    end
catch
    results(:,2) = 0;
    results(:,3) = 0;
end
saved = results(:,2);

%heat exchanger
cost = (area                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

%opts.InitialPopulationRange = [2 1; 20 10];
%[x,Fval,exitFlag,Output] = ga(FitnessFunction,numberOfVariables,[],[],[],[],[],[],[],opts);