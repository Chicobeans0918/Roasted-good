import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Read-only star display for a 0–5 rating.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 14});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = rating >= index + 0.75;
        final half = !filled && rating >= index + 0.25;
        return Icon(
          filled
              ? Icons.star
              : half
                  ? Icons.star_half
                  : Icons.star_border,
          size: size,
          color: context.palette.star,
        );
      }),
    );
  }
}

/// Interactive 1–5 star rating input.
class RatingInput extends StatelessWidget {
  const RatingInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            value >= starValue ? Icons.star : Icons.star_border,
            color: context.palette.star,
            size: 32,
          ),
          onPressed: () => onChanged(starValue),
        );
      }),
    );
  }
}
