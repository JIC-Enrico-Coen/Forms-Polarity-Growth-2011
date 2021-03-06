function m = gpt_invagembryo( m )
%m = gpt_invagembryo( m )
%   Morphogen interaction function.
%   Written at 2011-04-28 13:51:14.
%   GFtbox revision 3502, 2011-04-15 16:29:35.777989.

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

    m.globalProps.mgenownsideonly=true;

    m=leaf_plotoptions(m,'seamlinesize',0.1,'seamlinecolor','k');
    % the following overrides settings made with the GUI (Plot: Multi-plot)
    m=leaf_plotoptions(m,'morphogenA','kaper','morphogenB','kbper');
    % NOTE: to clip off one end of the mesh use Plot Options panel
    % Clip tick-box and (if necessary) select the Polariser (Mgens)
    
    % More code for all iterations.
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
    [id_twist_i,id_twist_p,id_twist_a,id_twist_l] = getMgenLevels( m, 'ID_TWIST' );
    [id_ventral_i,id_ventral_p,id_ventral_a,id_ventral_l] = getMgenLevels( m, 'ID_VENTRAL' );
    [f_seams_i,f_seams_p,f_seams_a,f_seams_l] = getMgenLevels( m, 'F_SEAMS' );
    [f_seam2_i,f_seam2_p,f_seam2_a,f_seam2_l] = getMgenLevels( m, 'F_SEAM2' );

% Mesh type: capsule
%         basecap: 1
%      baseheight: 1
%       baserings: 0
%          centre: 0
%      circumdivs: 60
%          height: 2
%      heightdivs: 12
%      randomness: -0.01
%          topcap: 1
%       topheight: 1
%        toprings: 0
%         version: 1
%          xwidth: 2
%          ywidth: 2

%            Morphogen   Diffusion   Decay   Dilution   Mutant
%            -------------------------------------------------
%                KAPAR        ----    ----       ----     ----
%                KAPER        ----    ----       ----     ----
%                KBPAR        ----    ----       ----     ----
%                KBPER        ----    ----       ----     ----
%                 KNOR        ----    ----       ----     ----
%            POLARISER        ----    ----       ----     ----
%            STRAINRET        ----    ----       ----     ----
%               ARREST        ----    ----       ----     ----
%             ID_TWIST        ----    ----       ----     ----
%           ID_VENTRAL        ----    ----       ----     ----
%              F_SEAMS        ----    ----       ----     ----
%              F_SEAM2        ----    ----       ----     ----


%%% USER CODE: MORPHOGEN INTERACTIONS

% In this section you may modify the mesh in any way that does not
% alter the set of nodes.
    if Steps(m)==0  % Initialisation code.
        % Put any code here that should only be performed at the start of
        % the simulation, for example, to set up initial morphogen values.
        m.morphogens=zeros(size(m.morphogens));
        m.seams=logical(zeros(size(m.seams)));
        m.polfreeze=zeros(size(m.polfreeze));
        m.mgen_production=zeros(size(m.mgen_production));

        xmax = max(m.nodes(:,1));
        id_twist_p(xmax - m.nodes(:,1) < .3) = 1;
        place_ventral = xmax - m.nodes(:,1) < .5;
        id_ventral_p(place_ventral) = 1;
        
        % PRN
        % set up a static polarity field along z
        P = m.nodes(:,3);
        
        % This section creates a display feature (not a part of the model)
        % seams usually designate lines along which canvas will be cut
        % however, here they are used to display a grid
        f_seams_p(:)=0; % local variable
        f_seam2_p(:)=0; % local variable
        dz=0.02;
        for z=-1.8:0.2:1.8
            inds=find(m.nodes(:,3)>(z-dz)& m.nodes(:,3)<(z+dz));
            f_seams_p(inds)=1;
        end
        % add seams around the cylinder and end caps
        m=leaf_addseam(m,'nodes',find(f_seams_p>0.5));
        indmid=(m.nodes(:,3) >= -1.001) & (m.nodes(:,3) <= 1.001);
        theta_p = atan2( m.nodes(:,2), m.nodes(:,1) )*(0.5/pi);
        % find clusters of vertices in the middle cylindrical part of mesh
        [cnum,cmin,cstep,csz,clumpindex] = clumplinear( theta_p(indmid) );
        % put a seam along every fourth cluster
        for i=1:4:cnum
            ind=find(clumpindex==i);
            f_seam2_p(ind)=1;
        end
        m=leaf_addseam(m,'nodes',find(f_seam2_p>0.5));
    end
    
    % GRN
    
    % KRN
    kapar_p(:) =0;
    kbpar_p(:) =0;
    kbper_p(:) = 0.1; % set kbper everywhere except ...
    kbper_p(id_twist_p == 1) = -0.5; % (i.e. where twist is 1 set kbper to shrink)
    kaper_p = 0.2*id_twist_p;
    knor_p = -0.05*id_ventral_p;
    
    if realtime >= 5.0
        kbper_p((id_ventral_p - id_twist_p) == 1) = 0.5;
    end
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
    m.morphogens(:,id_twist_i) = id_twist_p;
    m.morphogens(:,id_ventral_i) = id_ventral_p;
    m.morphogens(:,f_seams_i) = f_seams_p;
    m.morphogens(:,f_seam2_i) = f_seam2_p;

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
