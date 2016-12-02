%for (i in 1:nrow(heatmap)){
%     heatmap[i,3][is.infinite(heatmap[i,3])] <- heatmap[i,2]
%}

library(ggplot2)
time = c(1:24)
heatmap$time<-rep(time,length.out = 8746)
heatmap.m<-melt(heatmap, id.vars = 'time', measure.vars = c('V1','V2','V3','V4'))
heatmap.m$range.c<-cut(heatmap.m$value, breaks = c(430,400:350,320,0),right=FALSE)
% heatmap.m$range.c<-as.factor(heatmap.m$range.c)

%plot outliers

plot<- ggplot(data = subset(heatmap.m,value<320 | value>400), aes(x =variable, y = time))+
  geom_tile(aes(fill = value, alpha=z), colour = "white") +
  scale_fill_gradient(low='white',high='firebrick4')

plot + layer( geom='tile', data = subset(heatmap.m, 320<value &value>400),
              position = "identity", stat='identity',
  mapping = aes(x =variable, y = time))+
  geom_tile(aes(fill = value), colour = "white") +
  scale_fill_gradient(low='yellow', high='red')
                                   

ggplot(heatmap.m,aes(x = variable,y = time,fill = value,alpha = factor(range.c))) + 
  geom_tile(aes(fill = value), colour = "white") +
  scale_fill_gradient(low='yellow', high='red')


