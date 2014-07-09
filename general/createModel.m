%% CreateModel - Creates a model for the simulator based on the file
%            exported by COR to MatLab
%                                
%
%     model = CreateModel(modelFileInput,modelFileOutput,modelName)         
%                                                                                                                                                                                                  
%    Input:                                                                        
%      modelFileInput: String with the name of the file generated by 
%              COR
%      modelFileOutput: String with the name of the file where the *.m 
%              file of the model is saved
%      modelName: String with the name of the model 
%                                                                           
%    Output:                                                                
%      model: Model structure for the simulator                                       
%
%   See also  createModelStructure, showModels, 
%   createDefaultModelStructure
%
%-----------------------------------------------------------------------
% 
% MatCardiacMLab (v00.00)
%
% Matlab toolbox to Simulate Electrophysiologycal Cardiac Models 
% described in CellML files
%
% Jesus Carro Fernandez 
% jcarro@usj.es  
%                      
% School of Engineering
% San Jorge University 
% www.usj.es  
%       
% Last Modification 2014/07/09
%

function model = createModel(modelFileInput,modelFileOutput,modelName)

%"\r\n"
CRLF = char([13 10]);
sepLine = ['%------------------------------------------------------' ...
  '-------------------------'];
sepDoubleLine = ['%================================================' ...
  '==============================='];

% Remove file extensions
if(strcmp(modelFileInput(end-1:end),'.m'))
  modelFileInput = modelFileInput(1:end-2);
end
modelExtension = '.m';

if(strcmp(modelFileOutput(end-1:end),'.m'))
  modelFileOutput = modelFileOutput(1:end-2);
end

% Get function name
functionName = modelFileOutput;
% Check if there are folders in the name and remove it
namePosition = find(functionName=='/',1,'last');
if(~isempty(namePosition))
  functionName = functionName(namePosition+1:end);
end

% Get oldFunction name
oldFunctionName = modelFileInput;
% Check if there are folders in the name and remove it
oldNamePosition = find(oldFunctionName=='/',1,'last');
if(~isempty(oldNamePosition))
  oldFunctionName = oldFunctionName(oldNamePosition+1:end);
end


%% Start modifing the code
file = fopen([modelFileInput modelExtension]);
newCode=char(fread(file)');
fclose(file);

% Get the position of the function definition
indFunction=findstr('function',newCode); 
indFunction=indFunction(1);

% The following lines are to get the time variable name and where ends
% the function definition. Time variable is the second one
indStartFuncArg=findstr('(',newCode(indFunction:end));
indStartFuncArg=indStartFuncArg(1)+indFunction-1;
indTimeVarEnd=findstr(',',newCode(indStartFuncArg:end));
indTimeVarEnd=indTimeVarEnd(1)+indStartFuncArg-1;
indEndFuncArg=findstr(')',newCode(indTimeVarEnd:end));
indEndFuncArg=indEndFuncArg(1)+indTimeVarEnd-1;
time_str = newCode(indStartFuncArg+1:indTimeVarEnd-1);

% The new name with Constants and Values is introduced
newCode=[newCode(1:indFunction-1) 'function [dY, CompVar] = ' ...
  functionName '(' time_str ', Y, Constants, Values)' ...
  newCode(indEndFuncArg+1:end)]; 

% Find the initial values of the State variables and save in SV0
ind=findstr('% Y = [',newCode);
ind2 = findstr('];',newCode(ind:end));
eval(['SV0 = ' newCode(ind+6:ind+ind2-1) ';'])

% Find the State Variable Names and save in SVNames
ind=findstr('% YNames = {',newCode);
ind2 = findstr('};',newCode(ind:end));
eval(['SVNames' newCode(ind+8:ind+ind2-1) ';'])

% Find the State Variable Units and save in SVUnits
ind=findstr('% YUnits = {',newCode);
ind2 = findstr('};',newCode(ind:end));
eval(['SVUnits' newCode(ind+8:ind+ind2-1) ';'])

% Check if the file has been previously processed by MatCarciacMLab and 
% the reasign function has been added
ind=findstr(newCode,'reasign(Constants, Values)');

if(isempty(ind))
  % The reasign function hasn't been added. Add it before the Constants
  % definition
  compVarStartStr=[sepLine CRLF '% Computed variables' CRLF sepLine];

  ind = findstr(newCode,compVarStartStr);

  newCode=[newCode(1:ind-1) 'reasign(Constants, Values)' ...
    CRLF CRLF newCode(ind:end)];
end

% Get Constants code
constStartStr=[ sepLine CRLF '% Constants' CRLF sepLine];

indConstStart = findstr(newCode,constStartStr);
constantsCode=newCode(indConstStart+length(constStartStr):end);
indConstEnd = findstr('reasign(Constants, Values)',constantsCode);
constantsCode=constantsCode(1:indConstEnd-1);

% Remove all the spaces
constantsCode=sscanf(constantsCode,'%s');

% Get limits for the names and values:constant=value;%units(compartment)
indEquals = find(constantsCode=='=');
indComas = find(constantsCode==';');
indLeftBracket = [0 find(constantsCode==')')];
indRightBracket = find(constantsCode=='(');

CNames = cell(size(indEquals));
CUnits = cell(size(indEquals));
C0 = zeros(size(indEquals));

for i=1:length(indEquals);
  CNames{i} = constantsCode(indLeftBracket(i)+1:indEquals(i)-1);
  C0(i) = str2double(constantsCode(indEquals(i)+1:indComas(i)-1));
  CUnits{i} = constantsCode(indComas(i)+2:indRightBracket(i)-1);
end

% Get Computed Varibles code

cvStartStr = [sepLine CRLF '% Computed variables' CRLF sepLine];
computationStartStr = [sepLine CRLF '% Computation' CRLF sepLine];

ind = findstr(newCode,cvStartStr);
cvCode = newCode(ind+length(cvStartStr):end);
ind = findstr(computationStartStr,cvCode);
cvCode = cvCode(1:ind-1);

% Remove all the spaces
cvCode = sscanf(cvCode,'%s');

% Get limits for the names and values:%name(units)
indPerc = find(cvCode=='%');
indLeftBracket = find(cvCode=='(');
indRightBracket = find(cvCode==')');

CVNames = cell(size(indPerc));
CVUnits = cell(size(indPerc));

for i=1:length(indPerc);
  CVNames{i} = cvCode(indPerc(i)+1:indLeftBracket(2*i-1)-1);
  CVUnits{i} = cvCode(indLeftBracket(2*i-1)+1:indRightBracket(2*i-1)-1);
end

% Find the end of the COR exported File 
EOFStr=[CRLF sepDoubleLine CRLF '% End of file' CRLF sepDoubleLine];
indEOF = findstr(newCode,EOFStr);
indEOF = indEOF + length(EOFStr)-1;

% Added to save Computed Variables
newCode = [newCode(1:indEOF) CRLF CRLF 'CompVar = ['];
for i=1:length(CVNames)
  newCode = [newCode CVNames{i} ' '];
end
newCode = [newCode '];' CRLF CRLF];

% Saves the new model file
newFile=fopen([modelFileOutput modelExtension],'w+');
fwrite(newFile,newCode);
fclose(newFile);

% Creates the model structure
model = CreateModelStructure(modelName,str2func(functionName),...
  SV0,SVNames,SVUnits,C0,CNames,CUnits,CVNames,CVUnits);