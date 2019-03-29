%%Time specifications:
Fs = 250;                   % samples per second
dt = 1/Fs;                   % seconds per sample
StopTime = 4;             % seconds
t = (0:dt:StopTime-dt);     % seconds

%%Sine wave:               % hertz
x1 = sin(2*pi*2*t);
x2 = sin(2*pi*4*t);
x3 = sin(2*pi*8*t);
xt = [x1;x2;x3];
xf = squeeze(mean(xt));
xp = [xt;xf];
xp = flipud(xp);

% Plot the signal versus time:
figure;
hold on
for i = 1:4
      plot3(t,i*ones(1,size(t,2)),xp(i,:));
end
hold off
view(3)