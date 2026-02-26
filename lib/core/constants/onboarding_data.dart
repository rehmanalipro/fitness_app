class OnboardingData {
  OnboardingData._();

  static final OnboardingData instance = OnboardingData._();

  String? gender;
  String? goal;
  String? fitnessLevel;
  int? birthYear;
  int? age;
  num? heightValue;
  String? heightUnit;
  num? weightValue;
  String? weightUnit;

  Map<String, dynamic> toMap() {
    return {
      if (gender != null) 'gender': gender,
      if (goal != null) 'goal': goal,
      if (fitnessLevel != null) 'fitness_level': fitnessLevel,
      if (birthYear != null) 'birth_year': birthYear,
      if (age != null) 'age': age,
      if (heightValue != null) 'height_value': heightValue,
      if (heightUnit != null) 'height_unit': heightUnit,
      if (weightValue != null) 'weight_value': weightValue,
      if (weightUnit != null) 'weight_unit': weightUnit,
    };
  }

  void clear() {
    gender = null;
    goal = null;
    fitnessLevel = null;
    birthYear = null;
    age = null;
    heightValue = null;
    heightUnit = null;
    weightValue = null;
    weightUnit = null;
  }
}
