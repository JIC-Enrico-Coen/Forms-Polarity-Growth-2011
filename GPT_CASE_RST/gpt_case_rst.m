function m = gpt_case_rst( m )
%m = gpt_case_rst( m )
%   Morphogen interaction function.
%   Written at 2011-04-28 21:20:35.
%   GFtbox revision 3517, 2011-04-27 08:05:05.157080.

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
    if Steps(m)==0 % First iteration
        initial_thickness=0.05;
        m=setAbsoluteThickness(m,initial_thickness);
        % add the range fields
        % 1 NOPOL  is no polariser no cenorg
        % 6 POL3    clamp source and sink, polariser first and second phase, no cenorg, left-right different kper
        % 5 POLCEN2 clamp source and sink, polariser first and second phase, second phase cenorg, left-right different kper
        m.userdata.ranges.modelname.range{1}='NOPOL'; % no polariser
        m.userdata.ranges.modelname.range{2}='POL3' ; % polariser but no changes of -organiser
        m.userdata.ranges.modelname.range{3}='POLCEN2'; % polariser with change of -organiser
        % -------------------- CHANGE THIS INDEX ------------------
        % to select submodel number 1 2 or 3
        m.userdata.ranges.modelname.index=3; % selects just one of these modulation function options,
        
        m.morphogens=zeros(size(m.morphogens));
        m.seams=logical(zeros(size(m.seams)));
        m.polfreeze=zeros(size(m.polfreeze));
        m.mgen_production=zeros(size(m.mgen_production));
    end
    m = leaf_mgen_plotpriority( m, {'id_distorg','id_proxorg'}, [10], [0.19 0.5 ] );
    modelname=m.userdata.ranges.modelname.range{m.userdata.ranges.modelname.index};
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
    [id_proxorg_i,id_proxorg_p,id_proxorg_a,id_proxorg_l] = getMgenLevels( m, 'ID_PROXORG' );
    [id_distorg_i,id_distorg_p,id_distorg_a,id_distorg_l] = getMgenLevels( m, 'ID_DISTORG' );
    [id_lat_i,id_lat_p,id_lat_a,id_lat_l] = getMgenLevels( m, 'ID_LAT' );
    [s_lat_i,s_lat_p,s_lat_a,s_lat_l] = getMgenLevels( m, 'S_LAT' );
    [id_rightl_i,id_rightl_p,id_rightl_a,id_rightl_l] = getMgenLevels( m, 'ID_RIGHTL' );
    [v_kpar_i,v_kpar_p,v_kpar_a,v_kpar_l] = getMgenLevels( m, 'V_KPAR' );
    [v_kper_i,v_kper_p,v_kper_a,v_kper_l] = getMgenLevels( m, 'V_KPER' );
    [id_early_i,id_early_p,id_early_a,id_early_l] = getMgenLevels( m, 'ID_EARLY' );
    [id_late_i,id_late_p,id_late_a,id_late_l] = getMgenLevels( m, 'ID_LATE' );
    [id_later_i,id_later_p,id_later_a,id_later_l] = getMgenLevels( m, 'ID_LATER' );
    [v_clones_i,v_clones_p,v_clones_a,v_clones_l] = getMgenLevels( m, 'V_CLONES' );
    [id_dist_i,id_dist_p,id_dist_a,id_dist_l] = getMgenLevels( m, 'ID_DIST' );
    [id_prox_i,id_prox_p,id_prox_a,id_prox_l] = getMgenLevels( m, 'ID_PROX' );
    [id_upper_i,id_upper_p,id_upper_a,id_upper_l] = getMgenLevels( m, 'ID_UPPER' );
    [id_lower_i,id_lower_p,id_lower_a,id_lower_l] = getMgenLevels( m, 'ID_LOWER' );
    [id_leftl_i,id_leftl_p,id_leftl_a,id_leftl_l] = getMgenLevels( m, 'ID_LEFTL' );
    [id_startup_i,id_startup_p,id_startup_a,id_startup_l] = getMgenLevels( m, 'ID_STARTUP' );
    [id_g_i,id_g_p,id_g_a,id_g_l] = getMgenLevels( m, 'ID_G' );

% Mesh type: cup
%         basecap: 1
%      baseheight: 0.2
%       baserings: 11
%      circumdivs: 90
%          height: 0.3
%      heightdivs: 20
%      randomness: 0.01
%          topcap: 0
%       topheight: 1
%        toprings: 0
%         version: 1
%          xwidth: 0.8
%          ywidth: 0.8

%            Morphogen   Diffusion   Decay   Dilution   Mutant
%            -------------------------------------------------
%                KAPAR        ----    ----       ----     ----
%                KAPER        ----    ----       ----     ----
%                KBPAR        ----    ----       ----     ----
%                KBPER        ----    ----       ----     ----
%                 KNOR        ----    ----       ----     ----
%            POLARISER        0.05    ----       ----     ----
%            STRAINRET        ----    ----       ----     ----
%               ARREST        ----    ----       ----     ----
%           ID_PROXORG        ----    ----       ----     ----
%           ID_DISTORG        ----    ----       ----     ----
%               ID_LAT        ----    ----       ----     ----
%                S_LAT       0.005     0.1       ----     ----
%            ID_RIGHTL        ----    ----       ----     ----
%               V_KPAR        ----    ----       ----     ----
%               V_KPER        ----    ----       ----     ----
%             ID_EARLY        ----    ----       ----     ----
%              ID_LATE        ----    ----       ----     ----
%             ID_LATER        ----    ----       ----     ----
%             V_CLONES        ----    ----       ----     ----
%              ID_DIST        ----    ----       ----     ----
%              ID_PROX        ----    ----       ----     ----
%             ID_UPPER        ----    ----       ----     ----
%             ID_LOWER        ----    ----       ----     ----
%             ID_LEFTL        ----    ----       ----     ----
%           ID_STARTUP        ----    ----       ----     ----
%                 ID_G        ----    ----       ----     ----


%%% USER CODE: MORPHOGEN INTERACTIONS

    ZEROGROWTHTIME=20;
    FIRSTGROWTHTIME=140;
    SECONDGROWTHTIME=200;
    disp(sprintf('modelname=%s setup period=%d early growth=%d late growth=%d',...
        modelname,ZEROGROWTHTIME,FIRSTGROWTHTIME,SECONDGROWTHTIME))
    % In this section you may modify the mesh in any way that does not
    % alter the set of nodes.
    if Steps(m)==0  % zeroing code.
        %elseif Steps(m)==1  % Initialisation code.
        % setup proximo-distal regions
        ind_base=m.nodes(:,3)<=-0.15;
        id_base_p(ind_base)=1;
        width_polariser_band=0.03;
        prox_ind=find((m.nodes(:,3)<=-0.15+width_polariser_band)&(m.nodes(:,3)>-0.15));
        all_ind=find(m.nodes(:,3)>-1000);
        id_prox_p(prox_ind)=1;
        id_prox_l=id_prox_p.*id_prox_a;
        v_clones_p(:)=1; % everywhere except the base
        v_clones_p(id_prox_p>0.5)=0;
        % the following just identifies nodes the top
        epsilon=0.0025; %0.006;
        maxz=max(m.nodes(:,3)); % z coords
        id_dist_p(m.nodes(:,3)>=maxz)=1;
        %id_dist_p(m.nodes(:,3)>=maxz-width_polariser_band)=1;
        id_dist_l=id_dist_p.*id_dist_a;
        %fix z for the base to prevent base from moving up or down
        m=leaf_fix_vertex(m,'vertex',prox_ind,'dfs','z');

        minz= -0.13;
        % define ventral region (for experiments with strain retention)
        % need 4 separators for 5 intervals
        number_bands=7;
        stepz=(maxz-minz)/number_bands;
        for i=1:number_bands-1
            sep(i)=minz+stepz*i;
        end
        
        id_rightl_p(m.nodes(:,1)>=max(m.nodes(:,1))-0.002)=1;
        id_rightl_l=id_rightl_p.*id_rightl_a;
        id_leftl_p(m.nodes(:,1)<=(min(m.nodes(:,1))+0.002))=1;
        id_leftl_l=id_leftl_p.*id_leftl_a;
        id_lower_p(m.nodes(:,3)<sep(2))=1;
        id_lower_l=id_lower_p.*id_lower_a;

        % identify factors up the lat
        id_lat_p((m.nodes(:,1)>-0.0-6*epsilon)&(m.nodes(:,1)<0.0+6*epsilon))=1;
        id_lat_l=id_lat_p.*id_lat_a;
    end

    if realtime<ZEROGROWTHTIME                      % @@before 20
        id_startup_p(:)=1;
        id_early_p(:)=1;
        id_late_p(:)=0;
        arrest_p(:)=1;
    elseif realtime>=ZEROGROWTHTIME && realtime<FIRSTGROWTHTIME % @@between 20 120
        id_startup_p(:)=0;
        id_early_p(:)=1;
        id_late_p(:)=0;
        arrest_p(:)=0;
    elseif realtime>=FIRSTGROWTHTIME && realtime<SECONDGROWTHTIME% @@between 120 250
        id_startup_p(:)=0;
        id_early_p(:)=0;
        id_late_p(:)=1;
        arrest_p(:)=0;
    else                                % @@after 250
        id_startup_p(:)=0;
        id_early_p(:)=0;
        id_late_p(:)=0;
        arrest_p(:)=1;
    end        
        
    % set the timing on each iteration to make it easier to modify on the fly

    if realtime>(ZEROGROWTHTIME-dt) && realtime<=ZEROGROWTHTIME
        % add discs that will monitor growth by distorting and growing into ellipses
        m = leaf_makesecondlayer( m, ...  % This function adds equivalent of biological cells.
            'mode', 'each', ...  % Make biological cells randomly scattered over the flower.
            'relinitarea', 1/2000, ...  % Each cell has area was 1/8000 of the initial area of the flower.
            'probpervx', 'V_CLONES', ...% cells will be deposited within this region
            'numcells',200,... % number of cells
            'colorvariation',0,... % do not distinguish one from another
            'lat', 6, ...  % Each cell is approximated as a 6-sided regular polygon.
            'colors', [0 1 0], ...  % Each cell is green.
            'add', true );  % These cells are added to any cells existing already.
    end
    % Code common to all models.

    m = leaf_mgen_conductivity( m, 's_lat',     0.005); % diffusion constant
    m = leaf_mgen_dilution( m,     's_lat',     false );% it will not dilute with growth
    m = leaf_mgen_absorption( m,   's_lat',     0.1);     % it will decay everywhere

    id_proxorg_p=id_prox_l;
    id_distorg_p=id_dist_l;

    BASIC_GROWTH=0.018;
    % Code for incremental models.
    switch modelname
        case 'NOPOL'  % @@model MODEL1
            % @@PRN Polariser Regulatory Network
            m.mgen_production(:,polariser_i)  = 0; % no polariser % @@ Eqn 1
            P(:)=0;
            % @@GRN Gene Regulatory Network
            m.mgen_production(:,s_lat_i)  = 0.8*id_lat_l.*inh(100,id_prox_l); % diffuse out from lat % @@ Eqn 2
            id_upper_p=1*inh(100,id_lower_l);
            id_g_p=BASIC_GROWTH * id_upper_l .* inh(7,s_lat_l.*s_lat_l).*inh(1000,arrest_p);
            id_g_l=id_g_p.*id_g_a;
            % @@KRN Growth Regulatory Network
            kapar_p= 0.5*id_g_l;% @@ Eqn 3
            kbpar_p= kapar_p;      % @@ Eqn 4
            kaper_p = kapar_p;% @@ Eqn 5
            kbper_p = kaper_p;    % @@ Eqn 6
            knor_p  =0.003;       % @@ Eqn 7
            
            m=leaf_plotoptions(m,'morphogen',{'id_g','id_lower'});

          case 'POL3'  % @@model MODEL2
            % @@PRN Polariser Regulatory Network
            m = leaf_mgen_conductivity( m, 'Polariser', 0.05);   % diffusion constant
            m = leaf_mgen_dilution( m,     'Polariser', false );  % it will not dilute with growth
            m = leaf_mgen_absorption( m,   'Polariser', 0);       % it will not decay everywhere
            m.globalProps.mingradient=0;

            id_proxorg_p=id_prox_l;% @@ Eqn 8
            id_proxorg_l=id_proxorg_p.*id_proxorg_a;
            id_distorg_p=id_dist_l; % @@ Eqn 9
            id_distorg_l=id_distorg_p.*id_distorg_a;
            ind_distorg=find(id_distorg_l>0.0);
            ind_proxorg=find(id_proxorg_l>0.0);
            P(ind_distorg)=0; %id_distorg_l(ind_distorg);
            P(ind_proxorg)=1; %id_proxorg_l(ind_proxorg);
            m.morphogenclamp(:,polariser_i) = 0;
            m.morphogenclamp(ind_distorg,polariser_i) = 1;
            m.morphogenclamp(ind_proxorg,polariser_i) = 1;

            % @@GRN Gene Regulatory Network
            m.mgen_production(:,s_lat_i)  = 0.8*id_lat_l.*inh(100,id_prox_l); % diffuse out from lat % @@ Eqn 2
            id_upper_p=1*inh(100,id_lower_l);
            id_g_p=BASIC_GROWTH * id_upper_l .* inh(7,s_lat_l.*s_lat_l).*inh(1000,arrest_p);
            id_g_l=id_g_p.*id_g_a;
            % @@KRN Growth Regulatory Network
            kapar_p = 0.75 * id_g_l;% @@ Eqn 3
            kbpar_p = kapar_p;      % @@ Eqn 4
            kaper_p = 0.25 * id_g_l;% @@ Eqn 5
            kbper_p = kaper_p;    % @@ Eqn 6
            knor_p  = 0.003;       % @@ Eqn 7      
        
            m=leaf_plotoptions(m,'morphogen',{'id_g','id_proxorg','id_distorg','id_lower'});
        case 'POLCEN2'  % @@model MODEL2
            % @@PRN Polariser Regulatory Network
            m = leaf_mgen_conductivity( m, 'Polariser', 0.05);   % diffusion constant
            m = leaf_mgen_dilution( m,     'Polariser', false );  % it will not dilute with growth
            m = leaf_mgen_absorption( m,   'Polariser', 0);       % it will not decay everywhere
            m.globalProps.mingradient=0;

            id_proxorg_p=id_prox_l;% @@ Eqn 8
            id_proxorg_l=id_proxorg_p.*id_proxorg_a;
            id_distorg_p=id_early_l.*id_dist_l ...% @@ Eqn 9
                + id_late_l.*id_dist_l.*(id_leftl_l+id_rightl_l);% @@ Eqn 10
            id_distorg_l=id_distorg_p.*id_distorg_a;
            ind_distorg=find(id_distorg_l>0.0);
            ind_proxorg=find(id_proxorg_l>0.0);
            P(ind_distorg)=0; %id_distorg_l(ind_distorg);
            P(ind_proxorg)=1; %id_proxorg_l(ind_proxorg);
            m.morphogenclamp(:,polariser_i) = 0;
            m.morphogenclamp(ind_distorg,polariser_i) = 1;
            m.morphogenclamp(ind_proxorg,polariser_i) = 1;

            % @@GRN Gene Regulatory Network
            m.mgen_production(:,s_lat_i)  = 0.8*id_lat_l.*inh(100,id_prox_l); % diffuse out from lat % @@ Eqn 2
            id_upper_p=1*inh(100,id_lower_l);
            id_g_p=BASIC_GROWTH * id_upper_l .* inh(7,s_lat_l.*s_lat_l).*inh(1000,arrest_p);
            id_g_l=id_g_p.*id_g_a;
            % @@KRN Growth Regulatory Network
            kapar_p = 0.75 * id_g_l;% @@ Eqn 3
            kbpar_p = kapar_p;      % @@ Eqn 4
            kaper_p = 0.25 * id_g_l;% @@ Eqn 5
            kbper_p = kaper_p;    % @@ Eqn 6
            knor_p  = 0.003;       % @@ Eqn 7
            
            m=leaf_plotoptions(m,'morphogen',{'id_g','id_proxorg','id_distorg','id_lower'});
          otherwise
            kapar_p=0;    % @@ Eqn 3
            kbpar_p=0;    % @@ Eqn 4
            kaper_p=0;    % @@ Eqn 5
            kbper_p=0;    % @@ Eqn 6
            knor_p =0;    % @@ Eqn 7
    end
    v_kpar_p=(kapar_p+kbpar_p)/2;
    v_kper_p=(kaper_p+kbper_p)/2;
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
    m.morphogens(:,id_proxorg_i) = id_proxorg_p;
    m.morphogens(:,id_distorg_i) = id_distorg_p;
    m.morphogens(:,id_lat_i) = id_lat_p;
    m.morphogens(:,s_lat_i) = s_lat_p;
    m.morphogens(:,id_rightl_i) = id_rightl_p;
    m.morphogens(:,v_kpar_i) = v_kpar_p;
    m.morphogens(:,v_kper_i) = v_kper_p;
    m.morphogens(:,id_early_i) = id_early_p;
    m.morphogens(:,id_late_i) = id_late_p;
    m.morphogens(:,id_later_i) = id_later_p;
    m.morphogens(:,v_clones_i) = v_clones_p;
    m.morphogens(:,id_dist_i) = id_dist_p;
    m.morphogens(:,id_prox_i) = id_prox_p;
    m.morphogens(:,id_upper_i) = id_upper_p;
    m.morphogens(:,id_lower_i) = id_lower_p;
    m.morphogens(:,id_leftl_i) = id_leftl_p;
    m.morphogens(:,id_startup_i) = id_startup_p;
    m.morphogens(:,id_g_i) = id_g_p;

%%% USER CODE: FINALISATION

    % In this section you may modify the mesh in any way whatsoever.
%%% END OF USER CODE: FINALISATION

end


%%% USER CODE: SUBFUNCTIONS
% Here you may add any functions of your own, that you want to call from
% the interaction function, but never need to call from outside it.
% Whichever section they are called from, they must respect the same
% restrictions on what modifications they are allowed to make to the mesh.
% This comment can be deleted.

