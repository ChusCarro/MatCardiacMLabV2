%% testCreateModel002 - Creates a new model from a file that has been 
%            processed by MatCardiacMLab
%                                
%
%     [result,msg] = testCreateModel002()         
% 
%                                                                           
%    Output:                                                                
%      result: True if the file has been created. False in other case
%      msg:    Explanation of the result
%
%
%-----------------------------------------------------------------------
% 
% MatCardiacMLab
%
% Matlab toolbox to Simulate Electrophysiologycal Cardiac Models 
% described in CellML files
%
% https://github.com/ChusCarro/MatCardiacMLab/
%
%
% Jesus Carro Fernandez 
% jcarro@usj.es  
%                      
% School of Engineering
% San Jorge University 
% www.usj.es  
%
function [result,msg] = testCreateModel001()

pathInput = './testResults';
pathOutput = './testResults';
modelFileInput = 'Carro_Rodriguez_Laguna_Pueyo_2011_EPI.m';
modelFileOutput = [modelFileInput(1:end-2) '_2.m'];
modelName = 'CRLP2011EPI';

if(checkIfFileExists(pathOutput,modelFileOutput))
  delete([pathOutput '/' modelFileOutput]);
end

try
  result = false;
  model = createModel([pathInput '/' modelFileInput],[pathOutput '/' modelFileOutput],modelName);
  result = checkIfFileExists(pathOutput,modelFileOutput);
  
  if(~result)
    msg = 'File not created';
    return;
  end
cath ME
  disp(['Err:' ME ])
  result = false;
  msg = lasterr;
  return
end

msg = ['Created file: ' modelFileOutput];
