import ring_theory.fractional_ideal
import ring_theory.principal_ideal_domain

universes u v

variables {R : Type u} {K : Type v} [field K]
variables [integral_domain R] (g : fraction_map R K)
open localization ring ring.fractional_ideal units

section
/-- `to_principal_ideal x` sends `x ≠ 0 : K` to the fractional ideal generated by `x` -/
@[irreducible]
def to_principal_ideal : units g.codomain →* units (fractional_ideal g) :=
{ to_fun := λ x,
  ⟨ span_singleton x,
    span_singleton x⁻¹,
    by simp only [span_singleton_one, units.mul_inv', span_singleton_mul_span_singleton],
    by simp only [span_singleton_one, units.inv_mul', span_singleton_mul_span_singleton]⟩,
  map_mul' := λ x y, ext (by simp only [coe_mk, units.coe_mul, span_singleton_mul_span_singleton]),
  map_one' := ext (by simp only [span_singleton_one, coe_mk, units.coe_one]) }

local attribute [semireducible] to_principal_ideal

variables {g}

@[simp] lemma coe_to_principal_ideal (x : units g.codomain) :
  (to_principal_ideal g x : fractional_ideal g) = span_singleton x :=
rfl

@[simp] lemma to_principal_ideal_eq_iff {I : units (fractional_ideal g)} {x : units g.codomain} :
  to_principal_ideal g x = I ↔ span_singleton (x : g.codomain) = I :=
units.ext_iff

end

instance principal_ideals.normal : (to_principal_ideal g).range.normal :=
subgroup.normal_of_comm _

section
/-- The Picard group with respect to `g : fraction_map R K` is the group of invertible fractional ideals modulo the principal ideals. -/
@[irreducible, derive(comm_group)]
def picard_group_WRT := quotient_group.quotient (to_principal_ideal g).range

/-- The Picard group is the group of invertible fractional ideals in the fraction field modulo the principal ideals. -/
@[derive(comm_group)]
def picard_group (R : Type*) [integral_domain R] := picard_group_WRT (of R)

variables {K' : Type*} [field K'] (g) (g' : fraction_map R K')

local attribute [semireducible] picard_group picard_group_WRT

def map_units_equiv (e : units (fractional_ideal g) ≃* units (fractional_ideal g'))
  (he : ∀ I, I ∈ (to_principal_ideal g).range ↔ e I ∈ (to_principal_ideal g').range) :
  picard_group_WRT g ≃* picard_group_WRT g' :=
quotient_group.map_equiv _ e (subgroup.ext he)
end

def map_equiv {K' : Type*} [field K'] {g : fraction_map R K} (g' : fraction_map R K')
  (e : fractional_ideal g ≃* fractional_ideal g')
  (he : ∀ I, (∃ x, span_singleton x = I) ↔ (∃ y, span_singleton y = e I)):
  picard_group_WRT g ≃* picard_group_WRT g' :=
map_units_equiv _ _ (units.map_equiv e) begin
  intro I,
  split; rintros ⟨x, h⟩,
  { obtain ⟨x', h'⟩ := (he I).mp ⟨x, to_principal_ideal_eq_iff.mp h⟩,
    refine ⟨units.mk0 x' _, to_principal_ideal_eq_iff.mpr h'⟩,
    rintro rfl,
    have : e I * e (I⁻¹ : units _) = 1,
    { rw [←e.map_mul, ←units.coe_mul, mul_right_inv, units.coe_one, e.map_one] },
    simpa [←h'] using this },
  { obtain ⟨x', h'⟩ := (he I).mpr ⟨x, to_principal_ideal_eq_iff.mp h⟩,
    refine ⟨units.mk0 x' _, to_principal_ideal_eq_iff.mpr h'⟩,
    rintro rfl,
    have : (I * (I⁻¹ : units _) : fractional_ideal g) = 1,
    { rw [←units.coe_mul, mul_right_inv, units.coe_one] },
    simpa [←h'] using this },
end

noncomputable def canonical_equiv {K' : Type*} [field K'] {g : fraction_map R K}
  (g' : fraction_map R K') : picard_group_WRT g ≃* picard_group_WRT g' :=
have inj_id : function.injective (ring_hom.id R) := λ x y h, h,
map_equiv _ (canonical_equiv g g') (λ I,
  ⟨ λ ⟨x, hx⟩, hx ▸ ⟨g.map g' inj_id x, fractional_ideal.ext_iff.mp
      (λ x', (canonical_equiv_span_singleton g g' x).symm ▸ iff.rfl)⟩,
    λ ⟨y, hy⟩, have hy' : canonical_equiv g' g (span_singleton y) = I :=
        hy.symm ▸ canonical_equiv_flip g' g I,
      hy' ▸ ⟨g'.map g inj_id y, fractional_ideal.ext_iff.mp
        (λ y', (canonical_equiv_span_singleton g' g y).symm ▸ iff.rfl)⟩⟩)

open submodule submodule.is_principal

lemma monoid_hom.range_eq_top {G H : Type*} [group G] [group H] (f : G →* H) :
  f.range = ⊤ ↔ function.surjective f :=
⟨ λ h y, show y ∈ f.range, from h.symm ▸ subgroup.mem_top y,
  λ h, subgroup.ext (λ x, by simp [h x]) ⟩

namespace principal_ideal_domain

local attribute [semireducible] picard_group_WRT

def picard_group_WRT_trivial {R} [integral_domain R] [is_principal_ideal_ring R]
  (g : fraction_map R K) : picard_group_WRT g ≃* unit :=
show quotient_group.quotient (to_principal_ideal g).range ≃* unit,
from have (to_principal_ideal g).range = ⊤ :=
  (to_principal_ideal g).range_eq_top.mpr (λ I,
    ⟨ units.mk0 (generator ((I : fractional_ideal g) : submodule R g.codomain)) ((invertible_iff_generator_nonzero ↑I).mp (mul_inv_cancel_iff.mpr ⟨I.2, I.3⟩)),
    to_principal_ideal_eq_iff.mpr (by { rw [coe_mk0], exact (eq_span_singleton_of_principal ↑I).symm }) ⟩),
by { convert quotient_group.quotient_top (units (fractional_ideal g)); assumption }

noncomputable def picard_group_trivial (R) [integral_domain R] [is_principal_ideal_ring R] :
  picard_group R ≃* unit :=
picard_group_WRT_trivial (of R)

noncomputable example : picard_group ℤ ≃* unit := principal_ideal_domain.picard_group_trivial ℤ

/-- Condition (DD3) of being a Dedekind domain: all nonzero fractional ideals are invertible. -/
def DD3 (R) [integral_domain R] : Prop :=
∀ {I : fractional_ideal (of R)}, I ≠ 0 → I * I⁻¹ = 1

lemma DD3_of_principal_ideal_domain {R} [integral_domain R] [is_principal_ideal_ring R] : DD3 R :=
λ I hI, fractional_ideal.invertible_of_principal I hI

end principal_ideal_domain
