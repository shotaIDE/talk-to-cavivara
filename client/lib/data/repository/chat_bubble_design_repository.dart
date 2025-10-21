import 'package:house_worker/data/model/chat_bubble_design.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_bubble_design_repository.g.dart';

@riverpod
class ChatBubbleDesignRepository extends _$ChatBubbleDesignRepository {
  @override
  Future<ChatBubbleDesign> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final value = await preferenceService.getString(
      PreferenceKey.chatBubbleDesign,
    );

    return ChatBubbleDesign.values.firstWhere(
      (design) => design.name == value,
      orElse: () => ChatBubbleDesign.corporateStandard,
    );
  }

  Future<void> save(ChatBubbleDesign design) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setString(
      PreferenceKey.chatBubbleDesign,
      value: design.name,
    );

    if (!ref.mounted) {
      return;
    }
    state = AsyncValue.data(design);
  }
}
