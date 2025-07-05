import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/voice_components.dart';
import '../../voice/bloc/voice_bloc.dart';
import '../../voice/bloc/voice_state.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController messageController;
  final bool isComposing;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onAttach;
  final VoidCallback? onVoiceInput;

  const ChatInputBar({
    super.key,
    required this.messageController,
    required this.isComposing,
    required this.onChanged,
    required this.onSubmitted,
    this.onAttach,
    this.onVoiceInput,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              onChanged: onChanged,
              onSubmitted: isComposing ? onSubmitted : null,
              decoration: const InputDecoration(
                hintText: 'Type a message or tap the mic...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                isDense: true,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 4),
          BlocListener<VoiceBloc, VoiceState>(
            listener: (context, voiceState) {
              if (voiceState is VoiceReady && voiceState.isListening) {
                // Handle voice input received
              }
            },
            child: VoiceInputButton(
              onVoiceInput: (text) {
                messageController.text = text;
                onSubmitted(text);
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: onAttach,
            tooltip: 'Attach file',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed:
                isComposing ? () => onSubmitted(messageController.text) : null,
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}
