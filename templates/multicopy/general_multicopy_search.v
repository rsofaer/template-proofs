From iris.algebra Require Import excl auth cmra gmap agree gset numbers.
From iris.algebra.lib Require Import frac_agree.
From iris.heap_lang Require Export notation locations lang.
From iris.base_logic.lib Require Export invariants.
From iris.program_logic Require Export atomic.
From iris.proofmode Require Import tactics.
From iris.heap_lang Require Import proofmode par.
From iris.bi.lib Require Import fractional.
Set Default Proof Using "All".
Require Import general_multicopy util.

Section search_proof.
  Context {Σ} `{!heapG Σ, !multicopyG Σ}.
  Notation iProp := (iProp Σ).  
  Local Notation "m !1 i" := (nzmap_total_lookup i m) (at level 20).

<<<<<<< HEAD
  Lemma traverse_spec N γ_te γ_he γ_s γ_t γ_I γ_R γ_f γ_gh γ_fr lc r 
                          γ_en γ_cn γ_bn γ_qn γ_cirn n (k: K) t0 t1 :
    ⊢ ⌜k ∈ KS⌝ -∗ mcs_inv N γ_te γ_he γ_s γ_t γ_I γ_R γ_f γ_gh γ_fr lc r -∗
=======
  Lemma traverse_spec N1 γ_te γ_he γ_s γ_t γ_I γ_J γ_f γ_gh γ_fr lc r 
                          γ_en γ_cn γ_bn γ_qn γ_cirn n (k: K) t0 t1 :
    ⊢ ⌜k ∈ KS⌝ -∗ mcs_inv N1 γ_te γ_he γ_s γ_t γ_I γ_J γ_f γ_gh γ_fr lc r -∗
>>>>>>> ccbc163 (Variable -> Parameter; R interfaces -> J interfaces)
        inFP γ_f n -∗ 
          own γ_gh (◯ {[n := ghost_loc γ_en γ_cn γ_bn γ_qn γ_cirn]}) -∗ 
            own (γ_cirn !!! k) (◯ MaxNat t1) -∗ ⌜t0 ≤ t1⌝ -∗
              <<< True >>> 
                  traverse #n #k @ ⊤ ∖ ↑(mcsN N)
              <<< ∃ (t': nat), mcs_sr γ_s (k, t') ∗ ⌜t0 ≤ t'⌝ , RET #t' >>>.
  Proof.
    iIntros "k_in_KS #HInv". 
    iLöb as "IH" forall (n t1 γ_en γ_cn γ_bn γ_qn γ_cirn).
    iIntros "#FP_n #Hgh #Hlb H". iDestruct "H" as %t0_le_t1.
    iDestruct "k_in_KS" as %k_in_KS.
    iIntros (Φ) "AU". wp_lam. wp_pures.
    (** Lock node n **)
    awp_apply lockNode_spec_high; try done.
    iAaccIntro with ""; try eauto with iFrame. 
    iIntros (Cn Bn Qn)"HnP_n". iModIntro. wp_pures. 
    iDestruct "HnP_n" as (γ_en' γ_bn' γ_cn' γ_qn' γ_cirn' es T)
                    "(node_n & HnP_gh & HnP_frac & HnP_C & HnP_t)".
    iPoseProof (ghost_heap_sync with "[$HnP_gh] [$Hgh]") 
                                  as "(% & % & % & % & %)".
    subst γ_en'. subst γ_cn'. subst γ_bn'. subst γ_qn'. subst γ_cirn'.
    (** Check contents of n **)
    wp_apply (inContents_spec with "node_n").
    iIntros (t) "(node_n & H)". iDestruct "H" as %Cn_val.
    wp_pures.
    (** Case analysis on whether k in contents of n **)
    destruct t as [t |]; last first.
    - (** Case : k not in contents of n **)
      wp_pures.
      (** Find next node to visit **)
      wp_apply (findNext_spec with "node_n").
      iIntros (b n1) "(node_n & Hif)". 
      (** Case analysis on whether there exists a next node **)
      destruct b.
      + (** Case : exists next node n' **)
        wp_pures. iDestruct "Hif" as %k_in_es.
        iApply fupd_wp.
        (** Open invariant to establish resources
            required to apply induction hypothesis IH
            on node n' **)
        iInv "HInv" as ">H".
        iDestruct "H" as (T' H hγ I R) "(Hglob & Hstar)".
        iAssert (⌜n ∈ domm I⌝)%I as "%". 
        { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & FP_r & Max_ts & domm_IR & domm_Iγ)".
          by iPoseProof (inFP_domm _ _ _ with "[$FP_n] [$Hf]") as "H'". }
        rewrite (big_sepS_delete _ (domm I) n); last by eauto.
        iDestruct "Hstar" as "(H_n & Hstar')".
        iDestruct "H_n" as (bn Cn' Bn' Qn')"(Hl_n & Hlif_n & HnS_n)".
        iDestruct "HnS_n" as (γ_en' γ_cn' γ_bn' γ_qn' γ_cirn' es' In Jn) 
                      "(HnS_gh & HnS_frac & HnS_si & HnS_FP 
                                & HnS_cl & HnS_oc & HnS_H & HnS_star & Hφ)".
        iPoseProof (ghost_heap_sync with "[$HnP_gh] [$HnS_gh]") 
                                  as "(% & % & % & % & %)".
        subst γ_en'. subst γ_cn'. subst γ_bn'. subst γ_qn'. subst γ_cirn'.
        iPoseProof (frac_eq with "[$HnP_frac] [$HnS_frac]") as "%".
        destruct H1 as [Hes [Hc [Hb Hq]]]. 
        subst es'. subst Cn'. subst Bn'. subst Qn'.
        iAssert (inFP γ_f n1)%I as "#FP_n1".
        { iApply "HnS_cl". iPureIntro. 
          clear -k_in_es. set_solver. }
             
        iAssert (⌜n1 ∈ domm I⌝)%I as %n_in_I.
        { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & FP_r & Max_ts & domm_IR & domm_Iγ)".
          by iPoseProof (inFP_domm _ _ _ with "[$FP_n1] [$Hf]") as "H'". }
        iAssert (⌜n ≠ n1⌝)%I as %n_neq_n1.
        { destruct (decide (n = n1)); try done.
          iPoseProof (node_es_empty with "node_n") as "%".
          destruct H1 as [_ Es_n]. rewrite <-e in k_in_es.
          clear -k_in_es Es_n. set_solver. } 
        rewrite (big_sepS_delete _ (domm I ∖ {[n]}) n1); last by set_solver.
        iDestruct "Hstar'" as "(H_n1 & Hstar'')".
        iDestruct "H_n1" as (bn1 Cn1 Bn1 Qn1)"(Hl_n1 & Hlif_n1 & HnS_n1)".
        iDestruct "HnS_n1" as (γ_en1 γ_cn1 γ_bn1 γ_qn1 γ_cirn1 es1 In1 Jn1) 
                  "(HnS_gh1 & HnS_frac1 & HnS_si1 & HnS_FP1 
                       & HnS_cl1 & HnS_oc1 & HnS_H1 & HnS_star1 & Hφ1)".

        iEval (rewrite (big_sepS_elem_of_acc (_) (KS) k); 
                              last by eauto) in "HnS_star".
        iDestruct "HnS_star" as "(Hcirk_n & HnS_star')".
        iEval (rewrite (big_sepS_elem_of_acc (_) (KS) k);
                                     last by eauto) in "HnS_star1".
        iDestruct "HnS_star1" as "(Hcirk_n1 & HnS_star1')".
        iMod (own_update (γ_cirn1 !!! k) (● MaxNat (Bn1 !!! k)) 
              ((● MaxNat (Bn1 !!! k)) ⋅ (◯ MaxNat (Bn1 !!! k))) 
                  with "[Hcirk_n1]") as "(Hcirk_n1 & #Hlb_1)".
        { apply (auth_update_alloc _ (MaxNat (Bn1 !!! k)) 
                              (MaxNat (Bn1 !!! k))).
          apply max_nat_local_update. 
          simpl. lia. } { iFrame. }

        iAssert (⌜t0 ≤ Bn1 !!! k⌝)%I as "%".
        { iAssert (⌜t1 ≤ Bn !!! k⌝)%I as %lb_t1.
          { iPoseProof (own_valid_2 with "[$Hcirk_n] [$Hlb]") as "%".
            rename H1 into Valid_Bnt.
            apply auth_both_valid_discrete in Valid_Bnt.
            destruct Valid_Bnt as [H' _].
            apply max_nat_included in H'.
            simpl in H'. by iPureIntro. }
          destruct (Qn !! k) as [tq | ] eqn: Hqn.
          - iAssert (⌜(k, Qn !!! k) ∈ outset KT In n1⌝)%I as %outflow_n_n1.
            { iDestruct "HnS_oc" as "(H' & _)".
              iDestruct "H'" as %H'. iPureIntro.    
              apply (H' n1 k (Qn !!! k)).
              unfold outflow_constraint_I in H'.
              done. repeat split; try done. 
              rewrite lookup_total_alt. 
              rewrite Hqn. by simpl. }
            iAssert (⌜(k, Qn !!! k) ∈ inset KT In1 n1⌝)%I as %inflow_n1.
            { iDestruct "HnS_si" as "(H'&_)".
              iDestruct "HnS_si1" as "(H1'&_&%&_)".
              rename H1 into Domm_In1.
              assert (n1 ∈ domm In1) as H''. 
              { clear -Domm_In1. set_solver. }
              iCombine "H'" "H1'" as "H'".
              iPoseProof (own_valid with "[$H']") as "%".
              rename H1 into Valid_InIn1.
              rewrite auth_frag_valid in Valid_InIn1 *; intros Valid_InIn1.
              pose proof intComp_unfold_inf_2 In In1 Valid_InIn1 n1 H''.
              rename H1 into H'. unfold ccmop, ccm_op in H'.
              simpl in H'. unfold lift_op in H'.
              iPureIntro. rewrite nzmap_eq in H' *; intros H'.
              pose proof H' (k, Qn !!! k) as H'.
              rewrite nzmap_lookup_merge in H'.
              unfold ccmop, ccm_op in H'. simpl in H'.
              unfold nat_op in H'.
              assert (1 ≤ out In n1 !1 (k, Qn !!! k)) as Hout.
              { unfold outset, dom_ms in outflow_n_n1.
                rewrite nzmap_elem_of_dom_total in outflow_n_n1 *; 
                intros outflow_n_n1.
                unfold ccmunit, ccm_unit in outflow_n_n1.
                simpl in outflow_n_n1. unfold nat_unit in outflow_n_n1.
                clear - outflow_n_n1. lia. }
              assert (1 ≤ inf In1 n1 !1 (k, Qn !!! k)) as Hin.
              { clear -H' Hout. 
                assert (∀ (x y z: nat), 1 ≤ y → x = z + y → 1 ≤ x) as H''.
                lia. by pose proof H'' _ _ _ Hout H'. }
              unfold inset. rewrite nzmap_elem_of_dom_total.
              unfold ccmunit, ccm_unit. simpl. unfold nat_unit.
              clear -Hin. lia. }
            iAssert (⌜Bn1 !!! k = Qn !!! k⌝)%I as %Bn1_eq_Bn.
            { iDestruct "Hφ1" as "(_ & _& % & _)". 
              rename H1 into Hφ2. 
              pose proof Hφ2 k (Qn !!! k) k_in_KS inflow_n1 as H'.
              iPureIntro. done. } 
            iAssert (⌜Bn !!! k = Qn !!! k⌝)%I as %Bn_eq_Qn.
            { iDestruct "Hφ" as "(_ & % & _)". rename H1 into Hφ1.
              pose proof Hφ1 k as [_ H']. done.
              iPureIntro. pose proof H' Cn_val as H'. 
              rewrite /(Bn !!! k). unfold finmap_lookup_total.
              by rewrite H'.  } 
            iPureIntro. rewrite Bn1_eq_Bn.
            rewrite <-Bn_eq_Qn. clear -lb_t1 t0_le_t1.
            apply (Nat.le_trans _ t1 _); try done.
          - iDestruct "Hφ" as "(_ & % & _)".
            rename H1 into Hφ1. apply Hφ1 in Cn_val.
            rewrite <-Cn_val in Hqn.
            rewrite lookup_total_alt in lb_t1.
            rewrite Hqn in lb_t1.
            simpl in lb_t1. iPureIntro.
            clear -lb_t1 t0_le_t1. lia.
            try done. done. }
 
        iAssert (own γ_gh (◯ {[n1 := 
                      ghost_loc γ_en1 γ_cn1 γ_bn1 γ_qn1 γ_cirn1]}))%I
                            with "HnS_gh1" as "#Hgh1".  
        (** Closing the invariant **)
        iModIntro. iSplitR "node_n HnP_gh HnP_frac HnP_C HnP_t AU". iNext.
        iExists T', H, hγ, I, R. iFrame "Hglob".
        rewrite (big_sepS_delete _ (domm I) n); last by eauto.
        rewrite (big_sepS_delete _ (domm I ∖ {[n]}) n1); last set_solver.
        iFrame "Hstar''". iSplitL "Hl_n Hlif_n HnS_gh HnS_frac 
                    HnS_si HnS_FP HnS_cl HnS_oc HnS_H Hcirk_n HnS_star' Hφ".
        iExists bn, Cn, Bn, Qn. iFrame "Hl_n Hlif_n".
        iExists γ_en, γ_cn, γ_bn, γ_qn, γ_cirn, es, In, Jn.
        iFrame. by iApply "HnS_star'".                  
        iExists bn1, Cn1, Bn1, Qn1. iFrame "Hl_n1 Hlif_n1".
        iExists γ_en1, γ_cn1, γ_bn1, γ_qn1, γ_cirn1, es1, In1, Jn1.
        iFrame. by iApply "HnS_star1'".
        iModIntro.
        (** Unlock node n **)       
        awp_apply (unlockNode_spec_high with "[] [] 
            [HnP_gh HnP_frac HnP_C HnP_t node_n]"); try done.
        iExists γ_en, γ_cn, γ_bn, γ_qn, γ_cirn, es, T.
        iFrame.                
        iAaccIntro with ""; try eauto with iFrame.
        iIntros "_". iModIntro. wp_pures.
        (** Apply IH on node n' **)
        iApply "IH"; try done. 
      + (** Case : no next node from n **)
        wp_pures. iDestruct "Hif" as %Not_in_es.
        iApply fupd_wp. 
        (** Linearization Point: key k has not been found in the 
            data structure. Open invariant to obtain resources 
            required to establish post-condition **)
        iInv "HInv" as ">H".
        iDestruct "H" as (T' H hγ I R) "(Hglob & Hstar)".
        iAssert (⌜n ∈ domm I⌝)%I as "%". 
        { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & FP_r & Max_ts & domm_IR & domm_Iγ)".
          by iPoseProof (inFP_domm _ _ _ with "[$FP_n] [$Hf]") as "H'". }
        rewrite (big_sepS_delete _ (domm I) n); last by eauto.
        iDestruct "Hstar" as "(H_n & Hstar')".
        iDestruct "H_n" as (bn Cn' Bn' Qn')"(Hl_n & Hlif_n & HnS_n)".
        iDestruct "HnS_n" as (γ_en' γ_cn' γ_bn' γ_qn' γ_cirn' es' In Jn) 
                      "(HnS_gh & HnS_frac & HnS_si & HnS_FP 
                                & HnS_cl & HnS_oc & HnS_H & HnS_star & Hφ)".
        iPoseProof (ghost_heap_sync with "[$HnP_gh] [$HnS_gh]") 
                                  as "(% & % & % & % & %)".
        subst γ_en'. subst γ_cn'. subst γ_bn'. subst γ_qn'. subst γ_cirn'.
        iPoseProof (frac_eq with "[$HnP_frac] [$HnS_frac]") as "%".
        destruct H1 as [Hes [Hc [Hb Hq]]]. 
        subst es'. subst Cn'. subst Bn'. subst Qn'.
        iAssert (⌜Bn !!! k = 0⌝)%I as %Bn_eq_0.
        { iDestruct "Hφ" as "(Hφ0 & Hφ1 & _)".
          iDestruct "Hφ0" as %Hφ0.
          iDestruct "Hφ1" as %Hφ1.
          pose proof Hφ0 k k_in_KS Not_in_es as Hφ0.
          pose proof Hφ1 k as [_ H']. done.
          pose proof H' Cn_val as H'. 
          iPureIntro.
          rewrite lookup_total_alt.
          rewrite H' Hφ0. by simpl. }          
        iEval (rewrite (big_sepS_elem_of_acc (_) (KS) k); last by eauto) 
                                                       in "HnS_star".
        iDestruct "HnS_star" as "(Hcirk_n & HnS_star')".
        iAssert (⌜t1 ≤ Bn !!! k⌝)%I as %lb_t1.
        { iPoseProof (own_valid_2 with "[$Hcirk_n] [$Hlb]") as "%".
          rename H1 into Valid_Bnt.
          apply auth_both_valid_discrete in Valid_Bnt.
          destruct Valid_Bnt as [H' _].
          apply max_nat_included in H'.
          simpl in H'. by iPureIntro. }
        iAssert (⌜t0 = 0⌝)%I as %t0_zero. 
        { iPureIntro. rewrite Bn_eq_0 in lb_t1. 
          clear -lb_t1 t0_le_t1. lia. } subst t0.
        (** Linearization **)  
        iMod "AU" as "[_ [_ Hclose]]". 
        iAssert (⌜(k,0) ∈ H⌝)%I as "%". 
        { iDestruct "Hglob" as "(MCS_auth & HH & Hist & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & FP_r & Max_ts & domm_IR & domm_Iγ)".
          iDestruct "Hist" as %Hist. iPureIntro. 
          by pose proof Hist k k_in_KS as Hist. }
        rename H1 into k0_in_H.  
        iSpecialize ("Hclose" $! 0).
        iDestruct "Hglob" as "(MCS_auth & HH & Hglob')".
        iMod (own_update γ_s (● H) (● H ⋅ ◯ {[(k,0)]}) with "[$HH]") as "HH".
        { apply (auth_update_frac_alloc _ H ({[(k,0)]})).
          apply gset_included. clear -k0_in_H. set_solver. }
        iDestruct "HH" as "(HH & #mcs_sr)".
        iCombine "MCS_auth HH Hglob'" as "Hglob".        
        iMod ("Hclose" with "[]") as "HΦ". iFrame "mcs_sr". 
        by iPureIntro.
        (** Closing the invariant **)
        iModIntro. iSplitR "node_n HnP_gh HnP_frac HnP_C HnP_t HΦ". iNext.
        iExists T', H, hγ, I, R. iFrame "Hglob".
        rewrite (big_sepS_delete _ (domm I) n); last by eauto.
        iFrame "Hstar'". iExists bn, Cn, Bn, Qn.
        iFrame "Hl_n Hlif_n". 
        iExists γ_en, γ_cn, γ_bn, γ_qn, γ_cirn, es, In, Jn.
        iFrame "∗%". by iApply "HnS_star'". iModIntro.
        (** Unlock node n **)
        awp_apply (unlockNode_spec_high with "[] [] 
               [HnP_gh HnP_frac HnP_C HnP_t node_n]") without "HΦ"; try done. 
        iExists γ_en, γ_cn, γ_bn, γ_qn, γ_cirn, es, T. iFrame.
        iAaccIntro with ""; try eauto with iFrame.
        iIntros "_". iModIntro. iIntros "HΦ". by wp_pures.
    - (** Case : k in contents of n **)
      wp_pures.                                         
      iApply fupd_wp. 
      (** Linearization Point: key k has been found. Open 
          invariant to obtain resources required to 
          establish post-condition **)
      iInv "HInv" as ">H".
      iDestruct "H" as (T' H hγ I R) "(Hglob & Hstar)".
      iAssert (⌜n ∈ domm I⌝)%I as "%". 
      { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & FP_r & Max_ts & domm_IR & domm_Iγ)".
        by iPoseProof (inFP_domm _ _ _ with "[$FP_n] [$Hf]") as "H'". }
      rewrite (big_sepS_delete _ (domm I) n); last by eauto.
      iDestruct "Hstar" as "(H_n & Hstar')".
      iDestruct "H_n" as (bn Cn' Bn' Qn')"(Hl_n & Hlif_n & HnS_n)".
      iDestruct "HnS_n" as (γ_en' γ_cn' γ_bn' γ_qn' γ_cirn' es' In Jn) 
                    "(HnS_gh & HnS_frac & HnS_si & HnS_FP 
                              & HnS_cl & HnS_oc & HnS_H & HnS_star & Hφ)".
      iPoseProof (ghost_heap_sync with "[$HnP_gh] [$HnS_gh]") 
                                as "(% & % & % & % & %)".
      subst γ_en'. subst γ_cn'. subst γ_bn'. subst γ_qn'. subst γ_cirn'.
      iPoseProof (frac_eq with "[$HnP_frac] [$HnS_frac]") as "%".
      destruct H1 as [Hes [Hc [Hb Hq]]]. 
      subst es'. subst Cn'. subst Bn'. subst Qn'.
      iEval (rewrite (big_sepS_elem_of_acc (_) (KS) k); last by eauto) 
                                                      in "HnS_star".
      iDestruct "HnS_star" as "(Hcirk_n & HnS_star')".
      iAssert (⌜t1 ≤ Bn !!! k⌝)%I as %lb_t1.
      { iPoseProof (own_valid_2 with "[$Hcirk_n] [$Hlb]") as "%".
        rename H1 into Valid_Bnt.
        apply auth_both_valid_discrete in Valid_Bnt.
        destruct Valid_Bnt as [H' _].
        apply max_nat_included in H'.
        simpl in H'. by iPureIntro. }
      iAssert (⌜Bn !!! k = Cn !!! k⌝)%I as %Bn_eq_Cn.
      { iDestruct "Hφ" as "(_ & Hφ1 & _)".
        iDestruct "Hφ1" as %Hφ1.
        pose proof Hφ1 k t as [H' _].
        done. iPureIntro.
        rewrite !lookup_total_alt.
        pose proof H' Cn_val as H'.
        by rewrite Cn_val H'. }          
      iAssert (⌜set_of_map Cn ⊆ H⌝)%I as %Cn_Sub_H.
      { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & FP_r & Max_ts & domm_IR & domm_Iγ)".
        iPoseProof ((auth_own_incl γ_s H _) with "[$HH $HnP_C]") as "%".
        rename H1 into H'. by apply gset_included in H'. }  
      iAssert (⌜(k,t) ∈ set_of_map Cn⌝)%I as %kt_in_Cn.
      { iPureIntro. apply set_of_map_member.
        rewrite /(Cn !!! k) in Cn_val.
        unfold finmap_lookup_total, inhabitant in Cn_val.
        simpl in Cn_val. 
        destruct (Cn !! k) as [cnk | ] eqn: Hcnk.
        - rewrite Hcnk. apply f_equal.
          by inversion Cn_val. 
        - try done.  }
      (** Linearization **)      
      iMod "AU" as "[_ [_ Hclose]]". 
      iSpecialize ("Hclose" $! t).
      iDestruct "Hglob" as "(MCS_auth & HH & Hglob')".
      iMod (own_update γ_s (● H) (● H ⋅ ◯ {[(k,t)]}) with "[$HH]") as "HH".
      { apply (auth_update_frac_alloc _ H ({[(k,t)]})).
        apply gset_included. clear -kt_in_Cn Cn_Sub_H. set_solver. }
      iDestruct "HH" as "(HH & #mcs_sr)".
      iCombine "MCS_auth HH Hglob'" as "Hglob".        
      iMod ("Hclose" with "[]") as "HΦ". iFrame "mcs_sr". 
      iPureIntro. rewrite Bn_eq_Cn in lb_t1.
      rewrite lookup_total_alt in lb_t1.
      rewrite Cn_val in lb_t1. simpl in lb_t1. lia.
      (** Closing the invariant **)
      iModIntro. iSplitR "node_n HnP_gh HnP_frac HnP_C HnP_t HΦ".
      iNext. iExists T', H, hγ, I, R. iFrame "Hglob".
      rewrite (big_sepS_delete _ (domm I) n); last by eauto.
      iFrame "Hstar'". iExists bn, Cn, Bn, Qn.
      iFrame "Hl_n Hlif_n". 
      iExists γ_en, γ_cn, γ_bn, γ_qn, γ_cirn, es, In, Jn.
      iFrame "∗%". by iApply "HnS_star'". iModIntro.
      (** Unlock node n **)
      awp_apply (unlockNode_spec_high with "[] [] 
                [HnP_gh HnP_frac HnP_C HnP_t node_n]") without "HΦ"; 
                      try done.
      iExists γ_en, γ_cn, γ_bn, γ_qn, γ_cirn, es, T. iFrame.
      iAaccIntro with ""; try eauto with iFrame.
      iIntros "_". iModIntro. iIntros "HΦ". by wp_pures.
      Unshelve. try done. try done.
  Qed.
  

<<<<<<< HEAD
  Lemma search_recency N γ_te γ_he γ_s γ_t γ_I γ_R γ_f γ_gh γ_fr lc r 
                           (k: K) t0 :
    ⊢ ⌜k ∈ KS⌝ -∗ 
        mcs_inv N γ_te γ_he γ_s γ_t γ_I γ_R γ_f γ_gh γ_fr lc r -∗
=======
  Lemma search_recency N1 γ_te γ_he γ_s γ_t γ_I γ_J γ_f γ_gh γ_fr lc r 
                           (k: K) t0 :
    ⊢ ⌜k ∈ KS⌝ -∗ 
        mcs_inv N1 γ_te γ_he γ_s γ_t γ_I γ_J γ_f γ_gh γ_fr lc r -∗
>>>>>>> ccbc163 (Variable -> Parameter; R interfaces -> J interfaces)
          mcs_sr γ_s (k, t0) -∗
              <<< True >>> 
                  search r #k @ ⊤ ∖ ↑(mcsN N)
              <<< ∃ (t': nat), mcs_sr γ_s (k, t') ∗ ⌜t0 ≤ t'⌝ , RET #t' >>>.
  Proof.
    iIntros "% #HInv #mcs_sr" (Φ) "AU".
    rename H into k_in_KS. 
    iApply fupd_wp. iInv "HInv" as ">H".
    iDestruct "H" as (T H hγ I R) "(Hglob & Hstar)".
    iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & #FP_r & Max_ts & domm_IR & domm_Iγ)".
    iAssert (⌜r ∈ domm I⌝)%I as "%". 
    { by iPoseProof (inFP_domm _ _ _ with "[$FP_r] [$Hf]") as "H'". }
    rename H0 into r_in_I.
    rewrite (big_sepS_delete _ (domm I) r); last by eauto.
    iDestruct "Hstar" as "(H_r & Hstar')".
    iDestruct "H_r" as (br Cr Br Qr)"(Hl_r & Hlif_r & HnS_r)".
    iDestruct "HnS_r" as (γ_er γ_cr γ_br γ_qr γ_cirr es Ir Rr) 
                      "(#HnS_gh & HnS_frac & HnS_si & HnS_FP 
                                & HnS_cl & HnS_oc & HnS_H & HnS_star & Hφ)".
    rewrite (big_sepS_delete _ (KS) k); last by eauto.
    iDestruct "HnS_star" as "(HnS_stark & HnS_star')".
    iMod (own_update (γ_cirr !!! k) (● MaxNat (Br !!! k)) 
          (● (MaxNat (Br !!! k)) ⋅ ◯ (MaxNat (Br !!! k))) 
            with "[$HnS_stark]") as "HnS_stark".
    { apply (auth_update_frac_alloc); try done.
      unfold CoreId, pcore, cmra_pcore. simpl.
      unfold ucmra_pcore. simpl. by unfold max_nat_pcore. }
    iDestruct "HnS_stark" as "(HnS_stark & #mcs_sr')".
    iEval (rewrite decide_True) in "HnS_H".
    iDestruct "HnS_H" as "(% & %)".
    rename H0 into Br_eq_H. rename H1 into Infz_Ir.
    iAssert (⌜(k,t0) ∈ H⌝)%I as %kt0_in_H.
    { iPoseProof (own_valid_2 _ _ _ with "[$HH] [$mcs_sr]") as "H'".
      iDestruct "H'" as %H'.
      apply auth_both_valid_discrete in H'.
      destruct H' as [H' _].
      apply gset_included in H'.
      iPureIntro; clear -H'; set_solver. }
    assert (t0 ≤ Br !!! k) as t0_le_Brk.
    { rewrite Br_eq_H. by apply map_of_set_lookup_lb. }   
    
    iModIntro. iSplitR "AU". iNext.
    iExists T, H, hγ, I, R. 
    iSplitR "Hl_r Hlif_r HnS_frac HnS_si HnS_FP HnS_cl HnS_oc 
             HnS_star' Hφ Hstar' HnS_stark".
    { iFrame. iFrame "FP_r". }           
    rewrite (big_sepS_delete _ (domm I) r); last by eauto.
    iFrame "Hstar'". iExists br, Cr, Br, Qr.
    iFrame "Hl_r Hlif_r".
    iExists γ_er, γ_cr, γ_br, γ_qr, γ_cirr, es, Ir, Rr.
    iFrame "#∗". iSplitR. rewrite decide_True; try done.
    rewrite (big_sepS_delete _ (KS) k); last by eauto. iFrame.

    iModIntro. wp_lam. awp_apply traverse_spec; try done.
    iAaccIntro with ""; try done.
    { eauto with iFrame. }    
    iIntros (t) "H'".
    iMod "AU" as "[_ [_ Hclose]]".
    iMod ("Hclose" with "H'") as "HΦ". 
    by iModIntro.
  Qed.

  Lemma search_spec N γ_te γ_he γ_s γ_t γ_I γ_J γ_f γ_gh γ_fr lc r 
                           (k: K) γ_td γ_ght:
  ⊢ ⌜k ∈ KS⌝ -∗ mcs_inv N γ_te γ_he γ_s γ_t γ_I γ_J γ_f γ_gh γ_fr lc r -∗
      helping_inv N γ_te γ_he γ_fr γ_td γ_ght -∗ 
      <<< ∀ t M, MCS_high γ_te γ_he t M >>>
            search' r #k @ ⊤ ∖ (↑(mcsN N) ∪ ↑(helpN N) ∪ ↑(threadN N))
      <<<  ∃ (t': nat), MCS_high γ_te γ_he t M ∗ ⌜M !!! k = t'⌝, RET #t' >>>.
  Proof.
    iIntros "% #HInv #HInv_h" (Φ) "AU". wp_lam.
    rename H into k_in_KS.
    wp_apply wp_new_proph1; try done.
    iIntros (tid vt)"Htid". wp_pures.
    wp_apply (typed_proph_wp_new_proph1 NatTypedProph); first done.
    iIntros (tp p)"Hproph". wp_pures. 
    iApply fupd_wp.
    iInv "HInv" as ">H".
    iDestruct "H" as (T H hγ I R) "(Hglob & Hstar)".
    iAssert (⌜∃ t0, ((k,t0) ∈ H ∧ (∀ t, (k,t) ∈ H → t ≤ t0) 
                ∧ map_of_set H !! k = Some t0)⌝)%I as "%".
    { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & #FP_r & Max_ts & domm_IR & domm_Iγ)".
      iAssert (⌜r ∈ domm I⌝)%I as "%". 
      { by iPoseProof (inFP_domm _ _ _ with "[$FP_r] [$Hf]") as "H'". }
      rename H0 into r_in_I.
      rewrite (big_sepS_delete _ (domm I) r); last by eauto.
      iDestruct "Hstar" as "(H_r & Hstar')".
      iDestruct "H_r" as (br Cr Br Qr)"(Hl_r & Hlif_r & HnS_r)".
      iDestruct "HnS_r" as (γ_er γ_cr γ_br γ_qr γ_cirr es Ir Rr) 
                        "(#HnS_gh & HnS_frac & HnS_si & HnS_FP 
                                  & HnS_cl & HnS_oc & HnS_H & HnS_star & Hφ)".
      iEval (rewrite decide_True) in "HnS_H".
      iDestruct "HnS_H" as "(% & %)".
      rename H0 into Br_eq_H. rename H1 into Infz_Ir.
      pose proof (map_of_set_lookup_cases H k) as H'.
      destruct H' as [H' | H'].
      - destruct H' as [t0 [H' [H'' H''']]].
        iPureIntro. exists t0; split; try done.
      - iDestruct "Hist" as %Hist.
        destruct H' as [H' _].
        pose proof H' 0 as H'.
        pose proof Hist k k_in_KS as Hist.
        contradiction. }  

    destruct H0 as [t0 [kt0_in_H [Max_t0 H_k]]].
    iDestruct "Hglob" as "(MCS_auth & HH & Hglob')".
    iMod (own_update γ_s (● H) (● H ⋅ ◯ {[(k,t0)]}) with "[$HH]") as "HH".
    { apply (auth_update_frac_alloc _ H ({[(k,t0)]})).
      apply gset_included. clear -kt0_in_H. set_solver. }
    iDestruct "HH" as "(HH & #mcs_sr)".
    iAssert (global_state γ_te γ_he γ_s γ_t γ_I γ_J γ_f γ_gh γ_fr 
                     r T H hγ I R)%I with "[$MCS_auth $HH $Hglob']" as "Hglob".
                     
    destruct (decide (tp ≤ t0)).
    - assert ((tp < t0) ∨ tp = t0) as H' by lia.
      destruct H' as [Hcase' | Hcase'].
      + iModIntro. iSplitR "AU Hproph".
        iNext; iExists T, H, hγ, I, R; iFrame.
        iModIntro.
        awp_apply search_recency; try done.
        iAaccIntro with ""; try done.
        { iIntros "_". iModIntro; try eauto with iFrame. } 
        iIntros (t) "(Hkt & %)". rename H0 into t0_le_t.
        iModIntro. wp_pures.
        wp_apply (typed_proph_wp_resolve1 NatTypedProph with "Hproph"); try done.
        wp_pures. iModIntro. iIntros "%". rename H0 into tp_eq_t.
        clear -tp_eq_t Hcase' t0_le_t. exfalso; lia.
      + iMod "AU" as (T' M) "[MCS_high [_ Hcomm]]".
        set_solver.
        iAssert (⌜T' = T ∧ M = map_of_set H⌝)%I as "%". 
        { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & Ht & HI & Out_I & HR 
            & Out_J & Inf_J & Hf & Hγ & FP_r & Max_ts & domm_IR & domm_Iγ)".
          iDestruct "MCS_high" as (H')"(MCS & %)".  
          iPoseProof ((auth_agree' γ_he) with "[MCS_auth] [MCS]") as "%".
          unfold MCS_auth. by iDestruct "MCS_auth" as "(_ & H'')".
          by iDestruct "MCS" as "(_ & H')". subst H'.
          iPoseProof ((auth_agree γ_te) with "[MCS_auth] [MCS]") as "%".
          unfold MCS_auth. by iDestruct "MCS_auth" as "(H'' & _)".
          by iDestruct "MCS" as "(H' & _)".
          by iPureIntro. } 
        destruct H0 as [H' M_eq_H]. subst T'.
        assert (M !!! k = t0) as M_k.
        { rewrite lookup_total_alt. rewrite M_eq_H H_k.
          by simpl. }
        iSpecialize ("Hcomm" $! t0). 
        iMod ("Hcomm" with "[MCS_high]") as "HΦ".
        { iFrame. by iPureIntro. } 
        iModIntro. iSplitR "HΦ Hproph".
        iNext; iExists T, H, hγ, I, R; iFrame.
        iModIntro.
        awp_apply search_recency without "HΦ"; try done.
        iAaccIntro with ""; try done.
        { iIntros "_". iModIntro; try eauto with iFrame. } 
        iIntros (t) "(Hkt & %)". rename H0 into t0_le_t.
        iModIntro. iIntros "HΦ". wp_pures.
        wp_apply (typed_proph_wp_resolve1 NatTypedProph with "Hproph"); try done.
        wp_pures. iModIntro. iIntros "%". rename H0 into tp_eq_t. 
        wp_pures. iModIntro.
        assert (tp = t) as H' by lia.
        rewrite <-H'. by rewrite Hcase'.
    - assert (tp > t0) by lia. rename H0 into tp_ge_t0.
      iInv "HInv_h" as (H' TD hγt)"(>Hfr & >HTD & >Hγt & >Domm_hγt & Hstar_reg)".
      iAssert (⌜H' = H⌝)%I as "%". 
      { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & _ )". 
        iPoseProof (own_valid_2 _ _ _ with "[$HfrH] [$Hfr]") as "V_H".
        iDestruct "V_H" as %V_H.
        apply frac_agree_op_valid in V_H. destruct V_H as [_ V_H].
        apply leibniz_equiv_iff in V_H.
        by iPureIntro. } subst H'.
      iAssert (▷ (⌜tid ∉ TD⌝ 
                ∗ ([∗ set] t_id ∈ TD, registered N γ_te γ_he γ_ght H t_id) 
                ∗ proph1 tid vt))%I with "[Hstar_reg Htid]" 
                as "(>% & Hstar_reg & Htid)".
      { destruct (decide (tid ∈ TD)); try done.
        - iEval (rewrite (big_sepS_elem_of_acc _ (TD) tid); 
                                last by eauto) in "Hstar_reg".
          iDestruct "Hstar_reg" as "(Hreg & Hstar_reg')".
          iDestruct "Hreg" as (? ? ? ? ? ? ?)"(H' & _)".
          iAssert (▷ False)%I with "[H' Htid]" as "HF".
          iApply (proph1_exclusive tid with "[Htid]"); try done.
          iNext. iExFalso; try done.
        - iFrame. iNext. by iPureIntro. }
      rename H0 into tid_notin_TD.
      iMod (own_update γ_td (● TD) (● (TD ∪ {[tid]})) with "[$HTD]") as "HTD".
      { apply (auth_update_auth _ _ (TD ∪ {[tid]})).
        apply gset_local_update. set_solver. }
      iMod (own_update γ_td (● (TD ∪ {[tid]})) (● (TD ∪ {[tid]}) ⋅ ◯ {[tid]}) 
                with "[$HTD]") as "(HTD & #FP_t)".
      { apply (auth_update_frac_alloc _ (TD ∪ {[tid]}) ({[tid]})).
        apply gset_included. clear; set_solver. }

      iMod (own_alloc (to_frac_agree (1) (H))) 
              as (γ_sy)"Hfr_t". { try done. }        
      iEval (rewrite <-Qp_half_half) in "Hfr_t".      
      iEval (rewrite (frac_agree_op (1/2) (1/2) _)) in "Hfr_t". 
      iDestruct "Hfr_t" as "(Hreg_sy1 & Hreg_sy2)".
      
      iDestruct "Domm_hγt" as %Domm_hγt.
      set (<[ tid := to_agree γ_sy ]> hγt) as hγt'.
      iDestruct (own_update _ _ 
        (● hγt' ⋅ ◯ {[ tid := to_agree γ_sy ]})
               with "Hγt") as ">Hγt".
      { apply auth_update_alloc. 
        rewrite /hγt'.
        apply alloc_local_update; last done.
        rewrite <-Domm_hγt in tid_notin_TD.
        by rewrite not_elem_of_dom in tid_notin_TD*; 
        intros tid_notin_TD. }
      iDestruct "Hγt" as "(Hγt & #Hreg_gh)".  
                  
      iDestruct (laterable with "AU") as (AU_later) "[AU #AU_back]".
      iMod (own_alloc (Excl ())) as (γ_tk') "Token"; first try done.
      assert ((k,tp) ∉ H) as ktp_notin_H. 
      { destruct (decide ((k, tp) ∈ H)); try done.
        pose proof Max_t0 tp e as H'.
        clear -H' tp_ge_t0. lia. } 
      iMod (inv_alloc (threadN N) _
              (∃ H, get_op_state γ_sy tid γ_tk' AU_later (Φ) H k tp) 
                                    with "[AU Hreg_sy1]") as "#HthInv".
      { iNext. iExists H. unfold get_op_state. iFrame "Hreg_sy1".
        iLeft. unfold state_lin_pending. iFrame. by iPureIntro. }

      iModIntro. iSplitL "Htid Hfr Hstar_reg HTD Hγt Hreg_sy2". iNext.
      iExists H, (TD ∪ {[tid]}), hγt'. iFrame.
      iSplitR. iPureIntro. subst hγt'.
      apply leibniz_equiv. rewrite dom_insert.
      rewrite Domm_hγt. clear; set_solver.
      rewrite (big_sepS_delete _ (TD ∪ {[tid]}) tid); last by set_solver.
      iSplitR "Hstar_reg". unfold registered.
      iExists AU_later, Φ, k, tp, vt, γ_tk', γ_sy. iFrame "∗#".
      assert ((TD ∪ {[tid]}) ∖ {[tid]} = TD) as H' 
                  by (clear -tid_notin_TD; set_solver).
      by rewrite H'.
      
      iModIntro. iSplitR "Token Hproph".
      iNext. iExists T, H, hγ, I, R; iFrame.
      
      iModIntro. awp_apply search_recency; try done.
      iAaccIntro with ""; try done.
      { iIntros "_". iModIntro; try eauto with iFrame. } 
      iIntros (t) "(#Hkt & %)". rename H0 into t0_le_t.
      iModIntro. wp_pures.
      wp_apply (typed_proph_wp_resolve1 NatTypedProph with "Hproph"); try done.
      wp_pures. iModIntro. iIntros "%". rename H0 into tp_eq_t.
      iApply fupd_wp.
      iInv "HthInv" as (H1)"(>Hth_sy & Hth_or)".
      iInv "HInv_h" as (H1' TD1 hγt1)"(>Hfr & >HTD & >Hγt & >Domm_hγt & Hstar_reg)".
      iAssert (⌜tid ∈ TD1⌝)%I as "%".
      { iPoseProof (own_valid_2 _ _ _ with "[$HTD] [$FP_t]") as "H'".
        iDestruct "H'" as %H'.
        apply auth_both_valid_discrete in H'.
        destruct H' as [H' _].
        apply gset_included in H'.
        iPureIntro. set_solver. }
        
      iAssert (▷ (⌜H1' = H1⌝
               ∗ ([∗ set] t_id ∈ TD1, registered N γ_te γ_he γ_ght H1' t_id)
               ∗ own (γ_sy) (to_frac_agree (1 / 2) H1) ))%I
                with "[Hstar_reg Hth_sy]" as "(>% & Hstar_reg & >Hth_sy)". 
      { iEval (rewrite (big_sepS_elem_of_acc _ (TD1) tid); 
                                last by eauto) in "Hstar_reg".
        iDestruct "Hstar_reg" as "(Hreg_t & Hstar_reg')".
        iDestruct "Hreg_t" as (P' Q' k' vp' vt' γ_tk'' γ_sy')
                          "(Hreg_proph & >Hreg_gh' & >Hreg_sy & Ht_reg')".

        iCombine "Hreg_gh" "Hreg_gh'" as "H".
        iPoseProof (own_valid with "H") as "Valid".
        iDestruct "Valid" as %Valid.
        rewrite auth_frag_valid in Valid *; intros Valid.
        apply singleton_valid in Valid.
        apply to_agree_op_inv in Valid.
        apply leibniz_equiv in Valid.
        subst γ_sy'.
                  
        iAssert (⌜H1' = H1⌝)%I as "%".
        { iPoseProof (own_valid_2 _ _ _ with "[$Hth_sy] [$Hreg_sy]") as "V_H".
          iDestruct "V_H" as %V_H.
          apply frac_agree_op_valid in V_H. destruct V_H as [_ V_H].
          apply leibniz_equiv_iff in V_H.
          by iPureIntro. } subst H1'.
        iSplitR. iNext; by iPureIntro.
        iSplitR "Hth_sy". iApply "Hstar_reg'".
        iNext. iExists P', Q', k', vp', vt', γ_tk'', γ_sy.
        iFrame "∗#". by iNext. } subst H1'.
      iInv "HInv" as ">H".
      iDestruct "H" as (T1 H1' hγ1 I1 R1) "(Hglob & Hstar)".
      iAssert (⌜H1' = H1⌝)%I as "%". 
      { iDestruct "Hglob" as "(MCS_auth & HH & Hist & HfrH & _ )". 
        iPoseProof (own_valid_2 _ _ _ with "[$HfrH] [$Hfr]") as "V_H".
        iDestruct "V_H" as %V_H.
        apply frac_agree_op_valid in V_H. destruct V_H as [_ V_H].
        apply leibniz_equiv_iff in V_H.
        by iPureIntro. } subst H1'.
      assert (tp = t) as H' by lia. 
      iAssert (⌜(k,tp) ∈ H1⌝)%I as "%". 
      { iDestruct "Hglob" as "(MCS_auth & HH & Hglob')".
        iPoseProof (own_valid_2 _ _ _ with "[$HH] [$Hkt]") as "H'".
        iDestruct "H'" as %H''.
        apply auth_both_valid_discrete in H''.
        destruct H'' as [H'' _].
        apply gset_included in H''.
        rewrite <-H' in H''.
        iPureIntro; clear -H''; set_solver. }
      rename H0 into ktp_in_H1.
      iDestruct "Hth_or" as "[Hth_or | Hth_or]".
      { iDestruct "Hth_or" as "(? & >%)".
        exfalso. try done. }
      iDestruct "Hth_or" as "(Hth_or & >%)".  
      iDestruct "Hth_or" as "[Hth_or | >Hth_or]"; last first.
      { iPoseProof (own_valid_2 _ _ _ with "[$Token] [$Hth_or]") as "%".
        exfalso; try done. }
      
      iModIntro. iSplitL "Hglob Hstar".
      iExists T1, H1, hγ1, I1, R1; iFrame.

      iModIntro. iSplitL "Hstar_reg HTD Hfr Hγt Domm_hγt".
      iNext. iExists H1, TD1, hγt1; iFrame.
      
      iModIntro. iSplitL "Token Hth_sy".
      iNext. iExists H1. iFrame "Hth_sy". 
      iRight. iFrame "∗%".
      
      iModIntro. wp_pures. by rewrite H'.
  Qed.      

  
End search_proof.
