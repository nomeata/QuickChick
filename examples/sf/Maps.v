(* QuickChick Prelude *)
Set Warnings "-extraction-opaque-accessed,-extraction".
Set Warnings "-notation-overridden,-parsing".

Require Import String List. Open Scope string.

From QuickChick Require Import QuickChick Tactics.
From mathcomp Require Import ssreflect ssrfun ssrbool ssrnat eqtype seq.
Import QcDefaultNotation. Open Scope qc_scope.

Set Bullet Behavior "Strict Subproofs".

Require Import ZoeStuff.
(* End prelude *)

Require Import Ascii String.

Derive (Arbitrary, Show) for ascii.
Derive (Sized, CanonicalSized) for ascii.
Derive SizeMonotonic for ascii using genSascii.
Derive SizedMonotonic for ascii.
(* Zoe: Derive SizedCorrect for ascii using genSascii and SizeMonotonicascii. *)

Derive (Arbitrary, Show) for string.
Derive (Sized, CanonicalSized) for string.
Derive SizeMonotonic for string using genSstring.
Derive SizedMonotonic for string.


Inductive id : Type :=
  | Id : string -> id.

Derive (Arbitrary, Show) for id.
Derive (Sized, CanonicalSized) for id.
Derive SizeMonotonic for id using genSid.
Derive SizedMonotonic for id.
(* ZOEEE : Derive SizedCorrect for id using genSid and SizeMonotonicid.*)

Instance eq_dec_id (x y : id) : Dec (x = y).
constructor; unfold decidable. repeat decide equality. Defined.

Definition beq_id x y :=
  match x,y with
    | Id n1, Id n2 => if string_dec n1 n2 then true else false
  end.

Theorem beq_id_refl : forall id, true = beq_id id id.
Admitted. (* QuickChick beq_id_refl. *) 

Theorem beq_id_true_iff : forall x y : id,
  beq_id x y = true <-> x = y.
Admitted. (* Prop *)

Theorem beq_id_false_iff : forall x y : id,
  beq_id x y = false
  <-> x <> y.
Admitted. (* Prop *)

Theorem false_beq_id : forall x y : id,
   x <> y
   -> beq_id x y = false.
Admitted. (* Leo: TODO *) 

(* Maps as functions are bad *)
Definition total_map (A:Type) := id -> A. 

(** Intuitively, a total map over an element type [A] is just a
    function that can be used to look up [id]s, yielding [A]s.

    The function [t_empty] yields an empty total map, given a default
    element; this map always returns the default element when applied
    to any id. *)

Definition t_empty {A:Type} (v : A) : total_map A :=
  (fun _ => v).

(** More interesting is the [update] function, which (as before) takes
    a map [m], a key [x], and a value [v] and returns a new map that
    takes [x] to [v] and takes every other key to whatever [m] does. *)

Definition t_update {A:Type} (m : total_map A)
                    (x : id) (v : A) :=
  fun x' => if beq_id x x' then v else m x'.

(** This definition is a nice example of higher-order programming:
    [t_update] takes a _function_ [m] and yields a new function 
    [fun x' => ...] that behaves like the desired map.

    For example, we can build a map taking [id]s to [bool]s, where [Id
    3] is mapped to [true] and every other key is mapped to [false],
    like this: *)

Definition examplemap :=
  t_update (t_update (t_empty false) (Id "foo") false)
           (Id "bar") true.

(** This completes the definition of total maps.  Note that we don't
    need to define a [find] operation because it is just function
    application! *)

Example update_example1 : examplemap (Id "baz") = false.
Proof. reflexivity. Qed.

Example update_example2 : examplemap (Id "foo") = false.
Proof. reflexivity. Qed.

Example update_example3 : examplemap (Id "quux") = false.
Proof. reflexivity. Qed.

Example update_example4 : examplemap (Id "bar") = true.
Proof. reflexivity. Qed.

(** To use maps in later chapters, we'll need several fundamental
    facts about how they behave.  Even if you don't work the following
    exercises, make sure you thoroughly understand the statements of
    the lemmas!  (Some of the proofs require the functional
    extensionality axiom, which is discussed in the [Logic]
    chapter.) *)

(** **** Exercise: 1 star, optional (t_apply_empty)  *)
(** First, the empty map returns its default element for all keys: *)

Lemma t_apply_empty:  forall A x v, @t_empty A v x = v.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 2 stars, optional (t_update_eq)  *)
(** Next, if we update a map [m] at a key [x] with a new value [v]
    and then look up [x] in the map resulting from the [update], we
    get back [v]: *)

Lemma t_update_eq : forall A (m: total_map A) x v,
  (t_update m x v) x = v.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 2 stars, optional (t_update_neq)  *)
(** On the other hand, if we update a map [m] at a key [x1] and then
    look up a _different_ key [x2] in the resulting map, we get the
    same result that [m] would have given: *)

Theorem t_update_neq : forall (X:Type) v x1 x2
                         (m : total_map X),
  x1 <> x2 ->
  (t_update m x1 v) x2 = m x2.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 2 stars, optional (t_update_shadow)  *)
(** If we update a map [m] at a key [x] with a value [v1] and then
    update again with the same key [x] and another value [v2], the
    resulting map behaves the same (gives the same result when applied
    to any key) as the simpler map obtained by performing just
    the second [update] on [m]: *)

Lemma t_update_shadow : forall A (m: total_map A) v1 v2 x,
    t_update (t_update m x v1) x v2
  = t_update m x v2.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** For the final two lemmas about total maps, it's convenient to use
    the reflection idioms introduced in chapter [IndProp].  We begin
    by proving a fundamental _reflection lemma_ relating the equality
    proposition on [id]s with the boolean function [beq_id]. *)

(** **** Exercise: 2 stars, optional (beq_idP)  *)
(** Use the proof of [beq_natP] in chapter [IndProp] as a template to
    prove the following: *)

Lemma beq_idP : forall x y, reflect (x = y) (beq_id x y).
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** Now, given [id]s [x1] and [x2], we can use the [destruct (beq_idP
    x1 x2)] to simultaneously perform case analysis on the result of
    [beq_id x1 x2] and generate hypotheses about the equality (in the
    sense of [=]) of [x1] and [x2]. *)

(** **** Exercise: 2 stars (t_update_same)  *)
(** With the example in chapter [IndProp] as a template, use
    [beq_idP] to prove the following theorem, which states that if we
    update a map to assign key [x] the same value as it already has in
    [m], then the result is equal to [m]: *)

Theorem t_update_same : forall X x (m : total_map X),
  t_update m x (m x) = m.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 3 stars, recommended (t_update_permute)  *)
(** Use [beq_idP] to prove one final property of the [update]
    function: If we update a map [m] at two distinct keys, it doesn't
    matter in which order we do the updates. *)

Theorem t_update_permute : forall (X:Type) v1 v2 x1 x2
                             (m : total_map X),
  x2 <> x1 ->
    (t_update (t_update m x2 v2) x1 v1)
  = (t_update (t_update m x1 v1) x2 v2).
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(* ################################################################# *)
(** * Partial maps *)

(** Finally, we define _partial maps_ on top of total maps.  A partial
    map with elements of type [A] is simply a total map with elements
    of type [option A] and default element [None]. *)

Definition partial_map (A:Type) := total_map (option A).

Definition empty {A:Type} : partial_map A :=
  t_empty None.

Definition update {A:Type} (m : partial_map A)
                  (x : id) (v : A) :=
  t_update m x (Some v).

(** We now straightforwardly lift all of the basic lemmas about total
    maps to partial maps.  *)

Lemma apply_empty : forall A x, @empty A x = None.
Proof.
  intros. unfold empty. rewrite t_apply_empty.
  reflexivity.
Qed.

Lemma update_eq : forall A (m: partial_map A) x v,
  (update m x v) x = Some v.
Proof.
  intros. unfold update. rewrite t_update_eq.
  reflexivity.
Qed.

Theorem update_neq : forall (X:Type) v x1 x2
                       (m : partial_map X),
  x2 <> x1 ->
  (update m x2 v) x1 = m x1.
Proof.
  intros X v x1 x2 m H.
  unfold update. rewrite t_update_neq. reflexivity.
  apply H. Qed.

Lemma update_shadow : forall A (m: partial_map A) v1 v2 x,
  update (update m x v1) x v2 = update m x v2.
Proof.
  intros A m v1 v2 x1. unfold update. rewrite t_update_shadow.
  reflexivity.
Qed.

Theorem update_same : forall X v x (m : partial_map X),
  m x = Some v ->
  update m x v = m.
Proof.
  intros X v x m H. unfold update. rewrite <- H.
  apply t_update_same.
Qed.

Theorem update_permute : forall (X:Type) v1 v2 x1 x2
                                (m : partial_map X),
  x2 <> x1 ->
    (update (update m x2 v2) x1 v1)
  = (update (update m x1 v1) x2 v2).
Proof.
  intros X v1 v2 x1 x2 m. unfold update.
  apply t_update_permute.
Qed.

(** $Date: 2016-11-22 16:39:52 -0500 (Tue, 22 Nov 2016) $ *)

