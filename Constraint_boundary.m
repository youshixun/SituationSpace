function [aout] = Constraint_boundary(ain,a_max)
    a_max=a_max.*sign(ain);
    al=1000*ain;
    c=max(al./a_max);
    aout=al/c;
end