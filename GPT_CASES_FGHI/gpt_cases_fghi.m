function m = gpt_cases_fghi( m )
%m = gpt_cases_fghi( m )
%   Morphogen interaction function.
%   Written at 2011-04-19 15:43:11.
%   GFtbox revision 3499, 2011-04-15 16:29:35.777989.

% The user may edit any part of this function between delimiters
% of the form "USER CODE..." and "END OF USER CODE...".  The
% delimiters themselves must not be moved, edited, deleted, or added.

    if isempty(m), return; end

    fprintf( 1, '%s found in %s\n', mfilename(), which(mfilename()) );

    try
        m = local_setproperties( m );
    catch
    end

    realtime = m.globalDynamicProps.currenttime;

%%% USER CODE: INITIALISATION

% In this section you may modify the mesh in any way whatsoever.
    if (Steps(m)==0) && m.globalDynamicProps.doinit % First iteration
        % Zero out a lot of stuff to create a blank slate.  If you want to use the
        % GUI to set any of these things in the initial mesh, then you will need to
        % comment out the corresponding lines here.
        m.morphogens(:) = 0;
        m.morphogenclamp(:) = 0;
        m.mgen_production(:) = 0;
        m.mgen_absorption(:) = 0;
        m.seams(:) = false;
        m.mgen_dilution(:) = false;

        % Set up names for variant models.  Useful for running multiple models on a cluster.
        m.userdata.ranges.modelname.range = { 'CASE_F','CASE_G','CASE_H','CASE_I' };  
        m.userdata.ranges.modelname.index = 4;  % CHOOSE THE CASE HERE AND ALWAYS RESTART                      
    end
    modelname = m.userdata.ranges.modelname.range{m.userdata.ranges.modelname.index};  % CLUSTER
    disp(sprintf('\nRunning %s model %s\n',mfilename, modelname));
    	
    % More examples of code for all iterations.
    % set colour of polariser gradient arrows above and below gradient
    % threshold
    m=leaf_plotoptions(m,'highgradcolor',[0,0,0],'lowgradcolor',[0.6,0.6,0]); 
    m=leaf_setproperty(m,'mingradient',0); % i.e. threshold for using polariser gradient
    % pretty up the display
    m=leaf_plotoptions(m,'decorscale',1.5);
    m=leaf_plotoptions(m,'arrowthickness',1.3);
    % To set the following from the GUI comment out the following
    % Set priorities for simultaneous plotting of multiple morphogens, if desired.
    % The following ensures that the organisers are always visible
    m = leaf_mgen_plotpriority( m, {'id_plus_org', 'id_neg_org'}, [1,2], [0.5,0.05] );

    % setup a multiplot of the following morphogens (more flexible if set
    % using GUI Menu:Plot:Multi-plot)
    % m = leaf_plotoptions( m, 'morphogen', {'id_g','id_plus_org', 'id_neg_org'});
    
    % setup stepsize here (but like other parameters, could be setup in the
    % GUI Simulation panel
    m.globalProps.timestep=1;
%%% END OF USER CODE: INITIALISATION

%%% SECTION 1: ACCESSING MORPHOGENS AND TIME.
%%% AUTOMATICALLY GENERATED CODE: DO NOT EDIT.

    polariser_i = FindMorphogenRole( m, 'POLARISER' );
    P = m.morphogens(:,polariser_i);
    [kapar_i,kapar_p,kapar_a,kapar_l] = getMgenLevels( m, 'KAPAR' );
    [kaper_i,kaper_p,kaper_a,kaper_l] = getMgenLevels( m, 'KAPER' );
    [kbpar_i,kbpar_p,kbpar_a,kbpar_l] = getMgenLevels( m, 'KBPAR' );
    [kbper_i,kbper_p,kbper_a,kbper_l] = getMgenLevels( m, 'KBPER' );
    [knor_i,knor_p,knor_a,knor_l] = getMgenLevels( m, 'KNOR' );
    [strainret_i,strainret_p,strainret_a,strainret_l] = getMgenLevels( m, 'STRAINRET' );
    [arrest_i,arrest_p,arrest_a,arrest_l] = getMgenLevels( m, 'ARREST' );
    [id_plus_org_i,id_plus_org_p,id_plus_org_a,id_plus_org_l] = getMgenLevels( m, 'ID_PLUS_ORG' );
    [id_neg_org_i,id_neg_org_p,id_neg_org_a,id_neg_org_l] = getMgenLevels( m, 'ID_NEG_ORG' );
    [id_g_i,id_g_p,id_g_a,id_g_l] = getMgenLevels( m, 'ID_G' );

% Mesh type: rectangle
%            base: 0
%          centre: 0
%      randomness: 0.1
%         version: 1
%           xdivs: 20
%          xwidth: 0.2
%           ydivs: 20
%          ywidth: 0.2

%            Morphogen   Diffusion   Decay   Dilution   Mutant
%            -------------------------------------------------
%                KAPAR        ----    ----       ----     ----
%                KAPER        ----    ----       ----     ----
%                KBPAR        ----    ----       ----     ----
%                KBPER        ----    ----       ----     ----
%                 KNOR        ----    ----       ----     ----
%            POLARISER       0.001    ----       ----     ----
%            STRAINRET        ----    ----       ----     ----
%               ARREST        ----    ----       ----     ----
%          ID_PLUS_ORG        ----    ----       ----     ----
%           ID_NEG_ORG        ----    ----       ----     ----
%                 ID_G        ----    ----       ----     ----


%%% USER CODE: MORPHOGEN INTERACTIONS

% In this section you may modify the mesh in any way that does not
% alter the set of nodes.

    if (Steps(m)==0) && m.globalDynamicProps.doinit  % Initialisation code.
        % Put any code here that should only be performed at the start of
        % the simulation, for example, to set up initial morphogen values.
        
        % m.nodes is the set of vertex positions, an N by 3 array if there
        % are N vertices.  Row number K contains the X, Y, and Z
        % coordinates of the Kth vertex. To obtain a list of the X
        % coordinates of every vertex, write m.nodes(:,1).  The Y
        % coordinates are given by m.nodes(:,2) and the Z coordinates by
        % m.nodes(:,3).
        
        id_plus_org_p(abs(m.nodes(:,2))<0.005)=1; % middle line
        
        % get ready the right hand side negative organiser
        f_right_p=zeros(size(id_neg_org_p)); % temporary factor
        miny=min(m.nodes(:,2));
        maxy=max(m.nodes(:,2));
        f_right_p (m.nodes(:,1)==max(m.nodes(:,1)))=1; % distal (top)
        ind_right=find(f_right_p); % find the relevant nodes
        f_right_p(ind_right)=(2*abs(m.nodes(ind_right,2)))/(maxy-miny); % grade them from midline

        % now the top and bottom negative organiser
        minx=min(m.nodes(:,1));
        maxx=max(m.nodes(:,1));
        id_neg_org_p (m.nodes(:,2)==max(m.nodes(:,2)))=1; % distal (top)
        id_neg_org_p (m.nodes(:,2)==min(m.nodes(:,2)))=1; % distal (top)
        ind=find(id_neg_org_p); % find all the negative organiser nodes
        id_neg_org_p(ind)=(m.nodes(ind,1)-minx)/(maxx-minx); % grade them from left to right
        % and copy in the right hand side values
        id_neg_org_p(ind_right)=f_right_p(ind_right);
        %id_neg_org_p=id_neg_org_p.^2; % make gradients steeper
    end
    
    % Monitor growth by scattering discs that deform over time (c.f. inducing biological clones)
    if (5>realtime-dt) && (5<realtime+dt) % discs to be added at realtime==5
        m = leaf_makesecondlayer( m, ...  % This function adds discs that represent transformed cells.
            'mode', 'each', ...  % Make discs randomly scattered over the canvas.
            'relarea', 1/1600, ...
            'numcells',100,...%number of discs (that will become ellipses)
            'sides', 6, ...  % Each discs is approximated as a 6-sided regular polygon.
            'probpervx', 1, ... % induce discs with this probability 
            'colors', [0.5 0.5 0.5], ...  % Default colour is gray but
            'colorvariation',0.1,... % Each disc is a random colour
            'add', true );
    end

%     % If you want to define different phases according to the absolute
%     % time, create a morphogen for each phase and modulate 
%     % expressions using the morphogen
%     % like.  For example:
    if (realtime < 10)  % initialisation
        f_initialising = 1;
    else
        f_initialising = 0;
    end
    if (realtime >= 10) % growth 
        f_growth = 1;
    else
        f_growth = 0;
    end

    switch modelname
        case 'CASE_F'  
            % @@PRN Polariser Regulatory Network
            % POL (polariser) will be generated in the plus organiser region
            % and destroyed in the negative organiser region
            m.mgen_production(:,polariser_i) = 0.01*id_plus_org_p - 1*id_neg_org_p.*P;
            % freeze polariser pattern as soon as growth starts
            m = leaf_mgen_conductivity( m, 'POLARISER', 0.001 * f_initialising);  % diffusion rate stops when growing
            m = leaf_mgen_absorption( m, 'POLARISER', 0.00  );  % no degradation rate 
            m=leaf_setproperty(m,'mingradient',10*f_growth); % i.e. threshold for using polariser gradient increases when growing
            % @@GRN Gene Regulatory Network
            id_g_p=0.05 * ones(size(id_g_p)); % hypothesise a growth rate that is uniform over whole canvas
        case 'CASE_G'  
            % @@PRN Polariser Regulatory Network
            % POL (polariser) will be generated in the plus organiser region
            % and destroyed in the negative organiser region
            m.mgen_production(:,polariser_i) = 0.01*id_plus_org_p - 1*id_neg_org_p.*P;
            m = leaf_mgen_conductivity( m, 'POLARISER', 0.001 );  %specifies the diffusion rate of polariser
            m = leaf_mgen_absorption( m, 'POLARISER', 0.00  );  % no degradation rate 
            % @@GRN Gene Regulatory Network
            id_g_p=0.05 * ones(size(id_g_p)); % hypothesise a growth rate that is uniform over whole canvas
        case 'CASE_H'  
            % @@PRN Polariser Regulatory Network
            % POL (polariser) will be generated in the plus organiser region
            % and destroyed in the negative organiser region
            m.mgen_production(:,polariser_i) = 0.01*id_plus_org_p - 1*id_neg_org_p.*P;
            % freeze polariser pattern as soon as growth starts
            m = leaf_mgen_conductivity( m, 'POLARISER', 0.001 * f_initialising);  % diffusion rate stops when growing
            m = leaf_mgen_absorption( m, 'POLARISER', 0.00  );  % no degradation rate 
            % change colour of arrows when they no longer change
            m=leaf_setproperty(m,'mingradient',10*f_growth); % i.e. threshold for using polariser gradient increases when growing
            % @@GRN Gene Regulatory Network
            gradient=(m.nodes(:,1)-min(m.nodes(:,1)))/(max(m.nodes(:,1))-min(m.nodes(:,1))); % normalised to [0...1]
            id_g_p=0.05 * gradient;
        case 'CASE_I'  
            % @@PRN Polariser Regulatory Network
            % POL (polariser) will be generated in the plus organiser region
            % and destroyed in the negative organiser region
            m.mgen_production(:,polariser_i) = 0.01*id_plus_org_p - 1*id_neg_org_p.*P;
            m = leaf_mgen_conductivity( m, 'POLARISER', 0.001 );  %specifies the diffusion rate of polariser
            m = leaf_mgen_absorption( m, 'POLARISER', 0.00  );  % no degradation rate 
            % @@GRN Gene Regulatory Network
            gradient=(m.nodes(:,1)-min(m.nodes(:,1)))/(max(m.nodes(:,1))-min(m.nodes(:,1))); % normalised to [0...1]
            id_g_p=0.05 * gradient;
    end
    
    % @@KRN Growth Regulatory Network
    % The same for all these cases
    kapar_p = f_growth * id_g_l;  % growth only when realtime >= 10 hours
    kaper_p = 0;  % fully anisotropic growth
    kbpar_p = kapar_p;  % the same on both sides of the canvas
    kbper_p = kaper_p;  %
    knor_p  = 0;  % no change in thickness
%%% END OF USER CODE: MORPHOGEN INTERACTIONS

%%% SECTION 3: INSTALLING MODIFIED VALUES BACK INTO MESH STRUCTURE
%%% AUTOMATICALLY GENERATED CODE: DO NOT EDIT.
    m.morphogens(:,polariser_i) = P;
    m.morphogens(:,kapar_i) = kapar_p;
    m.morphogens(:,kaper_i) = kaper_p;
    m.morphogens(:,kbpar_i) = kbpar_p;
    m.morphogens(:,kbper_i) = kbper_p;
    m.morphogens(:,knor_i) = knor_p;
    m.morphogens(:,strainret_i) = strainret_p;
    m.morphogens(:,arrest_i) = arrest_p;
    m.morphogens(:,id_plus_org_i) = id_plus_org_p;
    m.morphogens(:,id_neg_org_i) = id_neg_org_p;
    m.morphogens(:,id_g_i) = id_g_p;

%%% USER CODE: FINALISATION

% In this section you may modify the mesh in any way whatsoever.

    % If needed force FE to subdivide (increase number FE's) here
    % if realtime==280+dt
         % m = leaf_subdivide( m, 'morphogen','id_vent',...
         %       'min',0.5,'max',1,...
         %       'mode','mid','levels','all');
    % end
% Cut the mesh along the seams (see above)
    % if m.userdata.CutOpen==1
    %    m=leaf_dissect(m);
    %    m.userdata.CutOpen=2;        
    %    Relax accumulated stresses slowly i.e. 0.95 to 0.999
    %    m = leaf_setproperty( m, 'freezing', 0.999 );
    % end
%%% END OF USER CODE: FINALISATION

end


%%% USER CODE: SUBFUNCTIONS

function m = local_setproperties( m )
% This function is called at time zero in the INITIALISATION section of the
% interaction function.  It provides commands to set each of the properties
% that are contained in m.globalProps.  Uncomment whichever ones you would
% like to set yourself, and put in whatever value you want.
%
% Some of these properties are for internal use only and should never be
% set by the user.  At some point these will be moved into a different
% component of m, but for the present, just don't change anything unless
% you know what it is you're changing.

%    m = leaf_setproperty( m, 'trinodesvalid', true );
%    m = leaf_setproperty( m, 'prismnodesvalid', true );
%    m = leaf_setproperty( m, 'thicknessRelative', 0.020000 );
%    m = leaf_setproperty( m, 'thicknessArea', 0.000000 );
%    m = leaf_setproperty( m, 'thicknessMode', 'physical' );
%    m = leaf_setproperty( m, 'activeGrowth', 1.000000 );
%    m = leaf_setproperty( m, 'displayedGrowth', 1.000000 );
%    m = leaf_setproperty( m, 'displayedMulti', [] );
%    m = leaf_setproperty( m, 'allowNegativeGrowth', true );
%    m = leaf_setproperty( m, 'usePrevDispAsEstimate', true );
%    m = leaf_setproperty( m, 'perturbInitGrowthEstimate', 0.000010 );
%    m = leaf_setproperty( m, 'perturbRelGrowthEstimate', 0.010000 );
%    m = leaf_setproperty( m, 'perturbDiffusionEstimate', 0.000100 );
%    m = leaf_setproperty( m, 'resetRand', false );
%    m = leaf_setproperty( m, 'mingradient', 0.000000 );
%    m = leaf_setproperty( m, 'relativepolgrad', false );
%    m = leaf_setproperty( m, 'usefrozengradient', true );
%    m = leaf_setproperty( m, 'userpolarisation', false );
%    m = leaf_setproperty( m, 'thresholdsq', 0.000400 );
%    m = leaf_setproperty( m, 'splitmargin', 1.400000 );
%    m = leaf_setproperty( m, 'splitmorphogen', '' );
%    m = leaf_setproperty( m, 'thresholdmgen', 0.500000 );
%    m = leaf_setproperty( m, 'bulkmodulus', 1.000000 );
%    m = leaf_setproperty( m, 'unitbulkmodulus', true );
%    m = leaf_setproperty( m, 'poissonsRatio', 0.300000 );
%    m = leaf_setproperty( m, 'starttime', 0.000000 );
%    m = leaf_setproperty( m, 'timestep', 0.010000 );
%    m = leaf_setproperty( m, 'timeunitname', '' );
%    m = leaf_setproperty( m, 'distunitname', 'mm' );
%    m = leaf_setproperty( m, 'scalebarvalue', 0.000000 );
%    m = leaf_setproperty( m, 'validateMesh', true );
%    m = leaf_setproperty( m, 'rectifyverticals', false );
%    m = leaf_setproperty( m, 'allowSplitLongFEM', true );
%    m = leaf_setproperty( m, 'longSplitThresholdPower', 0.000000 );
%    m = leaf_setproperty( m, 'allowSplitBentFEM', false );
%    m = leaf_setproperty( m, 'allowSplitBio', true );
%    m = leaf_setproperty( m, 'allowFlipEdges', false );
%    m = leaf_setproperty( m, 'allowElideEdges', true );
%    m = leaf_setproperty( m, 'mincellangle', 0.200000 );
%    m = leaf_setproperty( m, 'alwaysFlat', 0.000000 );
%    m = leaf_setproperty( m, 'flattenforceconvex', true );
%    m = leaf_setproperty( m, 'flatten', false );
%    m = leaf_setproperty( m, 'flattenratio', 1.000000 );
%    m = leaf_setproperty( m, 'useGrowthTensors', false );
%    m = leaf_setproperty( m, 'plasticGrowth', false );
%    m = leaf_setproperty( m, 'totalinternalrotation', 0.000000 );
%    m = leaf_setproperty( m, 'stepinternalrotation', 2.000000 );
%    m = leaf_setproperty( m, 'showinternalrotation', false );
%    m = leaf_setproperty( m, 'performinternalrotation', false );
%    m = leaf_setproperty( m, 'internallyrotated', false );
%    m = leaf_setproperty( m, 'maxFEcells', 0 );
%    m = leaf_setproperty( m, 'inittotalcells', 0 );
%    m = leaf_setproperty( m, 'bioApresplitproc', '' );
%    m = leaf_setproperty( m, 'bioApostsplitproc', '' );
%    m = leaf_setproperty( m, 'maxBioAcells', 0 );
%    m = leaf_setproperty( m, 'maxBioBcells', 0 );
%    m = leaf_setproperty( m, 'colors', (6 values) );
%    m = leaf_setproperty( m, 'colorvariation', 0.050000 );
%    m = leaf_setproperty( m, 'colorparams', (12 values) );
%    m = leaf_setproperty( m, 'freezing', 0.000000 );
%    m = leaf_setproperty( m, 'canceldrift', false );
%    m = leaf_setproperty( m, 'mgen_interaction', '' );
%    m = leaf_setproperty( m, 'mgen_interactionName', 'gpt_case1_110415' );
%    m = leaf_setproperty( m, 'allowInteraction', true );
%    m = leaf_setproperty( m, 'interactionValid', true );
%    m = leaf_setproperty( m, 'gaussInfo', (unknown type ''struct'') );
%    m = leaf_setproperty( m, 'stitchDFs', [] );
%    m = leaf_setproperty( m, 'D', (36 values) );
%    m = leaf_setproperty( m, 'C', (36 values) );
%    m = leaf_setproperty( m, 'G', (6 values) );
%    m = leaf_setproperty( m, 'solver', 'cgs' );
%    m = leaf_setproperty( m, 'solverprecision', 'double' );
%    m = leaf_setproperty( m, 'solvertolerance', 0.001000 );
%    m = leaf_setproperty( m, 'solvertolerancemethod', 'norm' );
%    m = leaf_setproperty( m, 'diffusiontolerance', 0.000010 );
%    m = leaf_setproperty( m, 'allowsparse', true );
%    m = leaf_setproperty( m, 'maxIters', 0 );
%    m = leaf_setproperty( m, 'maxsolvetime', 1000.000000 );
%    m = leaf_setproperty( m, 'cgiters', 0 );
%    m = leaf_setproperty( m, 'simsteps', 0 );
%    m = leaf_setproperty( m, 'stepsperrender', 0 );
%    m = leaf_setproperty( m, 'growthEnabled', true );
%    m = leaf_setproperty( m, 'diffusionEnabled', true );
%    m = leaf_setproperty( m, 'makemovie', false );
%    m = leaf_setproperty( m, 'moviefile', '' );
%    m = leaf_setproperty( m, 'codec', 'None' );
%    m = leaf_setproperty( m, 'autonamemovie', true );
%    m = leaf_setproperty( m, 'overwritemovie', false );
%    m = leaf_setproperty( m, 'framesize', [] );
%    m = leaf_setproperty( m, 'mov', [] );
%    m = leaf_setproperty( m, 'jiggleProportion', 1.000000 );
%    m = leaf_setproperty( m, 'cvtperiter', 0.200000 );
%    m = leaf_setproperty( m, 'boingNeeded', false );
%    m = leaf_setproperty( m, 'initialArea', 0.040000 );
%    m = leaf_setproperty( m, 'bendunitlength', 0.200000 );
%    m = leaf_setproperty( m, 'targetRelArea', 1.000000 );
%    m = leaf_setproperty( m, 'defaultinterp', 'min' );
%    m = leaf_setproperty( m, 'readonly', false );
%    m = leaf_setproperty( m, 'projectdir', 'C:\clusterstuff' );
%    m = leaf_setproperty( m, 'modelname', 'GPT_Case1_110415' );
%    m = leaf_setproperty( m, 'allowsave', true );
%    m = leaf_setproperty( m, 'addedToPath', false );
%    m = leaf_setproperty( m, 'bendsplit', 0.300000 );
%    m = leaf_setproperty( m, 'usepolfreezebc', false );
%    m = leaf_setproperty( m, 'dorsaltop', true );
%    m = leaf_setproperty( m, 'defaultazimuth', -45.000000 );
%    m = leaf_setproperty( m, 'defaultelevation', 33.750000 );
%    m = leaf_setproperty( m, 'defaultroll', 0.000000 );
%    m = leaf_setproperty( m, 'defaultViewParams', (unknown type ''struct'') );
%    m = leaf_setproperty( m, 'comment', '' );
%    m = leaf_setproperty( m, 'legendTemplate', '%T: %q\n%m' );
%    m = leaf_setproperty( m, 'bioAsplitcells', true );
%    m = leaf_setproperty( m, 'bioApullin', 0.142857 );
%    m = leaf_setproperty( m, 'bioAfakepull', 0.202073 );
%    m = leaf_setproperty( m, 'interactive', false );
%    m = leaf_setproperty( m, 'coderevision', 0 );
%    m = leaf_setproperty( m, 'coderevisiondate', '' );
%    m = leaf_setproperty( m, 'modelrevision', 0 );
%    m = leaf_setproperty( m, 'modelrevisiondate', '' );
%    m = leaf_setproperty( m, 'savedrunname', '' );
%    m = leaf_setproperty( m, 'savedrundesc', '' );
%    m = leaf_setproperty( m, 'vxgrad', (108 values) );
%    m = leaf_setproperty( m, 'lengthscale', 0.200000 );
end

% Here you may write any functions of your own, that you want to call from
% the interaction function, but never need to call from outside it.
% Remember that they do not have access to any variables except those
% that you pass as parameters, and cannot change anything except by
% returning new values as results.
% Whichever section they are called from, they must respect the same
% restrictions on what modifications they are allowed to make to the mesh.

% For example:

% function m = do_something( m )
%   % Change m in some way.
% end

% Call it from the main body of the interaction function like this:
%       m = do_something( m );
