import Mathlib.SetTheory.Cardinal.Finite
import Mathlib.Data.Nat.Cast.WithTop

instance : WellFoundedRelation ℕ∞ where
  rel := (· < ·)
  wf := IsWellFounded.wf

theorem ENat.le_coe_iff {n : ℕ∞} {k : ℕ} : n ≤ ↑k ↔ ∃ (n₀ : ℕ), n = n₀ ∧ n₀ ≤ k :=
  WithTop.le_coe_iff

theorem ENat.exists_eq_top_or_coe (n : ℕ∞) : n = ⊤ ∨ ∃ (n₀ : ℕ), n = n₀ := by
  obtain (rfl | n) := n; exact Or.inl rfl; exact Or.inr ⟨_,rfl⟩

theorem PartENat.card_sum (α β : Type _) :
    PartENat.card (α ⊕ β) = PartENat.card α + PartENat.card β := by
  simp only [PartENat.card, Cardinal.mk_sum, map_add, Cardinal.toPartENat_lift]

theorem WithTop.add_right_cancel_iff [Add α] [LE α] {a b c : WithTop α} [IsRightCancelAdd α] 
    (ha : a ≠ ⊤) : b + a = c + a ↔ b = c := by
  lift a to α using ha
  obtain rfl | hb := (eq_or_ne b ⊤)
  · rw [top_add, eq_comm, WithTop.add_coe_eq_top_iff, eq_comm]
  lift b to α using hb
  simp_rw [←WithTop.coe_add, eq_comm, WithTop.add_eq_coe, coe_eq_coe, exists_and_left, 
    exists_eq_left, add_left_inj, exists_eq_right, eq_comm]
  
theorem WithTop.add_right_cancel [Add α] [LE α] {a b c : WithTop α} [IsRightCancelAdd α] 
    (ha : a ≠ ⊤) (hle : b + a = c + a) : b = c :=
  (WithTop.add_right_cancel_iff ha).1 hle

theorem WithTop.add_left_cancel_iff [Add α] [LE α] {a b c : WithTop α} [IsLeftCancelAdd α]
    (ha : a ≠ ⊤) : a + b = a + c ↔ b = c := by
  lift a to α using ha
  obtain rfl | hb := (eq_or_ne b ⊤)
  · rw [add_top, eq_comm, WithTop.coe_add_eq_top_iff, eq_comm]
  lift b to α using hb
  simp_rw [←WithTop.coe_add, eq_comm, WithTop.add_eq_coe, eq_comm, coe_eq_coe, 
    exists_and_left, exists_eq_left', add_right_inj, exists_eq_right']

theorem WithTop.add_left_cancel [Add α] [LE α] {a b c : WithTop α} [IsLeftCancelAdd α] 
    (ha : a ≠ ⊤) (hle : a + b = a + c) : b = c :=
  (WithTop.add_left_cancel_iff ha).1 hle

namespace Set

theorem Function.invFunOn_injOn_image [Nonempty α] (f : α → β) (s : Set α) : 
    Set.InjOn (Function.invFunOn f s) (f '' s) := by
  rintro _ ⟨x, hx, rfl⟩ _ ⟨x', hx', rfl⟩ he
  rw [←Function.invFunOn_apply_eq (f := f) hx, he, Function.invFunOn_apply_eq (f := f) hx']

theorem Function.invFunOn_image_image_subset [Nonempty α] (f : α → β) (s : Set α) : 
    (Function.invFunOn f s) '' (f '' s) ⊆ s := by 
  rintro _ ⟨_, ⟨x,hx,rfl⟩, rfl⟩; exact Function.invFunOn_apply_mem hx

theorem Function.injOn_iff_invFunOn_image_image_eq_self [Nonempty α] {f : α → β} {s : Set α} : 
    InjOn f s ↔ (Function.invFunOn f s) '' (f '' s) = s := by 
  refine' ⟨fun h ↦ _, fun h ↦ _⟩
  · rw [h.invFunOn_image Subset.rfl]
  rw [InjOn, ←h]
  rintro _ ⟨_, ⟨x,hx,rfl⟩, rfl⟩ _ ⟨_, ⟨x',hx',rfl⟩, rfl⟩ h
  rw [Function.invFunOn_apply_eq (f := f) hx, Function.invFunOn_apply_eq (f := f) hx'] at h
  rw [h]

  
variable {s t : Set α}

noncomputable def encard (s : Set α) := PartENat.withTopEquiv (PartENat.card s)

theorem Finite.encard_eq_coe_toFinset_card (h : s.Finite) : s.encard = h.toFinset.card := by 
  have := h.fintype
  rw [encard, PartENat.card_eq_coe_fintype_card, 
    PartENat.withTopEquiv_natCast, toFinite_toFinset, toFinset_card]

theorem encard_eq_toFinset_card {s : Set α} [Fintype s] : encard s = s.toFinset.card := by 
  have h := toFinite s
  rw [h.encard_eq_coe_toFinset_card, toFinite_toFinset, toFinset_card]

theorem Infinite.encard_eq {s : Set α} (h : s.Infinite) : s.encard = ⊤ := by 
  have := h.to_subtype
  rw [encard, ←PartENat.withTopEquiv.symm.injective.eq_iff, Equiv.symm_apply_apply, 
    PartENat.withTopEquiv_symm_top, PartENat.card_eq_top_of_infinite]

@[simp] theorem encard_eq_zero : s.encard = 0 ↔ s = ∅ := by
  rw [encard, ←PartENat.withTopEquiv.symm.injective.eq_iff, Equiv.symm_apply_apply, 
    PartENat.withTopEquiv_symm_zero, PartENat.card_eq_zero_iff_empty, isEmpty_subtype, 
    eq_empty_iff_forall_not_mem]
  
@[simp] theorem encard_empty : (∅ : Set α).encard = 0 := by 
  rw [encard_eq_zero]

theorem nonempty_of_encard_ne_zero (h : s.encard ≠ 0) : s.Nonempty := by 
  rwa [nonempty_iff_ne_empty, Ne.def, ←encard_eq_zero]

@[simp] theorem encard_singleton (e : α) : ({e} : Set α).encard = 1 := by 
  rw [encard, ←PartENat.withTopEquiv.symm.injective.eq_iff, Equiv.symm_apply_apply, 
    PartENat.card_eq_coe_fintype_card, Fintype.card_ofSubsingleton, Nat.cast_one]; rfl 
  
theorem encard_union_eq (h : Disjoint s t) : (s ∪ t).encard = s.encard + t.encard := by 
  classical
  have e := (Equiv.Set.union (by rwa [subset_empty_iff, ←disjoint_iff_inter_eq_empty])).symm
  simp [encard, ←PartENat.card_congr e, PartENat.card_sum, PartENat.withTopEquiv]
  
theorem encard_le_of_subset (h : s ⊆ t) : s.encard ≤ t.encard := by
  rw [←union_diff_cancel h, encard_union_eq disjoint_sdiff_right]; exact le_self_add

theorem encard_mono {α : Type _} : Monotone (encard : Set α → ℕ∞) :=
  fun _ _ ↦ encard_le_of_subset
  
theorem encard_insert_of_not_mem (has : a ∉ s) : (insert a s).encard = s.encard + 1 := by 
  rw [←union_singleton, encard_union_eq (by simpa), encard_singleton]
  
theorem Finite.encard_lt_top (h : s.Finite) : s.encard < ⊤ := by
  refine' h.induction_on (by simpa using WithTop.zero_lt_top) _
  rintro a t hat _ ht'
  rw [encard_insert_of_not_mem hat]
  exact lt_tsub_iff_right.1 ht'

theorem Finite.encard_eq_coe (h : s.Finite) : s.encard = ENat.toNat s.encard :=
  (ENat.coe_toNat h.encard_lt_top.ne).symm

theorem Finite.exists_encard_eq_coe (h : s.Finite) : ∃ (n : ℕ), s.encard = n := 
  ⟨_, h.encard_eq_coe⟩ 

@[simp] theorem encard_lt_top_iff : s.encard < ⊤ ↔ s.Finite :=
  ⟨fun h ↦ by_contra fun h' ↦ h.ne (Infinite.encard_eq h'), Finite.encard_lt_top⟩

@[simp] theorem encard_ne_top_iff : s.encard ≠ ⊤ ↔ s.Finite := by 
  rw [←WithTop.lt_top_iff_ne_top, encard_lt_top_iff]
  
@[simp] theorem encard_eq_top_iff : s.encard = ⊤ ↔ s.Infinite := by 
  rw [←not_iff_not, ←Ne.def, encard_ne_top_iff, not_infinite]

theorem finite_of_encard_eq_coe {k : ℕ} (h : s.encard = k) : s.Finite := by 
  rw [←encard_ne_top_iff, h]; exact WithTop.coe_ne_top

theorem encard_diff_add_encard_of_subset (h : s ⊆ t) : (t \ s).encard + s.encard = t.encard := by 
  rw [←encard_union_eq disjoint_sdiff_left, diff_union_self, union_eq_self_of_subset_right h]

@[simp] theorem one_le_encard_iff_nonempty : 1 ≤ s.encard ↔ s.Nonempty := by 
  rw [nonempty_iff_ne_empty, Ne.def, ←encard_eq_zero, ENat.one_le_iff_ne_zero]
   
@[simp] theorem encard_pos_iff_nonempty : 0 < s.encard ↔ s.Nonempty := by 
  rw [←ENat.one_le_iff_pos, one_le_encard_iff_nonempty]

theorem encard_diff_add_encard_inter (s t : Set α) :
    (s \ t).encard + (s ∩ t).encard = s.encard := by
  rw [←encard_union_eq (disjoint_of_subset_right (inter_subset_right _ _) disjoint_sdiff_left),
    diff_union_inter]

theorem encard_union_add_encard_inter (s t : Set α) :
    (s ∪ t).encard + (s ∩ t).encard = s.encard + t.encard :=
by rw [←diff_union_self, encard_union_eq disjoint_sdiff_left, add_right_comm,
  encard_diff_add_encard_inter]

theorem encard_union_le (s t : Set α) : (s ∪ t).encard ≤ s.encard + t.encard := by
  rw [←encard_union_add_encard_inter]; exact le_self_add

theorem finite_iff_finite_of_encard_eq_encard (h : s.encard = t.encard) : s.Finite ↔ t.Finite := by
  rw [←encard_lt_top_iff, ←encard_lt_top_iff, h]

theorem infinite_iff_infinite_of_encard_eq_encard (h : s.encard = t.encard) :
    s.Infinite ↔ t.Infinite := by rw [←encard_eq_top_iff, h, encard_eq_top_iff]

theorem Finite.finite_of_encard_le (hs : s.Finite) (h : t.encard ≤ s.encard) : t.Finite :=
  encard_lt_top_iff.1 (h.trans_lt hs.encard_lt_top)

theorem Finite.eq_of_subset_of_encard_le (ht : t.Finite) (hst : s ⊆ t) (hts : t.encard ≤ s.encard) :
    s = t := by
  rw [←zero_add (a := encard s), ←encard_diff_add_encard_of_subset hst] at hts
  have hdiff := WithTop.le_of_add_le_add_right (ht.subset hst).encard_lt_top.ne hts
  rw [nonpos_iff_eq_zero, encard_eq_zero, diff_eq_empty] at hdiff
  exact hst.antisymm hdiff
  
theorem Finite.eq_of_subset_of_encard_le' (hs : s.Finite) (hst : s ⊆ t)
    (hts : t.encard ≤ s.encard) : s = t :=
  (hs.finite_of_encard_le hts).eq_of_subset_of_encard_le hst hts
  
theorem Finite.encard_lt_encard (ht : t.Finite) (h : s ⊂ t) : s.encard < t.encard := 
  (encard_mono h.subset).lt_of_ne (fun he ↦ h.ne (ht.eq_of_subset_of_encard_le h.subset he.symm.le))

theorem encard_insert_le (s : Set α) (x : α) : (insert x s).encard ≤ s.encard + 1 := by 
  rw [←union_singleton, ←encard_singleton x]; apply encard_union_le 

theorem encard_singleton_inter (s : Set α) (x : α) : ({x} ∩ s).encard ≤ 1 := by 
  rw [←encard_singleton x]; exact encard_le_of_subset (inter_subset_left _ _)

theorem encard_le_encard_diff_add_encard (s t : Set α) : s.encard ≤ (s \ t).encard + t.encard :=
  (encard_le_of_subset (by rw [diff_union_self]; apply subset_union_left)).trans
    (encard_union_le (s \ t) t)

theorem tsub_encard_le_encard_diff (s t : Set α) : s.encard - t.encard ≤ (s \ t).encard := by 
  rw [tsub_le_iff_left, add_comm]; apply encard_le_encard_diff_add_encard

theorem encard_diff_singleton_add_one_of_mem (h : a ∈ s) :
    (s \ {a}).encard + 1 = s.encard := by 
  rw [←encard_insert_of_not_mem (fun h ↦ h.2 rfl), insert_diff_singleton, insert_eq_of_mem h]

theorem encard_diff_singleton_of_mem (h : a ∈ s) : 
    (s \ {a}).encard = s.encard - 1 := by 
  rw [←encard_diff_singleton_add_one_of_mem h, ←WithTop.add_right_cancel_iff WithTop.one_ne_top, 
    tsub_add_cancel_of_le (self_le_add_left _ _)]
  
theorem encard_tsub_one_le_encard_diff_singleton (s : Set α) (x : α) : 
    s.encard - 1 ≤ (s \ {x}).encard := by 
  rw [←encard_singleton x]; apply tsub_encard_le_encard_diff

theorem encard_exchange (ha : a ∉ s) (hb : b ∈ s) : (insert a (s \ {b})).encard = s.encard := by 
  rw [encard_insert_of_not_mem, encard_diff_singleton_add_one_of_mem hb]
  simp_all only [not_true, mem_diff, mem_singleton_iff, false_and, not_false_eq_true]

theorem encard_exchange' (ha : a ∉ s) (hb : b ∈ s) : (insert a s \ {b}).encard = s.encard := by 
  rw [←insert_diff_singleton_comm (by rintro rfl; exact ha hb), encard_exchange ha hb]

theorem encard_pair (hne : x ≠ y) : ({x,y} : Set α).encard = 2 := by
  rw [encard_insert_of_not_mem (by simpa), ←one_add_one_eq_two, 
    WithTop.add_right_cancel_iff WithTop.one_ne_top, encard_singleton]

theorem encard_eq_one : s.encard = 1 ↔ ∃ x, s = {x} := by
  refine' ⟨fun h ↦ _, fun ⟨x, hx⟩ ↦ by rw [hx, encard_singleton]⟩
  obtain ⟨x, hx⟩ := nonempty_of_encard_ne_zero (s := s) (by rw [h]; simp)
  exact ⟨x, ((finite_singleton x).eq_of_subset_of_encard_le' (by simpa) (by simp [h])).symm⟩ 
  
theorem encard_le_one_iff_eq : s.encard ≤ 1 ↔ s = ∅ ∨ ∃ x, s = {x} := by 
  rw [le_iff_lt_or_eq, lt_iff_not_le, ENat.one_le_iff_ne_zero, not_not, encard_eq_zero, 
    encard_eq_one]

theorem encard_le_one_iff : s.encard ≤ 1 ↔ ∀ a b, a ∈ s → b ∈ s → a = b := by 
  rw [encard_le_one_iff_eq, or_iff_not_imp_left, ←Ne.def, ←nonempty_iff_ne_empty]
  refine' ⟨fun h a b has hbs ↦ _, 
    fun h ⟨x, hx⟩ ↦ ⟨x, ((singleton_subset_iff.2 hx).antisymm' (fun y hy ↦ h _ _ hy hx))⟩⟩
  obtain ⟨x, rfl⟩ := h ⟨_, has⟩
  rw [(has : a = x), (hbs : b = x)]

theorem one_lt_encard_iff : 1 < s.encard ↔ ∃ a b, a ∈ s ∧ b ∈ s ∧ a ≠ b := by
  rw [←not_iff_not, not_exists, not_lt, encard_le_one_iff]; aesop

theorem exists_ne_of_one_lt_encard (h : 1 < s.encard) (a : α) : ∃ b ∈ s, b ≠ a := by 
  by_contra' h'
  obtain ⟨b,b',hb,hb',hne⟩ := one_lt_encard_iff.1 h
  apply hne 
  rw [h' b hb, h' b' hb']

theorem encard_eq_two : s.encard = 2 ↔ ∃ x y, x ≠ y ∧ s = {x,y} := by 
  refine' ⟨fun h ↦ _, fun ⟨x, y, hne, hs⟩ ↦ by rw [hs, encard_pair hne]⟩
  obtain ⟨x, hx⟩ := nonempty_of_encard_ne_zero (s := s) (by rw [h]; simp) 
  rw [←insert_eq_of_mem hx, ←insert_diff_singleton, encard_insert_of_not_mem (fun h ↦ h.2 rfl), 
    ←one_add_one_eq_two, WithTop.add_right_cancel_iff (WithTop.one_ne_top), encard_eq_one] at h
  obtain ⟨y, h⟩ := h
  refine' ⟨x, y, by rintro rfl; exact (h.symm.subset rfl).2 rfl, _⟩
  rw [←h, insert_diff_singleton, insert_eq_of_mem hx]
   
theorem encard_eq_three {α : Type u_1} {s : Set α} :
    encard s = 3 ↔ ∃ x y z, x ≠ y ∧ x ≠ z ∧ y ≠ z ∧ s = {x, y, z} := by 
  refine' ⟨fun h ↦ _, fun ⟨x, y, z, hxy, hyz, hxz, hs⟩ ↦ _⟩
  · obtain ⟨x, hx⟩ := nonempty_of_encard_ne_zero (s := s) (by rw [h]; simp) 
    rw [←insert_eq_of_mem hx, ←insert_diff_singleton, 
      encard_insert_of_not_mem (fun h ↦ h.2 rfl), (by exact rfl : (3 : ℕ∞) = 2 + 1), 
      WithTop.add_right_cancel_iff WithTop.one_ne_top, encard_eq_two] at h
    obtain ⟨y,z,hne, hs⟩ := h
    refine' ⟨x,y,z, _, _, hne, _⟩ 
    · rintro rfl; exact (hs.symm.subset (Or.inl rfl)).2 rfl
    · rintro rfl; exact (hs.symm.subset (Or.inr rfl)).2 rfl
    rw [←hs, insert_diff_singleton, insert_eq_of_mem hx]
  rw [hs, encard_insert_of_not_mem, encard_insert_of_not_mem, encard_singleton] <;> aesop

theorem Finite.eq_insert_of_subset_of_encard_eq_succ (hs : s.Finite) (h : s ⊆ t)
    (hst : t.encard = s.encard + 1) : ∃ a, t = insert a s := by
  rw [←encard_diff_add_encard_of_subset h, add_comm, 
    WithTop.add_left_cancel_iff hs.encard_lt_top.ne, encard_eq_one] at hst
  obtain ⟨x, hx⟩ := hst; use x; rw [←diff_union_of_subset h, hx, singleton_union]

theorem exists_subset_encard_eq (hk : k ≤ s.encard) : ∃ t, t ⊆ s ∧ t.encard = k := by 
  revert hk
  refine' ENat.nat_induction k (fun _ ↦ ⟨∅, empty_subset _, by simp⟩) (fun n IH hle ↦ _) _
  · obtain ⟨t₀, ht₀s, ht₀⟩ := IH (le_trans (by simp) hle)
    simp only [Nat.cast_succ] at *
    have hne : t₀ ≠ s
    · rintro rfl; rw [ht₀, ←Nat.cast_one, ←Nat.cast_add, Nat.cast_le] at hle; simp at hle
    obtain ⟨x, hx⟩ := exists_of_ssubset (ht₀s.ssubset_of_ne hne)
    exact ⟨insert x t₀, insert_subset hx.1 ht₀s, by rw [encard_insert_of_not_mem hx.2, ht₀]⟩ 
  simp only [top_le_iff, encard_eq_top_iff]
  exact fun _ hi ↦ ⟨s, Subset.rfl, hi⟩  
  
theorem exists_supset_subset_encard_eq (hst : s ⊆ t) (hsk : s.encard ≤ k) (hkt : k ≤ t.encard) : 
    ∃ r, s ⊆ r ∧ r ⊆ t ∧ r.encard = k := by 
  obtain (hs | hs) := eq_or_ne s.encard ⊤
  · rw [hs, top_le_iff] at hsk; subst hsk; exact ⟨s, Subset.rfl, hst, hs⟩ 
  obtain ⟨k, rfl⟩ := exists_add_of_le hsk
  obtain ⟨k', hk'⟩ := exists_add_of_le hkt
  have hk : k ≤ encard (t \ s)
  · rw [←encard_diff_add_encard_of_subset hst, add_comm] at hkt
    exact WithTop.le_of_add_le_add_right hs hkt   
  obtain ⟨r', hr', rfl⟩ := exists_subset_encard_eq hk
  refine' ⟨s ∪ r', subset_union_left _ _, union_subset hst (hr'.trans (diff_subset _ _)), _⟩ 
  rw [encard_union_eq (disjoint_of_subset_right hr' disjoint_sdiff_right)]

theorem encard_image_of_injOn (h : InjOn f s) : (f '' s).encard = s.encard := by 
  rw [encard, PartENat.card_image_of_injOn h, encard]
  
theorem encard_image_of_injective (hf : f.Injective) : (f '' s).encard = s.encard :=
  encard_image_of_injOn (hf.injOn s)

theorem encard_image_le (f : α → β) (s : Set α) : (f '' s).encard ≤ s.encard := by 
  obtain (h | h) := isEmpty_or_nonempty α 
  · rw [s.eq_empty_of_isEmpty]; simp
  rw [←encard_image_of_injOn (Function.invFunOn_injOn_image f s)]
  apply encard_le_of_subset
  exact Function.invFunOn_image_image_subset f s
  
theorem Finite.injOn_of_encard_image_eq (hs : s.Finite) (h : (f '' s).encard = s.encard) :
    InjOn f s := by 
  obtain (h' | hne) := isEmpty_or_nonempty α 
  · rw [s.eq_empty_of_isEmpty]; simp
  rw [←encard_image_of_injOn (Function.invFunOn_injOn_image f s)] at h
  rw [Function.injOn_iff_invFunOn_image_image_eq_self]
  exact hs.eq_of_subset_of_encard_le (Function.invFunOn_image_image_subset f s) h.symm.le
  
theorem encard_preimage_of_injective_subset_range {f : α → β} {s : Set β} (hf : f.Injective) 
    (hs : s ⊆ range f) : (f ⁻¹' s).encard = s.encard := by 
  rw [←encard_image_of_injective hf, image_preimage_eq_inter_range, 
    inter_eq_self_of_subset_left hs] 

theorem encard_eq_add_one_iff {k : ℕ∞} : 
    s.encard = k + 1 ↔ (∃ a t, ¬a ∈ t ∧ insert a t = s ∧ t.encard = k) := by
  refine' ⟨fun h ↦ _, _⟩
  · obtain ⟨a, ha⟩ := nonempty_of_encard_ne_zero (s := s) (by simp [h])
    refine' ⟨a, s \ {a}, fun h ↦ h.2 rfl, by rwa [insert_diff_singleton, insert_eq_of_mem], _⟩ 
    rw [←WithTop.add_right_cancel_iff WithTop.one_ne_top, ←h, 
      encard_diff_singleton_add_one_of_mem ha]
  rintro ⟨a, t, h, rfl, rfl⟩ 
  rw [encard_insert_of_not_mem h]



  
section ncard

open Nat

/-- A tactic (for use in default params) that applies `Set.toFinite` to synthesize a
  `Set.Finite` term. -/
syntax "toFinite_tac" : tactic

macro_rules
  | `(tactic| toFinite_tac) => `(tactic| apply Set.toFinite)

syntax "toENat_tac" : tactic

macro_rules
  | `(tactic| toENat_tac) => `(tactic| 
      simp only [←Nat.cast_le (α := ℕ∞), ←Nat.cast_inj (R := ℕ∞), Nat.cast_add, Nat.cast_one])


/-- The cardinality of `s : Set α` . Has the junk value `0` if `s` is infinite -/
noncomputable def ncard (s : Set α) :=
  ENat.toNat s.encard

theorem ncard_def (s : Set α) : s.ncard = ENat.toNat s.encard := rfl 

theorem Finite.cast_ncard_eq (hs : s.Finite) : s.ncard = s.encard := by
  rwa [ncard, ENat.coe_toNat_eq_self, ne_eq, encard_eq_top_iff, Set.Infinite, not_not]

theorem ncard_eq_nat_card (s : Set α) : s.ncard = Nat.card s := by
  obtain (h | h) := s.finite_or_infinite
  · have := h.fintype
    rw [ncard, h.encard_eq_coe_toFinset_card, Nat.card_eq_fintype_card, 
      toFinite_toFinset, toFinset_card, ENat.toNat_coe]
  have := infinite_coe_iff.2 h
  rw [ncard, h.encard_eq, Nat.card_eq_zero_of_infinite, ENat.toNat_top]

theorem ncard_eq_toFinset_card (s : Set α) (hs : s.Finite := by toFinite_tac) :
    s.ncard = hs.toFinset.card := by
  rw [ncard_eq_nat_card, @Nat.card_eq_fintype_card _ hs.fintype, @Finite.card_toFinset _ _ hs.fintype hs]
#align set.ncard_eq_to_finset_card Set.ncard_eq_toFinset_card

theorem ncard_eq_toFinset_card' (s : Set α) [Fintype s] :
    s.ncard = s.toFinset.card := by
  simp [ncard_eq_nat_card, Nat.card_eq_fintype_card]

theorem Infinite.ncard (hs : s.Infinite) : s.ncard = 0 := by
  rw [ncard_eq_nat_card, @Nat.card_eq_zero_of_infinite _ hs.to_subtype]
#align set.infinite.ncard Set.Infinite.ncard

theorem ncard_le_of_subset (hst : s ⊆ t) (ht : t.Finite := by toFinite_tac) :
    s.ncard ≤ t.ncard := by
  rw [←Nat.cast_le (α := ℕ∞), ht.cast_ncard_eq, (ht.subset hst).cast_ncard_eq]
  exact encard_mono hst
#align set.ncard_le_of_subset Set.ncard_le_of_subset

theorem ncard_mono [Finite α] : @Monotone (Set α) _ _ _ ncard := fun _ _ ↦ ncard_le_of_subset
#align set.ncard_mono Set.ncard_mono

@[simp] theorem ncard_eq_zero (hs : s.Finite := by toFinite_tac) :
    s.ncard = 0 ↔ s = ∅ := by
  rw [←Nat.cast_inj (R := ℕ∞), hs.cast_ncard_eq, Nat.cast_zero, encard_eq_zero]
#align set.ncard_eq_zero Set.ncard_eq_zero

@[simp] theorem ncard_coe_Finset (s : Finset α) : (s : Set α).ncard = s.card := by
  rw [ncard_eq_toFinset_card _, Finset.finite_toSet_toFinset]
#align set.ncard_coe_finset Set.ncard_coe_Finset

theorem ncard_univ (α : Type _) : (univ : Set α).ncard = Nat.card α := by
  cases' finite_or_infinite α with h h
  · have hft := Fintype.ofFinite α
    rw [ncard_eq_toFinset_card, Finite.toFinset_univ, Finset.card_univ, Nat.card_eq_fintype_card]
  rw [Nat.card_eq_zero_of_infinite, Infinite.ncard]
  exact infinite_univ
#align set.ncard_univ Set.ncard_univ

@[simp] theorem ncard_empty (α : Type _) : (∅ : Set α).ncard = 0 := by
  rw [ncard_eq_zero]
#align set.ncard_empty Set.ncard_empty

theorem ncard_pos (hs : s.Finite := by toFinite_tac) : 0 < s.ncard ↔ s.Nonempty := by
  rw [pos_iff_ne_zero, Ne.def, ncard_eq_zero hs, nonempty_iff_ne_empty]
#align set.ncard_pos Set.ncard_pos

theorem ncard_ne_zero_of_mem (h : a ∈ s) (hs : s.Finite := by toFinite_tac) : s.ncard ≠ 0 :=
  ((ncard_pos hs).mpr ⟨a, h⟩).ne.symm
#align set.ncard_ne_zero_of_mem Set.ncard_ne_zero_of_mem

theorem finite_of_ncard_ne_zero (hs : s.ncard ≠ 0) : s.Finite :=
  s.finite_or_infinite.elim id fun h ↦ (hs h.ncard).elim
#align set.finite_of_ncard_ne_zero Set.finite_of_ncard_ne_zero

theorem finite_of_ncard_pos (hs : 0 < s.ncard) : s.Finite :=
  finite_of_ncard_ne_zero hs.ne.symm
#align set.finite_of_ncard_pos Set.finite_of_ncard_pos

theorem nonempty_of_ncard_ne_zero (hs : s.ncard ≠ 0) : s.Nonempty := by
  rw [nonempty_iff_ne_empty]; rintro rfl; simp at hs
#align set.nonempty_of_ncard_ne_zero Set.nonempty_of_ncard_ne_zero

@[simp] theorem ncard_singleton (a : α) : ({a} : Set α).ncard = 1 := by
  simp [ncard_eq_toFinset_card]
#align set.ncard_singleton Set.ncard_singleton

theorem ncard_singleton_inter (a : α) (s : Set α) : ({a} ∩ s).ncard ≤ 1 := by
  rw [←Nat.cast_le (α := ℕ∞), (toFinite _).cast_ncard_eq, Nat.cast_one]
  apply encard_singleton_inter
#align set.ncard_singleton_inter Set.ncard_singleton_inter

section InsertErase

@[simp] theorem ncard_insert_of_not_mem (h : a ∉ s) (hs : s.Finite := by toFinite_tac) :
    (insert a s).ncard = s.ncard + 1 := by
  rw [←Nat.cast_inj (R := ℕ∞), (hs.insert a).cast_ncard_eq, Nat.cast_add, Nat.cast_one, 
    hs.cast_ncard_eq, encard_insert_of_not_mem h]
#align set.ncard_insert_of_not_mem Set.ncard_insert_of_not_mem

theorem ncard_insert_of_mem (h : a ∈ s) : ncard (insert a s) = s.ncard := by
    rw [insert_eq_of_mem h]
#align set.ncard_insert_of_mem Set.ncard_insert_of_mem

theorem ncard_insert_le (a : α) (s : Set α) : (insert a s).ncard ≤ s.ncard + 1 := by
  obtain hs | hs := s.finite_or_infinite
  · toENat_tac; rw [hs.cast_ncard_eq, (hs.insert _).cast_ncard_eq]; apply encard_insert_le
  rw [(hs.mono (subset_insert a s)).ncard]
  exact Nat.zero_le _
#align set.ncard_insert_le Set.ncard_insert_le

theorem ncard_insert_eq_ite [Decidable (a ∈ s)] (hs : s.Finite := by toFinite_tac) :
    ncard (insert a s) = if a ∈ s then s.ncard else s.ncard + 1 := by
  by_cases h : a ∈ s
  · rw [ncard_insert_of_mem h, if_pos h]
  · rw [ncard_insert_of_not_mem h hs, if_neg h]
#align set.ncard_insert_eq_ite Set.ncard_insert_eq_ite

theorem ncard_le_ncard_insert (a : α) (s : Set α) : s.ncard ≤ (insert a s).ncard := by
  classical
  refine'
    s.finite_or_infinite.elim (fun h ↦ _) (fun h ↦ by (rw [h.ncard]; exact Nat.zero_le _))
  rw [ncard_insert_eq_ite h]; split_ifs <;> simp
#align set.ncard_le_ncard_insert Set.ncard_le_ncard_insert

@[simp] theorem ncard_pair (h : a ≠ b) : ({a, b} : Set α).ncard = 2 := by
  rw [ncard_insert_of_not_mem, ncard_singleton]; simpa
#align set.card_doubleton Set.ncard_pair

@[simp] theorem ncard_diff_singleton_add_one (h : a ∈ s) (hs : s.Finite := by toFinite_tac) :
    (s \ {a}).ncard + 1 = s.ncard := by
  toENat_tac; rw [hs.cast_ncard_eq, (hs.diff _).cast_ncard_eq, 
    encard_diff_singleton_add_one_of_mem h]
#align set.ncard_diff_singleton_add_one Set.ncard_diff_singleton_add_one

@[simp] theorem ncard_diff_singleton_of_mem (h : a ∈ s) (hs : s.Finite := by toFinite_tac) :
    (s \ {a}).ncard = s.ncard - 1 :=
  eq_tsub_of_add_eq (ncard_diff_singleton_add_one h hs)
#align set.ncard_diff_singleton_of_mem Set.ncard_diff_singleton_of_mem

theorem ncard_diff_singleton_lt_of_mem (h : a ∈ s) (hs : s.Finite := by toFinite_tac) :
    (s \ {a}).ncard < s.ncard := by
  rw [← ncard_diff_singleton_add_one h hs]; apply lt_add_one
#align set.ncard_diff_singleton_lt_of_mem Set.ncard_diff_singleton_lt_of_mem

theorem ncard_diff_singleton_le (s : Set α) (a : α) : (s \ {a}).ncard ≤ s.ncard := by
  obtain hs | hs := s.finite_or_infinite
  · apply ncard_le_of_subset (diff_subset _ _) hs
  convert @zero_le ℕ _ _
  exact (hs.diff (by simp : Set.Finite {a})).ncard
#align set.ncard_diff_singleton_le Set.ncard_diff_singleton_le

theorem pred_ncard_le_ncard_diff_singleton (s : Set α) (a : α) : s.ncard - 1 ≤ (s \ {a}).ncard := by
  cases' s.finite_or_infinite with hs hs
  · by_cases h : a ∈ s
    · rw [ncard_diff_singleton_of_mem h hs]
    rw [diff_singleton_eq_self h]
    apply Nat.pred_le
  convert Nat.zero_le _
  rw [hs.ncard]
#align set.pred_ncard_le_ncard_diff_singleton Set.pred_ncard_le_ncard_diff_singleton

theorem ncard_exchange (ha : a ∉ s) (hb : b ∈ s) : (insert a (s \ {b})).ncard = s.ncard := by
  rw [ncard_def, encard_exchange ha hb, ←ncard_def]
#align set.ncard_exchange Set.ncard_exchange

theorem ncard_exchange' (ha : a ∉ s) (hb : b ∈ s) : (insert a s \ {b}).ncard = s.ncard := by
  rw [← ncard_exchange ha hb, ← singleton_union, ← singleton_union, union_diff_distrib,
    @diff_singleton_eq_self _ b {a} fun h ↦ ha (by rwa [← mem_singleton_iff.mp h])]
#align set.ncard_exchange' Set.ncard_exchange'

end InsertErase

theorem ncard_image_le (hs : s.Finite := by toFinite_tac) : (f '' s).ncard ≤ s.ncard := by
  toENat_tac; rw [hs.cast_ncard_eq, (hs.image _).cast_ncard_eq]; apply encard_image_le
#align set.ncard_image_le Set.ncard_image_le

theorem ncard_image_of_injOn (H : Set.InjOn f s) : (f '' s).ncard = s.ncard := by
  rw [ncard_def, encard_image_of_injOn H, ←ncard_def]
#align set.ncard_image_of_inj_on Set.ncard_image_of_injOn

theorem injOn_of_ncard_image_eq (h : (f '' s).ncard = s.ncard) (hs : s.Finite := by toFinite_tac) :
    Set.InjOn f s := by
  rw [←Nat.cast_inj (R := ℕ∞), hs.cast_ncard_eq, (hs.image _).cast_ncard_eq] at h
  exact hs.injOn_of_encard_image_eq h
#align set.inj_on_of_ncard_image_eq Set.injOn_of_ncard_image_eq

theorem ncard_image_iff (hs : s.Finite := by toFinite_tac) :
    (f '' s).ncard = s.ncard ↔ Set.InjOn f s :=
  ⟨fun h ↦ injOn_of_ncard_image_eq h hs, ncard_image_of_injOn⟩
#align set.ncard_image_iff Set.ncard_image_iff

theorem ncard_image_of_injective (s : Set α) (H : f.Injective) : (f '' s).ncard = s.ncard :=
  ncard_image_of_injOn fun _ _ _ _ h ↦ H h
#align set.ncard_image_of_injective Set.ncard_image_of_injective

theorem ncard_preimage_of_injective_subset_range {s : Set β} (H : f.Injective)
  (hs : s ⊆ Set.range f) :
    (f ⁻¹' s).ncard = s.ncard := by
  rw [← ncard_image_of_injective _ H, image_preimage_eq_iff.mpr hs]
#align set.ncard_preimage_of_injective_subset_range Set.ncard_preimage_of_injective_subset_range

theorem fiber_ncard_ne_zero_iff_mem_image {y : β} (hs : s.Finite := by toFinite_tac) :
    { x ∈ s | f x = y }.ncard ≠ 0 ↔ y ∈ f '' s := by
  refine' ⟨nonempty_of_ncard_ne_zero, _⟩
  rintro ⟨z, hz, rfl⟩
  exact @ncard_ne_zero_of_mem _ ({ x ∈ s | f x = f z }) z (mem_sep hz rfl)
    (hs.subset (sep_subset _ _))
#align set.fiber_ncard_ne_zero_iff_mem_image Set.fiber_ncard_ne_zero_iff_mem_image

@[simp] theorem ncard_map (f : α ↪ β) : (f '' s).ncard = s.ncard :=
  ncard_image_of_injective _ f.inj'
#align set.ncard_map Set.ncard_map

@[simp] theorem ncard_subtype (P : α → Prop) (s : Set α) :
    { x : Subtype P | (x : α) ∈ s }.ncard = (s ∩ setOf P).ncard := by
  convert (ncard_image_of_injective _ (@Subtype.coe_injective _ P)).symm
  ext x
  simp [←and_assoc, exists_eq_right]
#align set.ncard_subtype Set.ncard_subtype

@[simp] theorem Nat.card_coe_set_eq (s : Set α) : Nat.card s = s.ncard := by
  convert (ncard_image_of_injective univ Subtype.coe_injective).symm using 1
  · rw [ncard_univ]
  simp
#align set.nat.card_coe_set_eq Set.Nat.card_coe_set_eq

theorem ncard_inter_le_ncard_left (s t : Set α) (hs : s.Finite := by toFinite_tac) :
    (s ∩ t).ncard ≤ s.ncard :=
  ncard_le_of_subset (inter_subset_left _ _) hs
#align set.ncard_inter_le_ncard_left Set.ncard_inter_le_ncard_left

theorem ncard_inter_le_ncard_right (s t : Set α) (ht : t.Finite := by toFinite_tac) :
    (s ∩ t).ncard ≤ t.ncard :=
  ncard_le_of_subset (inter_subset_right _ _) ht
#align set.ncard_inter_le_ncard_right Set.ncard_inter_le_ncard_right

theorem eq_of_subset_of_ncard_le (h : s ⊆ t) (h' : t.ncard ≤ s.ncard)
    (ht : t.Finite := by toFinite_tac) : s = t := 
  ht.eq_of_subset_of_encard_le h 
    (by rwa [←Nat.cast_le (α := ℕ∞), ht.cast_ncard_eq, (ht.subset h).cast_ncard_eq] at h')
#align set.eq_of_subset_of_ncard_le Set.eq_of_subset_of_ncard_le

theorem subset_iff_eq_of_ncard_le (h : t.ncard ≤ s.ncard) (ht : t.Finite := by toFinite_tac) :
    s ⊆ t ↔ s = t :=
  ⟨fun hst ↦ eq_of_subset_of_ncard_le hst h ht, Eq.subset'⟩
#align set.subset_iff_eq_of_ncard_le Set.subset_iff_eq_of_ncard_le

theorem map_eq_of_subset {f : α ↪ α} (h : f '' s ⊆ s) (hs : s.Finite := by toFinite_tac) :
    f '' s = s :=
  eq_of_subset_of_ncard_le h (ncard_map _).ge hs
#align set.map_eq_of_subset Set.map_eq_of_subset

theorem sep_of_ncard_eq {P : α → Prop} (h : { x ∈ s | P x }.ncard = s.ncard) (ha : a ∈ s)
    (hs : s.Finite := by toFinite_tac) : P a :=
  sep_eq_self_iff_mem_true.mp (eq_of_subset_of_ncard_le (by simp) h.symm.le hs) _ ha
#align set.sep_of_ncard_eq Set.sep_of_ncard_eq

theorem ncard_lt_ncard (h : s ⊂ t) (ht : t.Finite := by toFinite_tac) :
    s.ncard < t.ncard := by
  rw [←Nat.cast_lt (α := ℕ∞), ht.cast_ncard_eq, (ht.subset h.subset).cast_ncard_eq]
  exact ht.encard_lt_encard h
#align set.ncard_lt_ncard Set.ncard_lt_ncard

theorem ncard_strictMono [Finite α] : @StrictMono (Set α) _ _ _ ncard :=
  fun _ _ h ↦ ncard_lt_ncard h
#align set.ncard_strict_mono Set.ncard_strictMono

theorem ncard_eq_of_bijective {n : ℕ} (f : ∀ i, i < n → α)
    (hf : ∀ a ∈ s, ∃ i, ∃ h : i < n, f i h = a) (hf' : ∀ (i) (h : i < n), f i h ∈ s)
    (f_inj : ∀ (i j) (hi : i < n) (hj : j < n), f i hi = f j hj → i = j)
    (hs : s.Finite := by toFinite_tac) :
    s.ncard = n := by
  rw [ncard_eq_toFinset_card _ hs]
  apply Finset.card_eq_of_bijective
  all_goals simpa
#align set.ncard_eq_of_bijective Set.ncard_eq_of_bijective

-- theorem ncard_congr {t : Set β} (f : ∀ a ∈ s, β) (h₁ : ∀ a ha, f a ha ∈ t)
--     (h₂ : ∀ a b ha hb, f a ha = f b hb → a = b) (h₃ : ∀ b ∈ t, ∃ a ha, f a ha = b) :
--     s.ncard = t.ncard := by
--   set f' : s → t := fun x ↦ ⟨f x.1 x.2, h₁ _ _⟩
--   have hbij : f'.Bijective := by
--     constructor
--     · rintro ⟨x, hx⟩ ⟨y, hy⟩ hxy
--       simp only [Subtype.mk.injEq] at hxy ⊢
--       exact h₂ _ _ hx hy hxy
--     rintro ⟨y, hy⟩
--     obtain ⟨a, ha, rfl⟩ := h₃ y hy
--     simp only [Subtype.mk.injEq, Subtype.exists]
--     exact ⟨_, ha, rfl⟩
--   exact Nat.card_congr (Equiv.ofBijective f' hbij)
-- #align set.ncard_congr Set.ncard_congr

theorem ncard_le_ncard_of_injOn {t : Set β} (f : α → β) (hf : ∀ a ∈ s, f a ∈ t) (f_inj : InjOn f s)
    (ht : t.Finite := by toFinite_tac) :
    s.ncard ≤ t.ncard := by
  cases' s.finite_or_infinite with h h
  · haveI := h.to_subtype
    rw [ncard_eq_toFinset_card _ ht, ncard_eq_toFinset_card _ (toFinite s)]
    exact Finset.card_le_card_of_inj_on f (by simpa) (by simpa)
  convert Nat.zero_le _
  rw [h.ncard]
#align set.ncard_le_ncard_of_inj_on Set.ncard_le_ncard_of_injOn

theorem exists_ne_map_eq_of_ncard_lt_of_maps_to {t : Set β} (hc : t.ncard < s.ncard) {f : α → β}
  (hf : ∀ a ∈ s, f a ∈ t) (ht : t.Finite := by toFinite_tac) :
    ∃ x ∈ s, ∃ y ∈ s, x ≠ y ∧ f x = f y := by
  by_contra h'
  simp only [Ne.def, exists_prop, not_exists, not_and, not_imp_not] at h'
  exact (ncard_le_ncard_of_injOn f hf h' ht).not_lt hc
#align set.exists_ne_map_eq_of_ncard_lt_of_maps_to Set.exists_ne_map_eq_of_ncard_lt_of_maps_to

theorem le_ncard_of_inj_on_range {n : ℕ} (f : ℕ → α) (hf : ∀ i < n, f i ∈ s)
  (f_inj : ∀ i < n, ∀ j < n, f i = f j → i = j) (hs : s.Finite := by toFinite_tac) :
    n ≤ s.ncard := by
  rw [ncard_eq_toFinset_card _ hs]
  apply Finset.le_card_of_inj_on_range <;> simpa
#align set.le_ncard_of_inj_on_range Set.le_ncard_of_inj_on_range

theorem surj_on_of_inj_on_of_ncard_le {t : Set β} (f : ∀ a ∈ s, β) (hf : ∀ a ha, f a ha ∈ t)
  (hinj : ∀ a₁ a₂ ha₁ ha₂, f a₁ ha₁ = f a₂ ha₂ → a₁ = a₂) (hst : t.ncard ≤ s.ncard)
  (ht : t.Finite := by toFinite_tac) :
    ∀ b ∈ t, ∃ a ha, b = f a ha := by
  intro b hb
  set f' : s → t := fun x ↦ ⟨f x.1 x.2, hf _ _⟩
  have finj : f'.Injective := by
    rintro ⟨x, hx⟩ ⟨y, hy⟩ hxy
    simp only [Subtype.mk.injEq] at hxy ⊢
    apply hinj _ _ hx hy hxy
  have hft := ht.fintype
  have hft' := Fintype.ofInjective f' finj
  simp_rw [ncard_eq_toFinset_card] at hst
  set f'' : ∀ a, a ∈ s.toFinset → β := fun a h ↦ f a (by simpa using h)
  convert @Finset.surj_on_of_inj_on_of_card_le _ _ _ t.toFinset f'' _ _ _ (by simpa) (by simpa)
  · simp
  · simp [hf]
  · intros a₁ a₂ ha₁ ha₂ h
    rw [mem_toFinset] at ha₁ ha₂
    exact hinj _ _ ha₁ ha₂ h
  rwa [←ncard_eq_toFinset_card', ←ncard_eq_toFinset_card']
#align set.surj_on_of_inj_on_of_ncard_le Set.surj_on_of_inj_on_of_ncard_le

theorem inj_on_of_surj_on_of_ncard_le {t : Set β} (f : ∀ a ∈ s, β) (hf : ∀ a ha, f a ha ∈ t)
    (hsurj : ∀ b ∈ t, ∃ a ha, b = f a ha) (hst : s.ncard ≤ t.ncard) ⦃a₁ a₂⦄ (ha₁ : a₁ ∈ s)
    (ha₂ : a₂ ∈ s) (ha₁a₂ : f a₁ ha₁ = f a₂ ha₂) (hs : s.Finite := by toFinite_tac) :
    a₁ = a₂ := by
  classical
  set f' : s → t := fun x ↦ ⟨f x.1 x.2, hf _ _⟩
  have hsurj : f'.Surjective := by
    rintro ⟨y, hy⟩
    obtain ⟨a, ha, rfl⟩ := hsurj y hy
    simp only [Subtype.mk.injEq, Subtype.exists]
    exact ⟨_, ha, rfl⟩
  haveI := hs.fintype
  haveI := Fintype.ofSurjective _ hsurj
  simp_rw [ncard_eq_toFinset_card] at hst
  set f'' : ∀ a, a ∈ s.toFinset → β := fun a h ↦ f a (by simpa using h)
  exact
    @Finset.inj_on_of_surj_on_of_card_le _ _ _ t.toFinset f''
      (fun a ha ↦ by { rw [mem_toFinset] at ha ⊢; exact hf a ha }) (by simpa)
      (by { rwa [←ncard_eq_toFinset_card', ←ncard_eq_toFinset_card'] }) a₁ a₂
      (by simpa) (by simpa) (by simpa)
#align set.inj_on_of_surj_on_of_ncard_le Set.inj_on_of_surj_on_of_ncard_le

section Lattice

theorem ncard_union_add_ncard_inter (s t : Set α) (hs : s.Finite := by toFinite_tac)
    (ht : t.Finite := by toFinite_tac) : (s ∪ t).ncard + (s ∩ t).ncard = s.ncard + t.ncard := by
  toENat_tac; rw [hs.cast_ncard_eq, ht.cast_ncard_eq, (hs.union ht).cast_ncard_eq, 
    (hs.subset (inter_subset_left _ _)).cast_ncard_eq, encard_union_add_encard_inter]
#align set.ncard_union_add_ncard_inter Set.ncard_union_add_ncard_inter

theorem ncard_inter_add_ncard_union (s t : Set α) (hs : s.Finite := by toFinite_tac)
    (ht : t.Finite := by toFinite_tac) : (s ∩ t).ncard + (s ∪ t).ncard = s.ncard + t.ncard := by
  rw [add_comm, ncard_union_add_ncard_inter _ _ hs ht]
#align set.ncard_inter_add_ncard_union Set.ncard_inter_add_ncard_union

theorem ncard_union_le (s t : Set α) : (s ∪ t).ncard ≤ s.ncard + t.ncard := by
  obtain (h | h) := (s ∪ t).finite_or_infinite 
  · toENat_tac
    rw [h.cast_ncard_eq, (h.subset (subset_union_left _ _)).cast_ncard_eq, 
      (h.subset (subset_union_right _ _)).cast_ncard_eq]
    apply encard_union_le
  rw [h.ncard]
  apply zero_le
#align set.ncard_union_le Set.ncard_union_le

theorem ncard_union_eq (h : Disjoint s t) (hs : s.Finite := by toFinite_tac)
    (ht : t.Finite := by toFinite_tac) : (s ∪ t).ncard = s.ncard + t.ncard := by
  toENat_tac
  rw [hs.cast_ncard_eq, ht.cast_ncard_eq, (hs.union ht).cast_ncard_eq, encard_union_eq h]
#align set.ncard_union_eq Set.ncard_union_eq

theorem ncard_diff_add_ncard_of_subset (h : s ⊆ t) (ht : t.Finite := by toFinite_tac) :
    (t \ s).ncard + s.ncard = t.ncard := by
  toENat_tac
  rw [ht.cast_ncard_eq, (ht.subset h).cast_ncard_eq, (ht.diff _).cast_ncard_eq, 
    encard_diff_add_encard_of_subset]
#align set.ncard_diff_add_ncard_eq_ncard Set.ncard_diff_add_ncard_of_subset

theorem ncard_diff (h : s ⊆ t) (ht : t.Finite := by toFinite_tac) :
    (t \ s).ncard = t.ncard - s.ncard := by
  rw [← ncard_diff_add_ncard_of_subset h ht, add_tsub_cancel_right]
#align set.ncard_diff Set.ncard_diff

theorem ncard_le_ncard_diff_add_ncard (s t : Set α) (ht : t.Finite := by toFinite_tac) :
    s.ncard ≤ (s \ t).ncard + t.ncard := by
  cases' s.finite_or_infinite with hs hs
  · toENat_tac
    rw [ht.cast_ncard_eq, hs.cast_ncard_eq, (hs.diff _).cast_ncard_eq]
    apply encard_le_encard_diff_add_encard
  convert Nat.zero_le _
  rw [hs.ncard]
#align set.ncard_le_ncard_diff_add_ncard Set.ncard_le_ncard_diff_add_ncard

theorem le_ncard_diff (s t : Set α) (hs : s.Finite := by toFinite_tac) :
    t.ncard - s.ncard ≤ (t \ s).ncard :=
  tsub_le_iff_left.mpr (by rw [add_comm]; apply ncard_le_ncard_diff_add_ncard _ _ hs)
#align set.le_ncard_diff Set.le_ncard_diff

theorem ncard_diff_add_ncard (s t : Set α) (hs : s.Finite := by toFinite_tac)
  (ht : t.Finite := by toFinite_tac) :
    (s \ t).ncard + t.ncard = (s ∪ t).ncard := by
  rw [← union_diff_right, ncard_diff_add_ncard_eq_ncard (subset_union_right s t) (hs.union ht)]
#align set.ncard_diff_add_ncard Set.ncard_diff_add_ncard

theorem diff_nonempty_of_ncard_lt_ncard (h : s.ncard < t.ncard) (hs : s.Finite := by toFinite_tac) :
    (t \ s).Nonempty := by
  rw [Set.nonempty_iff_ne_empty, Ne.def, diff_eq_empty]
  exact fun h' ↦ h.not_le (ncard_le_of_subset h' hs)
#align set.diff_nonempty_of_ncard_lt_ncard Set.diff_nonempty_of_ncard_lt_ncard

theorem exists_mem_not_mem_of_ncard_lt_ncard (h : s.ncard < t.ncard)
  (hs : s.Finite := by toFinite_tac) : ∃ e, e ∈ t ∧ e ∉ s :=
  diff_nonempty_of_ncard_lt_ncard h hs
#align set.exists_mem_not_mem_of_ncard_lt_ncard Set.exists_mem_not_mem_of_ncard_lt_ncard

@[simp] theorem ncard_inter_add_ncard_diff_eq_ncard (s t : Set α)
    (hs : s.Finite := by toFinite_tac) :
    (s ∩ t).ncard + (s \ t).ncard = s.ncard := by
  simp_rw [← ncard_diff_add_ncard_eq_ncard (diff_subset s t) hs, sdiff_sdiff_right_self,
    inf_eq_inter]
#align set.ncard_inter_add_ncard_diff_eq_ncard Set.ncard_inter_add_ncard_diff_eq_ncard

theorem ncard_eq_ncard_iff_ncard_diff_eq_ncard_diff (hs : s.Finite := by toFinite_tac)
    (ht : t.Finite := by toFinite_tac) : s.ncard = t.ncard ↔ (s \ t).ncard = (t \ s).ncard := by
  rw [← ncard_inter_add_ncard_diff_eq_ncard s t hs, ← ncard_inter_add_ncard_diff_eq_ncard t s ht,
    inter_comm, add_right_inj]
#align set.ncard_eq_ncard_iff_ncard_diff_eq_ncard_diff Set.ncard_eq_ncard_iff_ncard_diff_eq_ncard_diff

theorem ncard_le_ncard_iff_ncard_diff_le_ncard_diff (hs : s.Finite := by toFinite_tac)
    (ht : t.Finite := by toFinite_tac) : s.ncard ≤ t.ncard ↔ (s \ t).ncard ≤ (t \ s).ncard := by
  rw [← ncard_inter_add_ncard_diff_eq_ncard s t hs, ← ncard_inter_add_ncard_diff_eq_ncard t s ht,
    inter_comm, add_le_add_iff_left]
#align set.ncard_le_ncard_iff_ncard_diff_le_ncard_diff
  Set.ncard_le_ncard_iff_ncard_diff_le_ncard_diff

theorem ncard_lt_ncard_iff_ncard_diff_lt_ncard_diff (hs : s.Finite := by toFinite_tac)
    (ht : t.Finite := by toFinite_tac) : s.ncard < t.ncard ↔ (s \ t).ncard < (t \ s).ncard := by
  rw [← ncard_inter_add_ncard_diff_eq_ncard s t hs, ← ncard_inter_add_ncard_diff_eq_ncard t s ht,
    inter_comm, add_lt_add_iff_left]
#align set.ncard_lt_ncard_iff_ncard_diff_lt_ncard_diff Set.ncard_lt_ncard_iff_ncard_diff_lt_ncard_diff

theorem ncard_add_ncard_compl (s : Set α) (hs : s.Finite := by toFinite_tac)
    (hsc : sᶜ.Finite := by toFinite_tac) : s.ncard + sᶜ.ncard = Nat.card α := by
  rw [← ncard_univ, ← ncard_union_eq (@disjoint_compl_right _ _ s) hs hsc, union_compl_self]
#align set.ncard_add_ncard_compl Set.ncard_add_ncard_compl

end Lattice

/-- Given a set `t` and a set `s` inside it, we can shrink `t` to any appropriate size, and keep `s`
    inside it. -/
theorem exists_intermediate_Set (i : ℕ) (h₁ : i + s.ncard ≤ t.ncard) (h₂ : s ⊆ t) :
    ∃ r : Set α, s ⊆ r ∧ r ⊆ t ∧ r.ncard = i + s.ncard := by
  cases' t.finite_or_infinite with ht ht
  · rw [ncard_eq_toFinset_card _ (ht.subset h₂)] at h₁ ⊢
    rw [ncard_eq_toFinset_card t ht] at h₁
    obtain ⟨r', hsr', hr't, hr'⟩ := Finset.exists_intermediate_set _ h₁ (by simpa)
    exact ⟨r', by simpa using hsr', by simpa using hr't, by rw [← hr', ncard_coe_Finset]⟩
  rw [ht.ncard] at h₁
  have h₁' := Nat.eq_zero_of_le_zero h₁
  rw [add_eq_zero_iff] at h₁'
  refine' ⟨t, h₂, rfl.subset, _⟩
  rw [h₁'.2, h₁'.1, ht.ncard, add_zero]
#align set.exists_intermediate_set Set.exists_intermediate_Set

theorem exists_intermediate_set' {m : ℕ} (hs : s.ncard ≤ m) (ht : m ≤ t.ncard) (h : s ⊆ t) :
    ∃ r : Set α, s ⊆ r ∧ r ⊆ t ∧ r.ncard = m := by
  obtain ⟨r, hsr, hrt, hc⟩ :=
    exists_intermediate_Set (m - s.ncard) (by rwa [tsub_add_cancel_of_le hs]) h
  rw [tsub_add_cancel_of_le hs] at hc
  exact ⟨r, hsr, hrt, hc⟩
#align set.exists_intermediate_set' Set.exists_intermediate_set'

/-- We can shrink `s` to any smaller size. -/
theorem exists_smaller_set (s : Set α) (i : ℕ) (h₁ : i ≤ s.ncard) :
    ∃ t : Set α, t ⊆ s ∧ t.ncard = i :=
  (exists_intermediate_Set i (by simpa) (empty_subset s)).imp fun t ht ↦
    ⟨ht.2.1, by simpa using ht.2.2⟩
#align set.exists_smaller_set Set.exists_smaller_set

theorem Infinite.exists_subset_ncard_eq {s : Set α} (hs : s.Infinite) (k : ℕ) :
    ∃ t, t ⊆ s ∧ t.Finite ∧ t.ncard = k := by
  have := hs.to_subtype
  obtain ⟨t', -, rfl⟩ := @Infinite.exists_subset_card_eq s univ infinite_univ k
  refine' ⟨Subtype.val '' (t' : Set s), by simp, Finite.image _ (by simp), _⟩
  rw [ncard_image_of_injective _ Subtype.coe_injective]
  simp
#align set.Infinite.exists_subset_ncard_eq Set.Infinite.exists_subset_ncard_eq

theorem Infinite.exists_supset_ncard_eq {s t : Set α} (ht : t.Infinite) (hst : s ⊆ t)
    (hs : s.Finite) {k : ℕ} (hsk : s.ncard ≤ k) : ∃ s', s ⊆ s' ∧ s' ⊆ t ∧ s'.ncard = k := by
  obtain ⟨s₁, hs₁, hs₁fin, hs₁card⟩ := (ht.diff hs).exists_subset_ncard_eq (k - s.ncard)
  refine' ⟨s ∪ s₁, subset_union_left _ _, union_subset hst (hs₁.trans (diff_subset _ _)), _⟩
  rwa [ncard_union_eq (disjoint_of_subset_right hs₁ disjoint_sdiff_right) hs hs₁fin, hs₁card,
    add_tsub_cancel_of_le]
#align set.infinite.exists_supset_ncard_eq Set.Infinite.exists_supset_ncard_eq

theorem exists_subset_or_subset_of_two_mul_lt_ncard {n : ℕ} (hst : 2 * n < (s ∪ t).ncard) :
    ∃ r : Set α, n < r.ncard ∧ (r ⊆ s ∨ r ⊆ t) := by
  classical
  have hu := finite_of_ncard_ne_zero ((Nat.zero_le _).trans_lt hst).ne.symm
  rw [ncard_eq_toFinset_card _ hu,
    Finite.toFinset_union (hu.subset (subset_union_left _ _))
      (hu.subset (subset_union_right _ _))] at hst
  obtain ⟨r', hnr', hr'⟩ := Finset.exists_subset_or_subset_of_two_mul_lt_card hst
  exact ⟨r', by simpa, by simpa using hr'⟩
#align set.exists_subset_or_subset_of_two_mul_lt_ncard
  Set.exists_subset_or_subset_of_two_mul_lt_ncard

/-! ### Explicit description of a set from its cardinality -/

@[simp] theorem ncard_eq_one : s.ncard = 1 ↔ ∃ a, s = {a} := by
  refine' ⟨fun h ↦ _, by rintro ⟨a, rfl⟩; rw [ncard_singleton]⟩
  have hft := (finite_of_ncard_ne_zero (ne_zero_of_eq_one h)).fintype
  simp_rw [ncard_eq_toFinset_card', @Finset.card_eq_one _ (toFinset s)] at h
  refine' h.imp fun a ha ↦ _
  simp_rw [Set.ext_iff, mem_singleton_iff]
  simp only [Finset.ext_iff, mem_toFinset, Finset.mem_singleton] at ha
  exact ha
#align set.ncard_eq_one Set.ncard_eq_one

theorem exists_eq_insert_iff_ncard (hs : s.Finite := by toFinite_tac) :
    (∃ (a : α) (_ : a ∉ s), insert a s = t) ↔ s ⊆ t ∧ s.ncard + 1 = t.ncard := by
  classical
  cases' t.finite_or_infinite with ht ht
  · rw [ncard_eq_toFinset_card _ hs, ncard_eq_toFinset_card _ ht,
      ←@Finite.toFinset_subset_toFinset _ _ _ hs ht, ←Finset.exists_eq_insert_iff]
    convert Iff.rfl using 2 ; simp
    ext x
    simp [Finset.ext_iff, Set.ext_iff]
  simp only [ht.ncard, exists_prop, add_eq_zero, and_false, iff_false, not_exists, not_and]
  rintro x - rfl
  exact ht (hs.insert x)
#align set.exists_eq_insert_iff_ncard Set.exists_eq_insert_iff_ncard

theorem ncard_le_one (hs : s.Finite := by toFinite_tac) :
    s.ncard ≤ 1 ↔ ∀ a ∈ s, ∀ b ∈ s, a = b := by
  simp_rw [ncard_eq_toFinset_card _ hs, Finset.card_le_one, Finite.mem_toFinset]
#align set.ncard_le_one Set.ncard_le_one

theorem ncard_le_one_iff (hs : s.Finite := by toFinite_tac) :
    s.ncard ≤ 1 ↔ ∀ {a b}, a ∈ s → b ∈ s → a = b := by
  rw [ncard_le_one hs]
  tauto
#align set.ncard_le_one_iff Set.ncard_le_one_iff

theorem ncard_le_one_iff_eq (hs : s.Finite := by toFinite_tac) :
    s.ncard ≤ 1 ↔ s = ∅ ∨ ∃ a, s = {a} := by
  obtain rfl | ⟨x, hx⟩ := s.eq_empty_or_nonempty
  · exact iff_of_true (by simp) (Or.inl rfl)
  rw [ncard_le_one_iff hs]
  refine' ⟨fun h ↦ Or.inr ⟨x, (singleton_subset_iff.mpr hx).antisymm' fun y hy ↦ h hy hx⟩, _⟩
  rintro (rfl | ⟨a, rfl⟩)
  · exact (not_mem_empty _ hx).elim
  simp_rw [mem_singleton_iff] at hx ⊢; subst hx
  simp only [forall_eq_apply_imp_iff', imp_self, implies_true]
#align set.ncard_le_one_iff_eq Set.ncard_le_one_iff_eq

theorem ncard_le_one_iff_subset_singleton [Nonempty α]
  (hs : s.Finite := by toFinite_tac) :
    s.ncard ≤ 1 ↔ ∃ x : α, s ⊆ {x} := by
  simp_rw [ncard_eq_toFinset_card _ hs, Finset.card_le_one_iff_subset_singleton,
    Finite.toFinset_subset, Finset.coe_singleton]
#align set.ncard_le_one_iff_subset_singleton Set.ncard_le_one_iff_subset_singleton

/-- A `Set` of a subsingleton type has cardinality at most one. -/
theorem ncard_le_one_of_subsingleton [Subsingleton α] (s : Set α) : s.ncard ≤ 1 := by
  rw [ncard_eq_toFinset_card]
  exact Finset.card_le_one_of_subsingleton _
#align ncard_le_one_of_subsingleton Set.ncard_le_one_of_subsingleton

theorem one_lt_ncard (hs : s.Finite := by toFinite_tac) :
    1 < s.ncard ↔ ∃ a ∈ s, ∃ b ∈ s, a ≠ b := by
  simp_rw [ncard_eq_toFinset_card _ hs, Finset.one_lt_card, Finite.mem_toFinset]
#align set.one_lt_ncard Set.one_lt_ncard

theorem one_lt_ncard_iff (hs : s.Finite := by toFinite_tac) :
    1 < s.ncard ↔ ∃ a b, a ∈ s ∧ b ∈ s ∧ a ≠ b :=   by
  rw [one_lt_ncard hs]
  simp only [exists_prop, exists_and_left]
#align set.one_lt_ncard_iff Set.one_lt_ncard_iff

theorem two_lt_ncard_iff (hs : s.Finite := by toFinite_tac) :
    2 < s.ncard ↔ ∃ a b c, a ∈ s ∧ b ∈ s ∧ c ∈ s ∧ a ≠ b ∧ a ≠ c ∧ b ≠ c := by
  simp_rw [ncard_eq_toFinset_card _ hs, Finset.two_lt_card_iff, Finite.mem_toFinset]
#align set.two_lt_ncard_iff Set.two_lt_ncard_iff

theorem two_lt_ncard (hs : s.Finite := by toFinite_tac) :
    2 < s.ncard ↔ ∃ a ∈ s, ∃ b ∈ s, ∃ c ∈ s, a ≠ b ∧ a ≠ c ∧ b ≠ c := by
  simp only [two_lt_ncard_iff hs, exists_and_left, exists_prop]
#align set.two_lt_card Set.two_lt_ncard

theorem exists_ne_of_one_lt_ncard (hs : 1 < s.ncard) (a : α) : ∃ b, b ∈ s ∧ b ≠ a := by
  have hsf := (finite_of_ncard_ne_zero (zero_lt_one.trans hs).ne.symm)
  rw [ncard_eq_toFinset_card _ hsf] at hs
  simpa only [Finite.mem_toFinset] using Finset.exists_ne_of_one_lt_card hs a
#align set.exists_ne_of_one_lt_ncard Set.exists_ne_of_one_lt_ncard

theorem eq_insert_of_ncard_eq_succ {n : ℕ} (h : s.ncard = n + 1) :
    ∃ a t, a ∉ t ∧ insert a t = s ∧ t.ncard = n := by
  classical
  have hsf := finite_of_ncard_pos (n.zero_lt_succ.trans_eq h.symm)
  rw [ncard_eq_toFinset_card _ hsf, Finset.card_eq_succ] at h
  obtain ⟨a, t, hat, hts, rfl⟩ := h
  simp only [Finset.ext_iff, Finset.mem_insert, Finite.mem_toFinset] at hts
  refine' ⟨a, t, hat, _, _⟩
  · simp only [Finset.mem_coe, ext_iff, mem_insert_iff]
    tauto
  simp
#align set.eq_insert_of_ncard_eq_succ Set.eq_insert_of_ncard_eq_succ

theorem ncard_eq_succ {n : ℕ} (hs : s.Finite := by toFinite_tac) :
    s.ncard = n + 1 ↔ ∃ a t, a ∉ t ∧ insert a t = s ∧ t.ncard = n := by
  refine' ⟨eq_insert_of_ncard_eq_succ, _⟩
  rintro ⟨a, t, hat, h, rfl⟩
  rw [← h, ncard_insert_of_not_mem hat (hs.subset ((subset_insert a t).trans_eq h))]
#align set.ncard_eq_succ Set.ncard_eq_succ

theorem ncard_eq_two : s.ncard = 2 ↔ ∃ x y, x ≠ y ∧ s = {x, y} := by
  rw [←encard_eq_two, ncard_def, ←Nat.cast_inj (R := ℕ∞), Nat.cast_ofNat]
  refine' ⟨fun h ↦ _, fun h ↦ _⟩
  · rwa [ENat.coe_toNat] at h; rintro h'; simp [h'] at h
  simp [h]; exact Iff.mp ENat.coe_toNat_eq_self rfl
#align set.ncard_eq_two Set.ncard_eq_two

theorem ncard_eq_three : s.ncard = 3 ↔ ∃ x y z, x ≠ y ∧ x ≠ z ∧ y ≠ z ∧ s = {x, y, z} := by
  rw [←encard_eq_three, ncard_def, ←Nat.cast_inj (R := ℕ∞), Nat.cast_ofNat]
  refine' ⟨fun h ↦ _, fun h ↦ _⟩
  · rwa [ENat.coe_toNat] at h; rintro h'; simp [h'] at h
  simp [h]; exact Iff.mp ENat.coe_toNat_eq_self rfl
#align set.ncard_eq_three Set.ncard_eq_three


  
  
  


end Set

