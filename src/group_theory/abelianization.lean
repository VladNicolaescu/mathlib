/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Michael Howes

The functor Grp → Ab which is the left adjoint
of the forgetful functor Ab → Grp.
-/

-- TODO:
-- (1) Abelian groups solvable
-- (2) Quotients of solvable groups solvable
-- (3) Subgroups of solvable groups solvable
-- (4) If G is in the middle of a short exact sequence with everything else solvable
--     then G is solvable
-- (5) S_5 is not solvable (A_5 is simple)

-- Small todos:
-- (1) Show that the set of commutators is already a subgroup without needing to take subgroup closure

import group_theory.quotient_group
import tactic.group

universes u v

-- let G be a group
variables (G : Type u) [group G]

/-- The commutator subgroup of a group G is the normal subgroup
  generated by the commutators [p,q]=`p*q*p⁻¹*q⁻¹` -/
@[derive subgroup.normal]
def commutator : subgroup G :=
subgroup.normal_closure {x | ∃ p q, p * q * p⁻¹ * q⁻¹ = x}

variables {G}

def general_commutator (H₁ : subgroup G) (H₂ : subgroup G) : subgroup G :=
subgroup.closure {x | ∃ (p ∈ H₁) (q ∈ H₂), p * q * p⁻¹ * q⁻¹ = x}

instance general_commutator_is_normal (H₁ : subgroup G) (H₂ : subgroup G) [h₁ : subgroup.normal H₁]
  [h₂ : subgroup.normal H₂] : subgroup.normal (general_commutator H₁ H₂) :=
begin
  let base : set G := {x | ∃ (p ∈ H₁) (q ∈ H₂), p * q * p⁻¹ * q⁻¹ = x},
  suffices h_base : base = group.conjugates_of_set base,
  { dsimp only [general_commutator, ←base],
    rw h_base,
    exact subgroup.normal_closure_normal },
  apply set.subset.antisymm group.subset_conjugates_of_set,
  intros a h,
  rw group.mem_conjugates_of_set_iff at h,
  rcases h with ⟨b, ⟨c, hc, e, he, rfl⟩, d, rfl⟩,
  exact ⟨d * c * d⁻¹, h₁.conj_mem c hc d, d * e * d⁻¹, h₂.conj_mem e he d, by group⟩,
end

lemma general_commutator_eq_normal_closure (H₁ : subgroup G) (H₂ : subgroup G) [H₁.normal] [H₂.normal] :
  general_commutator H₁ H₂ = subgroup.normal_closure (general_commutator H₁ H₂) :=
begin
  rw general_commutator,
  apply le_antisymm,
  { sorry,
    -- show that a subgroup is le its normal closure
  },
  { sorry,
    -- show that the normal_closure of a normal subgroup is the subgroup
  }
end

lemma general_commutator_eq_normal_closure' (H₁ : subgroup G) (H₂ : subgroup G) [H₁.normal] [H₂.normal] :
  general_commutator H₁ H₂ = subgroup.normal_closure {x | ∃ (p ∈ H₁) (q ∈ H₂), p * q * p⁻¹ * q⁻¹ = x} :=
begin
  rw general_commutator_eq_normal_closure,
  rw general_commutator,
  -- a lemma should be added to mathlib saying that the normal closure of the subgroup closure is
  -- equal to the normal closure
  -- Also there should be a lemma saying that the normal closure contains the subgroup closure
  -- and a lemma saying that the normal closure is idempotent
  sorry,
end

variables (G)

def nth_commutator (n : ℕ) : subgroup G :=
nat.rec_on n (⊤ : subgroup G) (λ _ H, general_commutator H H)

instance top_normal: (⊤: subgroup G).normal :=
{ conj_mem :=  λ  n mem g, subgroup.mem_top (g*n *g⁻¹ ), }

lemma nth_commutator_normal (n : ℕ) : (nth_commutator G n).normal :=
begin
  induction n with n ih,
  { change (⊤ : subgroup G).normal,
    exact top_normal G, },
  { haveI : (nth_commutator G n).normal := ih,
    change (general_commutator (nth_commutator G n) (nth_commutator G n)).normal,
    exact general_commutator_is_normal (nth_commutator G n) (nth_commutator G n), }
end

def is_solvable : Prop := ∃ n : ℕ, nth_commutator G n = (⊥ : subgroup G)

lemma commutator_eq_general_commutator_top_top :
  commutator G = general_commutator (⊤ : subgroup G) (⊤ : subgroup G) :=
begin
  rw commutator,
  rw general_commutator_eq_normal_closure',
  apply le_antisymm; apply subgroup.normal_closure_mono,
  { exact λ x ⟨p, q, h⟩, ⟨p, subgroup.mem_top p, q, subgroup.mem_top q, h⟩, },
  { exact λ x ⟨p, _, q, _, h⟩, ⟨p, q, h⟩, }
end

/-- The abelianization of G is the quotient of G by its commutator subgroup -/
def abelianization : Type u :=
quotient_group.quotient (commutator G)

namespace abelianization

local attribute [instance] quotient_group.left_rel

instance : comm_group (abelianization G) :=
{ mul_comm := λ x y, quotient.induction_on₂' x y $ λ a b,
  begin
    apply quotient.sound,
    apply subgroup.subset_normal_closure,
    use b⁻¹, use a⁻¹,
    group,
  end,
.. quotient_group.quotient.group _ }

instance : inhabited (abelianization G) := ⟨1⟩

variable {G}

/-- `of` is the canonical projection from G to its abelianization. -/
def of : G →* abelianization G :=
{ to_fun := quotient_group.mk,
  map_one' := rfl,
  map_mul' := λ x y, rfl }

section lift
-- so far -- built Gᵃᵇ and proved it's an abelian group.
-- defined `of : G → Gᵃᵇ`

-- let A be an abelian group and let f be a group hom from G to A
variables {A : Type v} [comm_group A] (f : G →* A)

lemma commutator_subset_ker : commutator G ≤ f.ker :=
begin
  apply subgroup.normal_closure_le_normal,
  rintros x ⟨p, q, rfl⟩,
  simp [monoid_hom.mem_ker, mul_right_comm (f p) (f q)],
end

/-- If `f : G → A` is a group homomorphism to an abelian group, then `lift f` is the unique map from
  the abelianization of a `G` to `A` that factors through `f`. -/
def lift : abelianization G →* A :=
quotient_group.lift _ f (λ x h, f.mem_ker.2 $ commutator_subset_ker _ h)

@[simp] lemma lift.of (x : G) : lift f (of x) = f x :=
rfl

theorem lift.unique
  (φ : abelianization G →* A)
  -- hφ : φ agrees with f on the image of G in Gᵃᵇ
  (hφ : ∀ (x : G), φ (of x) = f x)
  {x : abelianization G} :
  φ x = lift f x :=
quotient_group.induction_on x hφ

end lift

variables {A : Type v} [monoid A]

theorem hom_ext (φ ψ : abelianization G →* A)
  (h : φ.comp of = ψ.comp of) : φ = ψ :=
begin
  ext x,
  apply quotient_group.induction_on x,
  intro z,
  show φ.comp of z = _,
  rw h,
  refl,
end

end abelianization
