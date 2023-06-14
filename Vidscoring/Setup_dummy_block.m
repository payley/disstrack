%% Set-up dummy block
orig = ('R:\Rat\Intan\phDummy\Dummy-Fill');
input = fullfile(orig,'Dummy-Fill_0000_00_00_0_000000_000000.rhd');
output = fullfile('P:\Extracted_Data_To_Move\Rat\Intan\PH\phDummy');
orig_blockID = ('Dummy-Fill-000000');

blockObj = nigeLab.Block(input,output);

blockObj.doRawExtraction;
%blockObj.doEventDetection;
blockObj.save;

status = copyfile(fullfile(output,'Dummy-Fill-000000'),fullfile(output,'Dummy-Fill-000000_Orig'));
status = copyfile(fullfile(output,[orig_blockID,'_Block.mat']),fullfile(output,[orig_blockID,'_Orig_Block.mat']));
status = copyfile(fullfile(output,[orig_blockID,'_Pars.mat']),fullfile(output,[orig_blockID,'_Orig_Pars.mat']));