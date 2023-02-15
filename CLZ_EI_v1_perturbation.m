function [Mix,E,I] = CLZ_EI_v1_perturbation(DCM,TCM,dP,nStep,Mode)

% dP for Excitatory/Inhibitory
% Mode TCM - DCM/DCM - TCM
% This code only works in 4 nodes

ExcParam = {'H(3,1,1)','H(3,1,2)','H(3,1,3)','H(3,1,4)',...
            'H(3,4,1)','H(3,4,2)','H(3,4,3)','H(3,4,4)',...
            'H(4,2,1)','H(4,2,2)','H(4,2,3)','H(4,2,4)',...
            'H(2,1,1)','H(2,1,2)','H(2,1,3)','H(2,1,4)'};
InhParam = {'H(1,3,1)','H(1,3,2)','H(1,3,3)','H(1,3,4)',...
            'H(2,3,1)','H(2,3,2)','H(2,3,3)','H(2,3,4)',...
            'H(4,3,1)','H(4,3,2)','H(4,3,3)','H(4,3,4)'};
        
if  ~(length(dP) == 2)
    dP = repmat(dP,2,1);
end
% Make Absolute dP
dP = abs(dP);

dEP = dP(1);
dIP = dP(2);


[Ep,M,U] = jse_dcm_prepare_Hs(DCM);
%   Excitation connectivity
%   ----------------------------------------------------------------------
for Enp = 1:length(ExcParam)
    Pname = jse_dcm_param_divide(ExcParam{Enp});
    
    nPP =  dEP/nStep;
    nPM = -dEP/nStep;
    
    if Enp == 1
        ExcPP = jse_perturbate_parameter_nstep(Ep   ,...
                                               nPP  ,...
                                               Pname,...
                                               nStep,...
                                               1       );
        ExcPM = jse_perturbate_parameter_nstep(Ep   ,...
                                               nPM  ,...
                                               Pname,...
                                               nStep,...
                                               -1        );
    else
        PP = jse_perturbate_parameter_nstep(Ep   ,...
                                            nPP  ,...
                                            Pname,...
                                            nStep,...
                                            1       );
        ExcPP = jse_parameter_summation(ExcPP,PP,Pname);
        
        PM = jse_perturbate_parameter_nstep(Ep   ,...
                                            nPM  ,...
                                            Pname,...
                                            nStep,...
                                            -1        );
        ExcPM = jse_parameter_summation(ExcPM,PM,Pname);
    end
end

ExcP = [ExcPM ExcPP(2:end)];

clear PP PM nPP nPM

%   Inhibition connectivity
%   ----------------------------------------------------------------------
for Inp = 1:length(InhParam)
    Pname = jse_dcm_param_divide(InhParam{Inp});
    
    nPP =  dIP/nStep;
    nPM = -dIP/nStep;
    
    if Inp == 1
        InhPP = jse_perturbate_parameter_nstep(Ep   ,...
                                               nPP  ,...
                                               Pname,...
                                               nStep,...
                                               1       );
        InhPM = jse_perturbate_parameter_nstep(Ep   ,...
                                               nPM  ,...
                                               Pname,...
                                               nStep,...
                                               -1        );
    else
        PP = jse_perturbate_parameter_nstep(Ep   ,...
                                            nPP  ,...
                                            Pname,...
                                            nStep,...
                                            1       );
        InhPP = jse_parameter_summation(InhPP,PP,Pname);
        
        PM = jse_perturbate_parameter_nstep(Ep   ,...
                                            nPM  ,...
                                            Pname,...
                                            nStep,...
                                            -1        );
        InhPM = jse_parameter_summation(InhPM,PM,Pname);
    end
end


InhP = [InhPM InhPP(2:end)];

clear PP PM nPP nPM

%   Mix Excitation/Inhibition 
%   ----------------------------------------------------------------------
MixP = jse_parameter_mix(ExcP,InhP,jse_dcm_param_divide(InhParam));

%   Generate Hs
%   ----------------------------------------------------------------------
EHs = jse_calc_csd_mtf(ExcP,M,U);
IHs = jse_calc_csd_mtf(InhP,M,U);
MHs = jse_calc_csd_mtf(MixP,M,U);

%   Construct Result structure
Mix.Ep = MixP;
Mix.M  = M;
Mix.U  = U;
E.Ep   = ExcP;
E.M    = M;
E.U    = U;
I.Ep   = InhP;
I.M    = M;
I.U    = U;

Mix.Hs = MHs;
E.Hs   = EHs;
I.Hs   = IHs;

for ni = 1:nStep*2+1
    E.y{ni}    = jse_eval_dcm_Hs(E.Hs{ni});
    I.y{ni}    = jse_eval_dcm_Hs(I.Hs{ni});
    for nj = 1:nStep*2+1
        Mix.y{ni,nj}  = jse_eval_dcm_Hs(Mix.Hs{ni,nj});
    end
end



Mix.dP = dP;
E.dP   = dP;
I.dP   = dP;
Mix.nStep = nStep;
E.nStep   = nStep;
I.nStep   = nStep;

%   Low data mode
DelS = {'M','U'};
for d = 1:length(DelS)
    Mix = rmfield(Mix,DelS{d});
    E   = rmfield(E,DelS{d});
    I   = rmfield(I,DelS{d});
end

