function [poptot,pops,nec,act] = dcode_simfiles(nsim)


disp(['Decoding files from simulation number ' num2str(nsim)])

% Search for all 3D data files
a = dir(['Sim' num2str(nsim) '/Gen_space*.txt']);
Size = numel(a);

% Set spatial parameters
N = 80;     % Number of voxels per dimension
K = 2e5;    % Carrying capacity
threshold = 0.2*K; % Filled voxel threshold
alt = 8;

% Create cell list to store file 3D encrypted data
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

% Iterate along each 3D data file and decrypt coordinates
for i = 1:Size

    disp(num2str(i))

    poptot{i} = zeros(N,N,N);
    pops{i} = zeros(N,N,N,alt);
    nec{i} = zeros(N,N,N);
    act{i} = zeros(N,N,N);

    f = ['Sim' num2str(nsim) '/Gen_space_' num2str(i*20) '.txt'];
    delimiterIn = ' ';
    headerlinesIn = 0;
    A{i} = importdata(f,delimiterIn,headerlinesIn);

    for e = 1:alt

        % Coordinates of occupied voxels
        if A{i}(find(A{i}(:,e+3)),e+3)
            occ = A{i}(find(A{i}(:,e+3)),[1:3]); 
            index = length(occ(:,1));

            x = occ(:,1);
            y = occ(:,2);
            z = occ(:,3); 

            popgen = A{i}(find(A{i}(:,e+3)),e+3);         
            for j = 1:index

                pops{i}(x(j),y(j),z(j),e) = popgen(j);
                poptot{i}(x(j),y(j),z(j)) = poptot{i}(x(j),y(j),z(j)) + pops{i}(x(j),y(j),z(j),e);

            end

        end

    end

    % Heterogeneity
    popG = squeeze(sum(pops{i},1));
    popG = squeeze(sum(popG,1));
    popG = squeeze(sum(popG,1));
    for e = 1:8
        % Heterogeneity
        if popG(e) > 0
            shannon(i) = shannon(i) - popG(e)/sum(popG)*log(popG(e)/sum(popG));
            simpson(i) = simpson(i) + (popG(e)/sum(popG))^2; 
        end
    end

    occ = A{i}(find(A{i}(:,alt+4)),[1:3]);  
    x = occ(:,1);
    y = occ(:,2);
    z = occ(:,3);
    actvox = A{i}(find(A{i}(:,alt+4)),alt+4);
    for j = 1:length(occ(:,1))
        act{i}(x(j),y(j),z(j)) = actvox(j);
    end

    occ = A{i}(find(A{i}(:,alt+5)),[1:3]);  
    x = occ(:,1);
    y = occ(:,2);
    z = occ(:,3);
    necvox = A{i}(find(A{i}(:,alt+5)),alt+5);
    for j = 1:length(occ(:,1))
        nec{i}(x(j),y(j),z(j)) = necvox(j);
    end


    mascP{i} = poptot{i}+nec{i} > threshold;
    VOL2(i) = sum(sum(sum(mascP{i})));

    totact(i) = sum(sum(sum(act{i})));
    totnec(i) = sum(sum(sum(nec{i})));
    totcell(i) = sum(sum(sum(poptot{i})));

end

save(['Sim' num2str(nsim) '/Vol_voxels.mat'],'VOL2');
save(['Sim' num2str(nsim) '/CellN_total.mat'],'totcell');
save(['Sim' num2str(nsim) '/Act_total.mat'],'totact');
save(['Sim' num2str(nsim) '/Nec_total.mat'],'totnec');
save(['Sim' num2str(nsim) '/Shannon.mat'],'shannon');
save(['Sim' num2str(nsim) '/Simpson.mat'],'simpson');    






end