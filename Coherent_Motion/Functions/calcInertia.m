function inertia = calcInertia(shape,mass,radius,radius2)

if nargin < 4
    radius2 = 0;
end

if strcmp(shape,'sphere')
    inertia = 2*mass*radius^2/5;
elseif strcmp(shape,'solid cylinder')
    inertia = 0.5*mass*radius^2;
elseif strcmp(shape,'hollow cylinder')
    inertia = mass*radius^2;
elseif strcmp(shape,'cylindrical shell')
    inertia = 0.5*mass*(radius^2+radius2^2);
elseif strcmp(shape,'nonstandard')
    inertia = 0;
else
    error('invalid shape')
end

end