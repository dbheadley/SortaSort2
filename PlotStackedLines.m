%% PlotStackedLines
% Plots a series of line plots stacked along the y-axis
%% Syntax
%# lineHandles = PlotStackedLines(dataVals, xVals, dispColors, varargin)

%% Description
% Plots a collection of line plots stacked on top of each other.
% 
% INPUT
% * dataVals - an NxM array, each row is a different line to be plotted.
% * xVals - an N length array, specifies the corresponding x coordinates for
% each of the columns in dataVals
% * dispColors - the color of each line. If a single color value is given
% then the same color is used for all lines. Colors can be specified either
% as a string of a single color name, an N-length cell array of colors names, 
% or an Nx3 array of RGB colors.
% OPTIONAL INPUTS


%% Example
% numTrials = 10;
% durTrial = 10000;
% fakeData = rand(numTrials,durTrial);
% figure;
% PlotStackedLines(fakeData, [], 'black')
% 
% This will plot each random trace spaced apart as far as their maximum values. For dense traces like this one, it may be too tight, so you can specify how far apart you want them using the 'SEPRATIO' option. This allows you to control how far apart you want the lines based on a multiple of their maximum value. For instance, if you want them to be separated by 3X their maximum value then:
% figure;
% PlotStackedLines(fakeData, [], 'black','SEPRATIO',3)
% 
% You can also add labels to each line
% lblList = {'Ch1' 'Ch2' 'Ch3' 'Ch4' 'Ch5' 'Ch6' 'Ch7' 'Ch8' 'Ch9' 'Ch10'};
% figure;
% PlotStackedLines(fakeData, [], 'black','SEPRATIO',3, 'LABELS',lblList)
% 
% 
% Or specify the color for each line:
% colList = {'red' 'black' 'green' 'blue' 'cyan' 'red' 'black' 'green' 'blue' 'cyan'};
% figure;
% PlotStackedLines(fakeData, [], colList,'SEPRATIO',3, 'LABELS',lblList)


%% Executable code
function [lineHandles, lineSep] = PlotStackedLines(dataVals, xVals, dispColor,varargin)
  %check validity of inputs
  if isempty(xVals)
    xVals = 1:size(dataVals,2);
  end
  
  if size(dataVals,2) ~= length(xVals)
    error('dataVals does not agree with xVals');
  end
  
  if ischar(dispColor)
      dispColor = {dispColor};
  end

  if iscell(dispColor)
      dispColor = ColorName2RGB(dispColor);
  end

  if size(dispColor,1) == 1
      dispColor = repmat(dispColor,size(dataVals,1),1);
  elseif size(dispColor,1) ~= size(dataVals,1)
      error('Number of colors does not match number of traces');
  end
%   if any(strcmp(varargin, {'FILLED'}))
%     varargin(strcmp(varargin, {'FILLED'})) = [];
%     filledYes = true;
%   else
%     filledYes = false;
%   end
  
%   if any(strcmp(varargin, {'SETNAN'}))
%     nanRepl = varargin{find(strcmp(varargin, {'SETNAN'}))+1};
%     varargin(find(strcmp(varargin, {'SETNAN'}))+1) = [];
%     varargin(strcmp(varargin, {'SETNAN'})) = [];
%     dataVals(isnan(dataVals)) = nanRepl;
%   end
  
  if any(strcmp(varargin, {'SEPRATIO'}))
    sepRatio = varargin{find(strcmp(varargin, {'SEPRATIO'}))+1};
    varargin(find(strcmp(varargin, {'SEPRATIO'}))+1) = [];
    varargin(strcmp(varargin, {'SEPRATIO'})) = [];
  else
    sepRatio = 1;
  end

  if any(strcmp(varargin, {'LABELS'}))
    lineLabels = varargin{find(strcmp(varargin, {'LABELS'}))+1};
    varargin(find(strcmp(varargin, {'LABELS'}))+1) = [];
    varargin(strcmp(varargin, {'LABELS'})) = [];
  else
    lineLabels = [];
  end
  
  if any(strcmp(varargin, {'LABELSRIGHT'}))
    lineLabelsRight = varargin{find(strcmp(varargin, {'LABELSRIGHT'}))+1};
    varargin(find(strcmp(varargin, {'LABELSRIGHT'}))+1) = [];
    varargin(strcmp(varargin, {'LABELSRIGHT'})) = [];
  else
    lineLabelsRight = [];
  end
  
  if any(strcmp(varargin, {'ABSSEP'}))
    absSep = varargin{find(strcmp(varargin, {'ABSSEP'}))+1};
    varargin(find(strcmp(varargin, {'ABSSEP'}))+1) = [];
    varargin(strcmp(varargin, {'ABSSEP'})) = [];
    absSepYes = true;
  else
    absSepYes = false;
  end
  
  % format inputs
  dataVals(isinf(dataVals)) = NaN;
  xVals = xVals(:)';
  numLines = size(dataVals, 1);
  
  % determine limits
  if absSepYes
    lineSep = absSep;
  else
    minList = min(dataVals,[],2);
    maxList = max(dataVals,[],2);
    maxDiff = max(abs(maxList-minList));
    lineSep = maxDiff*sepRatio;
  end
  
  % plot lines
  for j = 1:numLines
    lineHandles(j) = plot(xVals, dataVals(j,:)+(j-1)*lineSep, 'color', dispColor(j,:), varargin{:});
    line([xVals(1) xVals(end)], [1 1]*(j-1)*lineSep, 'color', [0.5 0.5 0.5], 'LineStyle',':');
    if ~isempty(lineLabels)
      text(xVals(1),(j-1)*lineSep, lineLabels{j}, 'color', dispColor(j,:));
    end
    if ~isempty(lineLabelsRight)
      text(xVals(end),(j-1)*lineSep, lineLabelsRight{j}, 'color', dispColor(j,:));
    end
    hold on;
  end
  hold off;
  end
  
  
  
  function colVec = ColorName2RGB(colNames)
      for j = 1:length(colNames)
          switch colNames{j}
              case {'y' 'yellow'}
                  colVec(j,:) = [1 1 0];
              case {'m' 'magenta'}
                  colVec(j,:) = [1 0 1];
              case {'c' 'cyan'}
                  colVec(j,:) = [0 1 1];
              case {'r' 'red'}
                  colVec(j,:) = [1 0 0];
              case {'g' 'green'}
                  colVec(j,:) = [0 1 0];
              case {'b' 'blue'}
                  colVec(j,:) = [0 0 1];
              case {'w' 'white'}
                  colVec(j,:) = [1 1 1];
              case {'k' 'black'}
                  colVec(j,:) = [0 0 0];
              otherwise
                  colVec(j,:) = [0 0 0];
          end
      end
  end

         