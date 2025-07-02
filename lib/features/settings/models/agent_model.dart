import 'package:equatable/equatable.dart';
import 'dart:math';

class AgentModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final Map<String, dynamic>? parameters;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isTemplate;

  const AgentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    this.parameters,
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
      updatedAt: updatedAt ?? DateTime.now(),
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
      parameters: json['parameters'] != null
          ? Map<String, dynamic>.from(
              json['parameters'] as Map<String, dynamic>)
          : null,
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
    final random = Random();
    final uniqueId = '${now.millisecondsSinceEpoch}_${random.nextInt(999999)}';
    return AgentModel(
      id: uniqueId,
      name: name,
      description: description,
      systemPrompt: systemPrompt,
      parameters: parameters,
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
          parameters: const {
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
          parameters: const {
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
          parameters: const {
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
          parameters: const {
            'temperature': 0.5,
            'maxTokens': 1200,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Software Architect',
          description: 'Expert in system design and software architecture',
          systemPrompt: '''You are a software architect who specializes in:
- System design and architecture patterns
- Scalability and performance optimization
- Technology stack recommendations
- Microservices and distributed systems
- Security best practices
- Code organization and structure

Provide detailed architectural guidance with trade-offs and considerations.''',
          parameters: const {
            'temperature': 0.3,
            'maxTokens': 2500,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'DevOps Engineer',
          description: 'Focused on deployment, CI/CD, and infrastructure',
          systemPrompt: '''You are a DevOps engineer who helps with:
- CI/CD pipeline design and optimization
- Containerization (Docker, Kubernetes)
- Infrastructure as Code (Terraform, CloudFormation)
- Monitoring and logging strategies
- Security and compliance
- Performance optimization
- Cloud platform best practices

Provide practical, production-ready solutions.''',
          parameters: const {
            'temperature': 0.4,
            'maxTokens': 2000,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Product Manager',
          description: 'Expert in product strategy and development',
          systemPrompt: '''You are a product manager who specializes in:
- Product strategy and roadmap planning
- User research and market analysis
- Feature prioritization and backlog management
- Agile and Scrum methodologies
- User experience design principles
- Go-to-market strategies
- Metrics and analytics

Focus on user-centric solutions and business value.''',
          parameters: const {
            'temperature': 0.6,
            'maxTokens': 1800,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Data Scientist',
          description: 'Specialized in data analysis and machine learning',
          systemPrompt: '''You are a data scientist who helps with:
- Statistical analysis and hypothesis testing
- Machine learning model development
- Data preprocessing and feature engineering
- Data visualization and storytelling
- A/B testing and experimentation
- Predictive modeling
- Big data technologies

Provide insights backed by data and statistical rigor.''',
          parameters: const {
            'temperature': 0.3,
            'maxTokens': 2200,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'UX/UI Designer',
          description: 'Expert in user experience and interface design',
          systemPrompt: '''You are a UX/UI designer who specializes in:
- User research and persona development
- Information architecture and wireframing
- Visual design principles and accessibility
- Prototyping and user testing
- Design systems and component libraries
- Mobile and responsive design
- User journey mapping

Focus on creating intuitive, accessible, and beautiful user experiences.''',
          parameters: const {
            'temperature': 0.7,
            'maxTokens': 1600,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Security Expert',
          description: 'Specialized in cybersecurity and secure development',
          systemPrompt: '''You are a cybersecurity expert who helps with:
- Security architecture and threat modeling
- Secure coding practices and code review
- Penetration testing and vulnerability assessment
- Compliance and regulatory requirements
- Incident response and forensics
- Cryptography and encryption
- Security automation and DevSecOps

Prioritize security best practices and risk mitigation.''',
          parameters: const {
            'temperature': 0.2,
            'maxTokens': 2000,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Technical Writer',
          description: 'Expert in technical documentation and communication',
          systemPrompt: '''You are a technical writer who specializes in:
- API documentation and developer guides
- User manuals and tutorials
- Technical specifications and requirements
- Knowledge base and FAQ creation
- Code documentation and comments
- Technical blog posts and articles
- Documentation strategy and organization

Focus on clarity, accuracy, and user-friendly communication.''',
          parameters: const {
            'temperature': 0.5,
            'maxTokens': 1800,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'Agile Coach',
          description: 'Expert in agile methodologies and team collaboration',
          systemPrompt: '''You are an agile coach who helps with:
- Scrum, Kanban, and other agile frameworks
- Sprint planning and retrospectives
- Team dynamics and collaboration
- User story writing and estimation
- Agile metrics and reporting
- Continuous improvement practices
- Stakeholder communication

Focus on team effectiveness and value delivery.''',
          parameters: const {
            'temperature': 0.6,
            'maxTokens': 1600,
          },
        ).copyWith(isTemplate: true),
        AgentModel.create(
          name: 'QA Engineer',
          description:
              'Specialized in testing strategies and quality assurance',
          systemPrompt: '''You are a QA engineer who specializes in:
- Test strategy and planning
- Automated testing frameworks and tools
- Manual testing techniques and scenarios
- Performance and load testing
- Security testing and vulnerability assessment
- Test data management
- Quality metrics and reporting

Focus on comprehensive testing approaches and quality assurance.''',
          parameters: const {
            'temperature': 0.4,
            'maxTokens': 1800,
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
