function creategraph(YMatrix1)
%CREATEFIGURE1(YMATRIX1)
%  YMATRIX1:  matrix of y data

%  Auto-generated by MATLAB on 24-Jul-2015 02:30:30

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on',...
    'XTickLabel',{'5','6','7','8','9','10','11','12','13','14','15'});

% To preserve the Y-limits of the axes
ylim(axes1,[85 105]);

box(axes1,'on');
hold(axes1,'on');

% Create multiple lines using matrix input to plot
plot1 = plot(YMatrix1);
set(plot1(1),'DisplayName','Training');
set(plot1(2),'DisplayName','Testing');

% Create xlabel
xlabel('Number of hidden units');

% Create ylabel
ylabel('Prediction accuracy (%)');

% Create title
title('Train and test accuracy as function of number of hidden units');

% Create legend
legend(axes1,'show');
