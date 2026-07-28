import '../../domain/card_models.dart';

extension CardImageKindLabel on CardImageKind {
  String get label => switch (this) {
    CardImageKind.front => '正面',
    CardImageKind.back => '背面',
    CardImageKind.packaging => '包装',
    CardImageKind.number => '编号',
    CardImageKind.detail => '细节',
    CardImageKind.other => '其他',
  };
}
