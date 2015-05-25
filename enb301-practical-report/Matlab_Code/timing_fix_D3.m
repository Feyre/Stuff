function [ te_new,ye_new, ye_stepNew ] = timing_fix_D3(te,ye,ye_step)
    te_new = te;
    ye_new = ye;
    ye_stepNew = ye_step;
    
    % Remove initial zero gradient before resonse
    f = ye_new > ye_new(1) * 1.05;
    indice = find(f,1,'first');
    ye_new = ye_new(indice-100:end);
    te_new = te_new(indice-100:end);
    ye_stepNew = ye_stepNew(indice-100:end);

    % Shift time to start at zero
    te_new = te_new + abs(te_new(1));

    % Shift amplitude to start at zero
    %ye_new = ye_new + ye_new(1);
end