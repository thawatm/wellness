class News {
  Posts posts;
  String id;

  News({this.posts, this.id});

  News.fromJson(Map<String, dynamic> json) {
    posts = json['published_posts'] != null
        ? new Posts.fromJson(json['published_posts'])
        : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.posts != null) {
      data['published_posts'] = this.posts.toJson();
    }
    data['id'] = this.id;
    return data;
  }
}

class Posts {
  List<Data> data;
  Paging paging;

  Posts({this.data, this.paging});

  Posts.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    paging =
        json['paging'] != null ? new Paging.fromJson(json['paging']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    if (this.paging != null) {
      data['paging'] = this.paging.toJson();
    }
    return data;
  }
}

class Data {
  String message;
  String permalinkUrl;
  String fullPicture;
  String createdTime;
  String id;

  Data(
      {this.message,
      this.permalinkUrl,
      this.fullPicture,
      this.createdTime,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    permalinkUrl = json['permalink_url'];
    fullPicture = json['full_picture'];
    createdTime = json['created_time'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['permalink_url'] = this.permalinkUrl;
    data['full_picture'] = this.fullPicture;
    data['created_time'] = this.createdTime;
    data['id'] = this.id;
    return data;
  }
}

class Paging {
  Cursors cursors;

  Paging({this.cursors});

  Paging.fromJson(Map<String, dynamic> json) {
    cursors =
        json['cursors'] != null ? new Cursors.fromJson(json['cursors']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cursors != null) {
      data['cursors'] = this.cursors.toJson();
    }
    return data;
  }
}

class Cursors {
  String before;
  String after;

  Cursors({this.before, this.after});

  Cursors.fromJson(Map<String, dynamic> json) {
    before = json['before'];
    after = json['after'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['before'] = this.before;
    data['after'] = this.after;
    return data;
  }
}
