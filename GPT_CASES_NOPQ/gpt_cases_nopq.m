function m = gpt_cases_nopq( m )
%m = gpt_cases_nopq( m )
%   Morphogen interaction function.
%   Written at 2011-04-29 15:17:15.
%   GFtbox revision 3518, 2011-04-29 13:30:15.502745.

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
        % Cases CASE_N2 to CASE_Q2 implement a different mechanism for
        % setting the polariser gradient
        % The first method imposes the pattern of gradients at the start
        % the second allows it to change dynamically
        m.userdata.ranges.modelname.range = { 'CASE_N','CASE_O','CASE_P','CASE_Q', 'CASE_N2','CASE_O2','CASE_P2','CASE_Q2' };  
        m.userdata.ranges.modelname.index = 3;  % CHOOSE THE CASE HERE AND ALWAYS RESTART                      
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
    m = leaf_mgen_plotpriority( m, {'id_plus_org', 'id_neg_org', 'id_midorg','f_border'}, [1,2,3,4], [0.5,0.05,0.1,0.05] );
    % setup a multiplot (changes with CASE)
    switch modelname
        case 'CASE_N'  
            m = leaf_plotoptions( m, 'morphogen', {'id_g','id_plus_org','id_neg_org','f_border'});
        case 'CASE_O'
            m = leaf_plotoptions( m, 'morphogen', {'id_g','id_plus_org','id_neg_org','id_midorg','f_border'});
        case 'CASE_P'  
            m = leaf_plotoptions( m, 'morphogen', {'id_g','id_plus_org','id_neg_org','id_midorg','f_border'});
        case 'CASE_Q'

    end

    % setup stepsize here (but like other parameters, could be setup in the
    % GUI Simulation panel
    %m.globalProps.timestep=1;
    %m.globalProps.timestep=0.01;
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
    [f_radial_i,f_radial_p,f_radial_a,f_radial_l] = getMgenLevels( m, 'F_RADIAL' );
    [f_border_i,f_border_p,f_border_a,f_border_l] = getMgenLevels( m, 'F_BORDER' );
    [id_midorg_i,id_midorg_p,id_midorg_a,id_midorg_l] = getMgenLevels( m, 'ID_MIDORG' );

% Mesh type: rectangle
%            base: 0
%          centre: 0
%      randomness: -0.1
%         version: 1
%           xdivs: 30
%          xwidth: 2
%           ydivs: 30
%          ywidth: 2

%            Morphogen   Diffusion   Decay   Dilution   Mutant
%            -------------------------------------------------
%                KAPAR        ----    ----       ----     ----
%                KAPER        ----    ----       ----     ----
%                KBPAR        ----    ----       ----     ----
%                KBPER        ----    ----       ----     ----
%                 KNOR        ----    ----       ----     ----
%            POLARISER         0.1    ----       ----     ----
%            STRAINRET        ----    ----       ----     ----
%               ARREST        ----    ----       ----     ----
%          ID_PLUS_ORG        ----    ----       ----     ----
%           ID_NEG_ORG        ----    ----       ----     ----
%                 ID_G        ----    ----       ----     ----
%             F_RADIAL        ----    ----       ----     ----
%             F_BORDER        ----    ----       ----     ----
%            ID_MIDORG        ----    ----       ----     ----


%%% USER CODE: MORPHOGEN INTERACTIONS

% In this section you may modify the mesh in any way that does not
% alter the set of nodes.

    % Constants set up to create Figures
    EXTRAGROWTH = 0.75; % 0 or 0.75
    GROWTHRADIUS = 0.2;
    MAXPOLRADIUS = 0.5; %0.5;
    BACKGROUNDGROWTH = 0.25;
    POLRADIUS = 0.15; %0.15;

    if (Steps(m)==0) && m.globalDynamicProps.doinit  % Initialisation code.
        % Put any code here that should only be performed at the start of
        % the simulation, for example, to set up initial morphogen values.
        
        % Create and fix a morphogen that increases according to 3D radius
        % squared (c.f. Hill coefficient of 2)
        f_radial_p=(m.nodes(:,1).^2+m.nodes(:,2).^2+m.nodes(:,3).^2); % morphogen is visible in GUI
        % Uncomment the following to see the slight change of shape if only
        % 2D radius is used (bear in mind that the initial canvas is curved)
        %f_radial_p=(m.nodes(:,1).^2+m.nodes(:,2).^2; % morphogen is visible in GUI

        id_plus_org_p(m.nodes(:,1)==min(m.nodes(:,1)))=1; % left margin
        id_plus_org_l=id_plus_org_p*id_plus_org_a;
        id_neg_org_p (m.nodes(:,1)==max(m.nodes(:,1)))=1; % distal (top)
        id_neg_org_l=id_neg_org_p*id_neg_org_a;
        
        % Fixing vertices, i.e. fix z for the base to prevent base from moving up or down
        % (rather like embedding the canvas in a much larger canvas)
        f_border_p=zeros(size(id_plus_org_p)); % temporary factor
        f_border_p((abs(m.nodes(:,1))>0.9) | ...
            (abs(m.nodes(:,2))>0.9))=1;
        m=leaf_fix_vertex(m,'vertex',find(f_border_p==1),'dfs','z');
        
        m = leaf_mgen_conductivity( m, 'POLARISER', 0.1 );  % no diffusion
        m = leaf_mgen_absorption( m, 'POLARISER', 0.0  );   % no degradation
        % Set up the ...
        % @@PRN Polariser Regulatory Network
        % Pattern and fix gradients and gene patterns into tissue (canvas) before growth
        P = m.nodes(:,1) - min( m.nodes(:,1) );
        P = P/max(P); % normalise initial gradient to [0...1]
        m.morphogenclamp( :, polariser_i ) = 0; % clear the clamp
        % homeostatic clamp the polariser at each end,
        % diffusion between the two maintains the initial gradient
        m.morphogenclamp( (id_plus_org_p > 0) | (id_neg_org_p > 0), polariser_i ) = 1;        
        
        m = leaf_setproperty( m, 'poissonsRatio', 0 );
        THICKNESS = 0.1;    % Set the absolute thickness of the mesh. The
                            % initial mesh is always 2 units in diameter.
                            % Values of 0.05 to 0.25 are suitable.
        % Process the THICKNESS setting.
        m = leaf_setthicknessparams( m, 'scale', THICKNESS, 'power', 0 );
        m = leaf_bowlz( m, 'amount', -0.01, 'centre', [0 0 0] );

        switch modelname
            case {'CASE_O', 'CASE_P', 'CASE_Q'}
                % setup extra organiser in the centre
                % Gaussian shaped function in centre but force to zero
                % beyond a radius set indirectly by MAXPOLRADIUS
                P_level_at_MAXPOLRADIUS=exp(-MAXPOLRADIUS^2/(POLRADIUS^2));
                extra = max( 0, exp(-f_radial_p/(POLRADIUS^2)) -P_level_at_MAXPOLRADIUS );
                id_midorg_p = extra/max(extra); % normalised shape can be visualised
                % to see this extra organiser on its own place a break point here Restart
                % then evaluate the following (select the following, right click and evaluate)
                % figure; plot3(m.nodes(:,1),m.nodes(:,2),id_midorg_p);shg
                if strcmpi(modelname,'CASE_Q') % -organiser so subtract
                    P = P - id_midorg_p; % initialise the extra spot
                    % it will be maintained by mgen_production
                    m.mgen_production( :, polariser_i ) = -1*id_midorg_p; % maintain reduced P in centre by decay
                else
                    P = P + id_midorg_p; % initialise the pattern - 
                    % it will be maintained by mgen_production
                    m.mgen_production( :, polariser_i ) = 1*id_midorg_p; % maintain extra P in centre
                end
                P = P - min(P); % ensure P is never negative
        end
        % Set up the ...
        % @@GRN Gene Regulatory Network
        switch modelname
            % Pattern and fix gradients and gene patterns into tissue (canvas) before growth
            case {'CASE_N', 'CASE_P','CASE_Q'}
                % decreasing from centre by radius squared
                id_g_p = max( 0, GROWTHRADIUS - f_radial_p ); 
                id_g_p = BACKGROUNDGROWTH + EXTRAGROWTH * id_g_p/max(id_g_p); % normalised to 1 and *0.75 dt=0.1
                id_g_l=id_g_p*id_g_a;
            case {'CASE_O'}
                id_g_p = BACKGROUNDGROWTH;
                id_g_l=id_g_p*id_g_a;
        end
    end
    
    % Monitor growth by scattering discs that deform over time (c.f. inducing biological clones)
    if (0.1>realtime-dt) && (0.1<realtime+dt) % discs to be added at realtime==5
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

    % @@KRN Growth Regulatory Network
    % The same for all these cases
    kapar_p = id_g_l; 
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
    m.morphogens(:,f_radial_i) = f_radial_p;
    m.morphogens(:,f_border_i) = f_border_p;
    m.morphogens(:,id_midorg_i) = id_midorg_p;

%%% USER CODE: FINALISATION

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
