class PickupLineModel {
     final String text;
     final String category;

     PickupLineModel({
       required this.text,
       required this.category,
});
    factory PickupLineModel.fromJson(Map<String, dynamic> json){
      return PickupLineModel(
          text: json['text'],
          category: json['category']
      );
    }

}