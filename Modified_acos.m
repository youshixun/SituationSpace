function [th]=Modified_acos(vm)
    if vm>1
        vm=1;
    else
        if vm<-1
            vm=-1;
        end
    end
    th=acos(vm);
end