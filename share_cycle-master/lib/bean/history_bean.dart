class HistoryBean {
  String? id;
  String? lendUserId;
  String? applyUserId;
  String? state;
  String? toLenderName;
  String? applyName;
  String? lendId;
  String? historyDate;
  int? goodsScore = 0;
  String? toLendComment;
  String? toApplyComment;
  String? address;
  String? goodsImg;
  String? borrowed;

  HistoryBean({
    this.id,
    this.lendUserId,
    this.applyUserId,
    this.state,
    this.applyName,
    this.toLenderName,
    this.toApplyComment,
    this.lendId,
    this.historyDate,
    this.goodsScore = 0,
    this.toLendComment,
    this.address,
    this.goodsImg,
    this.borrowed,
  });

  HistoryBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lendUserId = json['lend_user_id'];
    applyUserId = json['apply_user_id'];
    state = json['state'];
    applyName = json['apply_name'];
    toLenderName = json['lender_name'];
    lendId = json['lend_id'];
    historyDate = json['history_date'];
    goodsScore = json['goods_score'];
    toLendComment = json['to_lend_comment'];
    toApplyComment = json['to_apply_comment'];
    address = json['address'];
    goodsImg = json['goods_img'];
    borrowed = json['borrowed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['lend_user_id'] = this.lendUserId;
    data['apply_user_id'] = this.applyUserId;
    data['state'] = this.state;
    data['apply_name'] = this.applyName;
    data['lender_name'] = this.toLenderName;
    data['lend_id'] = this.lendId;
    data['history_date'] = this.historyDate;
    data['goods_score'] = this.goodsScore;
    data['to_lend_comment'] = this.toLendComment;
    data['to_apply_comment'] = this.toApplyComment;
    data['address'] = this.address;
    data['goods_img'] = this.goodsImg;
    data['borrowed'] = this.borrowed;
    return data;
  }
}
