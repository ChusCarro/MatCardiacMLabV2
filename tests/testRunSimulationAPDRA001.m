function [result,msg] = testRunSimulationAPDRA001()

path_save = 'testResults';
Output = ['testCreateConfigAPDRA001_res.mat'];
ConfigFile = ['testCreateConfigAPDRA001_conf.mat'];

delete([path_save '/' Output]);

try
  MCMLSimulator([path_save '/' ConfigFile]);
  file = dir(path_save);
  result = false;
  for i=1:length(file)
    if(strcmp(file(i).name,Output))
      result = true;
      break
    end
  end

  if(~result)
    msg = 'Computation output not found';
    return;
  end

catch ME
  result = false;
  msg = ME.message;
  return;
end

msg = ['Computed file ' ConfigFile];
