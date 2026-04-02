import '../core/constants.dart';

/// Drug suggestion result.
class DrugSuggestion {
  final String diagnosis;
  final List<String> firstLine;
  final List<String> secondLine;
  final List<String> adjuncts;
  final String notes;

  const DrugSuggestion({
    required this.diagnosis,
    required this.firstLine,
    this.secondLine = const [],
    this.adjuncts = const [],
    this.notes = '',
  });
}

/// Guideline-based drug suggestion engine.
class DrugEngine {
  static DrugSuggestion getSuggestions({
    required String diagnosis,
    required String severity,
    Map<String, dynamic>? scaleResults,
  }) {
    final diag = diagnosis.toLowerCase();

    if (diag.contains('schizophrenia') || diag.contains('psychosis')) {
      return _schizophreniaSuggestion(severity);
    }
    if (diag.contains('bipolar') || diag.contains('mania')) {
      return _bipolarSuggestion(severity);
    }
    if (diag.contains('depression') || diag.contains('mdd')) {
      return _depressionSuggestion(severity);
    }
    if (diag.contains('anxiety') || diag.contains('gad')) {
      return _anxietySuggestion(severity);
    }
    if (diag.contains('ocd') || diag.contains('obsessive')) {
      return _ocdSuggestion(severity);
    }
    if (diag.contains('dementia') || diag.contains('alzheimer')) {
      return _dementiaSuggestion(severity);
    }
    if (diag.contains('ptsd') || diag.contains('trauma')) {
      return _ptsdSuggestion(severity);
    }
    if (diag.contains('adhd') || diag.contains('attention')) {
      return _adhdSuggestion(severity);
    }

    return DrugSuggestion(
      diagnosis: diagnosis,
      firstLine: ['Consult psychiatrist for tailored pharmacotherapy'],
      notes: 'No specific guideline matched. Clinical judgment required.',
    );
  }

  static DrugSuggestion _schizophreniaSuggestion(String severity) {
    return DrugSuggestion(
      diagnosis: 'Schizophrenia / Psychosis',
      firstLine: [
        'Risperidone 2–6 mg/day',
        'Olanzapine 10–20 mg/day',
        'Aripiprazole 10–30 mg/day',
      ],
      secondLine: [
        'Clozapine 100–450 mg/day (treatment-resistant)',
        'Quetiapine 300–800 mg/day',
        'Haloperidol 5–20 mg/day (acute)',
      ],
      adjuncts: [
        'Lorazepam 1–4 mg/day (acute agitation)',
        'Trihexyphenidyl 2–6 mg/day (EPS prophylaxis)',
        'Propranolol 20–80 mg/day (akathisia)',
      ],
      notes: severity == AppConstants.severitySevere ||
              severity == AppConstants.severityVerySevere
          ? '⚠️ Consider rapid tranquilization protocol. Monitor vitals.'
          : 'Start low, titrate slowly. Monitor metabolic parameters.',
    );
  }

  static DrugSuggestion _bipolarSuggestion(String severity) {
    return DrugSuggestion(
      diagnosis: 'Bipolar Disorder / Mania',
      firstLine: [
        'Lithium 600–1800 mg/day (target serum 0.8–1.2 mEq/L)',
        'Valproate 750–2500 mg/day (target 50–125 mcg/mL)',
        'Olanzapine 10–20 mg/day',
      ],
      secondLine: [
        'Quetiapine 400–800 mg/day',
        'Aripiprazole 15–30 mg/day',
        'Risperidone 2–6 mg/day',
      ],
      adjuncts: [
        'Lorazepam 1–4 mg/day (acute mania)',
        'Lamotrigine 100–400 mg/day (bipolar depression)',
      ],
      notes: 'Monitor lithium levels, renal function, thyroid. '
          'Avoid antidepressant monotherapy in bipolar.',
    );
  }

  static DrugSuggestion _depressionSuggestion(String severity) {
    final firstLine = severity == AppConstants.severityMild
        ? ['Psychotherapy (CBT / IPT) first-line for mild depression']
        : [
            'Sertraline 50–200 mg/day',
            'Escitalopram 10–20 mg/day',
            'Fluoxetine 20–60 mg/day',
          ];

    return DrugSuggestion(
      diagnosis: 'Major Depressive Disorder',
      firstLine: firstLine,
      secondLine: [
        'Venlafaxine 75–225 mg/day (SNRI)',
        'Mirtazapine 15–45 mg/day',
        'Bupropion 150–450 mg/day',
        'Amitriptyline 75–150 mg/day (TCA)',
      ],
      adjuncts: [
        'Quetiapine 50–300 mg/day (augmentation)',
        'Aripiprazole 2–15 mg/day (augmentation)',
        'Lithium augmentation (refractory)',
        'Clonazepam (if anxiety prominent)',
      ],
      notes: severity == AppConstants.severitySevere ||
              severity == AppConstants.severityVerySevere
          ? '⚠️ Assess suicidality. Consider hospitalization. ECT if needed.'
          : 'Reassess in 4–6 weeks. Full trial = 6–8 weeks at adequate dose.',
    );
  }

  static DrugSuggestion _anxietySuggestion(String severity) {
    return DrugSuggestion(
      diagnosis: 'Generalized Anxiety Disorder',
      firstLine: [
        'Escitalopram 10–20 mg/day',
        'Sertraline 50–200 mg/day',
        'Duloxetine 60–120 mg/day',
      ],
      secondLine: [
        'Venlafaxine 75–225 mg/day',
        'Pregabalin 150–600 mg/day',
        'Buspirone 15–60 mg/day',
      ],
      adjuncts: [
        'Lorazepam 0.5–2 mg (short-term only)',
        'Propranolol 10–40 mg (situational anxiety)',
        'CBT / relaxation therapy',
      ],
      notes: 'Benzodiazepines: limit to <4 weeks due to dependence risk.',
    );
  }

  static DrugSuggestion _ocdSuggestion(String severity) {
    return DrugSuggestion(
      diagnosis: 'Obsessive-Compulsive Disorder',
      firstLine: [
        'Fluoxetine 40–80 mg/day',
        'Sertraline 100–200 mg/day',
        'Fluvoxamine 100–300 mg/day',
        'CBT with ERP (Exposure & Response Prevention)',
      ],
      secondLine: [
        'Clomipramine 100–250 mg/day',
        'Paroxetine 40–60 mg/day',
      ],
      adjuncts: [
        'Risperidone 0.5–2 mg/day (augmentation)',
        'Quetiapine augmentation',
      ],
      notes: 'Higher SSRI doses needed for OCD vs depression. '
          '12-week trial before switching.',
    );
  }

  static DrugSuggestion _dementiaSuggestion(String severity) {
    return DrugSuggestion(
      diagnosis: 'Dementia / Cognitive Impairment',
      firstLine: [
        'Donepezil 5–10 mg/day (all stages)',
        'Rivastigmine 3–12 mg/day (Alzheimer/PDD)',
        'Galantamine 8–24 mg/day (mild-moderate)',
      ],
      secondLine: [
        'Memantine 5–20 mg/day (moderate-severe)',
        'Donepezil + Memantine combination',
      ],
      adjuncts: [
        'Risperidone 0.25–1 mg/day (BPSD — use with caution)',
        'Quetiapine 25–200 mg/day (BPSD)',
        'Mirtazapine (depression in dementia)',
        'Melatonin (sleep disturbance)',
      ],
      notes: '⚠️ Antipsychotics in elderly: increased stroke/mortality risk. '
          'Non-pharmacological interventions first for BPSD.',
    );
  }

  static DrugSuggestion _ptsdSuggestion(String severity) {
    return DrugSuggestion(
      diagnosis: 'PTSD / Trauma-Related Disorder',
      firstLine: [
        'Sertraline 50–200 mg/day',
        'Paroxetine 20–60 mg/day',
        'Trauma-focused CBT / EMDR',
      ],
      secondLine: [
        'Venlafaxine 75–225 mg/day',
        'Mirtazapine 15–45 mg/day',
      ],
      adjuncts: [
        'Prazosin 1–15 mg (nightmares)',
        'Quetiapine (sleep/hyperarousal)',
        'Clonazepam (short-term anxiety)',
      ],
      notes: 'Psychotherapy is equally important as pharmacotherapy in PTSD.',
    );
  }

  static DrugSuggestion _adhdSuggestion(String severity) {
    return DrugSuggestion(
      diagnosis: 'ADHD / Attention Deficit Disorder',
      firstLine: [
        'Methylphenidate 10–60 mg/day (children & adults)',
        'Amphetamine salts 10–40 mg/day',
      ],
      secondLine: [
        'Atomoxetine 40–100 mg/day (non-stimulant)',
        'Bupropion 150–450 mg/day',
        'Clonidine 0.1–0.4 mg/day',
      ],
      adjuncts: [
        'Behavioral therapy',
        'Parent training / school accommodations',
      ],
      notes: 'Monitor BP, HR, weight. Assess for abuse potential.',
    );
  }
}
