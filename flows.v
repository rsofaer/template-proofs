From iris.program_logic Require Export weakestpre.
From iris.base_logic.lib Require Export invariants.
From iris.proofmode Require Import tactics.
From iris.heap_lang Require Import proofmode.
From iris.heap_lang Require Import notation lang.
From iris.heap_lang.lib Require Import par.
From iris.algebra Require Export auth agree.

From stdpp Require Export gmap.
From stdpp Require Import mapset.
From stdpp Require Import finite.
Require Export ccm gmap_more.

Require Import Coq.Setoids.Setoid.

(* ---------- Flow Interface encoding and camera definitions ---------- *)

Definition Node := positive.

Parameter FlowDom: CCM.

Definition flowdom := @ccm_car FlowDom.
Local Notation "x + y" := (@ccm_op FlowDom x y).
Local Notation "x - y" := (@ccm_opinv FlowDom x y).
Local Notation "0" := (@ccm_unit FlowDom).


Record flowintR :=
  {
    infR : gmap Node flowdom;
    outR : gmap Node flowdom;
  }.

Inductive flowintT :=
| int: flowintR → flowintT
| intUndef: flowintT.

Definition I_emptyR := {| infR := ∅; outR := ∅ |}.
Definition I_empty := int I_emptyR.
Instance flowint_empty : Empty flowintT := I_empty.


Definition out_map (I: flowintT) :=
  match I with
    | int Ir => outR Ir
    | intUndef => ∅
  end.

Definition inf_map (I: flowintT) :=
  match I with
    | int Ir => infR Ir
    | intUndef => ∅
  end.

Definition inf (I: flowintT) (n: Node) := default 0 (inf_map I !! n).
Definition out (I: flowintT) (n: Node) := default 0 (out_map I !! n).

Instance flowint_dom : Dom flowintT (gset Node) :=
  λ I, dom (gset Node) (inf_map I).
Definition domm (I : flowintT) := dom (gset Node) I.

Instance flowint_elem_of : ElemOf Node flowintT :=
  λ n I, n ∈ domm I.

(* Composition and proofs - some of these have counterparts in flows.spl in GRASShopper *)

Instance flowdom_eq_dec: EqDecision flowdom.
Proof.
  apply (@ccm_eq FlowDom).
Qed.

Canonical Structure flowintRAC := leibnizO flowintT.

Instance int_eq_dec: EqDecision flowintT.
Proof.
  unfold EqDecision.
  unfold Decision.
  repeat decide equality.
  all: apply gmap_eq_eq.
Qed.

Instance flowint_valid : Valid flowintT :=
  λ I, match I with
       | int Ir =>
         infR Ir ##ₘ outR Ir
         ∧ (infR Ir = ∅ → outR Ir = ∅)
       | intUndef => False
       end.

Instance flowint_valid_dec : ∀ I: flowintT, Decision (✓ I).
Proof.
  intros.
  unfold valid; unfold flowint_valid.
  destruct I; last first.
  all: solve_decision.
Qed.

Definition intComposable (I1: flowintT) (I2: flowintT) :=
  ✓ I1 ∧ ✓ I2 ∧
  domm I1 ## domm I2 ∧
  map_Forall (λ (n: Node) (m: flowdom), inf I1 n = out I2 n + (inf I1 n - out I2 n)) (inf_map I1) ∧
  map_Forall (λ (n: Node) (m: flowdom), inf I2 n = out I1 n + (inf I2 n - out I1 n)) (inf_map I2).

Instance intComposable_dec (I1 I2: flowintT) : Decision (intComposable I1 I2).
Proof. solve_decision. Qed.

Instance intComp : Op flowintT :=
  λ I1 I2, if decide (intComposable I1 I2) then
             let f_inf n o1 o2 :=
                 match o1, o2 with
                 | Some m1, _ => Some (m1 - out I2 n)
                 | _, Some m2 => Some (m2 - out I1 n)
                 | _, _ => None
                 end
             in
             let inf12 := gmap_imerge f_inf (inf_map I1) (inf_map I2) in
             let f_out n o1 o2 : option flowdom :=
                 match o1, o2 with
                 | Some m1, None =>
                   if gset_elem_of_dec n (domm I2) then None else Some m1
                 | None, Some m2 =>
                   if gset_elem_of_dec n (domm I1) then None else Some m2
                 | Some m1, Some m2 => Some (m1 + m2)
                 | _, _ => None
                 end
             in
             let out12 := gmap_imerge f_out (out_map I1) (out_map I2) in
             int {| infR := inf12; outR := out12 |}
           else if decide (I1 = ∅) then I2
           else if decide (I2 = ∅) then I1
           else intUndef.

Lemma intEmp_valid : ✓ I_empty.
Proof.
  unfold valid.
  unfold flowint_valid.
  unfold I_empty.
  simpl.
  split.
  refine (map_disjoint_empty_l _).
  trivial.
Qed.

Lemma intUndef_not_valid : ¬ ✓ intUndef.
Proof. unfold valid, flowint_valid; auto. Qed.

Lemma intComposable_invalid : ∀ I1 I2, ¬ ✓ I1 → ¬ (intComposable I1 I2).
Proof.
  intros.
  unfold intComposable.
  unfold not.
  intros H_false.
  destruct H_false as [H_false _].
  now contradict H_false.
Qed.

Lemma intComp_invalid : ∀ I1 I2: flowintT, ¬ ✓ I1 → ¬ ✓ (I1 ⋅ I2).
Proof.
  intros.
  unfold op, intComp.
  rewrite decide_False; last by apply intComposable_invalid.
  rewrite decide_False; last first.
  unfold not; intros H_false.
  contradict H.
  rewrite H_false.
  apply intEmp_valid.
  destruct (decide (I2 = ∅)).
  auto.
  apply intUndef_not_valid.
Qed.


Lemma intComp_undef_op : ∀ I, intUndef ⋅ I ≡ intUndef.
Proof.
  intros.
  unfold op; unfold intComp.
  rewrite decide_False.
  unfold empty.
  unfold flowint_empty.
  rewrite decide_False.
  destruct (decide (I = I_empty)).
  1, 2: trivial.
  discriminate.
  unfold intComposable.
  cut (¬ (✓ intUndef)); intros.
  rewrite LeftAbsorb_instance_0.
  trivial.
  unfold valid; unfold flowint_valid.
  auto.
Qed.

Lemma intComp_unit : ∀ (I: flowintT), ✓ I → I ⋅ I_empty ≡ I.
Proof.
  intros.
  unfold op, intComp.
  simpl.
  repeat rewrite gmap_imerge_empty.
  destruct I as [Ir|].
  destruct (decide (intComposable (int Ir) I_empty)).
  - (* True *)
    destruct Ir.
    simpl.
    auto.
  - (* False *)
    unfold empty, flowint_empty.
    destruct (decide (int Ir = I_empty)).
    auto.
    rewrite decide_True.
    all: auto.
  - unfold intComposable.
    rewrite decide_False.
    rewrite decide_False.
    rewrite decide_True.
    all: auto.
  - intros.
    case y.
    2: auto.
    intros.
    case (gset_elem_of_dec i (domm I_empty)).
    2: auto.
    intros H_false; contradict H_false.
    unfold domm.
    replace I_empty with (empty : flowintT).
    replace (dom (gset Node) empty) with (empty : gset Node).
    apply not_elem_of_empty.
    symmetry.
    apply dom_empty_L.
    unfold empty.
    unfold flowint_empty.
    reflexivity.
  - intros.
    case y.
    intros.
    unfold out.
    rewrite lookup_empty.
    simpl.
    rewrite ccm_pinv_unit.
    all: easy.
Qed.

Lemma intComposable_comm_1 : ∀ (I1 I2 : flowintT), intComposable I1 I2 → intComposable I2 I1.
Proof.
  intros.
  unfold intComposable.
  repeat split.
  3: apply disjoint_intersection; rewrite intersection_comm_L; apply disjoint_intersection.
  unfold intComposable in H.
  all: try apply H.
Qed.

Lemma intComposable_comm : ∀ (I1 I2 : flowintT), intComposable I1 I2 ↔ intComposable I2 I1.
Proof.
  intros. split.
  all: refine (intComposable_comm_1 _ _).
Qed.

Lemma intComp_dom : ∀ I1 I2 I, ✓ I → I = I1 ⋅ I2 → domm I = domm I1 ∪ domm I2.
Proof.
  intros I1 I2 I H_valid H_comp_eq.
  unfold domm.
  set_unfold.
  intros.
  unfold dom.
  rewrite ?elem_of_dom.
  rewrite H_comp_eq.
  unfold op, intComp.
  case_eq (decide (intComposable I1 I2)).
  - intros H_comp H_comp_dec.
    rewrite gmap_imerge_prf; auto.
    case_eq (inf_map I1 !! x).
    + intros ? H1.
      rewrite H1.
      rewrite ?is_Some_alt; simpl.
      naive_solver.
    + intros H1.
      rewrite H1.
      case_eq (inf_map I2 !! x).
      * intros ? H2.
        rewrite H2.
        rewrite ?is_Some_alt; simpl.
        naive_solver.
      * intros H2.
        rewrite H2.
        split.
        apply or_introl.
        intros.
        destruct H.
        all: auto.
  - intros.
    case_eq (decide (I1 = ∅)).
    + intros H1 H1_dec.
      rewrite H1.
      simpl.
      rewrite lookup_empty.
      split.
      apply or_intror.
      intros H_or; destruct H_or as [H_false | H2].
      contradict H_false.
      exact is_Some_None.
      exact H2.
    + intros H1 H1_dec.
      case_eq (decide (I2 = ∅)).
      * intros H2 H2_dec.
        rewrite H2; simpl.
        rewrite lookup_empty.
        split.
        apply or_introl.
        intros H_or; destruct H_or.
        assumption.
        contradict H0.
        exact is_Some_None.
      * intros H2 H2_dec.
        contradict H_valid.
        rewrite H_comp_eq.
        unfold op, intComp.
        rewrite H. rewrite H1_dec. rewrite H2_dec.
        exact intUndef_not_valid.
Qed.

Lemma intComp_comm : ∀ (I1 I2: flowintT), I1 ⋅ I2 ≡ I2 ⋅ I1.
Proof.
  intros.
  cut (∀ I, intUndef ⋅ I ≡ I ⋅ intUndef).
  intros H_undef_comm.
  destruct I1 as [ir1|] eqn:H_eq1, I2 as [ir2|] eqn:H_eq2; revgoals.
  all: try rewrite H_undef_comm; auto.
  unfold op, intComp; simpl.
  case_eq (decide (intComposable (int ir1) (int ir2))).
  - (* if composable *)
    intros H_comp H_comp_dec.
    rewrite decide_True; last rewrite intComposable_comm; auto.
    f_equal.
    f_equal.
    + (* infR equality *)
      rewrite map_eq_iff.
      intros.
      repeat rewrite gmap_imerge_prf; auto.
      case_eq (infR ir1 !! i).
      all: case_eq (infR ir2 !! i).
      * (* i in both *)
        intros f1 H_lookup2 f2 H_lookup1.
        exfalso.
        generalize H_comp.
        unfold intComposable.
        intros (_ & _ & H_false & _).
        unfold domm, dom, flowint_dom in H_false.
        simpl in *.
        rewrite <- map_disjoint_dom in H_false.
        generalize H_false. clear H_false.
        rewrite map_disjoint_alt.
        intros H_false.
        assert (H_contra := H_false i).
        destruct H_contra.
        contradict H.
        now rewrite H_lookup1.
        contradict H.
        now rewrite H_lookup2.
      * (* in I1 but not in I2 *)
        intros H_lookup2 f1 H_lookup1.
        rewrite H_lookup1. rewrite H_lookup2.
        auto.
      * (* in I2 but not in I1 *)
        intros f2 H_lookup2 H_lookup1.
        rewrite H_lookup1. rewrite H_lookup2.
        auto.
      * (* in neither *)
        intros H_lookup2 H_lookup1.
        rewrite H_lookup1. rewrite H_lookup2.
        auto.
    + (* outR equality *)
      rewrite map_eq_iff.
      intros.
      rewrite ?gmap_imerge_prf.
      case_eq (outR ir1 !! i).
      all: auto.
      * intros f1 H_lookup1.
        rewrite H_lookup1.
        case_eq (outR ir2 !! i).
        intros f2 H_lookup2.
        rewrite H_lookup2.
        f_equal.
        apply ccm_comm.
        intros H_lookup2.
        rewrite H_lookup2.
        auto.
      * intros H_lookup1. rewrite H_lookup1.
        intuition.
  - (* if not composable *)
    intros H_not_comp H_not_comp_dec.
    symmetry.
    rewrite decide_False; last by rewrite intComposable_comm.
    case_eq (decide (int ir2 = ∅)).
    case_eq (decide (int ir1 = ∅)).
    all: auto.
    intros.
    now rewrite e e0.
  - (* proof of H_undef_comm *)
    intros.
    rewrite intComp_undef_op.
    unfold op, flowint_valid, intComp.
    rewrite decide_False.
    case (decide (I = ∅)).
    all: auto.
    intros _.
    rewrite decide_False.
    all: auto.
    unfold intComposable.
    rewrite ?not_and_l.
    right. left.
    exact intUndef_not_valid.
Qed.

Lemma intComp_unit2 : ∀ I : flowintT, ✓ I → I_empty ⋅ I ≡ I.
Proof.
  intros.
  rewrite intComp_comm.
  now apply intComp_unit.
Qed.

Lemma intComp_valid_proj1 : ∀ (I1 I2: flowintT), ✓ (I1 ⋅ I2) → ✓ I1.
Proof.
  intros I1 I2.
  rewrite <- Decidable.contrapositive.
  apply intComp_invalid.
  unfold Decidable.decidable.
  generalize (flowint_valid_dec I1).
  unfold Decision.
  intros.
  destruct H.
  all: auto.
Qed.

Lemma intComp_valid_proj2 : ∀ (I1 I2: flowintT), ✓ (I1 ⋅ I2) → ✓ I2.
Proof.
  intros I1 I2.
  rewrite intComp_comm.
  apply intComp_valid_proj1.
Qed.

Hypothesis intComp_assoc : ∀ (I1 I2 I3: flowintT), I1 ⋅ (I2 ⋅ I3) ≡ I1 ⋅ I2 ⋅ I3.

Instance flowintRAcore : PCore flowintT :=
  λ I, match I with
       | int Ir => Some I_empty
       | intUndef => Some intUndef
       end.

Instance flowintRAunit : cmra.Unit flowintT := I_empty.

Definition flowintRA_mixin : RAMixin flowintT.
Proof.
  split; try apply _; try done.
  - (* Core is unique? *)
    intros ? ? cx -> ?. exists cx. done.
  - (* Associativity *)
    unfold Assoc. eauto using intComp_assoc.
  - (* Commutativity *)
    unfold Comm. eauto using intComp_comm.
  - (* Core-ID *)
    intros x cx.
    destruct cx; unfold pcore, flowintRAcore; destruct x;
      try (intros H; inversion H).
    + rewrite intComp_comm. apply intComp_unit.
    + apply intComp_undef_op.
  - (* Core-Idem *)
    intros x cx.
    destruct cx; unfold pcore, flowintRAcore; destruct x;
      try (intros H; inversion H); try done.
  - (* Core-Mono *)
    intros x y cx.
    destruct cx; unfold pcore, flowintRAcore; destruct x; intros H;
      intros H1; inversion H1; destruct y; try eauto.
    + exists I_empty. split; try done.
      exists (int I_emptyR). by rewrite intComp_unit.
    + exists intUndef. split; try done. exists intUndef.
      rewrite intComp_comm. by rewrite intComp_unit.
    + exists I_empty. split; try done.
      destruct H as [a H].
      assert (intUndef ≡ intUndef ⋅ a); first by rewrite intComp_undef_op.
      rewrite <- H0 in H.
      inversion H.
  - (* Valid-Op *)
    intros x y. unfold valid. apply intComp_valid2.
Qed.


Canonical Structure flowintRA := discreteR flowintT flowintRA_mixin.

Instance flowintRA_cmra_discrete : CmraDiscrete flowintRA.
Proof. apply discrete_cmra_discrete. Qed.

Instance flowintRA_cmra_total : CmraTotal flowintRA.
Proof.
  rewrite /CmraTotal. intros. destruct x.
  - exists I_empty. done.
  - exists intUndef. done.
Qed.

Lemma flowint_ucmra_mixin : UcmraMixin flowintT.
Proof.
  split; try apply _; try done.
  - unfold ε, flowintRAunit, valid. apply intEmp_valid.
  - unfold LeftId. intros x. unfold ε, flowintRAunit. simpl.
    destruct x.
    + rewrite intComp_comm. by rewrite intComp_unit.
    + rewrite intComp_comm. by rewrite intComp_unit.
Qed.

Canonical Structure flowintUR : ucmraT := UcmraT flowintT flowint_ucmra_mixin.

Parameter contextualLeq : flowintUR → flowintUR → Prop.

Definition flowint_update_P (I I_n I_n': flowintUR) (x : authR flowintUR) : Prop :=
  match (auth_auth_proj x) with
  | Some (q, z) => ∃ I', (z = to_agree(I')) ∧ q = 1%Qp ∧ (I_n' = auth_frag_proj x)
                        ∧ contextualLeq I I' ∧ ∃ I_o, I = I_n ⋅ I_o ∧ I' = I_n' ⋅ I_o
  | _ => False
  end.

Hypothesis flowint_update : ∀ I I_n I_n',
  contextualLeq I_n I_n' → (● I ⋅ ◯ I_n) ~~>: (flowint_update_P I I_n I_n').
Lemma flowint_comp_fp : ∀ I1 I2 I, ✓I → I = I1 ⋅ I2 → domm I = domm I1 ∪ domm I2.
Proof.
  apply intComp_dom.
Qed.
