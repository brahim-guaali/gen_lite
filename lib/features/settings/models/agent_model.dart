import 'package:equatable/equatable.dart';

class AgentModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final Map<String, dynamic> parameters;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isTemplate;

  const AgentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    this.parameters = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isActive = false,
    this.isTemplate = false,
  });

  AgentModel copyWith({
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    Map<String, dynamic>? parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isTemplate,
  }) {
    return AgentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isTemplate: isTemplate ?? this.isTemplate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'systemPrompt': systemPrompt,
      'parameters': parameters,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isTemplate': isTemplate,
    };
  }

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      systemPrompt: json['systemPrompt'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
      isTemplate: json['isTemplate'] as bool? ?? false,
    );
  }

  factory AgentModel.create({
    required String name,
    required String description,
    required String systemPrompt,
    Map<String, dynamic>? parameters,
  }) {
    final now = DateTime.now();
    return AgentModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      systemPrompt: systemPrompt,
      parameters: parameters ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  // Predefined agent templates
  static List<AgentModel> get templates => [
        AgentModel.create(
          name: 'Code Assistant',
          description: 'Specialized in programming help and code review',
          systemPrompt:
              '''You are a helpful programming assistant. You help with:
- Code review and suggestions
- Debugging and problem solving
- Best practices and design patterns
- Language-specific guidance
- Algorithm optimization

Always provide clear, well-documented code examples.''',
          parameters: {
            'temperature': 0.3,
            'maxTokens': 2000,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Writing Coach',
          description: 'Focused on writing improvement and content creation',
          systemPrompt:
              '''You are a writing coach who helps improve writing skills. You assist with:
- Grammar and style corrections
- Content structure and flow
- Creative writing techniques
- Academic writing
- Business communication

Provide constructive feedback and specific suggestions.''',
          parameters: {
            'temperature': 0.7,
            'maxTokens': 1500,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Research Analyst',
          description: 'Optimized for research tasks and data analysis',
          systemPrompt: '''You are a research analyst who helps with:
- Research methodology
- Data analysis and interpretation
- Literature review
- Statistical analysis
- Report writing

Focus on accuracy, thoroughness, and evidence-based conclusions.''',
          parameters: {
            'temperature': 0.2,
            'maxTokens': 2500,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Language Tutor',
          description: 'Specialized in language learning and translation',
          systemPrompt: '''You are a language tutor who helps with:
- Grammar explanations
- Vocabulary building
- Pronunciation guidance
- Cultural context
- Translation assistance

Adapt to the learner's level and provide gradual progression.''',
          parameters: {
            'temperature': 0.5,
            'maxTokens': 1200,
          },
        ).copyWith(isTemplate: true),
      ];

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        systemPrompt,
        parameters,
        createdAt,
        updatedAt,
        isActive,
        isTemplate,
      ];
}
