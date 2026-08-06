# PostAlphaEye Clean-Room Reference Notes

Date: 2026-08-01

## Purpose

`PostAlphaEye.zip` was supplied as a behavioral reference for MMD eye-through-
hair rendering. It was inspected to understand render ordering and depth
responsibilities. No source text, symbol names, file layout, shader functions,
or effect scripts from that package are used by EndfieldMME.

## Behavior-level observations

- A separate eye image is prepared away from the main color buffer.
- Authored eye and brow subsets contribute color to that image.
- Other geometry contributes occlusion rather than visible color.
- Hair-to-eye distance is bounded so distant side or rear hair cannot reveal
  facial features.
- The prepared eye image is blended back over the completed scene.

These are general rendering-pipeline ideas, not implementation material.

## Independent EndfieldMME mapping

EndfieldMME does not recreate that offscreen pipeline. It uses assets and data
already produced by this project:

- duplicated Eye/Brow PMX geometry defines the feature domain;
- Hair Stencil bit 2 identifies the visible real-fringe silhouette;
- `ZMDshadow_ViewportMap2.g` supplies nearest-scene linear camera distance;
- an independently written distance fade rejects far hair;
- the existing head-facing fade prevents side-view leakage;
- the existing SrcAlpha/InvSrcAlpha overlay controls the final visibility.

The dynamic offset fringe shadow remains a separate translucent pass restricted
by shared facial receiver Stencil bit 1, written by face, base iris, and sclera.
It must not be conflated with the eye-through classifier.

## Provenance boundary

The supplied ZIP remains unchanged. The temporary extraction is analysis-only
and is not part of the EndfieldMME deliverable.
