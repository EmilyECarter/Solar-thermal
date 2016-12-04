# Solar-thermal
Code for finding evaluating the economic feasibility of a solar thermal system. Information for running code at the bottom. 

### Algorithm Inputs
The variables imputed into the genetic algorithm where: 
* Aperture area of the Solar Collector
* Effciency of Solar Collector
* Pump size
* Expander size
* Volume of Hot Water Tank
* Volume of Hot Storage
• Area of Boiler
• Area of the Hot Water Heat-exchanger
* Size of the absorption chiller
* Electricity Usecase
* State
* Annual Irradiance

 
### Penalty Function
The penalty function is used to train the algorithm to look for the best possible solutions.
The data on electricity and gas price was only predicted until 2040 After the year 2040 the electricity and gas price was set at the very low value of $0.03 per kW/h. Setting the value so low steadily increases the payback period, e ectively penalising these scenarios.
Selections which produce physically impossible results will be penalised and as- signed a payback period of 10000 yeas.
### Constraint Function
A constraint was placed on the algorithm that the location chosen had to be located in the State chosen. Constraints a ect the inputs that can be chosen.
The annual irradiance does determine the location. However, as mentioned above, the State can also have a large impact as it a ects the electricity price and subsidies. The number of locations also varies between States. This presents a problem as the algorithm might favour States simply because they have more measured locations and not because they are a more feasible option. One approach to solve this would be to use a very large initial population where the State is randomly chosen from a vector weighted to the number of measurement sites. However the discrepancy between the State with the largest number of locations (Texas,64) and the State with the fewest locations (Delaware,2) is large. This runs the risk of States with a small number of locations not being adequately sampled and ignored in the algorithm To have a 95% chance that the smallest State would be included would require an initial population of tens of thousands, which is not feasible.
To attempt to overcome this short-fall States were grouped into clusters using kmeans. Clustering is a way of identifying and grouping States with similar fea- tures such as electricity price, type of subsidy and price of selling electricity back to
This Annual Energy Outlook only projects until 2040 which would be a payback period of 25 years. It reasonable to assume a payback period of longer than this is essentially infeasible, as it is unlikely a homeowner will undertake an investment for such a long period or remain in the same house. Additionally some parts may need additional service and maintenance cost every 20 years.
As the algorithm forms subsequent populations based on the best results of the current generation, if a State is not sampled in the initial generation, it is possible that the State would not be sampled at all. One possibility would be to increase the random mutation rate in later generations, however this would take the algorithm longer to find solutions.

 
the grid. Kmeans is a way of distinguishing which States  t into which cluster by calculating the smallest possible di erence between State and cluster. Six clusters were identi ed and  tted to the State data.
 32details on how the number of clusters were selected as well as the makeup of the State clusters are given in the appendix

## Results and Discussion
### Sample Results
A selection of results for a given year and given location are shown below. The algorithm was run for 20 generations however after 11 generations no additional improvement could be found.
A visualisation of some of the di erent payback periods around the country is shown in figure ??. For more detail a map only including states with an average payback period of less than 35 years is shown infigure ??
The average value for each variable in each generation of the algorithm was plotted in  gure ??. As the generations progress the results  nd solutions that are closer. The average of each population is shown below.
From this we can see that a global optimum solution was found, at around pop- ulation 800. While in some cases payback periods of only a few years was the uncertainty inherent in the cost model means that only a an average can be con- sidered. A box-plot of the variable values from generations 750 to 850 are shown in  gure ??. Only scenarios which returned a payback period of less than twenty years 1 were included.
### Aggregated results
The plots in figure ?? identify a range in which an solar-thermal CCHP system could be feasible. Potentially interesting findings are noted below.

 
 Figure A.1: Electricity, hot water and cooling load generated throughout the year in a sample location. Note that during the middle of the year, in North American summer, the plot becomes denser as entries are more common. This indicates that more electricity heating and cooling is produced in this time period. Also note that far more electricity is produced than heating or cooling

 Figure A.2: Average payback time for each state

 Figure A.3: Average payback time for each state

 Figure A.4: A moving average of the average payback period vs population num- ber. The grey bar r represents uncertainty in this average. Note the grey bar is uniform on both sides of the moving average, and does not represent individual data points.

 Figure A.5: Plots of the optimal identi ed ranges. Larger individual plots can be seen in the appendix visualisation section.
#### Absorption Chiller
In aggregate the optimum absorption chiller value was around 7.5kW. Few solutions were found with an absorption chiller of at least 5kW was used which indicates that a chiller is necessary to successful implementation.
#### Hot Storage
A hot storage volume of around 500L was found to be feasible. This is slightly larger than many solar hot water heaters and indicates that hot storage is a crucial component to the feasibility of solar thermal CCHP.
#### Panel
Interestingly a solutions were found with a wide range of e ciencies of the Col- lector, with the average at around 0.85. Very few solutions were found with an extremely high eficiency of close to 1. This is promising as such panels are not yet widely available and indicates that a solar thermal CCHP system could be implemented with current panel technology.The bulk of optimum solutions was found with a larger collector area of around 8-9m2.
#### Solar Irradiance
Perhaps unsuprisingly areas the areas with the highest solar irradience in the country were the areas best suited for a solar thermal CCHP.
#### Heat Exchangers
The boiler heat exchanger may be slightly more important than the hot water heat exchanger evidenced as optimum solutions were found with larger boiler heat exchangers.
### Interactions
#### Sobol Indices
Additionally the Sobol sensitivity indices were generated to see interactions and importance of the di erent variables. This is important as the system will be implemented in specific cases and not on aggregate. The empty Sobol indices were generated in R, using the package ’sensitivity’. This output was then entered into the algorithm in Matlab and the results were entered into R for analysis.
Again, only scenarios with a payback period of less than 25 were selected for the index, so all areas of interaction indicate scenarios that are economically feasible. While Sobol indices are a standard way of calculating distribution and sensitivity for continuous variables, two of the input variables were factors (the State cluster and the electricity use case) the e ect of which was not accurately captured in indices, and as such have been left out from the table and plot in figure ??.
The variable importance plots highlights that the state the systems is installed in is the most important factor in whether a system is economical or not. Of the variables that determine the design of the system the panel size and panel eficecny are the most important. This could indicate that cost e ectiveness of the system comes from the solar input.

In the ten States where 95% of solar PV is installed the average payback period is eight years. This is slightly below the average payback period found for a solar thermal CCHP system. Future work would be needed to determine if a solar PV systems is more economical than a solar thermal CCHP system in each of the locations and use-cases. It is likely that a solar PV system would be more cost e ective when the solar input is the driving factor.
To better understand the factors that make a system economically feasible, a meta- model was constructed. The top interactions found from the Sobol indices were explored in depth and visualisations of these interactions were created using the R package ’ICEbox’. A selection of interesting findings is described in detail below.

### Meta-Model
A meta-model was created to better explore and visualise areas of pro tability. A meta-model is a model designed to mimic a computationally expensive simulation to allow for more in depth data exploration. The results gathered in the simulation were used to train a ’conditional random forest’ to replicate the Matlab simulation described above. A random forest is made up of decision trees6. Each decision tree is made using a random sample of predictors 7 and a random sample of data. Training the tree on only a random selection of data means that the tree can be tested on how accurately it predicts the remaining data. Like the name suggests the trees are aggregated together, with trees that are better predictors weighted higher. The forest outputs the weighted average of the value predicted by each tree.
As the input data contained factors (the State cluster, and the electricity use profile) a conditional random forest was used. A conditional random forest also allows for scenarios with a smaller payback time to be given more weight. This model was trained and tuned to  nd the optimal forest. The R package ’Partykit’
As such a system would not incur the cost of the chiller or hot water heater
A decision tree is similar to a probability tree and contains a series of ’nodes’ or choices where the data is split into groups. Each tree contains several nodes splitting the data into smaller groups containing like individuals.
a predictor is any of our input values
Traditional random forests are biased against factors
by sampling from these data points more frequently than scenarios that returned longer payback periods

 Figure A.7: The correlation between continuous variables
 was used to create the conditional random forest and the package ’Caret’ was used to train the forest. An optimal value of 1001 trees and nine randomly selected variables for each tree was found. The random forest was found to have an average prediction error of one year.
 
The results of the simulation were also tested for correlation. Correlation between variables can lead to variables that have a smaller e ect on the outcome acciden- tally being weighted as having more importance. For example high temperature might be correlated with longer daylight hours. However if we were measuring the amount of air-conditioner use in a household, the model could falsely assume that both variables contribute equally to air-conditioner use, when in reality the temperature is the driving factor.
The simulation data generally has very low levels of correlation which means all variables can be used to calculate the meta-model12. The correlation between the annual irradiance and the volume of the hot storage is likely a statistical error as it has no conceptual explanation. As such this interaction will be ignored.
Interestingly some of the State clusters appear to be correlated with the annual
The RMSE value was 0.0502, as the payback period was normalised with a maximum value of one. As the maximum payback period used in the model was twenty years 0.05 represents one year. So the model makes predictions that are on average one year o .
which can be seen in figure ??
only the continuous variables are shown here. Factors cannot be tested for correlation in the same way as continuous variables, however with only two variables as factors, this does not present an issue.
note this was one of the interactions picked up by the sobol indices 
 
irradiance. This could indicate that the States with more solar resources are more likely to take advantage of this. Alternatively it could be a result where political ideology is the driving factor behind a State’s energy policy, and political ideology is geographically distributed14. Future work could build on this, analysing the impact of each individual State compared to clusters of similar States.
There is also some correlation between di erent energy use cases and di erent States. Again there are valid reasons why this might be the case
A.2.3 State Cluster
Using the meta-model the importance of all variables can be calculated. It can be seen that the State cluster in which a system is located has the biggest e ect, followed by the solar irradiance.
It is not surprising that subsidies would be the most important factor in deter- mining whether a system is successful or not. However part of some State’s rebate included a tax credit. The simulation assumed that everyone installing a system paid the same amount of tax, which is a drastic over-simpli cation. In reality tax rates vary widely and around half of the United States population already receive tax credits that exceed their tax burden. So while it can be concluded that State subsides can have a large impact, more work would need to be done to evaluate the e ect of these subsidies on consumers.
The state cluster was not trained on energy prices as this was not found to be a di erentiating factor. Future work could better explore the role of electricity and gas prices, seperate from any subsides on a state level.
A.2.4 Solar Irradiance
Additionally it can be seen that while the annual irradiance is the second largest important variable, it impacts the outcome in two separate places. A partial deriva- tive plot of this is shown,in  gure ?? Partial yhat refers to the partial dependence the annual irradiance has on the algorithm.
The graph appears to show that solar irradiance can have a large impact on the model when the irradiance is very low. However at around 2,700,000 it drops by
14for this reason this correlation was not accounted for in the meta-model. Doing so would unfairly punish the importance of the individual State clusters. As the State clusters and annual irradiance represent di erent aspects it is valid to assume both contribute to the model.
15for example in some States with lower electricity and gas prices energy use might be higher 15
 
 Figure A.8: Solar irradience in di erent state clusters
16
 Figure A.9: An individual conditional expectation plot of total annual irradi- ance.[3] The highlighted yellow line is the overall partial dependence while the grey lines represent partial dependence with di erent variables. The dots repre- sent the random selection of values used to calculate the graph. Generally when the grey lines are parallel and stack on top of each other this indicates the e ect that the variable, solar irradiance, has on the overall model is not dependant on other variables. When the lines are sloped and cross over one another, this generally indicates another variable may be working in concert with the solar irradiance to in uence the results of the model. This graph was developed using the R package ’ICEbox’
17
around 50% and thereafter with increasing solar irradiation, it plays a smaller role in the overall result of the model16. This in uence is likely dependant on other variables. As di erent variables have di erent scales, in order to make sure that a larger value in one variable does not out-weigh a smaller value in a di erent variable, all variables are ’normalised’. Normalisation is adjusting the scale of di erent variables so they have the same minimum and maximum values. This allows us to compare di erent inputs with greater ease.
The fact that multiple variables can interact17 whereas at other times they do not, can be shown by plotting a derivative individual conditional expectation ?? coloured with di erent variables. This curve, shown in  gure ?? shows the regions at which one variable interacts with other variables to in uence the model. To make any conclusions about the importance of di erent features and designing future systems it is essential to determine the range at which features interact. As the meta-model has been trained only on economically feasible solutions, regions and interactions highlighted are factors that make a solar-thermal system feasible. Additionally the standard deviation of the model output is plotted at the bottom of the graph to show how in uential a certain interaction is.
This plot is a measure of how variables e ect the model. Any bump away from zero indicates an e ect on the model, and any lines outside of the yellow zone indicate that an interaction is impacting the model. On this graph, we can see that one interaction (the bright green line) is causing the spike. Thus this in- teraction between the solar irradiance (the yellow zone) and the panel size (the hue) is e ecting the model. While there is another cluster at 0.5, we do not have knowledge of what interactions are causing this cluster, because it is a mixture of various colours and hues. This indicates that various panel sizes are present at this particular feasibility point. The model output cannot be caused by the interaction of panel size and solar irradiance at this point.
The cluster of bright green points at around 0.75 indicates that when the annual irradiance is around 310,000 and there is also a large solar panel area, a solar thermal system is economically feasible. values plot This is logical, as it makes more sense to spend more money on a larger solar panel when it is located in an area with higher solar irradiation than in an area with lower irradiation, where the solar panel is less of a priority. There is also a noticeable spike at around
16Although from  gure ?? we note that very few observations for solar irradiance are in this range, so this higher relative importance is likely just noise
17interaction between variables is to be expected with any model. It could be a case that two or more variables happen to be correlated, as discussed above or it could be the case that two or more variables are causative, for example low temperatures combined with poorly insulated houses cause a large amount of heating to be required. Correlation e ects have already been taken out of the meta-model, so this interaction is primarily causative
18
 
 Figure A.10: a di erentiated individual conditional expectation plot of the yearly annual irradiance coloured with the size of the solar collector. Again the yellow line represents the partial dependence curve. The hue of red to green indicates the panel size. A bright red represents low values of the collector area, and bright green represents larger areas. The yellow highlighted black zone is what e ect we expect the solar irradience to have if it was completely independent. Both variables were indexed to lie between zero and one.
19
0.75. However there is no clear distinction between solar collector sizes as the data points appear to be somewhat in the middle. However when we plot the same annual irradience curve, coloured instead with electricity use, as shown in  gure ??, a much clearer relationship emerges.
At the clump at 0.5 we can see that low electricity use case impacts at lower solar irradiance, however the bulk of the interaction is governed by the base electricity case. The high electricity usage has a small interaction at higher values of around 0.6.
In sum: the location matters quite a bit (as a combination of both irradiation and the house), the second most important variable is the panel itself (which indicates that the radiation is the driving factor).
A.3 Conclusion
Optimal solutions to a solar thermal CCHP system were found using a genetic algorithm to identify if such a system could be economically feasible. These opti- mal solutions showed that such a system could probably be feasibly implemented. However there are several unknown uncertainties incurred in the cost equations which could possibly change this result.
Future work should focus on quantifying the uncertainties of the installation cost estimate. More accurate and speci c cost estimates for equipment could be gath- ered by professional estimators within the range of aggregated solutions identi-  ed.
Additionally the model was dissected to  nd the importance and relationship be- tween variables necessary to apply these  ndings to other locations. A method of identifying important variables and important interactions was presented. The technical implementation details were found to be not nearly as important as the area that the system was installed in. The locations determines both the subsidy level and the annual irradience which were the most important factors. Even in terms of the design the area of the panel is the most important variable both of which are in uenced by the annual irradiances, again re-enforcing the importance of the location.




#Instructions for code
Relies upon the wonderful package 'CoolProp' details here http://www.coolprop.org
Also requires two datasets. The TMY3 dataset from NREL available [here] (http://rredc.nrel.gov/solar/old_data/nsrdb/1991-2005/tmy3/) and the electricity use dataset from the Office of Energy Efficiency & Renewable Energyavailable [here] (http://en.openei.org/datasets/dataset/commercial-and-residential-hourly-load-profiles-for-all-tmy3-locations-in-the-united-states)
Included are two scripts 'importcsv' and 'importelec' which contain code to import, clean and format the TMY3 data and electricity data files respectively. This is only if you wish to customise or improve the system over-all.

Download all of the data separated by locations. There are around 1000 locations in total.

All other data-files used have been uploaded. Please contact me if you want information on how I got these data-files. Code contains many equations I derived from economic data I scraped. Contact me for details.
To run the global optimisation for all electricity use profiles and all 1000 locations run the 'gascript.m'. This will take several days. Change this file to customise the optimization.
The simulation function is in the file 'fitfunction' the first few lines will need to be changed to the individual folder structure. 
An example code for the visitations can be found in the R file. Do not run this as is.






--To do list--
Improve future price predications past 2040
Test for growth curve past 2040

