function geometric_features(nsim)


% Set spatial parameters
N = 80;     % Number of voxels per dimension
K = 2e5;    % Carrying capacity
threshold1 = 0.2*K; % Filled voxel threshold
alt = 8;

PX = 1; % mm
PY = 1; % mm
PZ = 1; % mm

m = 80;
n = 80;
p = 80;

[mallaX,mallaY,mallaZ] = meshgrid(PX/2 : PX : (PX*m-PX/2), ...
                                  PY/2 : PY : (PY*n-PY/2), ...
                                  PZ/2 : PZ : (PZ*p-PZ/2));


    
        
disp(['Simulation number ' num2str(nsim) ' selected'])

% Search for all 3D data files
a = dir(['Sim' num2str(nsim) '/Gen_space*.txt']);
Size = numel(a);

% Set spatial parameters
N = 80;     % Number of voxels per dimension
K = 2e5;    % Carrying capacity
threshold = 0.2*K; % Filled voxel threshold

% Create cell list to store all 3D encrypted data
A = cell(1,Size);

% Create cell lists to store subpopulations data
poptot = cell(1,Size);
pops = cell(1,Size);
nec = cell(1,Size);
act = cell(1,Size);
shannon = zeros(1,Size);
simpson = zeros(1,Size);
totact = zeros(1,Size);
totnec = zeros(1,Size);
totcell = zeros(1,Size);
VOL2 = zeros(1,Size);

[poptot, pops, nec, act] = dcode_simfiles(nsim);
shannon = load(['Sim' num2str(nsim) '/Shannon.mat']);
shannon = shannon.shannon;
simpson = load(['Sim' num2str(nsim) '/Simpson.mat']);
simpson = simpson.simpson;
totact = load(['Sim' num2str(nsim) '/Act_total.mat']);
totact = totact.totact;
totnec = load(['Sim' num2str(nsim) '/Nec_total.mat']);
totnec = totnec.totnec;
totcell = load(['Sim' num2str(nsim) '/CellN_total.mat']);
totcell = totcell.totcell;
VOL2 = load(['Sim' num2str(nsim) '/Vol_voxels.mat']);
VOL2 = VOL2.VOL2;



% Iterate along each 3D data file and decrypt coordinates

mascP1 = cell(1,Size);
mascP2 = cell(1,Size);
rim = zeros(1,Size);
Surf = [];
Vol = [];
SurfReg = [];


for i = 1:Size

    disp(num2str(i))

    % RIM WIDTH

    mascP1{i} = poptot{i}+nec{i} > threshold1;
    mascP2{i} = nec{i} > threshold1;

    VOLrim1(i) = sum(sum(sum(mascP1{i})));
    VOLrim2(i) = sum(sum(sum(mascP2{i})));

    rim(i) = 0.62*( (VOLrim1(i))^(1/3) - (VOLrim2(i))^(1/3) );


    % SURFACE REGULARITY AND VOLUME (JULIAN'S METHOD)

    if sum(mascP1{i}(:)) > 1e3
        hiso = patch(isosurface(mascP1{i},0.5),'FaceColor',[0,1,0.95],'EdgeColor','none');

        % Poner multiplicador si cambia espaciado malla (ahora es 1)
        CoorVertX = hiso.XData';
        CoorVertY = hiso.YData';
        CoorVertZ = hiso.ZData';

        V_P1P2 = [CoorVertX(:,1)-CoorVertX(:,2),CoorVertY(:,1)-CoorVertY(:,2),CoorVertZ(:,1)-CoorVertZ(:,2)];
        V_P1P3 = [CoorVertX(:,1)-CoorVertX(:,3),CoorVertY(:,1)-CoorVertY(:,3),CoorVertZ(:,1)-CoorVertZ(:,3)];

        Vnormal = cross(V_P1P2,V_P1P3);

        Norma2_Vnormal = sqrt(Vnormal(:,1).*Vnormal(:,1)+Vnormal(:,2).*Vnormal(:,2)+Vnormal(:,3).*Vnormal(:,3));

        Surf(i) = sum(Norma2_Vnormal)./2; % mm^2
        Vol(i) = sum( (0.5*Norma2_Vnormal).*(sum(CoorVertZ')./3)'.*(-Vnormal(:,3)./Norma2_Vnormal)); % mm^3
        SurfReg(i) = 6*sqrt(pi)*Vol(i)/(Surf(i)^(3/2)); % adimensional
    end

end


save(['Sim' num2str(nsim) '/RimWidth.mat'],'rim');
save(['Sim' num2str(nsim) '/Surface.mat'],'Surf');
save(['Sim' num2str(nsim) '/Volume_Julian.mat'],'Vol');
save(['Sim' num2str(nsim) '/SurfReg_Julian.mat'],'SurfReg'); 

end