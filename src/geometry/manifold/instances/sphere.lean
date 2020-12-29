/-
Copyright (c) 2020 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth
-/
import geometry.manifold.charted_space
import analysis.normed_space.inner_product


/-!
# Manifold structure on the sphere

This file defines stereographic projection from the sphere in an inner product space `E`, and uses
it to put a smooth manifold structure on the sphere.

-/

noncomputable theory

open metric

namespace is_R_or_C
/-! Lemmas for `data.complex.is_R_or_C`. -/

variables {𝕜 : Type*} [is_R_or_C 𝕜]

lemma im_eq_zero_of_le {a : 𝕜} (h : abs a ≤ re a) : im a = 0 :=
begin
  rw ← zero_eq_mul_self,
  have : re a * re a = re a * re a + im a * im a,
  { convert is_R_or_C.mul_self_abs a;
    linarith [re_le_abs a] },
  linarith
end

lemma re_eq_self_of_le {a : 𝕜} (h : abs a ≤ re a) : ↑(re a) = a :=
by { rw ← re_add_im a, simp [im_eq_zero_of_le h] }

end is_R_or_C

namespace inner_product_space
/-! Lemmas for `analysis.normed_space.inner_product`. -/

variables {𝕜 : Type*} [is_R_or_C 𝕜]
variables {E : Type*} [inner_product_space 𝕜 E]

open is_R_or_C

notation K`†`:1000 := submodule.orthogonal K

/-- The orthogonal projection is the unique point in `K` with the orthogonality property, variant
characterization in terms of the orthogonal complement. -/
lemma eq_orthogonal_projection_of_mem_of_inner_eq_zero' {K : submodule 𝕜 E} [complete_space K]
  {u v : E} (hv : v ∈ K) (hvo : u - v ∈ K†) :
  v = orthogonal_projection K u :=
begin
  apply eq_orthogonal_projection_fn_of_mem_of_inner_eq_zero hv,
  intros w hw,
  rw inner_eq_zero_sym,
  exact hvo w hw
end

lemma eq_proj_of_split (K : submodule 𝕜 E) [complete_space K]
  {v y z : E} (hy : y ∈ K) (hz : z ∈ K†) (hv : y + z = v) :
  y = orthogonal_projection K v :=
begin
  apply eq_orthogonal_projection_of_mem_of_inner_eq_zero' hy,
  convert hz,
  rw ← hv,
  abel
end

lemma eq_proj_of_split' [complete_space E] (K : submodule 𝕜 E) [complete_space K]
  {v y z : E} (hy : y ∈ K) (hz : z ∈ K†) (hv : y + z = v) :
  z = orthogonal_projection (K†) v  :=
begin
  suffices hy' : y ∈ K††, -- : set E), v = y' + z,
  { rw add_comm at hv,
    exact eq_proj_of_split (K†) hz hy' hv },
  simp [hy]
end

lemma sum_proj' [complete_space E] (K : submodule 𝕜 E) [complete_space K] (w : E) :
  ↑(orthogonal_projection K w) + ↑(orthogonal_projection (K†) w) = w :=
begin
  obtain ⟨y, hy, z, hz, hwyz⟩ := K.exists_sum_mem_mem_orthogonal w,
  convert hwyz,
  { rw eq_proj_of_split K hy hz hwyz },
  { rw eq_proj_of_split' K hy hz hwyz }
end


lemma sum_proj [complete_space E] (K : submodule 𝕜 E) [complete_space K] :
  K.subtype_continuous.comp (orthogonal_projection K)
  + K.orthogonal.subtype_continuous.comp (orthogonal_projection (K†))
  = continuous_linear_map.id 𝕜 E :=
by { ext w, exact sum_proj' K w }

lemma proj_perp [complete_space E] (K : submodule 𝕜 E) [complete_space K] (w : E) :
  @inner 𝕜 _ _ (orthogonal_projection K w : E) ↑(orthogonal_projection (K†) w) = 0 :=
(orthogonal_projection (K†) w).2 _ (orthogonal_projection K w).2

lemma pyth_proj [complete_space E] {K : submodule 𝕜 E} [complete_space K] (w : E) :
  ∥w∥ * ∥w∥ = ∥orthogonal_projection K w∥ * ∥orthogonal_projection K w∥
    + ∥orthogonal_projection (K†) w∥ * ∥orthogonal_projection (K†) w∥:=
begin
  convert norm_add_square_eq_norm_square_add_norm_square_of_inner_eq_zero _ _ (proj_perp K w);
  simp [sum_proj']
end

lemma pyth_proj_sq [complete_space E] (K : submodule 𝕜 E) [complete_space K] (w : E) :
  ∥w∥ ^ 2 = ∥orthogonal_projection K w∥ ^ 2 + ∥orthogonal_projection (K†) w∥ ^ 2:=
begin
  convert @pyth_proj _ _ _ _ _ K _ w;
  simp [pow_two]
end

include 𝕜

lemma norm_sub_crossmul (v x : E) :
  ∥(∥v∥:𝕜) • x - (∥x∥:𝕜) • v∥ * ∥(∥v∥:𝕜) • x - (∥x∥:𝕜) • v∥
  = 2 * ∥x∥ * ∥v∥ * (∥x∥ * ∥v∥ - re (@inner 𝕜 _ _ x v)) :=
begin
  rw norm_sub_mul_self,
  simp [inner_smul_left, inner_smul_right, norm_smul, is_R_or_C.norm_eq_abs],
  ring
end

lemma norm_sub_crossmul' (v x : E) :
  ∥(∥v∥:𝕜) • x - (∥x∥:𝕜) • v∥ ^ 2
  = 2 * ∥x∥ * ∥v∥ * (∥x∥ * ∥v∥ - re (@inner 𝕜 _ _ x v)) :=
by { convert norm_sub_crossmul v x, exact pow_two _ }


lemma inner_eq_norm_mul_iff {v x : E}:
  inner v x = (∥x∥ : 𝕜) * ∥v∥ ↔ (∥x∥ : 𝕜) • v = (∥v∥ : 𝕜) • x :=
begin
  transitivity ∥(∥x∥ : 𝕜) • v - (∥v∥ : 𝕜) • x∥ ^ 2 = 0,
  { rw norm_sub_crossmul' x v,
    split,
    { intros hxv,
      rw hxv,
      simp only [mul_re, norm_eq_zero, of_real_re, sub_zero, mul_zero, of_real_im],
      ring },
    { simp [is_R_or_C.two_ne_zero],
      rintros ((h | h )| h),
      { simp [h] },
      { simp [h] },
      have : abs (@inner 𝕜 _ _ v x) ≤ re (@inner 𝕜 _ _ v x),
      { have := @abs_inner_le_norm 𝕜 _ _ _ v x,
        linarith },
      rw ← re_eq_self_of_le this,
      norm_cast,
      linarith } },
  { split,
    { intros h,
      apply eq_of_norm_sub_eq_zero,
      apply pow_eq_zero h },
    { intros h,
      simp [h] } }
end

lemma inner_eq_norm_mul_iff_of_mem_sphere {v x : E} (hv : ∥v∥ = 1) (hx : ∥x∥ = 1) :
  @inner 𝕜 _ _ v x = 1 ↔ x = v :=
begin
  transitivity v = x,
  { convert inner_eq_norm_mul_iff using 2;
    simp [hv, hx] },
  exact eq_comm
end

end inner_product_space


namespace inner_product_space
/-! Reals-specific lemmas for `analysis.normed_space.inner_product`. -/

variables {E : Type*} [inner_product_space ℝ E]

lemma inner_product_space.mem_sphere (v w : E) (r : ℝ) : w ∈ sphere v r ↔ ∥w - v∥ = r :=
by simp [dist_eq_norm]


lemma inner_product_space.mem_sphere_zero {w : E} {r : ℝ} : w ∈ sphere (0:E) r ↔ ∥w∥ = r :=
by simp [dist_eq_norm]

@[simp] lemma norm_of_mem_unit_sphere (x : sphere (0:E) 1) : ∥(x:E)∥ = 1 :=
inner_product_space.mem_sphere_zero.mp x.2

lemma inner_eq_norm_mul_iff_real (v x : E) :
  inner v x = ∥x∥ * ∥v∥ ↔ ∥x∥ • v = ∥v∥ • x :=
inner_eq_norm_mul_iff

example {v x : E} (hxv : ⟪v, x⟫_ℝ = ∥x∥ * ∥v∥) :
  ∥v∥ • x = ∥x∥ • v :=
by { rw inner_eq_norm_mul_iff_real at hxv, simp [hxv] }

lemma inner_ne_norm_mul_iff_real (v x : E) :
  inner v x < ∥x∥ * ∥v∥ ↔ ∥x∥ • v ≠ ∥v∥ • x :=
begin
  have : _ ↔ (_ ≠ _):= not_congr (inner_eq_norm_mul_iff_real v x),
  rw ← this,
  refine ⟨ne_of_lt, lt_of_le_of_ne _⟩,
  rw mul_comm,
  refine le_trans _ (abs_real_inner_le_norm v x),
  exact le_abs_self _,
end


lemma inner_lt_one_iff_of_mem_sphere {v x : E} (hv : ∥v∥ = 1) (hx : ∥x∥ = 1) :
  ⟪v, x⟫_ℝ < 1 ↔ x ≠ v :=
begin
  transitivity v ≠ x,
  { convert inner_ne_norm_mul_iff_real v x;
    simp [hv, hx] },
  exact ne_comm
end


end inner_product_space


section
/-! Lemmas for `algebra.ordered_field` and similar. -/

variables {α : Type*} [linear_ordered_field α]

/- this lemma would work for `ordered_integral_domain`, if that typeclass existed -/
@[simp] lemma eq_of_pow_two_eq_pow_two {a b : α} (ha : 0 ≤ a) (hb : 0 ≤ b) : a ^ 2 = b ^ 2 ↔ a = b :=
begin
  split,
  { intros h,
    refine (eq_or_eq_neg_of_pow_two_eq_pow_two _ _ h).elim id _,
    intros h',
    linarith },
  { rintros rfl,
    simp },
end

lemma foo (a : α) {b : α} (hb : 0 < b) : (a ^ 2 + b)⁻¹ * (a ^ 2 - b) < 1 :=
begin
  refine (inv_mul_lt_iff' _).mpr _,
  { nlinarith },
  linarith
end

@[simp] lemma abs_sq_eq (a : ℝ) : (abs a) ^ 2 = a ^ 2 :=
begin
  by_cases h : 0 ≤ a,
  { simp [abs_of_nonneg h] },
  { simp [abs_of_neg (not_le.mp h)] }
end



end


namespace inner_product_space
/-! Another batch of lemmas for `analysis.normed_space.inner_product`, these ones specific to
projections onto singletons -/

variables {𝕜 : Type*} [is_R_or_C 𝕜]
variables {E : Type*} [inner_product_space 𝕜 E]

open submodule

notation 𝕜`∙`:1000 x := span 𝕜 (@singleton _ _ set.has_singleton x)


lemma projR_eq' {v : E} (hv : v ≠ 0) (w : E) :
  ((@inner 𝕜 _ _ v w) / ∥v∥ ^ 2) • v = orthogonal_projection (𝕜 ∙ v) w :=
begin
  apply eq_orthogonal_projection_of_mem_of_inner_eq_zero,
  { rw mem_span_singleton,
    use (@inner 𝕜 _ _ v w) / ∥v∥ ^ 2 },
  intros x hx,
  rw mem_span_singleton at hx,
  obtain ⟨c, rfl⟩ := hx,
  have hv' : ↑∥v∥ ^ 2 = @inner 𝕜 _ _ v v := by { norm_cast, simp [norm_sq_eq_inner] },
  have hv'' : @inner 𝕜 _ _ v v ≠ 0 := hv ∘ inner_self_eq_zero.mp,
  have h_div := div_mul_cancel _ hv'',
  simp [inner_sub_left, inner_smul_left, inner_smul_right, is_R_or_C.conj_div, conj_sym, hv'],
  right,
  rw h_div,
  simp [sub_self],
end

lemma projR_eq {v : E} (hv : ∥v∥ = 1) (w : E) :
  (@inner 𝕜 _ _ v w) • v = orthogonal_projection (𝕜 ∙ v) w :=
begin
  have hv' : v ≠ 0,
  { intros h,
    rw ← norm_eq_zero at h,
    rw hv at h,
    norm_num at h },
  convert projR_eq' hv' w,
  rw hv,
  simp
end

def submodule.mk_mem_span_singleton (v : E) (c : 𝕜) : 𝕜 ∙ v :=
⟨c • v, submodule.mem_span_singleton.mpr ⟨_, rfl⟩⟩

lemma projR_eq'' {v : E} (hv : ∥v∥ = 1) (w : E) :
  (⟨(@inner 𝕜 _ _ v w) • v, submodule.mem_span_singleton.mpr ⟨_, rfl⟩⟩ : 𝕜 ∙ v)
   = orthogonal_projection (𝕜 ∙ v) w :=
begin
  ext,
  exact projR_eq hv w,
end

variables [complete_space E]

end inner_product_space


variables {E : Type*} [inner_product_space ℝ E] [complete_space E]
variables (v : E)

open inner_product_space submodule

lemma prod_zero_left {w : E} (hw : w ∈ (ℝ ∙ v)†) : ⟪w, v⟫_ℝ = 0 :=
inner_left_of_mem_orthogonal (mem_span_singleton_self v) hw

lemma prod_zero_right {w : E} (hw : w ∈ (ℝ ∙ v)†) : ⟪v, w⟫_ℝ = 0 :=
inner_right_of_mem_orthogonal (mem_span_singleton_self v) hw

-- abbreviation projR : E →L[ℝ] ℝ := inner_left v

abbreviation proj' : E →L[ℝ] (ℝ ∙ v)† :=
orthogonal_projection ((ℝ ∙ v)†) -- (span ℝ {v})


lemma sphere_inter_hyperplane {v : E} (hv : ∥v∥ = 1) {x : sphere (0:E) 1} (hx : inner_left v x = (1:ℝ)) :
  x = ⟨v, by simp [hv]⟩ :=
begin
  ext,
  simpa [← inner_eq_norm_mul_iff_of_mem_sphere hv] using hx
end

lemma sphere_inter_hyperplane'' {v : E} (hv : ∥v∥ = 1) {x : sphere (0:E) 1} (hx : ↑x ≠ v) :
  inner_left v x < (1:ℝ) :=
begin
  refine (inner_lt_one_iff_of_mem_sphere hv _).mpr hx,
  simp
end


lemma sphere_inter_hyperplane'  {v : E} (hv : ∥v∥ = 1) :
  ({⟨v, by simp [hv]⟩}ᶜ : set (sphere (0:E) 1)) ⊆ coe ⁻¹' {w : E | inner_left v w ≠ (1:ℝ)} :=
λ w h, h ∘ (sphere_inter_hyperplane hv)


/-- Stereographic projection, forward direction. This is a map from an inner product space `E` to
the orthogonal complement of an element `v` of `E`. It is smooth away from the affine hyperplane
through `v` parallel to the orthogonal complement.  It restricts on the sphere to the stereographic
projection. -/
def stereo_to_fun (x : E) : (ℝ ∙ v)† := (2 / ((1:ℝ) - inner_left v x)) • proj' v x

lemma continuous_on_stereo_to_fun :
  continuous_on (stereo_to_fun v) {x : E | inner_left v x ≠ (1:ℝ)} :=
begin
  refine continuous_on.smul _ (proj' v).continuous.continuous_on,
  refine continuous_const.continuous_on.div _ _,
  { exact (continuous_const.sub (inner_left v).continuous).continuous_on },
  { intros x h h',
    exact h (sub_eq_zero.mp h').symm }
end

def stereo_inv_fun_aux (w : E) : E := (∥w∥ ^ 2 + 4)⁻¹ • ((4:ℝ) • w + (∥w∥ ^ 2 - 4) • v)

@[simp] lemma stereo_inv_fun_aux_apply (w : E) :
  stereo_inv_fun_aux v w = (∥w∥ ^ 2 + 4)⁻¹ • ((4:ℝ) • w + (∥w∥ ^ 2 - 4) • v) :=
rfl

variables {v}



lemma stereo_inv_fun_aux_mem (hv : ∥v∥ = 1) {w : E} (hw : w ∈ (ℝ ∙ v)†) :
  stereo_inv_fun_aux v w ∈ (sphere (0:E) 1) :=
begin
  rw inner_product_space.mem_sphere_zero,
  have h₁ : 0 ≤ ∥w∥ ^ 2 + 4 := by nlinarith,
  suffices : ∥(4:ℝ) • w + (∥w∥ ^ 2 - 4) • v∥ = ∥w∥ ^ 2 + 4,
  { have h₂ : ∥w∥ ^ 2 + 4 ≠ 0 := ne_of_gt (by nlinarith),
    simp only [norm_smul, real.norm_eq_abs, abs_inv, this, abs_of_nonneg h₁,
      stereo_inv_fun_aux_apply],
    field_simp },
  suffices : ∥(4:ℝ) • w + (∥w∥ ^ 2 - 4) • v∥ ^ 2 = (∥w∥ ^ 2 + 4) ^ 2,
  { have h₃ : 0 ≤ ∥stereo_inv_fun_aux v w∥ := norm_nonneg _,
    simpa [h₁, h₃, -one_pow] using this },
  simp [norm_add_pow_two_real, norm_smul, inner_smul_left, inner_smul_right, prod_zero_left _ hw,
    mul_pow, real.norm_eq_abs, hv],
  ring,
end


/-- Stereographic projection, reverse direction.  This is a map from the orthogonal complement of a
unit vector `v` in an inner product space `E` to the unit sphere in `E`. -/
def stereo_inv_fun (hv : ∥v∥ = 1) (w : (ℝ ∙ v)†) : sphere (0:E) 1 :=
⟨stereo_inv_fun_aux v (w:E), stereo_inv_fun_aux_mem hv w.2⟩

@[simp] lemma stereo_inv_fun_apply (hv : ∥v∥ = 1) (w : (ℝ ∙ v)†) :
  (stereo_inv_fun hv w : E) = (∥w∥ ^ 2 + 4)⁻¹ • ((4:ℝ) • w + (∥w∥ ^ 2 - 4) • v) :=
rfl

lemma ne_north_pole (hv : ∥v∥ = 1) (w : (ℝ ∙ v)†) :
  stereo_inv_fun hv w ≠ (⟨v, inner_product_space.mem_sphere_zero.mpr hv⟩ : sphere (0:E) 1) :=
begin
  refine subtype.ne_of_val_ne _,
  refine (inner_lt_one_iff_of_mem_sphere hv _).mp _,
  { rw ← inner_product_space.mem_sphere_zero,
    exact stereo_inv_fun_aux_mem hv w.2 },
  convert foo (∥(w : E)∥) (by norm_num : (0:ℝ) < 4),
  have hw : ⟪v, w⟫_ℝ = 0 := prod_zero_right v w.2,
  simp [inner_add_right, inner_smul_right, real_inner_self_eq_norm_square, hw, hv]
end

lemma continuous_stereo_inv_fun (hv : ∥v∥ = 1) :
  continuous (stereo_inv_fun hv) :=
begin
  let c : sphere (0:E) 1 → E := coe,
  suffices : continuous (c ∘ (stereo_inv_fun hv)),
  { exact continuous_induced_rng this },
  have h₀ : continuous (λ w : E, ∥w∥ ^ 2) := (continuous_pow 2).comp continuous_norm,
  have h₁ : continuous (λ w : E, (∥w∥ ^ 2 + 4)⁻¹),
  { refine (h₀.add continuous_const).inv' _,
    intros w,
    refine ne_of_gt _,
    nlinarith },
  have h₂ : continuous (λ w, (4:ℝ) • w + (∥w∥ ^ 2 - 4) • v),
  { refine (continuous_const.smul continuous_id).add _,
    refine (h₀.sub continuous_const).smul continuous_const },
  convert (h₁.smul h₂).comp continuous_subtype_coe
end


lemma stereo_left_inv (hv : ∥v∥ = 1) {x : sphere (0:E) 1} (hx : (x:E) ≠ v) :
  stereo_inv_fun hv (stereo_to_fun v x) = x :=
begin
  ext,
  simp only [stereo_to_fun, stereo_inv_fun_apply, norm_smul, smul_add, coe_smul, real.norm_two, normed_field.norm_div],
  set a := inner_left v x,
  set y := proj' v x,
  have split : ↑y + a • v = ↑x,
  { rw add_comm,
    convert sum_proj' (ℝ ∙ v) x,
    simp [← projR_eq'' hv x, a] },
  have pyth : 1 = a ^ 2 + ∥(y:E)∥ ^ 2,
  { convert (pyth_proj_sq (ℝ ∙ v) x) using 2,
    { simp },
    { rw ← projR_eq'' hv x,
      simp [norm_smul, hv, real.norm_eq_abs, abs_sq_eq, a] } },
  have ha : a < 1 := sphere_inter_hyperplane'' hv hx,
  have ha' : 1 - a ≠ 0 := by linarith,
  have ha''' : ∥1 - a∥ ^ 2 = (1 - a) ^ 2 := by rw [real.norm_eq_abs, abs_sq_eq],
  have h_denom : (2 / ∥1 - a∥ * ∥y∥) ^ 2 + 4 ≠ 0,
  { refine ne_of_gt _,
    nlinarith },
  rw ← split,
  congr' 1,
  { rw ← mul_smul,
    rw ← mul_smul,
    convert one_smul ℝ ↑y,
    { field_simp [ha'],
      refine (div_eq_iff _).mpr _,
      { intros h,
        apply ha',
        refine (mul_eq_zero.mp h).elim id (λ h', _),
        suffices : (1 - a) ^ 2 = 0,
        { exact pow_eq_zero this },
        have : 4 * ∥(y:E)∥ ^ 2 + 4 * (1 - a) ^ 2 = 0,
        { rw ← h',
          simp [real.norm_eq_abs, abs_sq_eq],
          ring }, -- := by nlinarith,
        have : (1 - a) ^ 2 ≥ 0 := pow_two_nonneg (1 - a),
        linarith },
      rw ha''',
      have := coe_norm _ y,
      nlinarith } },
  { rw ← mul_smul,
    congr' 1,
    rw ← div_eq_inv_mul,
    refine (div_eq_iff h_denom).mpr _,
    field_simp [ha''', ha'],
    nlinarith }
end

lemma inner_left_self {v : E} (hv : ∥v∥ = 1) : inner_left v v = (1:ℝ) :=
by simp [real_inner_self_eq_norm_square, hv]

lemma inner_left_orthogonal (v : E) {w : E} (hw : w ∈ (ℝ ∙ v)†) :
  @inner_left ℝ E _ _ v w = (0:ℝ) :=
hw _ (mem_span_singleton_self v)

lemma proj_orthogonal_singleton (v : E) :
  orthogonal_projection ((ℝ ∙ v)†) v = 0 :=
begin
  symmetry,
  ext,
  apply eq_orthogonal_projection_of_mem_of_inner_eq_zero',
  { simp },
  { simp [mem_span_singleton_self] },
end

lemma proj_orthogonal (v : E) {w : E} (hw : w ∈ (ℝ ∙ v)†) :
  ↑(orthogonal_projection ((ℝ ∙ v)†) w) = w :=
orthogonal_projection_mem_subspace_eq_self hw

lemma stereo_right_inv (hv : ∥v∥ = 1) (w : (ℝ ∙ v)†) :
  (stereo_to_fun v ∘ coe) (stereo_inv_fun hv w) = w :=
begin
  have h₁ : proj' v v = 0 := proj_orthogonal_singleton v,
  have h₂ : proj' v w = w := by simpa using orthogonal_projection_mem_subspace_eq_self w.2,
  have h₃ : inner_left v w = (0:ℝ) := inner_left_orthogonal v w.2,
  have h₄ : inner_left v v = (1:ℝ) := inner_left_self hv,
  simp only [stereo_to_fun, stereo_inv_fun, stereo_inv_fun_aux, function.comp_app],
  simp only [h₁, h₂, h₃, h₄, add_zero, continuous_linear_map.map_add, zero_add,
  subtype.coe_mk, mul_zero, smul_zero, continuous_linear_map.map_smul],
  rw ← mul_smul,
  rw ← mul_smul,
  convert one_smul ℝ w,
  have h_denom : ∥(w:E)∥ ^ 2 + 4 ≠ 0 := by nlinarith,
  field_simp [h_denom],
  ring
end

/-- Stereographic projection from the unit sphere in `E`, centred at a unit vector `v` in `E`; this
is the version as a local homeomorphism. -/
def stereographic (hv : ∥v∥ = 1) : local_homeomorph (sphere (0:E) 1) ((ℝ ∙ v)†) :=
{ to_fun := (stereo_to_fun v) ∘ coe,
  inv_fun := stereo_inv_fun hv,
  source := {⟨v, by simp [hv]⟩}ᶜ,
  target := set.univ,
  map_source' := by simp,
  map_target' := λ w _, ne_north_pole hv w,
  left_inv' := λ _ hx, stereo_left_inv hv (λ h, hx (subtype.ext h)),
  right_inv' := λ w _, stereo_right_inv hv w,
  open_source := is_open_compl_singleton,
  open_target := is_open_univ,
  continuous_to_fun := (continuous_on_stereo_to_fun v).comp continuous_subtype_coe.continuous_on
    (sphere_inter_hyperplane' hv),
  continuous_inv_fun := (continuous_stereo_inv_fun hv).continuous_on }
