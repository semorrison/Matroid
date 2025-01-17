import Matroid.Rank

open Set

variable {α : Type _} {M N : Matroid α}

namespace Matroid

section Delete

variable {D D₁ D₂ : Set α}

class HasDelete (α β : Type _) where
  del : α → β → α

infixl:75 " ⟍ " => HasDelete.del

/-- The deletion `M ⟍ D` is the restriction of a matroid `M` to `M.E \ D`-/
def delete (M : Matroid α) (D : Set α) : Matroid α :=
  M ↾ (M.E \ D)

instance delSet {α : Type _} : HasDelete (Matroid α) (Set α) :=
  ⟨Matroid.delete⟩

instance delElem {α : Type _} : HasDelete (Matroid α) α :=
  ⟨fun M e ↦ M.delete {e}⟩

instance delete_finite [Finite M] : Finite (M ⟍ D) :=
  ⟨M.ground_finite.diff D⟩ 
  
instance delete_finiteRk [FiniteRk M] : FiniteRk (M ⟍ D) :=
  Matroid.restrict_finiteRk

theorem restrict_compl (M : Matroid α) (D : Set α) : M ↾ (M.E \ D) = M ⟍ D := rfl  

@[simp] theorem delete_compl (hR : R ⊆ M.E := by aesop_mat) : M ⟍ (M.E \ R) = M ↾ R := by 
  rw [←restrict_compl, diff_diff_cancel_left hR]

@[simp] theorem delete_restriction (M : Matroid α) (D : Set α) : M ⟍ D ≤r M :=
  restrict_restriction _ _ (diff_subset _ _)

@[simp] theorem delete_ground (M : Matroid α) (D : Set α) : (M ⟍ D).E = M.E \ D := rfl 
  
@[aesop unsafe 10% (rule_sets [Matroid])]
theorem delete_subset_ground (M : Matroid α) (D : Set α) : (M ⟍ D).E ⊆ M.E :=
  diff_subset _ _

@[simp] theorem delete_elem (M : Matroid α) (e : α) : M ⟍ e = M ⟍ ({e} : Set α) := rfl

@[simp] theorem delete_delete (M : Matroid α) (D₁ D₂ : Set α) : M ⟍ D₁ ⟍ D₂ = M ⟍ (D₁ ∪ D₂) := by
  rw [←restrict_compl, ←restrict_compl, ←restrict_compl, restrict_restrict_eq, restrict_ground_eq, 
    diff_diff]
  simp [diff_subset]
  
theorem delete_comm (M : Matroid α) (D₁ D₂ : Set α) : M ⟍ D₁ ⟍ D₂ = M ⟍ D₂ ⟍ D₁ := by
  rw [delete_delete, union_comm, delete_delete]

theorem delete_inter_ground_eq (M : Matroid α) (D : Set α) : M ⟍ (D ∩ M.E) = M ⟍ D := by
  rw [←restrict_compl, ←restrict_compl, diff_inter_self_eq_diff]  
  
theorem delete_eq_delete_iff : M ⟍ D₁ = M ⟍ D₂ ↔ D₁ ∩ M.E = D₂ ∩ M.E := by 
  rw [←delete_inter_ground_eq, ←M.delete_inter_ground_eq D₂]
  refine' ⟨fun h ↦ _, fun h ↦ by rw [h]⟩
  apply_fun (M.E \ Matroid.E ·) at h
  simp_rw [delete_ground, diff_diff_cancel_left (inter_subset_right _ _)] at h
  assumption

@[simp] theorem delete_eq_self_iff : M ⟍ D = M ↔ Disjoint D M.E := by
  rw [←restrict_compl, restrict_eq_self_iff, sdiff_eq_left, disjoint_comm]
  
@[simp] theorem delete_indep_iff : (M ⟍ D).Indep I ↔ M.Indep I ∧ Disjoint I D := by
  rw [←restrict_compl, restrict_indep_iff, subset_diff, ←and_assoc, 
    and_iff_left_of_imp Indep.subset_ground]
  
theorem Indep.of_delete (h : (M ⟍ D).Indep I) : M.Indep I :=
  (delete_indep_iff.mp h).1

theorem Indep.indep_delete_of_disjoint (h : M.Indep I) (hID : Disjoint I D) : (M ⟍ D).Indep I :=
  delete_indep_iff.mpr ⟨h, hID⟩

@[simp] theorem delete_dep_iff : (M ⟍ D).Dep X ↔ M.Dep X ∧ Disjoint X D := by
  rw [dep_iff, dep_iff, delete_indep_iff, delete_ground, subset_diff]; tauto
  
@[simp] theorem delete_base_iff : (M ⟍ D).Base B ↔ M.Basis B (M.E \ D) := by
  rw [←restrict_compl, base_restrict_iff]

@[simp] theorem delete_basis_iff : (M ⟍ D).Basis I X ↔ M.Basis I X ∧ Disjoint X D := by 
  rw [←restrict_compl, basis_restrict_iff, subset_diff, ←and_assoc, 
    and_iff_left_of_imp Basis.subset_ground]

theorem Basis.of_delete (h : (M ⟍ D).Basis I X) : M.Basis I X :=
  (delete_basis_iff.mp h).1

theorem Basis.to_delete (h : M.Basis I X) (hX : Disjoint X D) : (M ⟍ D).Basis I X := by
  rw [delete_basis_iff]; exact ⟨h, hX⟩

@[simp] theorem delete_loop_iff : (M ⟍ D).Loop e ↔ M.Loop e ∧ e ∉ D := by
  rw [←singleton_dep, delete_dep_iff, disjoint_singleton_left, singleton_dep]

@[simp] theorem delete_nonloop_iff : (M ⟍ D).Nonloop e ↔ M.Nonloop e ∧ e ∉ D := by
  rw [← indep_singleton, delete_indep_iff, disjoint_singleton_left, indep_singleton]

@[simp] theorem delete_circuit_iff : (M ⟍ D).Circuit C ↔ M.Circuit C ∧ Disjoint C D := by
  simp_rw [circuit_iff, delete_dep_iff, and_imp]
  rw [and_comm, ← and_assoc, and_congr_left_iff, and_comm, and_congr_right_iff]
  exact fun hdj _↦ ⟨fun h I hId hIC ↦ h hId (disjoint_of_subset_left hIC hdj) hIC, 
    fun h I hI _ hIC ↦ h hI hIC⟩   

@[simp] theorem delete_cl_eq (M : Matroid α) (D X : Set α) : (M ⟍ D).cl X = M.cl (X \ D) \ D := by 
  rw [←restrict_compl, restrict_cl_eq', sdiff_sdiff_self, bot_eq_empty, union_empty, 
    diff_eq, inter_comm M.E, ←inter_assoc X, ←diff_eq, ←cl_eq_cl_inter_ground, 
    ←inter_assoc, ←diff_eq, inter_eq_left]
  exact (diff_subset _ _).trans (M.cl_subset_ground _)

theorem delete_loops_eq (M : Matroid α) (D : Set α) : (M ⟍ D).cl ∅ = M.cl ∅ \ D := by
  simp  

@[simp] theorem delete_er_eq' (M : Matroid α) (D X : Set α) : (M ⟍ D).er X = M.er (X \ D) := by 
  rw [←restrict_compl, restrict_er_eq', diff_eq, inter_comm M.E, ←inter_assoc, ←diff_eq, 
    er_inter_ground_eq]

theorem delete_er_eq (M : Matroid α) (h : Disjoint X D) : (M ⟍ D).er X = M.er X := by 
  rwa [delete_er_eq', sdiff_eq_left.2]

theorem delete_er_eq_delete_er_diff (M : Matroid α) (D X : Set α) :
    (M ⟍ D).er X = (M ⟍ D).er (X \ D) := by
  simp
  
@[simp] theorem delete_rFin_iff : (M ⟍ D).rFin X ↔ M.rFin (X \ D) := by
  rw [←er_lt_top_iff, delete_er_eq', er_lt_top_iff]

@[simp] theorem delete_empty (M : Matroid α) : M ⟍ (∅ : Set α) = M := by 
  rw [delete_eq_self_iff]; exact empty_disjoint _

theorem delete_delete_diff (M : Matroid α) (D₁ D₂ : Set α) : M ⟍ D₁ ⟍ D₂ = M ⟍ D₁ ⟍ (D₂ \ D₁) :=
  by simp

/-- Deletions of isomorphic matroids are isomorphic. TODO : Actually define as a term. -/
noncomputable def Iso.delete {β : Type _} {N : Matroid β} (e : Iso M N) (hD : D ⊆ M.E) :
    Iso (M ⟍ D) (N ⟍ e '' D) := by
  convert Iso.restrict e (M.E \ D) using 1
  rw [e.injOn_ground.image_diff hD, e.image_ground, ←restrict_compl]
  
end Delete

section Contract

variable {C C₁ C₂ : Set α}

class HasContract (α β : Type _) where
  con : α → β → α

infixl:75 " ⟋ " => HasContract.con

/-- The contraction `M ⟋ C` is the matroid on `M.E \ C` whose bases are the sets `B \ I` where `B` 
  is a base for `M` containing a base `I` for `C`. It is also equal to the dual of `M﹡ ⟍ C`, and is defined this way so we don't have to give a separate proof that it is actually a matroid. -/
def contract (M : Matroid α) (C : Set α) : Matroid α :=
  (M﹡ ⟍ C)﹡

instance conSet {α : Type _} : HasContract (Matroid α) (Set α) :=
  ⟨Matroid.contract⟩

instance conElem {α : Type _} : HasContract (Matroid α) α :=
  ⟨fun M e ↦ M.contract {e}⟩

@[simp] theorem dual_delete_dual_eq_contract (M : Matroid α) (X : Set α) : (M﹡ ⟍ X)﹡ = M ⟋ X :=
  rfl

@[simp] theorem contract_ground (M : Matroid α) (C : Set α) : (M ⟋ C).E = M.E \ C := rfl

instance contract_finite [Finite M] : Finite (M ⟋ C) := by
  rw [← dual_delete_dual_eq_contract]; infer_instance

@[simp] theorem dual_contract_dual_eq_delete (M : Matroid α) (X : Set α) : (M﹡ ⟋ X)﹡ = M ⟍ X := by
  rw [← dual_delete_dual_eq_contract, dual_dual, dual_dual]

@[simp] theorem contract_dual_eq_dual_delete (M : Matroid α) (X : Set α) : (M ⟋ X)﹡ = M﹡ ⟍ X := by
  rw [← dual_delete_dual_eq_contract, dual_dual]

@[simp] theorem delete_dual_eq_dual_contract (M : Matroid α) (X : Set α) : (M ⟍ X)﹡ = M﹡ ⟋ X := by
  rw [← dual_delete_dual_eq_contract, dual_dual]

@[aesop unsafe 10% (rule_sets [Matroid])]
theorem contract_ground_subset_ground (M : Matroid α) (C : Set α) : (M ⟋ C).E ⊆ M.E :=
  (M.contract_ground C).trans_subset (diff_subset _ _)

@[simp] theorem contract_elem (M : Matroid α) (e : α) : M ⟋ e = M ⟋ ({e} : Set α) :=
  rfl

@[simp] theorem contract_contract (M : Matroid α) (C₁ C₂ : Set α) : M ⟋ C₁ ⟋ C₂ = M ⟋ (C₁ ∪ C₂) := by
  rw [eq_comm, ← dual_delete_dual_eq_contract, ← delete_delete, ← dual_contract_dual_eq_delete, ←
    dual_contract_dual_eq_delete, dual_dual, dual_dual, dual_dual]

theorem contract_comm (M : Matroid α) (C₁ C₂ : Set α) : M ⟋ C₁ ⟋ C₂ = M ⟋ C₂ ⟋ C₁ := by
  rw [contract_contract, union_comm, contract_contract]

theorem contract_eq_self_iff : M ⟋ C = M ↔ Disjoint C M.E := by
  rw [← dual_delete_dual_eq_contract, ← dual_inj_iff, dual_dual, delete_eq_self_iff, dual_ground]

@[simp] theorem contract_empty (M : Matroid α) : M ⟋ (∅ : Set α) = M := by
  rw [←dual_delete_dual_eq_contract, delete_empty, dual_dual]
  
theorem contract_contract_diff (M : Matroid α) (C₁ C₂ : Set α) :
    M ⟋ C₁ ⟋ C₂ = M ⟋ C₁ ⟋ (C₂ \ C₁) := by
  simp

theorem contract_eq_contract_iff : M ⟋ C₁ = M ⟋ C₂ ↔ C₁ ∩ M.E = C₂ ∩ M.E := by
  rw [← dual_delete_dual_eq_contract, ← dual_delete_dual_eq_contract, dual_inj_iff,
    delete_eq_delete_iff, dual_ground]

@[simp] theorem contract_inter_ground_eq (M : Matroid α) (C : Set α) : M ⟋ (C ∩ M.E) = M ⟋ C := by
  rw [← dual_delete_dual_eq_contract, (show M.E = M﹡.E from rfl), delete_inter_ground_eq]; rfl

theorem coindep_contract_iff : (M ⟋ C).Coindep X ↔ M.Coindep X ∧ Disjoint X C := by
  rw [coindep_def, contract_dual_eq_dual_delete, delete_indep_iff, ←coindep_def] 
    
theorem Coindep.coindep_contract_of_disjoint (hX : M.Coindep X) (hXC : Disjoint X C) :
    (M ⟋ C).Coindep X :=
  coindep_contract_iff.mpr ⟨hX, hXC⟩

theorem Indep.contract_base_iff (hI : M.Indep I) : 
    (M ⟋ I).Base B ↔ M.Base (B ∪ I) ∧ Disjoint B I := by
  have hIE := hI.subset_ground
  rw [← dual_dual M, ←coindep_def, coindep_iff_exists] at hI 
  obtain ⟨B₀, hB₀, hfk⟩ := hI
  rw [←dual_dual M, ←dual_delete_dual_eq_contract, dual_base_iff', dual_base_iff', 
    delete_base_iff, dual_dual, delete_ground, diff_diff, union_comm, union_subset_iff, 
    subset_diff, ←and_assoc, and_congr_left_iff, dual_ground, and_iff_left hIE, and_congr_left_iff]
  refine' fun _ _ ↦
    ⟨fun h ↦ h.base_of_base_subset hB₀ (subset_diff.mpr ⟨hB₀.subset_ground, _⟩), fun hB ↦
      hB.basis_of_subset (diff_subset _ _) (diff_subset_diff_right (subset_union_right _ _))⟩
  exact disjoint_of_subset_left hfk disjoint_sdiff_left
  
theorem Indep.contract_indep_iff (hI : M.Indep I) :
    (M ⟋ I).Indep J ↔ Disjoint J I ∧ M.Indep (J ∪ I) := by
  simp_rw [indep_iff_subset_base, hI.contract_base_iff, union_subset_iff]
  exact ⟨fun ⟨B, ⟨hBI, hdj⟩, hJB⟩ ↦ 
    ⟨disjoint_of_subset_left hJB hdj, _, hBI, hJB.trans (subset_union_left _ _), 
      subset_union_right _ _⟩, 
    fun ⟨hdj, B, hB, hJB, hIB⟩ ↦ ⟨B \ I,⟨by simpa [union_eq_self_of_subset_right hIB],
      disjoint_sdiff_left⟩, subset_diff.2 ⟨hJB, hdj⟩ ⟩⟩

theorem Indep.union_indep_iff_contract_indep (hI : M.Indep I) :
    M.Indep (I ∪ J) ↔ (M ⟋ I).Indep (J \ I) := by
  rw [hI.contract_indep_iff, and_iff_right disjoint_sdiff_left, diff_union_self, union_comm]

theorem Indep.diff_indep_contract_of_subset (hJ : M.Indep J) (hIJ : I ⊆ J) :
    (M ⟋ I).Indep (J \ I) := by
  rwa [← (hJ.subset hIJ).union_indep_iff_contract_indep, union_eq_self_of_subset_left hIJ]

theorem Indep.contract_dep_iff (hI : M.Indep I) :
    (M ⟋ I).Dep J ↔ Disjoint J I ∧ M.Dep (J ∪ I) := by
  rw [dep_iff, hI.contract_indep_iff, dep_iff, contract_ground, subset_diff, disjoint_comm,
    union_subset_iff, and_iff_left hI.subset_ground]
  tauto

theorem Indep.union_contract_basis_union_of_basis (hI : M.Indep I) (hB : (M ⟋ I).Basis J X) :
    M.Basis (J ∪ I) (X ∪ I) := by
  have hi := hB.indep
  rw [hI.contract_indep_iff] at hi 
  refine' hi.2.basis_of_maximal_subset (union_subset_union_left _ hB.subset) _ _
  · intro K hK hJIK hKXI
    rw [union_subset_iff] at hJIK 
    have hK' : (M ⟋ I).Indep (K \ I) := hK.diff_indep_contract_of_subset hJIK.2
    have hm := hB.eq_of_subset_indep hK'
    rw [subset_diff, and_iff_left hi.1, diff_subset_iff, union_comm, imp_iff_right hKXI,
      imp_iff_right hJIK.1] at hm 
    simp [hm]
  exact union_subset (hB.subset_ground.trans (contract_ground_subset_ground _ _)) hI.subset_ground

theorem Basis.contract_basis_union_union (h : M.Basis (J ∪ I) (X ∪ I)) (hdj : Disjoint (J ∪ X) I) :
    (M ⟋ I).Basis J X := by
  rw [disjoint_union_left] at hdj 
  have hI := h.indep.subset (subset_union_right _ _)
  simp_rw [Basis, mem_maximals_setOf_iff, hI.contract_indep_iff, and_iff_right hdj.1,
    and_iff_right h.indep, contract_ground, subset_diff, and_iff_left hdj.2,
    and_iff_left ((subset_union_left _ _).trans h.subset_ground), and_imp,
    and_iff_right
      (Disjoint.subset_left_of_subset_union ((subset_union_left _ _).trans h.subset) hdj.1)]
  intro Y hYI hYi hYX hJY
  have hu :=
    h.eq_of_subset_indep hYi (union_subset_union_left _ hJY) (union_subset_union_left _ hYX)
  apply_fun fun x : Set α ↦ x \ I at hu 
  simp_rw [union_diff_right, hdj.1.sdiff_eq_left, hYI.sdiff_eq_left] at hu 
  exact hu

theorem contract_eq_delete_of_subset_coloops (hX : X ⊆ M﹡.cl ∅) : M ⟋ X = M ⟍ X := by
  refine' eq_of_indep_iff_indep_forall rfl fun I _ ↦ _
  rw [(indep_of_subset_coloops hX).contract_indep_iff, delete_indep_iff, and_comm,
    union_indep_iff_indep_of_subset_coloops hX]

theorem contract_eq_delete_of_subset_loops (hX : X ⊆ M.cl ∅) : M ⟋ X = M ⟍ X := by
  rw [← dual_inj_iff, contract_dual_eq_dual_delete, delete_dual_eq_dual_contract, eq_comm,
    contract_eq_delete_of_subset_coloops]
  rwa [dual_dual]

theorem Basis.contract_eq_contract_delete (hI : M.Basis I X) : M ⟋ X = M ⟋ I ⟍ (X \ I) := by
  nth_rw 1 [← diff_union_of_subset hI.subset]
  rw [union_comm, ← contract_contract]
  refine' contract_eq_delete_of_subset_loops fun e he ↦ _
  rw [← loop_iff_mem_cl_empty, ←singleton_dep, hI.indep.contract_dep_iff,
    disjoint_singleton_left, and_iff_right he.2, singleton_union, 
    ←hI.indep.mem_cl_iff_of_not_mem he.2]
  exact hI.subset_cl he.1
  
theorem Basis'.contract_eq_contract_delete (hI : M.Basis' I X) : M ⟋ X = M ⟋ I ⟍ (X \ I) := by 
  rw [←contract_inter_ground_eq, hI.basis_inter_ground.contract_eq_contract_delete, eq_comm, 
    ←delete_inter_ground_eq, contract_ground, diff_eq, diff_eq, ←inter_inter_distrib_right, 
    ←diff_eq]

theorem contract_cl_eq_contract_delete (M : Matroid α) (C : Set α) :
    M ⟋ M.cl C = M ⟋ C ⟍ (M.cl C \ C) := by
  obtain ⟨I, hI⟩ := M.exists_basis_inter_ground_basis_cl C
  rw [hI.2.contract_eq_contract_delete, ←M.contract_inter_ground_eq C, 
    hI.1.contract_eq_contract_delete, delete_delete]
  convert rfl using 2
  rw [union_comm, diff_eq (t := I), union_distrib_left, union_distrib_left, diff_union_self, 
    union_eq_self_of_subset_left ((diff_subset _ _).trans (M.cl_subset_ground _)), 
      inter_distrib_right, diff_eq, inter_eq_self_of_subset_left (M.cl_subset_ground _), 
      cl_eq_cl_inter_ground, union_eq_self_of_subset_right (M.subset_cl (C ∩ M.E)), 
      inter_distrib_left, ←inter_assoc, inter_self, ←inter_distrib_left, ←compl_inter, 
      ←diff_eq, inter_eq_self_of_subset_right (hI.1.subset.trans (inter_subset_left _ _))]
    
theorem exists_eq_contract_indep_delete (M : Matroid α) (C : Set α) :
    ∃ I D : Set α, M.Basis I (C ∩ M.E) ∧ D ⊆ (M ⟋ I).E ∧ D ⊆ C ∧ M ⟋ C = M ⟋ I ⟍ D := by
  obtain ⟨I, hI⟩ := M.exists_basis (C ∩ M.E)
  use I, C \ I ∩ M.E, hI
  rw [contract_ground, and_iff_right ((inter_subset_left _ _).trans (diff_subset _ _)), diff_eq,
    diff_eq, inter_right_comm, inter_assoc, and_iff_right (inter_subset_right _ _),
    ←contract_inter_ground_eq, hI.contract_eq_contract_delete, diff_eq, inter_assoc]
  
theorem Indep.of_contract (hI : (M ⟋ C).Indep I) : M.Indep I := by
  obtain ⟨J, R, hJ, -, -, hM⟩ := M.exists_eq_contract_indep_delete C
  rw [hM, delete_indep_iff, hJ.indep.contract_indep_iff] at hI 
  exact hI.1.2.subset (subset_union_left _ _)

@[simp] theorem contract_loop_iff_mem_cl : (M ⟋ C).Loop e ↔ e ∈ M.cl C \ C := by
  obtain ⟨I, D, hI, -, -, hM⟩ := M.exists_eq_contract_indep_delete C
  rw [hM, delete_loop_iff, ←singleton_dep, hI.indep.contract_dep_iff, disjoint_singleton_left,
    singleton_union, hI.indep.insert_dep_iff, mem_diff, M.cl_eq_cl_inter_ground C, hI.cl_eq_cl,
    and_comm (a := e ∉ I), and_self_right, ← mem_diff, ← mem_diff, diff_diff]
  apply_fun Matroid.E at hM 
  rw [delete_ground, contract_ground, contract_ground, diff_diff, diff_eq_diff_iff_inter_eq_inter,
    inter_comm, inter_comm M.E] at hM 
  exact
    ⟨fun h ↦ ⟨h.1, fun heC ↦ h.2 (hM.subset ⟨heC, M.cl_subset_ground _ h.1⟩).1⟩, fun h ↦
      ⟨h.1, fun h' ↦ h.2 (hM.symm.subset ⟨h', M.cl_subset_ground _ h.1⟩).1⟩⟩

theorem contract_loops_eq : (M ⟋ C).cl ∅ = M.cl C \ C := by
  simp [Set.ext_iff, ← loop_iff_mem_cl_empty, contract_loop_iff_mem_cl]

@[simp] theorem contract_cl_eq (M : Matroid α) (C X : Set α) :
    (M ⟋ C).cl X = M.cl (X ∪ C) \ C := by
  ext e
  by_cases heX : e ∈ X
  · by_cases he : e ∈ (M ⟋ C).E
    · refine' iff_of_true (mem_cl_of_mem' _ heX) _
      rw [contract_ground] at he 
      exact ⟨mem_cl_of_mem' _ (Or.inl heX) he.1, he.2⟩
    refine' iff_of_false (he ∘ fun h ↦ cl_subset_ground _ _ h) (he ∘ fun h ↦ _)
    rw [contract_ground]
    exact ⟨M.cl_subset_ground _ h.1, h.2⟩
  suffices h' : e ∈ (M ⟋ C).cl X \ X ↔ e ∈ M.cl (X ∪ C) \ (X ∪ C)
  · rwa [mem_diff, and_iff_left heX, mem_diff, mem_union, or_iff_right heX, ← mem_diff] at h' 
  rw [← contract_loop_iff_mem_cl, ← contract_loop_iff_mem_cl, contract_contract, union_comm]

/-- This lemma is useful where it is known (or unimportant) that `X ⊆ M.E` -/
theorem er_contract_eq_er_contract_diff (M : Matroid α) (C X : Set α) :
    (M ⟋ C).er X = (M ⟋ C).er (X \ C) := by
  rw [← er_cl_eq, contract_cl_eq, ← er_cl_eq _ (X \ C), contract_cl_eq, diff_union_self]

/-- This lemma is useful where it is known (or unimportant) that `X` and `C` are disjoint -/
theorem er_contract_eq_er_contract_inter_ground (M : Matroid α) (C X : Set α) :
    (M ⟋ C).er X = (M ⟋ C).er (X ∩ M.E) := by
  rw [←er_inter_ground_eq, contract_ground, M.er_contract_eq_er_contract_diff _ (X ∩ M.E),
    inter_diff_assoc]

/-- This lemma is essentially defining the 'relative rank' of `X` to `C`. The required set `I` can 
  be obtained for any `X,C ⊆ M.E` using `M.exists_basis_union_inter_basis X C`. -/
theorem Basis.er_contract (hI : M.Basis I (X ∪ C)) (hIC : M.Basis (I ∩ C) C) :
    (M ⟋ C).er X = (I \ C).encard := by
  rw [er_contract_eq_er_contract_diff, hIC.contract_eq_contract_delete, delete_er_eq',
    diff_inter_self_eq_diff, ←Basis.er_eq_encard]
  apply Basis.contract_basis_union_union
  · rw [diff_union_inter, diff_diff, union_eq_self_of_subset_right (diff_subset _ _)]
    apply hI.basis_subset _ (union_subset_union (diff_subset _ _) (inter_subset_right _ _))
    rw [union_comm, ← diff_subset_iff, subset_diff, diff_self_inter, diff_subset_iff, union_comm]
    exact ⟨hI.subset, disjoint_sdiff_left⟩
  rw [disjoint_union_left]
  exact
    ⟨disjoint_of_subset_right (inter_subset_right _ _) disjoint_sdiff_left,
      disjoint_of_subset (diff_subset _ _) (inter_subset_right _ _) disjoint_sdiff_left⟩

theorem Basis.er_contract_of_subset (hI : M.Basis I X) (hCX : C ⊆ X) (hIC : M.Basis (I ∩ C) C) :
    (M ⟋ C).er (X \ C) = (I \ C).encard := by
  rw [← er_contract_eq_er_contract_diff, Basis.er_contract _ hIC]
  rwa [union_eq_self_of_subset_right hCX]

theorem er_contract_add_er_eq_er_union (M : Matroid α) (C X : Set α) :
    (M ⟋ C).er X + M.er C = M.er (X ∪ C) := by
  obtain ⟨I, D, hIC, hD, -, hM⟩ := M.exists_eq_contract_indep_delete C
  obtain ⟨J, hJ, rfl⟩ :=
    hIC.exists_basis_inter_eq_of_supset (subset_union_right (X ∩ M.E) _) (by simp)
  rw [er_contract_eq_er_contract_inter_ground, ←contract_inter_ground_eq,
    hJ.er_contract hIC, ←er_inter_ground_eq, ← hIC.encard, ←er_inter_ground_eq ,
    inter_distrib_right, ← hJ.encard, encard_diff_add_encard_inter]

-- theorem er_contract_eq_tsub (M : Matroid α) [FiniteRk M] (C X : Set α) : 
--     (M ⟋ C).er X = M.er (X ∪ C) - M.er C := by 


theorem Basis.diff_subset_loops_contract (hIX : M.Basis I X) : X \ I ⊆ (M ⟋ I).cl ∅ := by
  rw [diff_subset_iff, contract_loops_eq, union_diff_self,
    union_eq_self_of_subset_left (M.subset_cl I)]
  exact hIX.subset_cl

/-- Relative rank is additive. TODO : maybe `Basis'` shortens the proof? -/
theorem contract_er_add_contract_er (M : Matroid α) (hXY : X ⊆ Y) (hYZ : Y ⊆ Z) :
    (M ⟋ X).er Y + (M ⟋ Y).er Z = (M ⟋ X).er Z :=
  by
  suffices h' : ∀ X' Y' Z', X' ⊆ Y' → Y' ⊆ Z' → X' ⊆ M.E → Y' ⊆ M.E → Z' ⊆ M.E → 
    (M ⟋ X').er Y' + (M ⟋ Y').er Z' = (M ⟋ X').er Z'
  · have :=
      h' (X ∩ M.E) (Y ∩ M.E) (Z ∩ M.E) (inter_subset_inter_left M.E hXY)
        (inter_subset_inter_left M.E hYZ) (inter_subset_right _ _) (inter_subset_right _ _)
        (inter_subset_right _ _)
    simpa [← er_contract_eq_er_contract_inter_ground] using this
  clear hXY hYZ X Y Z
  intro X Y Z hXY hYZ hXE hYE hZE
  obtain ⟨I, hI⟩ := M.exists_basis X
  obtain ⟨J, hJ, rfl⟩ := hI.exists_basis_inter_eq_of_supset hXY
  obtain ⟨K, hK, rfl⟩ := hJ.exists_basis_inter_eq_of_supset hYZ
  rw [M.er_contract_eq_er_contract_diff, M.er_contract_eq_er_contract_diff Y,
    M.er_contract_eq_er_contract_diff _ Z, hK.er_contract_of_subset hYZ hJ,
    hJ.er_contract_of_subset hXY hI, ←
    encard_union_eq (disjoint_of_subset_left _ disjoint_sdiff_right)]
  · rw [inter_assoc, inter_eq_self_of_subset_right hXY] at hI 
    rw [diff_eq, diff_eq, inter_assoc, ← inter_distrib_left, union_distrib_right, union_compl_self,
      univ_inter, ← compl_inter, ← diff_eq, inter_eq_self_of_subset_left hXY, Basis.encard]
    rw [hI.contract_eq_contract_delete, delete_basis_iff,
      and_iff_left (disjoint_of_subset_right (diff_subset _ _) disjoint_sdiff_left)]
    refine' Basis.contract_basis_union_union _ _
    · rw [diff_union_inter]
      refine'
        hK.basis_subset _ (union_subset (diff_subset _ _) ((inter_subset_left _ _).trans hK.subset))
      rw [union_comm, ← diff_subset_iff, diff_self_inter]
      exact diff_subset_diff_left hK.subset
    rw [← union_diff_distrib]
    exact disjoint_of_subset_right (inter_subset_right _ _) disjoint_sdiff_left
  refine' (diff_subset _ _).trans (inter_subset_right _ _)

theorem contract_er_diff_add_contract_er_diff (M : Matroid α) (hXY : X ⊆ Y) (hYZ : Y ⊆ Z) :
    (M ⟋ X).er (Y \ X) + (M ⟋ Y).er (Z \ Y) = (M ⟋ X).er (Z \ X) := by
  simp_rw [← er_contract_eq_er_contract_diff, M.contract_er_add_contract_er hXY hYZ]

theorem er_contract_le_er (M : Matroid α) (C X : Set α) : (M ⟋ C).er X ≤ M.er X :=
  by
  obtain ⟨I, hI⟩ := (M ⟋ C).exists_basis (X ∩ (M ⟋ C).E)
  rw [←er_inter_ground_eq, ← hI.encard, ←hI.indep.of_contract.er]
  exact M.er_mono (hI.subset.trans (inter_subset_left _ _))
  
theorem rFin.contract_rFin (h : M.rFin X) (C : Set α) : (M ⟋ C).rFin X := by
  rw [←er_lt_top_iff] at *; exact (er_contract_le_er _ _ _).trans_lt h

noncomputable def Iso.contract {β : Type _} {N : Matroid β} (e : Iso M N) (hC : C ⊆ M.E) :
    Iso (M ⟋ C) (N ⟋ e '' C) :=
  (e.dual.delete hC).dual
  
lemma rFin.contract_rFin_of_subset_union (h : M.rFin Z) (X C : Set α) (hX : X ⊆ M.cl (Z ∪ C)) :
    (M ⟋ C).rFin (X \ C) :=
  (h.contract_rFin C).to_cl.subset (by rw [contract_cl_eq]; exact diff_subset_diff_left hX)

instance contract_finiteRk [FiniteRk M] : FiniteRk (M ⟋ C) := by
  have h := ‹FiniteRk M›
  rw [← rFin_ground_iff_finiteRk] at h ⊢
  exact (h.contract_rFin C).subset (diff_subset _ _)

-- Todo : Probably `Basis'` makes this shorter.
lemma contract_er_add_er_eq (M : Matroid α) (C X : Set α) :
    (M ⟋ C).er X + M.er C = M.er (X ∪ C) := by
  rw [←contract_inter_ground_eq, ←M.er_inter_ground_eq C]
  obtain ⟨I, hI⟩ := M.exists_basis (C ∩ M.E)
  rw [hI.contract_eq_contract_delete, delete_er_eq', ←er_inter_ground_eq, contract_ground, 
    inter_diff_assoc, diff_inter, inter_distrib_right, diff_inter_self, union_empty, 
    ←inter_diff_assoc, inter_diff_right_comm]
  have hdiff : (X \ C) \ I ∩ M.E ⊆ (M ⟋ I).E
  · rw [contract_ground, inter_comm, diff_eq, diff_eq, diff_eq]
    apply inter_subset_inter_right; apply inter_subset_right
  obtain ⟨J, hJ⟩  := (M ⟋ I).exists_basis (((X \ C) \ I) ∩ M.E)
  rw [hJ.er_eq_encard, hI.er_eq_encard, ←encard_union_eq, 
      ←(hI.indep.union_contract_basis_union_of_basis hJ).er_eq_encard, union_distrib_right, 
      diff_union_self, ←union_distrib_right, ←er_cl_eq, ←cl_union_cl_right_eq, hI.cl_eq_cl, 
      cl_union_cl_right_eq, ←inter_distrib_right, diff_union_self, er_cl_eq, 
      er_inter_ground_eq]
  exact disjoint_of_subset hJ.subset (hI.subset.trans (inter_subset_left _ _)) 
    (disjoint_of_subset_left ((inter_subset_left _ _).trans (diff_subset _ _)) disjoint_sdiff_left)

theorem contract_spanning_iff' (M : Matroid α) (C X : Set α) : 
    (M ⟋ C).Spanning X ↔ M.Spanning (X ∪ (C ∩ M.E)) ∧ Disjoint X C := by 
  simp_rw [Spanning, contract_cl_eq, contract_ground, subset_diff, union_subset_iff, 
    and_iff_left (inter_subset_right _ _), ←and_assoc, and_congr_left_iff, 
    subset_antisymm_iff, subset_diff, diff_subset_iff, and_iff_left disjoint_sdiff_left, 
    and_iff_right (M.cl_subset_ground _ ), 
    and_iff_right (subset_union_of_subset_right (M.cl_subset_ground _) C)]
  rw [←inter_eq_left (s := M.E), inter_distrib_left, 
    inter_eq_self_of_subset_right (M.cl_subset_ground _), subset_antisymm_iff, union_subset_iff, 
    and_iff_right (inter_subset_left _ _), union_eq_self_of_subset_left (s := M.E ∩ C), 
    and_iff_right (M.cl_subset_ground _), Iff.comm, ←cl_union_cl_right_eq, ←cl_eq_cl_inter_ground, 
    cl_union_cl_right_eq]
  · exact fun _ _ ↦ Iff.rfl
  exact (M.subset_cl _).trans 
    (M.cl_subset_cl ((inter_subset_right _ _).trans (subset_union_right _ _))) 

theorem contract_spanning_iff (hC : C ⊆ M.E := by aesop_mat) : 
    (M ⟋ C).Spanning X ↔ M.Spanning (X ∪ C) ∧ Disjoint X C := by 
  rw [contract_spanning_iff', inter_eq_self_of_subset_left hC] 

theorem Nonloop.contract_er_add_one_eq (he : M.Nonloop e) (X : Set α) : 
    (M ⟋ e).er X + 1 = M.er (insert e X) := by 
  rw [contract_elem, ←he.er_eq, er_contract_add_er_eq_er_union, union_singleton]

theorem Nonloop.contract_er_eq (he : M.Nonloop e) (X : Set α) : 
    (M ⟋ e).er X = M.er (insert e X) - 1 := by 
  rw [←WithTop.add_right_cancel_iff (by norm_num : (1 : ℕ∞) ≠ ⊤), he.contract_er_add_one_eq, 
    tsub_add_cancel_iff_le.2]
  rw [←he.er_eq, ←union_singleton]
  exact M.er_mono (subset_union_right _ _)
  
  
  
  

end Contract

section Minor

variable {M₀ M₁ M₂ : Matroid α}

theorem contract_delete_diff (M : Matroid α) (C D : Set α) : M ⟋ C ⟍ D = M ⟋ C ⟍ (D \ C) := by
  rw [delete_eq_delete_iff, contract_ground, diff_eq, diff_eq, ←inter_inter_distrib_right,
    inter_assoc]

theorem contract_delete_comm (M : Matroid α) {C D : Set α} (hCD : Disjoint C D) :
    M ⟋ C ⟍ D = M ⟍ D ⟋ C := by
  refine eq_of_indep_iff_indep_forall (by simp [diff_diff_comm]) (fun I hI ↦ ?_)
  rw [delete_ground, contract_ground, subset_diff, subset_diff] at hI
  simp only [delete_ground, contract_ground, delete_indep_iff, and_iff_left hI.2]
  obtain ⟨J, hJ⟩ := (M ⟍ D).exists_basis' C;  have hJ' := hJ
  rw [← restrict_compl, basis'_restrict_iff, subset_diff, diff_eq, inter_comm M.E, ←inter_assoc, 
    ←diff_eq, sdiff_eq_left.2 hCD] at hJ'
  rw [hJ.contract_eq_contract_delete, delete_indep_iff, hJ.indep.contract_indep_iff, 
    delete_indep_iff, ←contract_inter_ground_eq, hJ'.1.contract_eq_contract_delete, 
    delete_indep_iff,  hJ'.1.indep.contract_indep_iff, disjoint_union_left, and_iff_right hI.2, 
    and_iff_left (disjoint_of_subset_right (diff_subset _ _) hI.1.2), and_iff_left hJ'.2.2, 
    and_iff_left 
    (disjoint_of_subset_right ((diff_subset _ _).trans (inter_subset_left _ _)) hI.1.2)]

theorem contract_delete_comm' (M : Matroid α) (C D : Set α) : M ⟋ C ⟍ D = M ⟍ (D \ C) ⟋ C := by
  rw [contract_delete_diff, contract_delete_comm _ disjoint_sdiff_right]

theorem delete_contract_diff (M : Matroid α) (D C : Set α) : M ⟍ D ⟋ C = M ⟍ D ⟋ (C \ D) := by
  rw [contract_eq_contract_iff, delete_ground, diff_inter_diff_right, diff_eq, diff_eq, inter_assoc]

theorem delete_contract_comm' (M : Matroid α) (D C : Set α) : M ⟍ D ⟋ C = M ⟋ (C \ D) ⟍ D := by
  rw [delete_contract_diff, ← contract_delete_comm _ disjoint_sdiff_left]

theorem contract_delete_contract' (M : Matroid α) (C D C' : Set α) :
    M ⟋ C ⟍ D ⟋ C' = M ⟋ (C ∪ C' \ D) ⟍ D := by
  rw [delete_contract_diff, ← contract_delete_comm _ disjoint_sdiff_left, contract_contract]

theorem contract_delete_contract (M : Matroid α) (C D C' : Set α) (h : Disjoint C' D) :
    M ⟋ C ⟍ D ⟋ C' = M ⟋ (C ∪ C') ⟍ D := by rw [contract_delete_contract', sdiff_eq_left.mpr h]

theorem contract_delete_contract_delete' (M : Matroid α) (C D C' D' : Set α) :
    M ⟋ C ⟍ D ⟋ C' ⟍ D' = M ⟋ (C ∪ C' \ D) ⟍ (D ∪ D') := by
  rw [contract_delete_contract', delete_delete]

theorem contract_delete_contract_delete (M : Matroid α) (C D C' D' : Set α) (h : Disjoint C' D) :
    M ⟋ C ⟍ D ⟋ C' ⟍ D' = M ⟋ (C ∪ C') ⟍ (D ∪ D') := by
  rw [contract_delete_contract_delete', sdiff_eq_left.mpr h]

theorem delete_contract_delete' (M : Matroid α) (D C D' : Set α) :
    M ⟍ D ⟋ C ⟍ D' = M ⟋ (C \ D) ⟍ (D ∪ D') := by rw [delete_contract_comm', delete_delete]

theorem delete_contract_delete (M : Matroid α) (D C D' : Set α) (h : Disjoint C D) :
    M ⟍ D ⟋ C ⟍ D' = M ⟋ C ⟍ (D ∪ D') := by rw [delete_contract_delete', sdiff_eq_left.mpr h]

/- `N` is a minor of `M` if `N = M ⟋ C ⟍ D` for disjoint sets `C,D ⊆ M.E`-/
def Minor (N M : Matroid α) : Prop :=
  ∃ C D, C ⊆ M.E ∧ D ⊆ M.E ∧ Disjoint C D ∧ N = M ⟋ C ⟍ D

def StrictMinor (N M : Matroid α) : Prop :=
  Minor N M ∧ ¬Minor M N

infixl:50 " ≤m " => Matroid.Minor
infixl:50 " <m " => Matroid.StrictMinor

instance {α : Type _} : IsNonstrictStrictOrder (Matroid α) (· ≤m ·) (· <m ·) :=
  ⟨fun _ _ ↦ Iff.rfl⟩  

theorem contract_delete_minor (M : Matroid α) (C D : Set α) : M ⟋ C ⟍ D ≤m M := by 
  rw [contract_delete_diff, ←contract_inter_ground_eq, ←delete_inter_ground_eq,
    contract_ground, diff_inter_self_eq_diff, diff_inter_diff_right, inter_diff_right_comm]
  refine ⟨_,_, inter_subset_right _ _, inter_subset_right _ _, ?_, rfl⟩  
  exact disjoint_of_subset (inter_subset_left C M.E) (inter_subset_left _ M.E) disjoint_sdiff_right 

theorem minor_iff_exists_contract_delete : N ≤m M ↔ ∃ C D : Set α, N = M ⟋ C ⟍ D :=
  ⟨fun ⟨C, D, h⟩ ↦ ⟨_,_,h.2.2.2⟩, fun ⟨C, D, h⟩ ↦ by rw [h]; apply contract_delete_minor⟩

instance minor_refl : IsRefl (Matroid α) (· ≤m ·) :=
  ⟨fun M ↦ minor_iff_exists_contract_delete.2 ⟨∅, ∅, by simp⟩⟩ 
  
lemma Minor.eq_of_ground_subset (h : N ≤m M) (hE : M.E ⊆ N.E) : M = N := by 
  obtain ⟨C, D, -, -, -, rfl⟩ := h
  rw [delete_ground, contract_ground, subset_diff, subset_diff] at hE
  rw [←contract_inter_ground_eq, hE.1.2.symm.inter_eq, contract_empty, ←delete_inter_ground_eq, 
    hE.2.symm.inter_eq, delete_empty] 

lemma Minor.subset (h : N ≤m M) : N.E ⊆ M.E := by 
  obtain ⟨C, D, -, -, -, rfl⟩ := h; exact (diff_subset _ _).trans (diff_subset _ _)

instance minor_antisymm : IsAntisymm (Matroid α) (· ≤m ·) := 
  ⟨fun _ _ h h' ↦ h'.eq_of_ground_subset h.subset⟩ 
  
instance minor_trans : IsTrans (Matroid α) (· ≤m ·) :=
⟨ by
    rintro M₀ M₁ M₂ ⟨C₁, D₁, -, -, -, rfl⟩ ⟨C₂, D₂, -, -, -, rfl⟩ 
    rw [contract_delete_contract_delete']
    apply contract_delete_minor ⟩ 
    
theorem Minor.refl (M : Matroid α) : M ≤m M :=
  _root_.refl M

theorem Minor.trans {M₁ M₂ M₃ : Matroid α} (h : M₁ ≤m M₂) (h' : M₂ ≤m M₃) : M₁ ≤m M₃ :=
  _root_.trans h h'

theorem Minor.antisymm (h : N ≤m M) (h' : M ≤m N) : N = M :=
  _root_.antisymm h h'

theorem contract_minor (M : Matroid α) (C : Set α) : M ⟋ C ≤m M := by
  rw [← (M ⟋ C).delete_empty]; apply contract_delete_minor

theorem delete_minor (M : Matroid α) (D : Set α) : M ⟍ D ≤m M := by
  nth_rw 1 [← M.contract_empty]; apply contract_delete_minor

theorem restrict_minor (M : Matroid α) (hR : R ⊆ M.E := by aesop_mat) : (M ↾ R) ≤m M := by
  rw [←delete_compl]; apply delete_minor

theorem Restriction.minor (h : N ≤r M) : N ≤m M := by
  rw [← h.eq_restrict, ←delete_compl h.subset]; apply delete_minor

theorem delete_contract_minor (M : Matroid α) (D C : Set α) : M ⟍ D ⟋ C ≤m M :=
  ((M ⟍ D).contract_minor C).trans (M.delete_minor D)

theorem contract_restrict_minor (M : Matroid α) (C : Set α) (hR : R ⊆ M.E \ C) :
    (M ⟋ C) ↾ R ≤m M := by
  rw [←delete_compl]; apply contract_delete_minor

theorem Minor.to_dual (h : N ≤m M) : N﹡ ≤m M﹡ := by
  obtain ⟨C, D, -, -, -, rfl⟩ := h
  rw [delete_dual_eq_dual_contract, contract_dual_eq_dual_delete]
  apply delete_contract_minor

theorem dual_minor_iff : N﹡ ≤m M﹡ ↔ N ≤m M := by
  refine' ⟨fun h ↦ _, Minor.to_dual⟩; rw [← dual_dual N, ← dual_dual M]; exact h.to_dual

/-- The scum theorem. We can always realize a minor by contracting an independent set and deleting
  a coindependent set -/
theorem Minor.exists_contract_indep_delete_coindep (h : N ≤m M) :
    ∃ C D, M.Indep C ∧ M.Coindep D ∧ Disjoint C D ∧ N = M ⟋ C ⟍ D := by
  obtain ⟨C', D', hC', hD', hCD', rfl⟩ := h
  obtain ⟨I, hI⟩ := M.exists_basis C'
  obtain ⟨K, hK⟩ := M﹡.exists_basis D'
  have hIK : Disjoint I K := disjoint_of_subset hI.subset hK.subset hCD'
  use I ∪ D' \ K, C' \ I ∪ K
  refine' ⟨_, _, _, _⟩
  · have hss : (D' \ K) \ I ⊆ (M﹡ ⟋ K ⟍ I).cl ∅
    · rw [delete_loops_eq];
      exact diff_subset_diff_left hK.diff_subset_loops_contract
    rw [← delete_dual_eq_dual_contract, ← contract_dual_eq_dual_delete] at hss 
    have hi := indep_of_subset_coloops hss
    rw [← contract_delete_comm _ hIK, delete_indep_iff, hI.indep.contract_indep_iff,
      diff_union_self, union_comm] at hi 
    exact hi.1.2
  · rw [coindep_def]
    have hss : (C' \ I) \ K ⊆ (M ⟋ I ⟍ K)﹡﹡.cl ∅
    · rw [dual_dual, delete_loops_eq];
      exact diff_subset_diff_left hI.diff_subset_loops_contract
    have hi := indep_of_subset_coloops hss
    rw [delete_dual_eq_dual_contract, contract_dual_eq_dual_delete, ←
      contract_delete_comm _ hIK.symm, delete_indep_iff, hK.indep.contract_indep_iff,
      diff_union_self] at hi 
    exact hi.1.2
  · rw [disjoint_union_left, disjoint_union_right, disjoint_union_right,
      and_iff_right disjoint_sdiff_right, and_iff_right hIK, and_iff_left disjoint_sdiff_left]
    exact disjoint_of_subset (diff_subset _ _) (diff_subset _ _) hCD'.symm
  have hb : (M ⟋ C')﹡.Basis K D' :=
    by
    rw [contract_dual_eq_dual_delete, delete_basis_iff, and_iff_right hK]
    exact hCD'.symm
  rw [← dual_dual (M ⟋ C' ⟍ D'), delete_dual_eq_dual_contract, hb.contract_eq_contract_delete,
    hI.contract_eq_contract_delete, delete_dual_eq_dual_contract, contract_dual_eq_dual_delete,
    dual_dual, delete_delete, contract_delete_contract]
  rw [disjoint_union_right, and_iff_left disjoint_sdiff_left]
  exact disjoint_of_subset (diff_subset _ _) (diff_subset _ _) hCD'.symm

theorem Minor.exists_contract_spanning_restrict (h : N ≤m M) :
    ∃ C, M.Indep C ∧ (N ≤r M ⟋ C) ∧ (M ⟋ C).cl N.E = (M ⟋ C).E := by
  obtain ⟨C, D, hC, hD, hCD, rfl⟩ := h.exists_contract_indep_delete_coindep
  refine' ⟨C, hC, delete_restriction _ _, _⟩
  rw [← (hD.coindep_contract_of_disjoint hCD.symm).cl_compl, delete_ground]

end Minor

section Iso

variable {β : Type _} {N' M' : Matroid α}

/-- We have `N ≤i M` if `M` has an `N`-minor; i.e. `N` is isomorphic to a minor of `M`. This is 
  defined to be type-heterogeneous.  -/
def IsoMinor (N : Matroid β) (M : Matroid α) : Prop :=
  ∃ M' : Matroid α, M' ≤m M ∧ N ≃ M'

infixl:50 " ≤i " => Matroid.IsoMinor

instance isoMinor_refl : IsRefl (Matroid α) (· ≤i ·) :=
  ⟨fun M ↦ ⟨M, refl M, ⟨Iso.refl M⟩⟩⟩

theorem Iso.isoMinor {N : Matroid β} (e : Iso N M) : N ≤i M :=
  ⟨M, Minor.refl _, ⟨e⟩⟩

theorem IsIso.isoMinor {N : Matroid β} (h : M ≃ N) : M ≤i N := by
  obtain ⟨e⟩ := h; exact e.isoMinor

theorem Minor.trans_iso {M' : Matroid β} (h : N ≤m M) (e : Iso M M') : N ≤i M' := by
  obtain ⟨C, D, hC, hD, hCD, rfl⟩ := h
  exact ⟨_, 
    contract_delete_minor _ _ _, ⟨(Iso.contract e hC).delete (subset_diff.2 ⟨hD, hCD.symm⟩)⟩⟩

theorem Minor.isoMinor (h : N ≤m M) : N ≤i M :=
  ⟨N, h, ⟨Iso.refl N⟩⟩

theorem IsoMinor.trans {α₁ α₂ α₃ : Type _} {M₁ : Matroid α₁} {M₂ : Matroid α₂}
    {M₃ : Matroid α₃} (h : M₁ ≤i M₂) (h' : M₂ ≤i M₃) : M₁ ≤i M₃ :=
  by
  obtain ⟨M₂', hM₂'M₃, ⟨i'⟩⟩ := h'
  obtain ⟨M₁', hM₁'M₂, ⟨i''⟩⟩ := h
  obtain ⟨N, hN, ⟨iN⟩⟩ := hM₁'M₂.trans_iso i'
  exact ⟨N, hN.trans hM₂'M₃, ⟨i''.trans iN⟩⟩

theorem Iso.trans_isoMinor {N : Matroid β} (e : Iso N N') (h : N' ≤i M) : N ≤i M :=
  e.isoMinor.trans h

end Iso

end Matroid




-- theorem Flat.covby_iff_er_contract_eq (hF : M.Flat F) (hF' : M.Flat F') :
--     M.Covby F F' ↔ F ⊆ F' ∧ (M ⟋ F).er (F' \ F) = 1 :=
--   by
--   refine' (em' (F ⊆ F')).elim (fun h ↦ iff_of_false (h ∘ covby.subset) (h ∘ And.left)) fun hss ↦ _
--   obtain ⟨I, hI⟩ := M.exists_basis F
--   rw [hF.covby_iff_eq_cl_insert, and_iff_right hss]
--   refine' ⟨_, fun h ↦ _⟩
--   · rintro ⟨e, ⟨heE, heF⟩, rfl⟩
--     obtain ⟨J, hJF', rfl⟩ := hI.exists_basis_inter_eq_of_supset (subset_insert e F)
--     rw [hJF'.basis_cl.er_contract_of_subset (M.subset_cl_of_subset (subset_insert e F)) hI]
--     rw [← encard_singleton e]; apply congr_arg
--     rw [subset_antisymm_iff, diff_subset_iff, singleton_subset_iff, mem_diff, and_iff_left heF,
--       union_singleton, and_iff_right hJF'.subset]
--     by_contra heJ
--     have hJF := hF.cl_subset_of_subset ((subset_insert_iff_of_not_mem heJ).mp hJF'.subset)
--     rw [hJF'.cl] at hJF 
--     exact heF (hJF (M.mem_cl_of_mem (mem_insert e F)))
--   obtain ⟨J, hJF', rfl⟩ := hI.exists_basis_inter_eq_of_supset hss
--   rw [hJF'.er_contract_of_subset hss hI, ← ENat.coe_one, encard_eq_coe_iff, ncard_eq_one] at h 
--   obtain ⟨e, he⟩ := h.2; use e
--   rw [← singleton_subset_iff, ← union_singleton, ← he,
--     and_iff_right (diff_subset_diff_left hJF'.subset_ground_left), union_diff_self, ←
--     cl_union_cl_right_eq, hJF'.cl, hF'.cl, union_eq_self_of_subset_left hss, hF'.cl]

-- theorem Covby.er_contract_eq (h : M.Covby F F') : (M ⟋ F).er (F' \ F) = 1 :=
--   ((h.flat_left.covby_iff_er_contract_eq h.flat_right).mp h).2

-- theorem Hyperplane.inter_right_covby_of_inter_left_covby {H₁ H₂ : Set α} (hH₁ : M.Hyperplane H₁)
--     (hH₂ : M.Hyperplane H₂) (h : M.Covby (H₁ ∩ H₂) H₁) : M.Covby (H₁ ∩ H₂) H₂ :=
--   by
--   rw [(hH₁.flat.inter hH₂.flat).covby_iff_er_contract_eq hH₁.flat] at h 
--   rw [(hH₁.flat.inter hH₂.flat).covby_iff_er_contract_eq hH₂.flat,
--     and_iff_right (inter_subset_right _ _)]
--   have h₁' := hH₁.covby.er_contract_eq
--   have h₂' := hH₂.covby.er_contract_eq
--   have h1 := M.contract_er_diff_add_contract_er_diff (inter_subset_left H₁ H₂) hH₁.subset_ground
--   have h2 := M.contract_er_diff_add_contract_er_diff (inter_subset_right H₁ H₂) hH₂.subset_ground
--   rwa [h.2, h₁', ← h2, h₂', ENat.add_eq_add_iff_right WithTop.one_ne_top, eq_comm] at h1 

-- theorem Hyperplane.inter_covby_comm {H₁ H₂ : Set α} (hH₁ : M.Hyperplane H₁)
--     (hH₂ : M.Hyperplane H₂) : M.Covby (H₁ ∩ H₂) H₁ ↔ M.Covby (H₁ ∩ H₂) H₂ :=
--   ⟨hH₁.inter_right_covby_of_inter_left_covby hH₂, by rw [inter_comm]; intro h;
--     exact hH₂.inter_right_covby_of_inter_left_covby hH₁ h⟩

-- end Matroid

