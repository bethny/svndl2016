% 1. random image at a certain density - image size 
%   input: # of checkerboard squares, density of black dots, shift (in units of dot
%   width) - [1 10]
% 2. for each image, 40 versions - 4 shift directions x 10 shift lengths
% 3. # of black dots lost via shifting are randomly replaced in the gap left behind
% example: 120 x 120 squares 
% naming: 6 digits, first 2 = pattern ID, dig3-4 = direction, dig5-6 =
% shift length in # of dots 

% function [checkerboard] = makeCheckerboard(numSquares,dotDensity,shift)
%   Description:        Generates an n x n checkerboard with a certain
%       density of black squares, then generates 4 new checkerboards with the
%       pattern shifted in the 4 cardinal directions. Lost black squares are
%       reshuffled back into the remainder of the board. 

%   Syntax:     [checkerboard] = makeCheckerboard(numSquares,dotDensity,shift)

%   In:
%       numSquares:   Integer double n that indicates the n x n size of
%           board.

%       dotDensity:   Float or integer double that indicates percentage of
%           black dots. Can be either out of 100 or 1. 

%       shift:        Integer double that indicates the n number of squares
%           the pattern is shifted. Must be less than numSquares.

%   Out:
%       

clear all
close all
codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/Coherent_Motion/Functions';
addpath(genpath(codeFolder));

numSquares = 128;
dotDensity = .4;
shift = 32;

if dotDensity > 1 % making sure we get a decimal value
    dotDensity = dotDensity/100;
end

totalSquares = numSquares^2;
boardArray = ones(1,totalSquares);
numBlackDots = ceil(dotDensity*totalSquares);

p = randperm(totalSquares);
distro = p(1:numBlackDots);

for i = 1:numBlackDots
    boardArray(distro(i)) = 0;
end

squareBoard = reshape(boardArray,numSquares,numSquares);
board = cat(3,squareBoard,squareBoard,squareBoard); % original starting board

shiftedBoardUp = [squareBoard(shift+1:end,:)];
discardedUp = squareBoard(1:shift,:);
for i = 1:shift
    numBlackDiscardedU(i) = numSquares-sum(discardedUp(i,:));
end
totalDisc = sum(numBlackDiscardedU);
a = randperm(numSquares*shift);
idx = a(1:totalDisc);

newRowUp = ones(1,shift*numSquares);
for i = 1:totalDisc
    newRowUp(idx(i)) = 0;
end
newRowUp = reshape(newRowUp,shift,numSquares);
shiftedBoardUp = [shiftedBoardUp;newRowUp];
shiftedUp = cat(3,shiftedBoardUp,shiftedBoardUp,shiftedBoardUp);

shiftedBoardDown = [squareBoard(1:end-shift,:)];
discardedDown = squareBoard(end-shift+1:end,:);
for i = 1:shift
    numBlackDiscardedD(i) = numSquares-sum(discardedDown(i,:));
end
totalDisc = sum(numBlackDiscardedD);
a = randperm(numSquares*shift);
idx = a(1:totalDisc);
newRowDown = ones(1,shift*numSquares);
for i = 1:totalDisc
    newRowDown(idx(i)) = 0;
end
newRowDown = reshape(newRowDown,shift,numSquares);
shiftedBoardDown = [newRowDown;shiftedBoardDown];
shiftedDown = cat(3,shiftedBoardDown,shiftedBoardDown,shiftedBoardDown);

shiftedBoardLeft = squareBoard(:,shift+1:end);
discardedLeft = squareBoard(:,1:shift);
for i = 1:shift
    numBlackDiscardedL(i) = numSquares-sum(discardedLeft(:,i));
end
totalDisc = sum(numBlackDiscardedL);
a = randperm(numSquares*shift);
idx = a(1:totalDisc);
newColLeft = ones(numSquares*shift,1);
for i = 1:totalDisc
    newColLeft(idx(i)) = 0;
end
newColLeft = reshape(newColLeft,numSquares,shift);
shiftedBoardLeft = cat(2,shiftedBoardLeft,newColLeft);
shiftedLeft = cat(3,shiftedBoardLeft,shiftedBoardLeft,shiftedBoardLeft);

shiftedBoardRight = squareBoard(:,1:end-shift);
discardedRight = squareBoard(:,end-shift+1:end);
for i = 1:shift
    numBlackDiscardedU(i) = numSquares-sum(discardedRight(:,i));
end
totalDisc = sum(numBlackDiscardedU);
a = randperm(numSquares*shift);
idx = a(1:totalDisc);
newColRight = ones(numSquares*shift,1);
for i = 1:totalDisc
    newColRight(idx(i)) = 0;
end
newColRight = reshape(newColRight,numSquares,shift);
shiftedBoardRight = cat(2,newColRight,shiftedBoardRight);
shiftedRight = cat(3,shiftedBoardRight,shiftedBoardRight,shiftedBoardRight);

figure
imagesc(board)
axis off;
set(gcf, 'Color', 'w', 'Position', [0 0 600 600]);
export_fig board32.png -m7
figure
imagesc(shiftedUp)
axis off;
set(gcf, 'Color', 'w', 'Position', [0 0 600 600]);
export_fig boardshifted32.png -m7

% figure
% imagesc(shiftedDown)
% set(gcf, 'Color', 'w');
% figure
% imagesc(shiftedLeft)
% set(gcf, 'Color', 'w');
% figure
% imagesc(shiftedRight)
% set(gcf, 'Color', 'w');

% end