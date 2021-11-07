function []=pgui()

%% PURPOSE: THIS IS THE FUNCTION THAT IS CALLED AT THE COMMAND LINE TO OPEN THE GUI FOR IMPORTING/PROCESSING/PLOTTING DATA

% WRITTEN BY: MITCHELL TILLMAN, 11/06/2021
% IN HONOR OF DOUGLAS ERIC TILLMAN, 10/29/1961-07/05/2021

fig=uifigure('Visible','on','AutoResizeChildren','off','SizeChangedFcn',@appResize); % Create the figure window for the app
fig.Name='pgui'; % Name the window

tabGroup1=uitabgroup(fig,'Position',[0 0 figSize]); % Create the tab group for the four stages of data processing
importTab=uitab(tabGroup1,'Title','Import'); % Create the import tab
processTab=uitab(tabGroup1,'Title','Process'); % Create the process tab
plotTab=uitab(tabGroup1,'Title','Plot'); % Create the plot tab
statsTab=uitab(tabGroup1,'Title','Stats'); % Crate the stats tab
tabGroup1.HorizontalAlignment='center';
tabGroup1.Layout.Row={'1x'};
tabGroup1.Layout.Column={'1x'};
